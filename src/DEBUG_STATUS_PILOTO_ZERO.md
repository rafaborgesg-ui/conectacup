# 🔍 DEBUG: Status "Piloto" mostrando ZERO no Dashboard

## Problema Relatado

- **Status:** "Piloto"
- **Valor esperado:** 101 pneus
- **Valor mostrado no Dashboard:** 0 pneus
- **Localização:** Tabela `stock_entries`, coluna `status`

## Logs de Debug Adicionados

Foram adicionados logs detalhados no Dashboard para identificar o problema:

### 1. Distribuição de Status no Banco

```typescript
📊 DEBUG - Distribuição de Status (TODOS os registros):
  "Novo": 50 pneus (length: 4, charCodes: 78,111,118,111)
  "Piloto": 101 pneus (length: 6, charCodes: 80,105,108,111,116,111)
  "Descarte Piloto": 20 pneus (length: 15, charCodes: ...)
```

**O que verificar:**
- ✅ Se "Piloto" aparece na lista
- ✅ Se a contagem está correta (101)
- ✅ Se há espaços extras (verificar `length`)
- ✅ Se há caracteres invisíveis (verificar `charCodes`)

### 2. Distribuição de Status ATIVOS

```typescript
📊 DEBUG - Distribuição de Status (APENAS ATIVOS):
  "Novo": 50 pneus
  "Piloto": 101 pneus  ← Deve aparecer aqui!
```

**O que verificar:**
- ❌ Se "Piloto" NÃO aparece = está sendo filtrado como descartado
- ✅ Se "Piloto" aparece = problema está na comparação com tire_status

### 3. Busca Case-Insensitive por "Piloto"

```typescript
🔍 DEBUG - Pneus com "piloto" no status (case-insensitive): 121
```

**O que isso indica:**
- Se > 101: Há outros status com "piloto" (ex: "Descarte Piloto")
- Se = 101: Apenas "Piloto" existe
- Se < 101: Alguns registros têm status null ou diferente

### 4. Status Cadastrados na Tabela tire_status

```typescript
📋 DEBUG - Status cadastrados na tabela tire_status:
  1. "Novo" (length: 4, charCodes: 78,111,118,111)
  2. "Piloto" (length: 6, charCodes: 80,105,108,111,116,111)
  3. "Em Uso" (length: 6, charCodes: ...)
```

**O que verificar:**
- ✅ Se "Piloto" está cadastrado na tabela tire_status
- ✅ Se o nome é exatamente igual (sem espaços, case-sensitive)
- ✅ CharCodes devem ser idênticos entre tire_status e stock_entries

### 5. Processamento de Cards de Status

```typescript
🔍 DEBUG - Processando cards de status cadastrados:

  Status cadastrado: "Piloto"
    - Total no banco: 101
    - Em activeEntries: 101
    - Filtrados como descartados: 0
    - Containers: 5
    - Exemplos: [
        { barcode: "12345678", status: "Piloto" },
        { barcode: "87654321", status: "Piloto" }
      ]
```

**O que verificar:**
- `Total no banco`: Deve ser 101 ✅
- `Em activeEntries`: Deve ser 101 ✅ (se for 0, problema no filtro)
- `Filtrados como descartados`: Deve ser 0 ✅
- `Exemplos`: Confirma que status está correto

## Possíveis Causas do Problema

### Causa 1: Nome do Status Diferente (Case-Sensitive)

**Sintoma:** 
```
Tabela tire_status: "Piloto"
Tabela stock_entries: "piloto" ou "PILOTO"
```

**Solução:**
```sql
-- Verificar inconsistências
SELECT DISTINCT status, COUNT(*) 
FROM stock_entries 
WHERE LOWER(status) = 'piloto'
GROUP BY status;

-- Se retornar múltiplas linhas, há inconsistência
-- Exemplo de resultado problemático:
-- "Piloto": 50
-- "piloto": 51
-- Total = 101, mas comparação === falha
```

**Correção:**
```sql
-- Padronizar para "Piloto" (primeira letra maiúscula)
UPDATE stock_entries 
SET status = 'Piloto' 
WHERE LOWER(status) = 'piloto';
```

### Causa 2: Espaços Extras no Nome

**Sintoma:**
```
tire_status: "Piloto" (length: 6)
stock_entries: "Piloto " (length: 7) ← espaço extra
```

**Solução:**
```sql
-- Verificar espaços
SELECT status, LENGTH(status), COUNT(*) 
FROM stock_entries 
WHERE status LIKE '%Piloto%'
GROUP BY status, LENGTH(status);

-- Remover espaços extras
UPDATE stock_entries 
SET status = TRIM(status) 
WHERE status LIKE '% %';
```

### Causa 3: Caracteres Invisíveis

**Sintoma:**
```
CharCodes diferentes mesmo parecendo iguais
tire_status: [80,105,108,111,116,111]
stock_entries: [80,105,108,111,116,111,32] ← código 32 = espaço
```

**Solução:**
```sql
-- Limpar todos os status
UPDATE stock_entries 
SET status = REGEXP_REPLACE(TRIM(status), '\s+', ' ', 'g');

-- Reprocessar tire_status também
UPDATE tire_status 
SET name = REGEXP_REPLACE(TRIM(name), '\s+', ' ', 'g');
```

### Causa 4: Status "Piloto" Está Sendo Filtrado Como Descartado

**Sintoma:**
```
📊 DEBUG - Distribuição de Status (TODOS os registros):
  "Piloto": 101 pneus

📊 DEBUG - Distribuição de Status (APENAS ATIVOS):
  (Piloto não aparece) ← PROBLEMA!
```

**Causa:** O filtro `activeEntries` está removendo "Piloto"

**Verificar código:**
```typescript
const activeEntries = (allEntries || []).filter(entry => 
  entry.status !== 'Descartado DSI' && 
  entry.status !== 'Descarte DSI' && 
  entry.status !== 'Descarte'
);
```

**Problema possível:** Se o status no banco for:
- "Descarte Piloto" → Não seria filtrado (usa `!==`, não `.includes()`)
- Mas se houve refatoração anterior com `.includes('Descarte')`, então "Descarte Piloto" seria removido

**Solução:** Ajustar filtro para ser mais específico:
```typescript
const activeEntries = (allEntries || []).filter(entry => {
  const status = entry.status || '';
  // Remove apenas descartados DSI, não "Descarte Piloto"
  return status !== 'Descartado DSI' && 
         status !== 'Descarte DSI' && 
         status !== 'Descarte' &&
         !status.startsWith('Descartado DSI') &&
         !status.startsWith('Descarte DSI');
  // NÃO usar .includes('Descarte') pois removeria "Descarte Piloto"
});
```

### Causa 5: Status Não Está Cadastrado na Tabela tire_status

**Sintoma:**
```
📋 DEBUG - Status cadastrados na tabela tire_status:
  1. "Novo"
  2. "Em Uso"
  3. "Descartado DSI"
  (Piloto não está na lista) ← PROBLEMA!
```

**Solução:**
```sql
-- Inserir status "Piloto" na tabela tire_status
INSERT INTO tire_status (name, color, display_order)
VALUES ('Piloto', '#3B82F6', 3)
ON CONFLICT (name) DO NOTHING;
```

### Causa 6: Comparação Está Falhando no Código

**Sintoma:**
```
🔍 DEBUG - Processando cards de status cadastrados:

  Status cadastrado: "Piloto"
    - Total no banco: 101
    - Em activeEntries: 101 ← Dados estão corretos!
    - Filtrados como descartados: 0
    - Containers: 5
    (Mas o card ainda mostra 0)
```

**Causa:** O problema está DEPOIS da contagem, na criação do card

**Verificar:** Se `statsData.push()` está sendo chamado corretamente

## Como Debugar - Passo a Passo

### 1. Abra o Console do Navegador (F12)

### 2. Vá para o Dashboard

Recarregue a página se necessário

### 3. Procure pelos Logs de Debug

Procure por:
- `📊 DEBUG - Distribuição de Status`
- `📋 DEBUG - Status cadastrados na tabela tire_status`
- `🔍 DEBUG - Processando cards de status cadastrados`

### 4. Identifique o Problema

Use a tabela abaixo:

| Sintoma | Causa Provável | Solução |
|---------|---------------|---------|
| "Piloto" não aparece em "TODOS os registros" | Status diferente no banco | Verificar SQL: `SELECT DISTINCT status FROM stock_entries WHERE status LIKE '%iloto%'` |
| "Piloto" aparece em "TODOS" mas não em "ATIVOS" | Sendo filtrado como descartado | Ajustar filtro `activeEntries` |
| CharCodes diferentes | Espaços ou caracteres invisíveis | Executar `UPDATE stock_entries SET status = TRIM(status)` |
| "Piloto" não em tire_status | Não está cadastrado | Inserir na tabela tire_status |
| Contagem correta mas card mostra 0 | Bug no código de criação do card | Verificar `statsData.push()` |

### 5. Copie os Logs e Cole Aqui

```
📊 DEBUG - Distribuição de Status (TODOS os registros):
  [COLE AQUI]

📊 DEBUG - Distribuição de Status (APENAS ATIVOS):
  [COLE AQUI]

🔍 DEBUG - Pneus com "piloto" no status:
  [COLE AQUI]

📋 DEBUG - Status cadastrados na tabela tire_status:
  [COLE AQUI]

🔍 DEBUG - Processando cards de status cadastrados:
  [COLE STATUS "Piloto" AQUI]
```

## SQL Queries Úteis para Debug

### 1. Verificar Status com "Piloto"

```sql
SELECT 
  status,
  LENGTH(status) as tam,
  COUNT(*) as qtd
FROM stock_entries 
WHERE status LIKE '%iloto%'
GROUP BY status, LENGTH(status)
ORDER BY qtd DESC;
```

### 2. Comparar tire_status vs stock_entries

```sql
-- Status em stock_entries que NÃO existem em tire_status
SELECT DISTINCT se.status, COUNT(*) as qtd
FROM stock_entries se
LEFT JOIN tire_status ts ON se.status = ts.name
WHERE ts.name IS NULL AND se.status IS NOT NULL
GROUP BY se.status
ORDER BY qtd DESC;
```

### 3. Verificar Espaços e Caracteres Especiais

```sql
SELECT 
  status,
  LENGTH(status) as comprimento,
  LENGTH(TRIM(status)) as comprimento_sem_espacos,
  status = TRIM(status) as esta_limpo,
  COUNT(*) as qtd
FROM stock_entries
WHERE status LIKE '%Piloto%'
GROUP BY status;
```

### 4. Corrigir TODOS os Status (Limpeza Geral)

```sql
-- CUIDADO: Faz backup antes!

-- 1. Remove espaços extras
UPDATE stock_entries 
SET status = TRIM(status);

-- 2. Padroniza capitalização (primeira letra maiúscula)
UPDATE stock_entries 
SET status = INITCAP(LOWER(status))
WHERE status IS NOT NULL;

-- 3. Remove múltiplos espaços internos
UPDATE stock_entries 
SET status = REGEXP_REPLACE(status, '\s+', ' ', 'g');

-- 4. Faz o mesmo em tire_status
UPDATE tire_status 
SET name = TRIM(name);

UPDATE tire_status 
SET name = REGEXP_REPLACE(name, '\s+', ' ', 'g');
```

## Verificação Final

Após corrigir, verifique se:

1. ✅ Console mostra "Piloto" em TODOS os registros: 101
2. ✅ Console mostra "Piloto" em ATIVOS: 101
3. ✅ Console mostra "Piloto" em tire_status
4. ✅ CharCodes são idênticos
5. ✅ Card do Dashboard mostra: 101 pneus

## Arquivos Modificados

- `/components/Dashboard.tsx` - Adicionados logs detalhados de debug

## Próximo Passo

**COPIE OS LOGS DO CONSOLE** e envie para análise. Com os logs, poderei identificar exatamente qual das 6 causas está afetando seu sistema.
