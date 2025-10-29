-- ============================================
-- VERIFICAÇÃO FINAL: NÃO HÁ MAIS UUIDs EM BARCODES
-- ============================================
-- Este script verifica se a limpeza foi bem-sucedida
-- e não há mais UUIDs no campo barcode

-- 1. BUSCAR REGISTROS COM BARCODE EM FORMATO UUID
SELECT 
  id,
  barcode,
  model_name,
  container_name,
  created_at,
  'UUID detectado' as issue
FROM stock_entries
WHERE barcode ~ '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$'
ORDER BY created_at DESC;

-- 2. CONTAR TOTAL DE REGISTROS COM UUID
SELECT 
  COUNT(*) as total_uuids,
  'UUIDs encontrados no campo barcode' as descricao
FROM stock_entries
WHERE barcode ~ '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$';

-- 3. BUSCAR REGISTROS COM BARCODE INVÁLIDO (NÃO TEM 8 DÍGITOS)
SELECT 
  id,
  barcode,
  LENGTH(barcode) as tamanho,
  model_name,
  container_name,
  created_at,
  CASE 
    WHEN LENGTH(barcode) < 8 THEN 'Menos de 8 caracteres'
    WHEN LENGTH(barcode) > 8 THEN 'Mais de 8 caracteres'
    WHEN barcode !~ '^\d+$' THEN 'Contém caracteres não numéricos'
    ELSE 'Outro problema'
  END as issue
FROM stock_entries
WHERE barcode !~ '^\d{8}$'
ORDER BY LENGTH(barcode), created_at DESC
LIMIT 100;

-- 4. CONTAGEM GERAL DE BARCODES VÁLIDOS VS INVÁLIDOS
SELECT 
  COUNT(*) FILTER (WHERE barcode ~ '^\d{8}$') as barcodes_validos,
  COUNT(*) FILTER (WHERE barcode !~ '^\d{8}$') as barcodes_invalidos,
  COUNT(*) as total_registros,
  ROUND(
    (COUNT(*) FILTER (WHERE barcode ~ '^\d{8}$')::DECIMAL / COUNT(*)) * 100, 
    2
  ) as percentual_validos
FROM stock_entries;

-- 5. BUSCAR O UUID ESPECÍFICO MENCIONADO NO ERRO
SELECT 
  *,
  'Este é o UUID que está causando o erro!' as observacao
FROM stock_entries
WHERE barcode = '0f0e10f6-aff5-4c19-ae6b-444e1945bf23';

-- ============================================
-- RESULTADO ESPERADO SE LIMPEZA FOI CONCLUÍDA:
-- ============================================
-- Query 1 e 2: 0 registros (nenhum UUID)
-- Query 3: 0 registros (nenhum barcode inválido)
-- Query 4: 100% válidos
-- Query 5: 0 registros (UUID específico não existe mais)
