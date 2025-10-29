-- ============================================
-- DELETAR UUID ESPECÍFICO IMEDIATAMENTE
-- ============================================
-- Execute este SQL AGORA no Supabase Dashboard

-- 1. DELETA O UUID ESPECÍFICO QUE ESTÁ CAUSANDO O ERRO
DELETE FROM stock_entries 
WHERE barcode = '0f0e10f6-aff5-4c19-ae6b-444e1945bf23';

-- 2. VERIFICA SE FOI DELETADO
SELECT 
  CASE 
    WHEN COUNT(*) = 0 THEN '✅ UUID deletado com sucesso!'
    ELSE '❌ UUID ainda existe - execute DELETE novamente'
  END as status,
  COUNT(*) as registros_encontrados
FROM stock_entries 
WHERE barcode = '0f0e10f6-aff5-4c19-ae6b-444e1945bf23';

-- 3. DELETA TODOS OS OUTROS UUIDs QUE AINDA EXISTAM
DELETE FROM stock_entries
WHERE barcode ~ '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$';

-- 4. VERIFICA QUANTOS UUIDs RESTAM
SELECT 
  CASE 
    WHEN COUNT(*) = 0 THEN '✅ Nenhum UUID restante - banco limpo!'
    ELSE '❌ Ainda existem ' || COUNT(*) || ' UUIDs'
  END as status,
  COUNT(*) as total_uuids_restantes
FROM stock_entries
WHERE barcode ~ '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$';

-- 5. VALIDAÇÃO FINAL: CONTA BARCODES VÁLIDOS VS INVÁLIDOS
SELECT 
  COUNT(*) FILTER (WHERE barcode ~ '^\d{8}$') as barcodes_validos,
  COUNT(*) FILTER (WHERE barcode !~ '^\d{8}$') as barcodes_invalidos,
  COUNT(*) as total,
  CASE 
    WHEN COUNT(*) FILTER (WHERE barcode !~ '^\d{8}$') = 0 
    THEN '✅ 100% DOS BARCODES SÃO VÁLIDOS!'
    ELSE '⚠️ Ainda existem ' || COUNT(*) FILTER (WHERE barcode !~ '^\d{8}$') || ' barcodes inválidos'
  END as resultado
FROM stock_entries;

-- ============================================
-- RESULTADO ESPERADO:
-- ============================================
-- Query 1: 1+ linhas deletadas
-- Query 2: 0 registros encontrados
-- Query 3: 0+ linhas deletadas
-- Query 4: 0 UUIDs restantes
-- Query 5: barcodes_invalidos = 0
