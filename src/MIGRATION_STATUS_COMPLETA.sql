-- =====================================================
-- MIGRAÇÃO COMPLETA: Status de Descarte
-- =====================================================
-- Este script atualiza TODOS os status de descarte
-- para o padrão definitivo "Descartado DSI"
-- 
-- Execute no Supabase SQL Editor:
-- https://supabase.com/dashboard/project/nflgqugaabtxzifyhjor/sql
-- =====================================================

BEGIN;

-- =====================================================
-- PASSO 1: DIAGNÓSTICO
-- Mostra a situação atual do banco
-- =====================================================

SELECT 
  '📊 DIAGNÓSTICO INICIAL' as etapa,
  status,
  COUNT(*) as quantidade
FROM stock_entries
GROUP BY status
ORDER BY quantidade DESC;

-- =====================================================
-- PASSO 2: BACKUP VISUAL
-- Lista todos os registros que serão afetados
-- =====================================================

SELECT 
  '🔍 REGISTROS QUE SERÃO ATUALIZADOS' as etapa,
  id,
  barcode,
  status as status_atual,
  created_at
FROM stock_entries
WHERE status IN ('Descarte', 'Descarte DSI')
ORDER BY created_at DESC
LIMIT 50;

-- Conta total de registros a atualizar
SELECT 
  '📈 TOTAL A ATUALIZAR' as etapa,
  COUNT(*) as total_registros
FROM stock_entries
WHERE status IN ('Descarte', 'Descarte DSI');

-- =====================================================
-- PASSO 3: ATUALIZAÇÃO
-- Converte todos os status de descarte para "Descartado DSI"
-- =====================================================

-- 3.1: Atualiza "Descarte DSI" → "Descartado DSI"
UPDATE stock_entries
SET 
  status = 'Descartado DSI',
  updated_at = NOW()
WHERE status = 'Descarte DSI';

-- 3.2: Atualiza "Descarte" → "Descartado DSI"
UPDATE stock_entries
SET 
  status = 'Descartado DSI',
  updated_at = NOW()
WHERE status = 'Descarte';

-- =====================================================
-- PASSO 4: VERIFICAÇÃO
-- Confirma que a migração foi bem-sucedida
-- =====================================================

SELECT 
  '✅ RESULTADO FINAL' as etapa,
  status,
  COUNT(*) as quantidade
FROM stock_entries
GROUP BY status
ORDER BY quantidade DESC;

-- Confirma registros com "Descartado DSI"
SELECT 
  '🎯 DESCARTADOS DSI' as etapa,
  COUNT(*) as total_descartado_dsi
FROM stock_entries
WHERE status = 'Descartado DSI';

-- Verifica se ainda existem status antigos (deve retornar 0)
SELECT 
  '⚠️ STATUS ANTIGOS REMANESCENTES (deve ser 0)' as etapa,
  COUNT(*) as total_status_antigos
FROM stock_entries
WHERE status IN ('Descarte', 'Descarte DSI');

-- =====================================================
-- PASSO 5: ATUALIZAR TABELA tire_status (se existir)
-- Garante que o status está cadastrado corretamente
-- =====================================================

-- Remove status antigos duplicados (se existirem)
DELETE FROM tire_status 
WHERE name IN ('Descarte', 'Descarte DSI');

-- Garante que "Descartado DSI" existe
INSERT INTO tire_status (id, name, color, is_default, display_order, created_at)
VALUES (
  'status-descartado-dsi',
  'Descartado DSI',
  '#DC2626',
  true,
  3,
  NOW()
)
ON CONFLICT (id) 
DO UPDATE SET
  name = 'Descartado DSI',
  color = '#DC2626',
  updated_at = NOW();

-- =====================================================
-- PASSO 6: VERIFICAÇÃO FINAL DA TABELA tire_status
-- =====================================================

SELECT 
  '📋 STATUS CADASTRADOS' as etapa,
  id,
  name,
  color,
  display_order
FROM tire_status
ORDER BY display_order ASC, name ASC;

COMMIT;

-- =====================================================
-- RESULTADO ESPERADO
-- =====================================================
-- Após executar este script:
-- 
-- ✅ Todos os pneus descartados têm status "Descartado DSI"
-- ✅ Não existem mais registros com "Descarte" ou "Descarte DSI"
-- ✅ A página "Relatórios & Histórico de Descarte" funciona
-- ✅ O sistema está padronizado e consistente
-- 
-- PRÓXIMOS PASSOS:
-- 1. Recarregue a aplicação (Ctrl+F5 ou Cmd+Shift+R)
-- 2. Acesse "Relatórios & Histórico de Descarte"
-- 3. Verifique que os pneus descartados aparecem
-- 4. O alerta amarelo não deve mais aparecer
-- =====================================================

-- =====================================================
-- ROLLBACK (apenas se necessário)
-- =====================================================
-- Se algo der errado, você pode reverter com:
-- 
-- BEGIN;
-- UPDATE stock_entries
-- SET status = 'Descarte DSI'
-- WHERE status = 'Descartado DSI';
-- COMMIT;
-- 
-- MAS: Execute apenas se realmente necessário!
-- =====================================================
