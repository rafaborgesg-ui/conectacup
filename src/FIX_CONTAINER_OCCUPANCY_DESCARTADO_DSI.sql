-- =====================================================
-- CORREÇÃO: Excluir pneus "Descartado DSI" da ocupação dos containers
-- =====================================================
-- 
-- PROBLEMA IDENTIFICADO:
-- Pneus com status "Descartado DSI" estão sendo contabilizados
-- incorretamente na ocupação dos containers (coluna current_stock).
--
-- SOLUÇÃO:
-- Criar uma view que calcula current_stock dinamicamente
-- excluindo pneus com status "Descartado DSI", "Descarte DSI" e "Descarte"
--
-- Execute este SQL no Supabase SQL Editor:
-- https://supabase.com/dashboard/project/nflgqugaabtxzifyhjor/sql
-- =====================================================

BEGIN;

-- =====================================================
-- 1. Criar VIEW para containers com ocupação correta
-- =====================================================

DROP VIEW IF EXISTS containers_with_stock CASCADE;

CREATE OR REPLACE VIEW containers_with_stock AS
SELECT 
  c.id,
  c.name,
  c.location,
  c.capacity,
  -- Calcula current_stock contando APENAS pneus ativos (exclui descartados)
  COALESCE(
    (
      SELECT COUNT(*)
      FROM stock_entries se
      WHERE se.container_id = c.id
        AND se.status NOT IN ('Descartado DSI', 'Descarte DSI', 'Descarte')
    ), 
    0
  ) AS current_stock,
  c.created_at,
  c.updated_at
FROM containers c;

-- Adicionar comentário explicativo
COMMENT ON VIEW containers_with_stock IS 
  'View que calcula ocupação real dos containers excluindo pneus descartados (Descartado DSI, Descarte DSI, Descarte)';

-- =====================================================
-- 2. Criar função para atualizar current_stock em containers
-- =====================================================

-- Remove função antiga se existir
DROP FUNCTION IF EXISTS sync_container_stock();

-- Cria nova função que atualiza current_stock excluindo descartados
CREATE OR REPLACE FUNCTION sync_container_stock()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Atualiza current_stock de todos os containers
  -- Conta apenas pneus ATIVOS (exclui Descartado DSI, Descarte DSI, Descarte)
  UPDATE containers c
  SET 
    current_stock = COALESCE(
      (
        SELECT COUNT(*)
        FROM stock_entries se
        WHERE se.container_id = c.id
          AND se.status NOT IN ('Descartado DSI', 'Descarte DSI', 'Descarte')
      ),
      0
    ),
    updated_at = NOW();
    
  -- Log de sucesso
  RAISE NOTICE 'Ocupação dos containers sincronizada com sucesso (excluindo descartados)';
END;
$$;

-- Adicionar comentário explicativo
COMMENT ON FUNCTION sync_container_stock IS 
  'Atualiza current_stock de todos os containers excluindo pneus descartados';

-- =====================================================
-- 3. Criar trigger para atualizar current_stock automaticamente
-- =====================================================

-- Remove trigger antigo se existir
DROP TRIGGER IF EXISTS trigger_sync_container_stock_on_insert ON stock_entries;
DROP TRIGGER IF EXISTS trigger_sync_container_stock_on_update ON stock_entries;
DROP TRIGGER IF EXISTS trigger_sync_container_stock_on_delete ON stock_entries;
DROP FUNCTION IF EXISTS trigger_sync_container_stock();

-- Cria função para o trigger
CREATE OR REPLACE FUNCTION trigger_sync_container_stock()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  affected_containers TEXT[];
BEGIN
  -- Identifica containers afetados
  IF TG_OP = 'INSERT' THEN
    affected_containers := ARRAY[NEW.container_id];
  ELSIF TG_OP = 'UPDATE' THEN
    -- Se container mudou OU status mudou, atualiza ambos
    affected_containers := ARRAY[OLD.container_id, NEW.container_id];
  ELSIF TG_OP = 'DELETE' THEN
    affected_containers := ARRAY[OLD.container_id];
  END IF;
  
  -- Atualiza current_stock dos containers afetados
  -- Conta apenas pneus ATIVOS (exclui Descartado DSI, Descarte DSI, Descarte)
  UPDATE containers c
  SET 
    current_stock = COALESCE(
      (
        SELECT COUNT(*)
        FROM stock_entries se
        WHERE se.container_id = c.id
          AND se.status NOT IN ('Descartado DSI', 'Descarte DSI', 'Descarte')
      ),
      0
    ),
    updated_at = NOW()
  WHERE c.id = ANY(affected_containers);
  
  RETURN COALESCE(NEW, OLD);
END;
$$;

-- Criar triggers para INSERT, UPDATE e DELETE
CREATE TRIGGER trigger_sync_container_stock_on_insert
  AFTER INSERT ON stock_entries
  FOR EACH ROW
  EXECUTE FUNCTION trigger_sync_container_stock();

CREATE TRIGGER trigger_sync_container_stock_on_update
  AFTER UPDATE ON stock_entries
  FOR EACH ROW
  EXECUTE FUNCTION trigger_sync_container_stock();

CREATE TRIGGER trigger_sync_container_stock_on_delete
  AFTER DELETE ON stock_entries
  FOR EACH ROW
  EXECUTE FUNCTION trigger_sync_container_stock();

-- =====================================================
-- 4. Sincronizar dados existentes
-- =====================================================

-- Executa a sincronização inicial
SELECT sync_container_stock();

-- =====================================================
-- 5. Verificação
-- =====================================================

-- Verificar ocupação corrigida
SELECT 
  name,
  capacity,
  current_stock,
  CASE 
    WHEN capacity > 0 THEN ROUND((current_stock::NUMERIC / capacity) * 100, 1)
    ELSE 0
  END AS ocupacao_percentual,
  -- Mostrar quantos descartados foram excluídos
  (
    SELECT COUNT(*)
    FROM stock_entries se
    WHERE se.container_id = containers.id
      AND se.status IN ('Descartado DSI', 'Descarte DSI', 'Descarte')
  ) AS pneus_descartados_excluidos
FROM containers
ORDER BY name;

COMMIT;

-- =====================================================
-- ✅ CORREÇÃO APLICADA COM SUCESSO
-- =====================================================
-- 
-- O que foi feito:
-- 1. ✅ Criada VIEW containers_with_stock que calcula ocupação correta
-- 2. ✅ Criada FUNCTION sync_container_stock() para sincronização manual
-- 3. ✅ Criados TRIGGERS automáticos em stock_entries (INSERT/UPDATE/DELETE)
-- 4. ✅ Sincronizados dados existentes
--
-- Agora:
-- - current_stock NÃO conta pneus com status "Descartado DSI", "Descarte DSI" ou "Descarte"
-- - A ocupação é atualizada AUTOMATICAMENTE quando:
--   * Um pneu é cadastrado (INSERT)
--   * Um pneu muda de status ou container (UPDATE)
--   * Um pneu é removido (DELETE)
--
-- Para resincronizar manualmente a qualquer momento:
-- SELECT sync_container_stock();
--
-- =====================================================
