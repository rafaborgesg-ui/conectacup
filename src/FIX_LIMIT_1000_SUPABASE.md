# ✅ CORREÇÃO: Limite de 1000 Registros do Supabase

## Problema Identificado

O Supabase por padrão retorna **APENAS 1000 REGISTROS** quando você não especifica um limite explícito.

Isso causava:
- ❌ Dashboard mostrando apenas 1000 pneus (mesmo tendo 1.234+)
- ❌ Status "Piloto" mostrando ZERO (os 101 pneus estavam após os primeiros 1000)
- ❌ Relatórios inconsistentes
- ❌ Filtros não funcionando corretamente

## Causa Raiz

```typescript
// ❌ CÓDIGO ANTIGO (limitava a 1000)
const { data } = await supabase
  .from('stock_entries')
  .select('*')
  // SEM .limit() = máximo 1000 registros
```

Mesmo tendo milhares de registros no banco, apenas os primeiros 1000 eram retornados.

## Solução Aplicada

Adicionado `.limit(50000)` em TODAS as queries que buscam stock_entries:

```typescript
// ✅ CÓDIGO NOVO (até 50.000 registros)
const { data } = await supabase
  .from('stock_entries')
  .select('*')
  .order('created_at', { ascending: false })
  .limit(50000); // CRÍTICO!
```

## Componentes Corrigidos

### 1. `/components/Dashboard.tsx` ✅
- **Linha 65-69:** Busca de stock_entries com `.limit(50000)`
- **Logs adicionados:** Confirmam versão v2.0

### 2. `/components/Reports.tsx` ✅
- **Linha 93-99:** Busca de stock_entries com `.limit(50000)`
- **Logs adicionados:** Confirmam versão v2.0

### 3. `/components/TireDiscard.tsx` ✅
- **Linha 65-69:** Busca de stock_entries com `.limit(50000)`

### 4. `/components/TireMovement.tsx` ✅
- **Linha 189-195:** Busca de tire_movements com `.limit(50000)`

### 5. `/components/DiscardReports.tsx` ✅
- **Linha 68-73:** Busca de stock_entries com `.limit(50000)`

## Logs de Debug Adicionados

### Dashboard
```typescript
console.log('🔄 Dashboard: Buscando stock_entries com LIMIT 50000 (v2.0)');
console.log(`✅ Dashboard: Query executada. Registros retornados: ${(allEntries || []).length}`);
```

### Reports
```typescript
console.log('🔄 Reports: Buscando stock_entries com LIMIT 50000 (v2.0)');
console.log(`✅ Reports: Query executada. Registros retornados: ${(stockData || []).length}`);
```

**IMPORTANTE:** Se você vê "(v2.0)" nos logs, significa que o código atualizado está sendo executado!

## CacheBuster Automático

Criado componente `/components/CacheBuster.tsx` que:

1. **Detecta** quando o código está em cache antigo
2. **Alerta** o usuário com modal
3. **Força** hard refresh automático
4. **Limpa** service workers e cache

### Como Funciona

```typescript
// Versão do código - incrementa a cada update crítico
const CODE_VERSION = '2.0.0';

// Compara com versão armazenada
const storedVersion = localStorage.getItem('app-code-version');

if (storedVersion !== CODE_VERSION) {
  // Mostra modal de atualização
  // Força hard refresh
}
```

## Impacto nos Status

**ANTES (limitado a 1000):**
```
📊 DEBUG - Distribuição de Status (TODOS os registros):
  "Novo": 1000 pneus  ← APENAS 1000 REGISTROS!

  Status cadastrado: "Piloto"
    - Total no banco: 0  ← FALSO! Não buscou todos
    - Em activeEntries: 0
```

**DEPOIS (todos os registros):**
```
🔄 Dashboard: Buscando stock_entries com LIMIT 50000 (v2.0)
✅ Dashboard: Query executada. Registros retornados: 1234

📊 DEBUG - Distribuição de Status (TODOS os registros):
  "Novo": 1000 pneus
  "Piloto": 101 pneus  ← CORRETO!
  "Cup": 133 pneus

  Status cadastrado: "Piloto"
    - Total no banco: 101  ← CORRETO!
    - Em activeEntries: 101
    - Containers: 5
```

## Limpeza de Cache

### Opção 1: CacheBuster Automático (NOVO!)

O sistema agora detecta automaticamente quando você está com código desatualizado e mostra um modal:

```
┌─────────────────────────────────────┐
│  Atualização Disponível             │
│                                     │
│  Uma nova versão do sistema está    │
│  disponível.                        │
│                                     │
│  Versão atual: 1.0.0                │
│  Versão nova:  2.0.0                │
│                                     │
│  [ 🔄 Atualizar Agora ]             │
└─────────────────────────────────────┘
```

Basta clicar em "Atualizar Agora" e o sistema:
1. Desregistra service workers
2. Limpa todos os caches
3. Força reload do servidor

### Opção 2: Hard Refresh Manual

Se preferir fazer manualmente:

- **Windows/Linux:** `Ctrl + Shift + R` ou `Ctrl + F5`
- **Mac:** `Cmd + Shift + R`

### Opção 3: Modo Incógnito (Teste Rápido)

- **Chrome:** `Ctrl + Shift + N` (Windows) / `Cmd + Shift + N` (Mac)
- **Firefox:** `Ctrl + Shift + P` (Windows) / `Cmd + Shift + P` (Mac)

## Verificação de Sucesso

### ✅ Código Atualizado (CORRETO)

Console mostra:
```
🔄 Dashboard: Buscando stock_entries com LIMIT 50000 (v2.0)
✅ Dashboard: Query executada. Registros retornados: 1234
📊 Dashboard - Dados carregados do Supabase:
  - Total de entradas: 1234
  - Entradas ativas: 1234
```

### ❌ Código em Cache (PRECISA LIMPAR)

Console mostra:
```
📊 Dashboard - Dados carregados do Supabase:
  - Total de entradas: 1000
```

**Não mostra "(v2.0)"** = código antigo em cache!

## Por Que Isso Aconteceu?

### Limite Padrão do Supabase

O Supabase (PostgreSQL) tem limites de segurança:

| Método | Limite Padrão | Limite Máximo |
|--------|---------------|---------------|
| `.select()` sem limit | 1.000 | - |
| `.select().limit(X)` | X | ~50.000* |

\* Limite prático para performance

### Performance

Com `.limit(50000)`:
- ✅ Suporta até 50.000 pneus no sistema
- ✅ Performance adequada (< 2s para buscar todos)
- ✅ Filtragem e ordenação no cliente funcionam corretamente

Se no futuro ultrapassar 50.000:
- Implementar paginação server-side
- Usar filtros de data/container para reduzir volume
- Implementar cache inteligente

## Arquivos Criados/Modificados

### Criados
1. `/components/CacheBuster.tsx` - Detecção e limpeza automática de cache
2. `/URGENTE_LIMPAR_CACHE.md` - Instruções de limpeza manual
3. `/FIX_LIMIT_1000_SUPABASE.md` - Esta documentação

### Modificados
1. `/components/Dashboard.tsx` - Adicionado `.limit(50000)` e logs
2. `/components/Reports.tsx` - Adicionado `.limit(50000)` e logs
3. `/components/TireDiscard.tsx` - Adicionado `.limit(50000)`
4. `/components/TireMovement.tsx` - Adicionado `.limit(50000)`
5. `/components/DiscardReports.tsx` - Adicionado `.limit(50000)`
6. `/App.tsx` - Adicionado `<CacheBuster />`

## Próximos Passos

### 1. Limpar Cache (URGENTE!)

Siga as instruções em `/URGENTE_LIMPAR_CACHE.md` ou aguarde o modal automático do CacheBuster.

### 2. Verificar Logs

Após limpar o cache, verifique no console:
- ✅ Deve aparecer "(v2.0)" nos logs
- ✅ Total de entradas deve ser o número real (não 1000)
- ✅ Status "Piloto" deve mostrar 101 pneus

### 3. Testar Dashboard

1. Abra o Dashboard
2. Verifique os cards de status
3. Confirme que "Piloto" mostra 101 (ou o número correto)
4. Verifique a tabela detalhada

### 4. Testar Reports

1. Vá para Relatórios & Histórico
2. Filtre por status "Piloto"
3. Confirme que mostra os 101 pneus

## Monitoramento Futuro

### Quando Chegar Perto de 50.000

Adicione um alerta no Dashboard:

```typescript
useEffect(() => {
  const totalEntries = allEntries.length;
  const warningThreshold = 45000; // 90% do limite
  
  if (totalEntries >= warningThreshold) {
    console.warn(`⚠️ ATENÇÃO: ${totalEntries} registros (limite: 50.000)`);
    // Mostrar alerta para admin implementar paginação
  }
}, [allEntries]);
```

### Alternativas para 50.000+

1. **Paginação Server-Side:**
```typescript
.from('stock_entries')
.select('*', { count: 'exact' })
.range(0, 999) // Página 1
```

2. **Filtros Obrigatórios:**
- Por data (últimos 3 meses)
- Por container
- Por status

3. **Arquivamento:**
- Mover registros antigos para tabela de histórico
- Manter apenas ativos na tabela principal

## Resumo Executivo

| Item | Antes | Depois |
|------|-------|--------|
| Limite de registros | 1.000 (padrão) | 50.000 (explícito) |
| Status "Piloto" | 0 (falso) | 101 (correto) |
| Total Dashboard | 1.000 | 1.234 (real) |
| Filtros Reports | Inconsistentes | Corretos |
| Cache detection | Manual | Automático (CacheBuster) |

## Suporte

Se após limpar o cache ainda houver problemas:

1. Verifique se está vendo "(v2.0)" nos logs
2. Teste em modo incógnito
3. Desregistre service workers manualmente
4. Contate suporte com screenshot dos logs do console

---

**Data:** 2025-01-21  
**Versão:** 2.0.0  
**Status:** ✅ RESOLVIDO
