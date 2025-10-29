# ✅ CORREÇÃO: Entrada Planilha - Busca por Código de Modelo

## 🔍 Problema Identificado

A aba "Entrada Planilha" não estava cadastrando pneus porque a **busca de modelos** estava usando o campo `name` ao invés do campo `code`.

### Logs do Problema

```
📦 [PLANILHA] Modelos disponíveis (7):
   - "Slick 991 Dianteiro"
   - "Slick 991 Traseiro"
   - "Slick 992 Dianteiro"
   ...

❌ [PLANILHA] Linha 2: Modelo "27/65-18 Porsche Cup N2" não encontrado
   Comparando modelo "Slick 991 Dianteiro" com "27/65-18 Porsche Cup N2": ❌
```

**Causa:** Os nomes na tabela `tire_models` são diferentes dos nomes na planilha:

| Planilha                    | Tabela `name`        | Tabela `code`  |
|----------------------------|---------------------|---------------|
| 27/65-18 Porsche Cup N2    | Slick 991 Dianteiro | 27/65-18 N2   |
| 30/65-18 P2L               | ?                   | 30/65-18 P2L  |

## ✅ Solução Implementada

### 1. Busca por Código (campo `code`)

Modificada a função `handleSpreadsheetEntry` para:

1. **Normalizar** o nome do modelo da planilha:
   - Remove "Porsche Cup" → `"27/65-18 Porsche Cup N2"` → `"27/65-18 N2"`
   - Normaliza espaços

2. **Buscar primeiro pelo código** (`tire_models.code`):
   ```typescript
   const model = tireModels.find(m => {
     const modelCode = (m.code || '').toLowerCase();
     const searchLower = normalizedSearchName.toLowerCase();
     
     // Tenta código primeiro
     const codeMatch = modelCode.includes(searchLower) || searchLower.includes(modelCode);
     
     // Fallback para nome
     const nameMatch = modelNameLower.includes(searchLower) || searchLower.includes(modelNameLower);
     
     return codeMatch || nameMatch;
   });
   ```

3. **Logs detalhados** mostrando código:
   ```
   📦 [PLANILHA] Modelos disponíveis (7):
      - "Slick 991 Dianteiro" (código: "27/65-18 N2")
      - "Slick 991 Traseiro" (código: "31/71-18 N2")
      ...
   
   🔄 [PLANILHA] Nome normalizado: "27/65-18 N2"
   ✅ Comparando código "27/65-18 N2" com "27/65-18 N2": ✅ MATCH
   ✅ [PLANILHA] Modelo encontrado: "Slick 991 Dianteiro" (Código: "27/65-18 N2", ID: abc-123)
   ```

### 2. Normalização de Contêineres

Também corrigida a busca de contêineres para remover duplicações:

```typescript
// "GSILVA - GSILVA - MTBU 4003682" → "GSILVA - MTBU 4003682"
const normalizeContainerName = (name: string): string => {
  const parts = name.split(' - ');
  const uniqueParts = parts.filter((part, index, arr) => 
    index === 0 || part !== arr[index - 1]
  );
  return uniqueParts.join(' - ').trim();
};
```

## 📋 Mapeamento de Modelos

Para que a importação funcione, certifique-se de que a tabela `tire_models` tenha os códigos corretos:

| Código Planilha              | `tire_models.code` esperado |
|-----------------------------|-----------------------------|
| 27/65-18 Porsche Cup N2     | 27/65-18 N2                 |
| 31/71-18 Porsche Cup N2     | 31/71-18 N2                 |
| 30/65-18 Porsche Cup N3     | 30/65-18 N3                 |
| 31/71-18 Porsche Cup N3R    | 31/71-18 N3R                |
| 27/65-18 P2L                | 27/65-18 P2L                |
| 31/71-18 P2L                | 31/71-18 P2L                |
| 30/65-18 P2L                | 30/65-18 P2L                |

## 🎯 Como Testar

1. **Abra o Console** (F12)
2. **Cole os dados** na aba "Entrada Planilha":
   ```
   CÓDIGO	MODELO	CONTÊINER
   5248932	27/65-18 Porsche Cup N2	GSILVA - MTBU 4003682
   5349203	31/71-18 Porsche Cup N2	GSILVA - MTBU 4003682
   ```

3. **Clique em "Processar Planilha"**

4. **Veja os logs** - agora deve mostrar:
   ```
   📦 [PLANILHA] Modelos disponíveis (7):
      - "Slick 991 Dianteiro" (código: "27/65-18 N2")
      ...
   
   🔍 [PLANILHA] Linha 2: Processando código 05248932
   📝 [PLANILHA] Procurando modelo: "27/65-18 Porsche Cup N2"
   🔄 [PLANILHA] Nome normalizado: "27/65-18 N2"
   ✅ Comparando código "27/65-18 N2" com "27/65-18 N2": ✅ MATCH
   ✅ [PLANILHA] Modelo encontrado: "Slick 991 Dianteiro" (Código: "27/65-18 N2", ID: ...)
   ✅ [PLANILHA] Contêiner encontrado: "GSILVA - MTBU 4003682" (ID: ...)
   💾 [PLANILHA] Salvando entrada: {...}
   ✅ [PLANILHA] Resultado saveStockEntry: SUCESSO
   ```

## 🔧 Se Ainda Não Funcionar

### Verifique os códigos na tabela `tire_models`

Execute no SQL Editor do Supabase:

```sql
SELECT id, name, code, type 
FROM tire_models 
ORDER BY code;
```

**Resultado esperado:**
```
| id  | name                  | code          | type  |
|-----|-----------------------|---------------|-------|
| ... | Slick 991 Dianteiro   | 27/65-18 N2   | Slick |
| ... | Slick 991 Traseiro    | 31/71-18 N2   | Slick |
| ... | Slick 992 Dianteiro   | 30/65-18 N3   | Slick |
| ... | Slick 992 Traseiro    | 31/71-18 N3R  | Slick |
| ... | Wet 991 Dianteiro     | 27/65-18 P2L  | Wet   |
| ... | Wet 992 Dianteiro     | 30/65-18 P2L  | Wet   |
| ... | Wet 991 e 992 Traseiro| 31/71-18 P2L  | Wet   |
```

### Se os códigos estiverem errados, atualize-os:

```sql
-- Exemplo de atualização
UPDATE tire_models 
SET code = '27/65-18 N2' 
WHERE name = 'Slick 991 Dianteiro';

UPDATE tire_models 
SET code = '31/71-18 N2' 
WHERE name = 'Slick 991 Traseiro';

-- Continue para todos os modelos...
```

## 📝 Flexibilidade da Busca

A busca agora é **muito flexível** e aceita:

✅ `27/65-18 Porsche Cup N2` → encontra `27/65-18 N2`  
✅ `27/65-18 N2` → encontra `27/65-18 N2`  
✅ `N2` → encontra qualquer código com `N2` (pode ser ambíguo)  
✅ `30/65-18 P2L` → encontra exatamente `30/65-18 P2L`  
✅ `P2L` → encontra qualquer código com `P2L` (pode ser ambíguo)

**Recomendação:** Use sempre o código completo ou próximo disso para evitar ambiguidades.

## 🚀 Próximas Melhorias (Opcional)

1. **Validação de ambiguidade:** Se múltiplos modelos corresponderem, pedir confirmação
2. **Sugestões:** Se modelo não for encontrado, sugerir os mais próximos
3. **Cache de mapeamento:** Criar tabela de aliases para acelerar busca
4. **Importação de alias:** Permitir cadastrar nomes alternativos para modelos

## ✅ Status

- [x] Busca por código implementada
- [x] Normalização de nomes implementada
- [x] Normalização de contêineres implementada
- [x] Logs detalhados para debug
- [x] Documentação completa

**Data:** 2025-01-21  
**Arquivo:** `/components/TireStockEntry.tsx` - função `handleSpreadsheetEntry`
