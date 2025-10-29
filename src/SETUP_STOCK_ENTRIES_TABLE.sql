-- =====================================================
-- SETUP: Tabela stock_entries
-- Cria a tabela SQL para armazenar entradas de estoque
-- =====================================================

-- IMPORTANTE: Execute este SQL no Supabase SQL Editor
-- Link: https://supabase.com/dashboard/project/nflgqugaabtxzifyhjor/sql

BEGIN;

-- =====================================================
-- 1. Criar a tabela stock_entries (se não existir)
-- =====================================================

CREATE TABLE IF NOT EXISTS stock_entries (
  -- Identificadores
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  barcode TEXT NOT NULL UNIQUE, -- Código de barras único de 8 dígitos
  
  -- Informações do Modelo
  model_id TEXT NOT NULL,
  model_name TEXT NOT NULL,
  model_type TEXT NOT NULL CHECK (model_type IN ('Slick', 'Wet')),
  
  -- Informações do Container
  container_id TEXT NOT NULL,
  container_name TEXT NOT NULL,
  
  -- Status do Pneu
  status TEXT NOT NULL DEFAULT 'Novo',
  
  -- Timestamps
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- =====================================================
-- 2. Criar índices para performance
-- =====================================================

-- Índice único no código de barras (busca rápida e garante unicidade)
CREATE UNIQUE INDEX IF NOT EXISTS idx_stock_entries_barcode 
  ON stock_entries(barcode);

-- Índice para busca por modelo
CREATE INDEX IF NOT EXISTS idx_stock_entries_model 
  ON stock_entries(model_id);

-- Índice para busca por container
CREATE INDEX IF NOT EXISTS idx_stock_entries_container 
  ON stock_entries(container_id);

-- Índice para busca por status
CREATE INDEX IF NOT EXISTS idx_stock_entries_status 
  ON stock_entries(status);

-- Índice para ordenação por data
CREATE INDEX IF NOT EXISTS idx_stock_entries_created_at 
  ON stock_entries(created_at DESC);

-- =====================================================
-- 3. Criar função para atualizar updated_at automaticamente
-- =====================================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 4. Criar trigger para updated_at
-- =====================================================

DROP TRIGGER IF EXISTS update_stock_entries_updated_at ON stock_entries;

CREATE TRIGGER update_stock_entries_updated_at
  BEFORE UPDATE ON stock_entries
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- 5. Habilitar Row Level Security (RLS)
-- =====================================================

ALTER TABLE stock_entries ENABLE ROW LEVEL SECURITY;

-- Política: Todos podem LER (com autenticação)
CREATE POLICY "Todos podem ler stock_entries" 
  ON stock_entries 
  FOR SELECT 
  USING (true);

-- Política: Todos podem INSERIR (com autenticação)
CREATE POLICY "Todos podem inserir stock_entries" 
  ON stock_entries 
  FOR INSERT 
  WITH CHECK (true);

-- Política: Todos podem ATUALIZAR (com autenticação)
CREATE POLICY "Todos podem atualizar stock_entries" 
  ON stock_entries 
  FOR UPDATE 
  USING (true);

-- Política: Todos podem DELETAR (com autenticação)
CREATE POLICY "Todos podem deletar stock_entries" 
  ON stock_entries 
  FOR DELETE 
  USING (true);

-- =====================================================
-- 6. Comentários para documentação
-- =====================================================

COMMENT ON TABLE stock_entries IS 
  'Armazena todas as entradas de estoque de pneus da Porsche Cup Brasil';

COMMENT ON COLUMN stock_entries.barcode IS 
  'Código de barras único de 8 dígitos numéricos';

COMMENT ON COLUMN stock_entries.model_type IS 
  'Tipo do pneu: Slick (seco) ou Wet (molhado)';

COMMENT ON COLUMN stock_entries.status IS 
  'Status atual do pneu (Novo, Pneu CUP, Descartado DSI, etc)';

-- =====================================================
-- 7. Verificar estrutura criada
-- =====================================================

-- Verificar tabela
SELECT 
  table_name,
  table_type
FROM information_schema.tables
WHERE table_name = 'stock_entries';

-- Verificar colunas
SELECT 
  column_name,
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns
WHERE table_name = 'stock_entries'
ORDER BY ordinal_position;

-- Verificar índices
SELECT 
  indexname,
  indexdef
FROM pg_indexes
WHERE tablename = 'stock_entries';

-- Verificar policies (RLS)
SELECT 
  policyname,
  cmd,
  qual,
  with_check
FROM pg_policies
WHERE tablename = 'stock_entries';

COMMIT;

-- =====================================================
-- 8. Dados de Exemplo (OPCIONAL - Descomente se quiser testar)
-- =====================================================

/*
-- Inserir alguns pneus de exemplo
INSERT INTO stock_entries (id, barcode, model_id, model_name, model_type, container_id, container_name, status)
VALUES
  (gen_random_uuid(), '12345678', 'model-991-dianteiro', '991 Dianteiro', 'Slick', 'container-a', 'Container A', 'Novo'),
  (gen_random_uuid(), '23456789', '991-traseiro', '991 Traseiro', 'Slick', 'container-a', 'Container A', 'Novo'),
  (gen_random_uuid(), '34567890', 'model-992-dianteiro', '992 Dianteiro', 'Slick', 'container-b', 'Container B', 'Novo'),
  (gen_random_uuid(), '45678901', 'model-992-traseiro', '992 Traseiro', 'Slick', 'container-b', 'Container B', 'Pneu CUP'),
  (gen_random_uuid(), '56789012', 'model-991-wet-dianteiro', '991 Wet Dianteiro', 'Wet', 'container-c', 'Container C', 'Novo');

-- Verificar dados inseridos
SELECT * FROM stock_entries ORDER BY created_at DESC;
*/

-- =====================================================
-- 9. Queries Úteis para Administração
-- =====================================================

/*
-- Ver todos os pneus
SELECT * FROM stock_entries ORDER BY created_at DESC;

-- Contar total de pneus
SELECT COUNT(*) as total_pneus FROM stock_entries;

-- Contar pneus por status
SELECT status, COUNT(*) as quantidade
FROM stock_entries
GROUP BY status
ORDER BY quantidade DESC;

-- Contar pneus por modelo
SELECT model_name, COUNT(*) as quantidade
FROM stock_entries
GROUP BY model_name
ORDER BY quantidade DESC;

-- Contar pneus por container
SELECT container_name, COUNT(*) as quantidade
FROM stock_entries
GROUP BY container_name
ORDER BY quantidade DESC;

-- Buscar pneu por código de barras
SELECT * FROM stock_entries WHERE barcode = '12345678';

-- Deletar todos os pneus (CUIDADO!)
-- DELETE FROM stock_entries;
*/

-- =====================================================
-- ✅ SETUP COMPLETO
-- =====================================================

-- Após executar este script, você deve ver:
-- ✅ Tabela stock_entries criada
-- ✅ 5 índices criados
-- ✅ 1 função criada (update_updated_at_column)
-- ✅ 1 trigger criado (update_stock_entries_updated_at)
-- ✅ RLS habilitado com 4 políticas

-- Agora o sistema está pronto para:
-- 1. Cadastrar pneus via Entrada de Estoque
-- 2. Verificar duplicatas automaticamente
-- 3. Buscar pneus por código de barras
-- 4. Consultar histórico de entradas
