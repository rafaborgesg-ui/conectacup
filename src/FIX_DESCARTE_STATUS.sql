-- =====================================================
-- FIX: Atualiza status "Descarte" para "Descartado DSI"
-- =====================================================
-- Este script corrige os pneus que foram descartados 
-- com o status antigo "Descarte" para o novo padrão 
-- "Descartado DSI"
-- =====================================================

-- IMPORTANTE: Execute este script no Supabase SQL Editor
-- Link: https://supabase.com/dashboard/project/nflgqugaabtxzifyhjor/sql

BEGIN;

-- 1. Verificar quantos registros serão afetados
SELECT 
  COUNT(*) as total_pneus_descartados,
  status
FROM stock_entries
WHERE status = 'Descarte'
GROUP BY status;

-- 2. Atualizar o status de "Descarte" para "Descartado DSI"
UPDATE stock_entries
SET 
  status = 'Descartado DSI',
  updated_at = NOW()
WHERE status = 'Descarte';

-- 3. Verificar os resultados
SELECT 
  COUNT(*) as total_descartado_dsi
FROM stock_entries
WHERE status = 'Descartado DSI';

-- 4. Mostrar todos os status únicos no banco
SELECT 
  status,
  COUNT(*) as quantidade
FROM stock_entries
GROUP BY status
ORDER BY quantidade DESC;

COMMIT;

-- =====================================================
-- RESULTADO ESPERADO:
-- - Todos os pneus com status "Descarte" agora têm "Descartado DSI"
-- - A página de Relatórios & Histórico de Descarte funcionará corretamente
-- =====================================================
