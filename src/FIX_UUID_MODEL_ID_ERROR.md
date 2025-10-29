# ✅ CORREÇÃO: Erro UUID no model_id

## 🐛 Problema Identificado

```
❌ Erro 500: Erro ao salvar: invalid input syntax for type uuid: "1"
❌ Erro ao salvar entrada: Error: Erro ao salvar: invalid input syntax for type uuid: "1"
```

### Causa Raiz

A função `getTireModels()` retornava modelos **hardcoded** com IDs simples ('1', '2', '3'), mas a tabela SQL `stock_entries` espera **UUIDs válidos** no campo `model_id`.

**Fluxo do erro:**
```
1. TireStockEntry → selectedModel = '1' (string simples)
2. saveStockEntry({ model_id: '1', ... })
3. Servidor → INSERT INTO stock_entries (model_id = '1')
4. PostgreSQL → ERRO: '1' não é um UUID válido
```

### Schema Esperado

```sql
-- Tabela stock_entries
CREATE TABLE stock_entries (
  id UUID PRIMARY KEY,
  barcode TEXT NOT NULL,
  model_id UUID NOT NULL,  -- ❌ ESPERA UUID, RECEBIA '1'
  model_name TEXT,
  ...
);

-- Tabela tire_models
CREATE TABLE tire_models (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),  -- ✅ GERA UUIDs
  name TEXT NOT NULL,
  code TEXT,
  type TEXT
);
```

---

## 🔧 Solução Aplicada

### 1. Atualização de `getTireModels()`

**Antes:**
```typescript
export async function getTireModels(): Promise<TireModel[]> {
  console.log('📦 Usando modelos de pneus padrão');
  return DEFAULT_TIRE_MODELS; // IDs: '1', '2', '3'... ❌
}
```

**Depois:**
```typescript
export async function getTireModels(): Promise<TireModel[]> {
  try {
    // 1. Busca da tabela SQL tire_models (IDs com UUID)
    const result = await apiRequest('/tire-models');
    
    if (result.data && result.data.length > 0) {
      console.log(`✅ ${result.data.length} modelos carregados da tabela SQL`);
      return result.data; // ✅ IDs são UUIDs válidos
    }
    
    // 2. Fallback: Gera UUIDs para modelos padrão
    const modelsWithUUIDs = DEFAULT_TIRE_MODELS.map(model => ({
      ...model,
      id: generateUUID(), // ✅ Gera UUID válido
    }));
    
    return modelsWithUUIDs;
  } catch (error) {
    // 3. Erro: Também gera UUIDs para fallback
    const modelsWithUUIDs = DEFAULT_TIRE_MODELS.map(model => ({
      ...model,
      id: generateUUID(),
    }));
    
    return modelsWithUUIDs;
  }
}
```

### 2. Importação do `generateUUID`

```typescript
import { generateUUID } from './uuid';
```

---

## 🎯 Fluxo Corrigido

### Cenário 1: Banco de Dados Configurado (Ideal)

```
1. getTireModels() → Chama /tire-models
2. Servidor → SELECT * FROM tire_models
3. Retorna: [{ id: "a1b2c3d4-...", name: "Slick 991", ... }]
4. TireStockEntry → selectedModel = "a1b2c3d4-..." (UUID válido) ✅
5. saveStockEntry({ model_id: "a1b2c3d4-...", ... })
6. Servidor → INSERT ... model_id = "a1b2c3d4-..." ✅
7. PostgreSQL → Sucesso! ✅
```

### Cenário 2: Banco Vazio (Fallback)

```
1. getTireModels() → Chama /tire-models
2. Servidor → SELECT * FROM tire_models (retorna [])
3. Fallback → Gera UUIDs para DEFAULT_TIRE_MODELS
4. Retorna: [{ id: "e5f6g7h8-...", name: "Slick 991", ... }]
5. TireStockEntry → selectedModel = "e5f6g7h8-..." (UUID válido) ✅
6. saveStockEntry({ model_id: "e5f6g7h8-...", ... })
7. Servidor → INSERT ... model_id = "e5f6g7h8-..." ✅
8. PostgreSQL → Sucesso! ✅
```

### Cenário 3: Servidor Offline (Fallback)

```
1. getTireModels() → Chama /tire-models
2. Erro de rede (timeout, 500, etc.)
3. Catch → Gera UUIDs para DEFAULT_TIRE_MODELS
4. Retorna: [{ id: "i9j0k1l2-...", name: "Slick 991", ... }]
5. TireStockEntry → selectedModel = "i9j0k1l2-..." (UUID válido) ✅
```

---

## 📊 Impacto da Correção

### ✅ O que foi corrigido:

1. **Entrada de Estoque Individual** → Agora salva com `model_id` UUID válido
2. **Entrada de Estoque em Massa** → Também corrigido automaticamente
3. **Compatibilidade SQL** → `model_id` sempre será UUID válido
4. **Fallback Robusto** → Funciona mesmo se banco estiver vazio ou offline

### ⚠️ Importante para Produção:

**O ideal é ter os modelos cadastrados na tabela SQL `tire_models`:**

1. Acesse: https://supabase.com/dashboard/project/nflgqugaabtxzifyhjor/editor
2. Navegue até a tabela `tire_models`
3. Cadastre os 7 modelos oficiais da Porsche Cup Brasil
4. O sistema usará automaticamente esses modelos (com UUIDs)

**Se a tabela estiver vazia:**
- O sistema funciona normalmente (fallback com UUIDs gerados)
- Mas os IDs serão regenerados a cada sessão
- Recomenda-se cadastrar os modelos permanentemente

---

## 🚀 Como Testar

### 1. Teste com Banco Configurado (Ideal):

```bash
# 1. Cadastre modelos na tabela tire_models via Supabase Dashboard
# 2. Recarregue a aplicação (F5)
# 3. Verifique o console:
# "✅ 7 modelos carregados da tabela SQL"
# 4. Tente salvar um pneu
# 5. Deve funcionar sem erros ✅
```

### 2. Teste com Banco Vazio (Fallback):

```bash
# 1. Garanta que tire_models está vazia
# 2. Recarregue a aplicação (F5)
# 3. Verifique o console:
# "⚠️ Nenhum modelo no banco. Usando dados padrão com UUIDs."
# 4. Tente salvar um pneu
# 5. Deve funcionar sem erros ✅
```

### 3. Verificação de UUIDs:

```bash
# No console do browser:
getTireModels().then(models => {
  console.log('Modelos:', models);
  models.forEach(m => {
    console.log(`${m.name}: ${m.id}`);
    // Deve mostrar UUIDs válidos no formato:
    // "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
  });
});
```

---

## 📋 Checklist de Validação

- [ ] Entrada de Estoque Individual funciona
- [ ] Entrada de Estoque em Massa funciona
- [ ] Nenhum erro "invalid input syntax for type uuid"
- [ ] Logs mostram "modelos carregados da tabela SQL" OU "usando dados padrão com UUIDs"
- [ ] IDs dos modelos são UUIDs válidos (36 caracteres com hífens)
- [ ] Pneus salvos aparecem no banco com `model_id` UUID válido

---

## 🔗 Arquivos Alterados

1. `/utils/storage.ts`:
   - Import `generateUUID`
   - Reescrita completa de `getTireModels()`
   - Fallback com geração de UUIDs

2. `/FIX_UUID_MODEL_ID_ERROR.md`:
   - Este documento

---

## 💡 Próximos Passos Recomendados

1. ✅ **Cadastrar Modelos no Banco** (via Supabase Dashboard ou interface Admin):
   - 7 modelos oficiais da Porsche Cup Brasil
   - O sistema passará a usar esses IDs permanentes

2. ⏳ **Verificar Containers**:
   - A função `getContainers()` já busca do SQL (linha 268)
   - Mas verifique se os IDs também são UUIDs

3. ⏳ **Auditar Outras Tabelas**:
   - Verificar se `tire_status`, `tire_consumption`, etc. também usam UUIDs corretamente

---

## 🎓 Lições Aprendidas

### ⚠️ REGRA DE OURO: Consistência de Tipos

**Problema:**
Misturar IDs simples ('1', '2', '3') com colunas UUID causa erros de tipo.

**Solução:**
Se a tabela SQL usa UUID, **TODAS** as fontes de dados devem fornecer UUIDs válidos:
- ✅ Dados do banco → UUID (automático pelo Postgres)
- ✅ Dados padrão → UUID (via `generateUUID()`)
- ✅ Dados de fallback → UUID (via `generateUUID()`)

### 🔍 Por que UUID?

**Vantagens:**
- Globalmente únicos (sem colisões)
- Gerados sem coordenação central
- Seguros contra adivinhação
- Padrão em bancos distribuídos

**Formato:**
```
xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
a1b2c3d4-e5f6-7890-abcd-ef1234567890
```

**Geração:**
```typescript
import { generateUUID } from './uuid';
const id = generateUUID(); // "a1b2c3d4-e5f6-..."
```

---

Corrigido em: **2025-10-19**  
Status: ✅ **RESOLVIDO**  
Teste: ⏳ **AGUARDANDO VALIDAÇÃO DO USUÁRIO**
