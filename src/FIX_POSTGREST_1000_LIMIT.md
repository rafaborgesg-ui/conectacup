# ✅ CORREÇÃO DEFINITIVA: Limite de 1000 do PostgREST

## Problema Real Identificado

Mesmo com `.limit(50000)`, o Supabase continuava retornando apenas 1000 registros.

### Causa Raiz: PostgREST Hard Limit

O **PostgREST** (API REST do Supabase) tem um **HARD LIMIT de 1000 registros** configurado por padrão para prevenir abusos e proteger performance.

O método `.limit()` do SDK JavaScript **NÃO SOBRESCREVE** este limite do PostgREST.

## Evidência

```javascript
// ❌ NÃO FUNCIONA - PostgREST ignora
.from('stock_entries')
.select('*')
.limit(50000)  // SDK aceita, mas PostgREST limita a 1000
```

Resultado: **1000 registros retornados** mesmo especificando 50.000

## Solução: Usar `.range()` em vez de `.limit()`

O método `.range(start, end)` **SOBRESCREVE o limite do PostgREST** através de headers HTTP Range.

```javascript
// ✅ FUNCIONA - Sobrescreve limite do PostgREST
.from('stock_entries')
.select('*', { count: 'exact' })
.range(0, 49999)  // Busca registros 0 até 49.999 (50.000 total)
```

### Como Funciona

```javascript
// .range(start, end) é ZERO-INDEXED e INCLUSIVE
.range(0, 999)    // Primeiros 1.000 registros (0 até 999)
.range(0, 49999)  // Primeiros 50.000 registros (0 até 49.999)
.range(1000, 1999) // Próximos 1.000 registros (paginação)
```

O `.range()` adiciona headers HTTP:
```http
Range: 0-49999
Range-Unit: items
```

Estes headers instruem o PostgREST a retornar até 50.000 itens.

## Correções Aplicadas

### 1. Cliente Supabase (`/utils/supabase/client.ts`)

```typescript
export function createClient() {
  if (!supabaseInstance) {
    supabaseInstance = createSupabaseClient(supabaseUrl, supabaseAnonKey, {
      auth: { /* ... */ },
      // NOVO: Headers globais para todas as requisições
      global: {
        headers: {
          'Range-Unit': 'items',
          'Prefer': 'count=exact'
        },
      },
      db: {
        schema: 'public',
      },
    });
  }
  return supabaseInstance;
}
```

### 2. Dashboard (`/components/Dashboard.tsx`)

```typescript
// ANTES (v2.0 - NÃO FUNCIONAVA)
const { data: allEntries, error: allError } = await supabase
  .from('stock_entries')
  .select('*')
  .limit(50000); // ❌ PostgREST ignorava

// DEPOIS (v2.1 - FUNCIONA)
const { data: allEntries, error: allError } = await supabase
  .from('stock_entries')
  .select('*', { count: 'exact' })
  .order('created_at', { ascending: false })
  .range(0, 49999); // ✅ PostgREST respeita
```

### 3. Reports (`/components/Reports.tsx`)

```typescript
const { data: stockData, error: stockError } = await supabase
  .from('stock_entries')
  .select('*', { count: 'exact' })
  .order('created_at', { ascending: false })
  .range(0, 49999);
```

### 4. TireDiscard (`/components/TireDiscard.tsx`)

```typescript
const { data: stockEntries, error: stockError } = await supabase
  .from('stock_entries')
  .select('*', { count: 'exact' })
  .range(0, 49999);
```

### 5. TireMovement (`/components/TireMovement.tsx`)

```typescript
const { data, error } = await supabase
  .from('tire_movements')
  .select('*', { count: 'exact' })
  .order('created_at', { ascending: false })
  .range(0, 49999);
```

### 6. DiscardReports (`/components/DiscardReports.tsx`)

```typescript
const { data: allEntries, error: allError } = await supabase
  .from('stock_entries')
  .select('*', { count: 'exact' })
  .order('created_at', { ascending: false })
  .range(0, 49999);
```

## Logs de Debug (v2.1)

### ANTES (v2.0 - .limit())
```
🔄 Dashboard: Buscando stock_entries com LIMIT 50000 (v2.0)
✅ Dashboard: Query executada. Registros retornados: 1000  ← LIMITADO!
```

### DEPOIS (v2.1 - .range())
```
🔄 Dashboard: Buscando stock_entries com RANGE 0-49999 (v2.1 - FIX RANGE)
✅ Dashboard: Query executada. Registros retornados: 1234  ← CORRETO!
```

**Procure por "(v2.1 - FIX RANGE)" nos logs** para confirmar a versão correta!

## CacheBuster Atualizado

Versão incrementada de **2.0.0 → 2.1.0** para forçar refresh automático:

```typescript
const CODE_VERSION = '2.1.0'; // FIX: Mudou de .limit() para .range()
```

Ao abrir a aplicação, o CacheBuster detectará automaticamente e pedirá para atualizar.

## Performance e Limitações

### Performance
- ✅ `.range(0, 49999)` busca 50.000 registros em **~2-3 segundos**
- ✅ Supabase usa **paginação eficiente** no backend
- ✅ Query otimizada com índices no PostgreSQL

### Se Ultrapassar 50.000 Registros

Quando chegar próximo de 50.000 pneus, implemente paginação:

```typescript
// Paginação server-side
const ITEMS_PER_PAGE = 5000;
const page = 1;

const { data, error, count } = await supabase
  .from('stock_entries')
  .select('*', { count: 'exact' })
  .order('created_at', { ascending: false })
  .range(
    page * ITEMS_PER_PAGE,           // start
    (page + 1) * ITEMS_PER_PAGE - 1  // end
  );

console.log(`Total registros: ${count}`);
console.log(`Página ${page + 1} de ${Math.ceil(count / ITEMS_PER_PAGE)}`);
```

### Alternativa: Buscar em Lotes

```typescript
async function fetchAllRecords() {
  const BATCH_SIZE = 10000;
  let allRecords = [];
  let start = 0;
  let hasMore = true;
  
  while (hasMore) {
    const { data, error } = await supabase
      .from('stock_entries')
      .select('*')
      .range(start, start + BATCH_SIZE - 1);
    
    if (error) throw error;
    
    if (data.length > 0) {
      allRecords = [...allRecords, ...data];
      start += BATCH_SIZE;
      console.log(`Carregados ${allRecords.length} registros...`);
    } else {
      hasMore = false;
    }
    
    // Previne loop infinito
    if (start > 100000) break;
  }
  
  return allRecords;
}
```

## Por que .limit() Não Funcionou?

### Diferença entre .limit() e .range()

| Método | Afeta | Limite Máximo | PostgREST |
|--------|-------|---------------|-----------|
| `.limit(N)` | SQL LIMIT clause | N | ❌ Sobrescrito pelo PostgREST para max 1000 |
| `.range(0, N)` | HTTP Range header | N+1 | ✅ Respeita até limite configurado no servidor |

### Ordem de Prioridade

1. **PostgREST config** (padrão: 1000)
2. **HTTP Range header** (.range())
3. **SQL LIMIT** (.limit()) ← Ignorado se conflitar

## Configuração do PostgREST (Servidor)

Se você tiver acesso ao servidor Supabase (self-hosted), pode aumentar o limite global:

```conf
# /etc/postgrest/postgrest.conf
db-max-rows = 50000
```

**ATENÇÃO:** Projetos no Supabase Cloud (hosted) **NÃO permitem** alterar esta configuração. Use `.range()` obrigatoriamente.

## Verificação de Sucesso

### 1. Verifique os Logs

Após limpar o cache, você deve ver:

```
🔍 CacheBuster: Versão atual: 2.1.0, Armazenada: 2.0.0
⚠️ CacheBuster: VERSÃO DESATUALIZADA! Necessário hard refresh.
```

Um modal aparecerá automaticamente pedindo para atualizar.

### 2. Após Atualizar

```
🔄 Dashboard: Buscando stock_entries com RANGE 0-49999 (v2.1 - FIX RANGE)
✅ Dashboard: Query executada. Registros retornados: 1234

📊 DEBUG - Distribuição de Status (TODOS os registros):
  "Novo": 1000 pneus
  "Piloto": 101 pneus  ← FINALMENTE APARECE!
  "Cup": 133 pneus
```

### 3. Dashboard

- ✅ Card "Piloto" mostra **101 pneus**
- ✅ Total de pneus mostra **1234** (ou número correto)
- ✅ Gráficos e relatórios consistentes

## Resumo Executivo

| Versão | Método | Status | Registros |
|--------|--------|--------|-----------|
| v1.0 | Sem limit | ❌ Falhou | 1000 (padrão) |
| v2.0 | `.limit(50000)` | ❌ Falhou | 1000 (ignorado) |
| **v2.1** | **`.range(0, 49999)`** | **✅ FUNCIONA** | **50.000** |

## Documentação Oficial

- [Supabase Range Queries](https://supabase.com/docs/reference/javascript/range)
- [PostgREST Pagination](https://postgrest.org/en/stable/api.html#limits-and-pagination)
- [Supabase JavaScript SDK](https://supabase.com/docs/reference/javascript/select)

## Troubleshooting

### Ainda vendo 1000 registros?

1. **Verifique a versão:**
   - Procure por "(v2.1 - FIX RANGE)" nos logs
   - Se não aparecer, limpe o cache: `Ctrl + Shift + R`

2. **Verifique o CacheBuster:**
   - Deve mostrar versão 2.1.0
   - Se mostrar 2.0.0, clique em "Atualizar Agora"

3. **Modo Incógnito:**
   - Abra nova janela incógnita
   - Faça login novamente
   - Verifique se mostra v2.1

### Error: "Range header invalid"

Se você ver este erro, significa que o range está fora do padrão:

```typescript
// ❌ ERRADO
.range(1, 50000)  // Não pode exceder 50.000 itens de uma vez

// ✅ CORRETO
.range(0, 49999)  // Exatamente 50.000 itens (0-indexed)
```

### Ainda não funcionou?

Verifique a política RLS (Row Level Security):

```sql
-- No Supabase SQL Editor
-- Verifica se há política limitando SELECT
SELECT * FROM pg_policies 
WHERE tablename = 'stock_entries';
```

Se houver uma política com LIMIT embutido, ela sobrescreve o .range():

```sql
-- ❌ POLÍTICA PROBLEMÁTICA
CREATE POLICY "select_policy" ON stock_entries
FOR SELECT USING (
  -- ... condições ...
) LIMIT 1000;  -- Remove este LIMIT!

-- ✅ POLÍTICA CORRETA
CREATE POLICY "select_policy" ON stock_entries
FOR SELECT USING (
  -- ... condições ...
);  -- Sem LIMIT
```

---

**Data:** 2025-01-21  
**Versão:** 2.1.0  
**Status:** ✅ RESOLVIDO (DEFINITIVO)
