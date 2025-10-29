# 🔧 FIX: Erro "containers_check constraint violation"

## ❌ Problema

```
Erro ao inserir na tabela stock_entries: 
new row for relation "containers" violates check constraint "containers_check"
```

## 🔍 Causa Raiz

A tabela `containers` tem uma **CHECK constraint** que valida:

```sql
CHECK (current_stock <= capacity)
```

Quando você insere um pneu em `stock_entries`:
1. O Supabase incrementa `current_stock` do container via trigger/função
2. Se `current_stock` ultrapassar `capacity`, a constraint falha
3. A inserção é rejeitada

## 📊 Exemplo do Problema

```
Container: C-001
├─ Capacity: 100
├─ Current Stock: 100
└─ Tentativa: Inserir mais 1 pneu ❌
   └─ 101 > 100 = CONSTRAINT VIOLATION
```

## ✅ Solução 1: Aumentar Capacidade do Container

Execute no **Supabase SQL Editor**:

```sql
-- Verificar containers cheios
SELECT 
  id,
  name,
  capacity,
  current_stock,
  (capacity - current_stock) AS disponivel
FROM containers
WHERE current_stock >= capacity
ORDER BY name;

-- Aumentar capacidade de um container específico
UPDATE containers
SET capacity = 200  -- Novo limite
WHERE name = 'C-001';

-- OU aumentar capacidade de TODOS os containers
UPDATE containers
SET capacity = capacity + 100;  -- Adiciona 100 ao limite atual
```

## ✅ Solução 2: Verificar Estoque Real

A constraint pode estar falhando porque o `current_stock` está **desincronizado** com a realidade.

```sql
-- Conta quantos pneus realmente existem em cada container
WITH real_stock AS (
  SELECT 
    container_id,
    COUNT(*) AS total_pneus
  FROM stock_entries
  WHERE status NOT IN ('Descartado DSI', 'Descarte', 'Descarte Piloto')
    OR status IS NULL
  GROUP BY container_id
)
SELECT 
  c.id,
  c.name,
  c.capacity,
  c.current_stock AS current_stock_registrado,
  COALESCE(rs.total_pneus, 0) AS current_stock_real,
  (c.current_stock - COALESCE(rs.total_pneus, 0)) AS diferenca
FROM containers c
LEFT JOIN real_stock rs ON c.id = rs.container_id
WHERE c.current_stock != COALESCE(rs.total_pneus, 0)
ORDER BY diferenca DESC;
```

### Corrigir Desincronização

```sql
-- Atualiza current_stock baseado na contagem real
WITH real_stock AS (
  SELECT 
    container_id,
    COUNT(*) AS total_pneus
  FROM stock_entries
  WHERE status NOT IN ('Descartado DSI', 'Descarte', 'Descarte Piloto')
    OR status IS NULL
  GROUP BY container_id
)
UPDATE containers c
SET current_stock = COALESCE(rs.total_pneus, 0)
FROM real_stock rs
WHERE c.id = rs.container_id;

-- Também zera containers vazios
UPDATE containers
SET current_stock = 0
WHERE id NOT IN (
  SELECT DISTINCT container_id 
  FROM stock_entries 
  WHERE status NOT IN ('Descartado DSI', 'Descarte', 'Descarte Piloto')
    OR status IS NULL
);
```

## ✅ Solução 3: Desabilitar Temporariamente a Constraint

**⚠️ ATENÇÃO:** Só use em DESENVOLVIMENTO!

```sql
-- Desabilita a constraint
ALTER TABLE containers
DROP CONSTRAINT IF EXISTS containers_check;

-- Recria a constraint (depois de corrigir os dados)
ALTER TABLE containers
ADD CONSTRAINT containers_check 
CHECK (current_stock >= 0 AND current_stock <= capacity);
```

## ✅ Solução 4: Criar Capacidade "Ilimitada"

Se você não quer limitar a capacidade:

```sql
-- Define capacidade muito alta (99999)
UPDATE containers
SET capacity = 99999
WHERE capacity < 1000;

-- OU remove a constraint de capacidade (não recomendado)
ALTER TABLE containers
DROP CONSTRAINT IF EXISTS containers_check;

-- Recria apenas com validação de não-negativo
ALTER TABLE containers
ADD CONSTRAINT containers_check 
CHECK (current_stock >= 0);
```

## 🛠️ Solução Preventiva: Atualizar Triggers

Se você usa triggers para incrementar `current_stock`, garanta que ele valida antes:

```sql
-- Trigger para incrementar current_stock (exemplo)
CREATE OR REPLACE FUNCTION increment_container_stock()
RETURNS TRIGGER AS $$
BEGIN
  -- Verifica se container tem espaço
  IF (
    SELECT current_stock >= capacity 
    FROM containers 
    WHERE id = NEW.container_id
  ) THEN
    RAISE EXCEPTION 'Container % está cheio (capacidade: %, atual: %)', 
      NEW.container_id,
      (SELECT capacity FROM containers WHERE id = NEW.container_id),
      (SELECT current_stock FROM containers WHERE id = NEW.container_id);
  END IF;
  
  -- Incrementa se tiver espaço
  UPDATE containers
  SET current_stock = current_stock + 1
  WHERE id = NEW.container_id;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

## 📋 Checklist de Diagnóstico

Execute no Supabase SQL Editor:

```sql
-- 1. Verificar containers com problema
SELECT 
  id,
  name,
  capacity,
  current_stock,
  (capacity - current_stock) AS espaco_disponivel,
  CASE 
    WHEN current_stock > capacity THEN '❌ OVER CAPACITY'
    WHEN current_stock = capacity THEN '⚠️ FULL'
    ELSE '✅ OK'
  END AS status
FROM containers
ORDER BY (capacity - current_stock) ASC;

-- 2. Containers que causarão erro na próxima inserção
SELECT 
  id,
  name,
  capacity,
  current_stock
FROM containers
WHERE current_stock >= capacity;

-- 3. Total de pneus por container (contagem real)
SELECT 
  c.name AS container,
  COUNT(se.id) AS total_pneus,
  c.capacity,
  c.current_stock,
  (COUNT(se.id) - c.current_stock) AS diferenca
FROM containers c
LEFT JOIN stock_entries se ON c.id = se.container_id
  AND (se.status NOT IN ('Descartado DSI', 'Descarte', 'Descarte Piloto') OR se.status IS NULL)
GROUP BY c.id, c.name, c.capacity, c.current_stock
ORDER BY total_pneus DESC;
```

## 🎯 Solução Recomendada (Passo a Passo)

### 1️⃣ Diagnóstico

```sql
-- Executa diagnóstico completo
SELECT 
  c.id,
  c.name,
  c.capacity,
  c.current_stock AS registrado,
  COALESCE(COUNT(se.id), 0) AS real,
  (c.capacity - c.current_stock) AS espaco,
  CASE 
    WHEN c.current_stock > c.capacity THEN '❌ VIOLAÇÃO'
    WHEN c.current_stock = c.capacity THEN '⚠️ CHEIO'
    WHEN c.current_stock != COALESCE(COUNT(se.id), 0) THEN '⚠️ DESSINCRONIZADO'
    ELSE '✅ OK'
  END AS status
FROM containers c
LEFT JOIN stock_entries se ON c.id = se.container_id
  AND (se.status NOT IN ('Descartado DSI', 'Descarte', 'Descarte Piloto') OR se.status IS NULL)
GROUP BY c.id, c.name, c.capacity, c.current_stock
ORDER BY status, name;
```

### 2️⃣ Correção Automática

```sql
-- PASSO 1: Sincroniza current_stock com realidade
WITH real_stock AS (
  SELECT 
    container_id,
    COUNT(*) AS total_pneus
  FROM stock_entries
  WHERE status NOT IN ('Descartado DSI', 'Descarte', 'Descarte Piloto')
    OR status IS NULL
  GROUP BY container_id
)
UPDATE containers c
SET current_stock = COALESCE(rs.total_pneus, 0)
FROM real_stock rs
WHERE c.id = rs.container_id;

-- PASSO 2: Zera containers sem pneus
UPDATE containers
SET current_stock = 0
WHERE id NOT IN (
  SELECT DISTINCT container_id 
  FROM stock_entries 
  WHERE status NOT IN ('Descartado DSI', 'Descarte', 'Descarte Piloto')
    OR status IS NULL
);

-- PASSO 3: Aumenta capacidade de containers que violam
UPDATE containers
SET capacity = current_stock + 100
WHERE current_stock > capacity;

-- PASSO 4: Verifica se corrigiu
SELECT 
  name,
  capacity,
  current_stock,
  (capacity - current_stock) AS espaco_disponivel
FROM containers
WHERE current_stock > capacity;
-- Se retornar 0 linhas, está OK!
```

### 3️⃣ Prevenção Futura

```sql
-- Aumenta capacidade de TODOS os containers para evitar problema futuro
UPDATE containers
SET capacity = GREATEST(capacity, current_stock + 200);
-- Garante pelo menos 200 de espaço acima do atual

-- Verificação final
SELECT 
  MIN(capacity - current_stock) AS menor_espaco,
  MAX(capacity - current_stock) AS maior_espaco,
  AVG(capacity - current_stock) AS espaco_medio
FROM containers;
```

## 🚀 Solução Rápida (1 Comando)

Se você só quer **resolver agora e investigar depois**:

```sql
-- Aumenta capacidade de TODOS os containers para 99999
UPDATE containers SET capacity = 99999;
```

Depois investigue qual container estava causando o problema.

## 📱 Solução Frontend (Preventiva)

Adicione validação no frontend para avisar antes de tentar inserir:

```typescript
// TireStockEntry.tsx
const validateContainer = async (containerId: string) => {
  const container = containers.find(c => c.id === containerId);
  
  if (!container) {
    toast.error('Container não encontrado');
    return false;
  }
  
  if (container.current_stock >= container.capacity) {
    toast.error(`Container ${container.name} está cheio!`, {
      description: `Capacidade: ${container.capacity}, Atual: ${container.current_stock}`
    });
    return false;
  }
  
  if (container.current_stock + 1 > container.capacity) {
    toast.warning(`Container ${container.name} ficará cheio após esta entrada`, {
      description: `Último espaço disponível`
    });
  }
  
  return true;
};

// Valida antes de inserir
if (!await validateContainer(selectedContainer)) {
  return; // Cancela inserção
}
```

## 📊 Monitoramento

Adicione no Dashboard um alerta de containers próximos ao limite:

```typescript
// Dashboard.tsx
const containerAlerts = containers.filter(c => {
  const usage = (c.current_stock / c.capacity) * 100;
  return usage >= 80; // 80% ou mais
}).map(c => ({
  name: c.name,
  usage: ((c.current_stock / c.capacity) * 100).toFixed(1),
  available: c.capacity - c.current_stock
}));

if (containerAlerts.length > 0) {
  console.warn('⚠️ Containers próximos ao limite:', containerAlerts);
}
```

## 🔍 Logs para Debug

Quando o erro ocorrer, verifique:

```sql
-- Qual container estava sendo usado?
SELECT 
  id,
  name,
  capacity,
  current_stock,
  (capacity - current_stock) AS disponivel
FROM containers
WHERE id = 'CONTAINER_ID_DO_ERRO';

-- Histórico recente de inserções neste container
SELECT 
  barcode,
  model_name,
  status,
  created_at
FROM stock_entries
WHERE container_id = 'CONTAINER_ID_DO_ERRO'
ORDER BY created_at DESC
LIMIT 20;
```

## ✅ Resumo Executivo

| Solução | Quando Usar | Comando |
|---------|-------------|---------|
| **Aumentar capacidade** | Container realmente cheio | `UPDATE containers SET capacity = 200 WHERE id = '...'` |
| **Sincronizar stock** | Dados dessincronizados | Execute script de correção acima |
| **Capacidade ilimitada** | Desenvolvimento/teste | `UPDATE containers SET capacity = 99999` |
| **Remover constraint** | Último recurso | `ALTER TABLE containers DROP CONSTRAINT containers_check` |

## 🎯 Próximo Passo

1. **Execute o diagnóstico** (query do passo 1️⃣)
2. **Identifique** quais containers têm problema
3. **Aplique** a correção apropriada
4. **Teste** inserindo um pneu novamente

---

**Versão:** 1.0  
**Data:** 2025-01-21  
**Status:** 🔧 AGUARDANDO EXECUÇÃO NO SUPABASE
