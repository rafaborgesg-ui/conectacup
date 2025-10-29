-- =====================================================
-- ATUALIZAÇÃO: Corrige status para "Descartado DSI"
-- =====================================================
-- Este script atualiza TODOS os registros que usam
-- o status incorreto para o nome correto
-- =====================================================

-- IMPORTANTE: Execute no Supabase SQL Editor
-- Link: https://supabase.com/dashboard/project/nflgqugaabtxzifyhjor/sql

BEGIN;

-- 1. Mostrar status atuais no banco
SELECT 
  status,
  COUNT(*) as quantidade
FROM stock_entries
GROUP BY status
ORDER BY quantidade DESC;

-- 2. Atualizar "Descarte DSI" para "Descartado DSI"
UPDATE stock_entries
SET 
  status = 'Descartado DSI',
  updated_at = NOW()
WHERE status = 'Descarte DSI';

-- 3. Atualizar status antigo "Descarte" para "Descartado DSI"
UPDATE stock_entries
SET 
  status = 'Descartado DSI',
  updated_at = NOW()
WHERE status = 'Descarte';

-- 4. Verificar resultado final
SELECT 
  status,
  COUNT(*) as quantidade
FROM stock_entries
GROUP BY status
ORDER BY quantidade DESC;

-- 5. Confirmar registros com o status correto
SELECT 
  COUNT(*) as total_descartado_dsi
FROM stock_entries
WHERE status = 'Descartado DSI';

COMMIT;

-- =====================================================
-- RESULTADO ESPERADO:
-- - Status "Descarte DSI" → "Descartado DSI"
-- - Status "Descarte" → "Descartado DSI"
-- - A página de Relatórios & Histórico de Descarte 
--   exibirá todos os pneus corretamente
-- =====================================================

-- =====================================================
-- NOTAS IMPORTANTES:
-- =====================================================
-- 1. O nome correto do status é "Descartado DSI"
--    (com "Descartado" e não "Descarte")
-- 
-- 2. Este script também corrige registros antigos
--    que possam estar usando apenas "Descarte"
--
-- 3. Após executar, verifique a página:
--    Relatórios & Histórico de Descarte
-- =====================================================
