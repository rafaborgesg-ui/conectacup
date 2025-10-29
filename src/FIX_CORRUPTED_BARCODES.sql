-- ============================================
-- FIX: Detecta e corrige barcodes corrompidos
-- Problema: Alguns registros têm UUID no campo barcode
-- Solução: Identifica e deleta registros inválidos
-- ============================================

-- Passo 1: DETECTAR registros com UUID no campo barcode
SELECT 
  id,
  barcode,
  model_name,
  container_name,
  created_at,
  CASE 
    WHEN barcode ~ '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$' THEN 'UUID DETECTADO ❌'
    WHEN LENGTH(barcode) != 8 THEN 'TAMANHO INCORRETO ❌'
    WHEN barcode !~ '^\d{8}$' THEN 'NÃO É 8 DÍGITOS ❌'
    ELSE 'VÁLIDO ✅'
  END as status_barcode
FROM stock_entries
WHERE 
  -- Detecta UUIDs (formato: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx)
  barcode ~ '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$'
  OR
  -- Detecta barcodes com tamanho diferente de 8
  LENGTH(barcode) != 8
  OR
  -- Detecta barcodes que não são 8 dígitos numéricos
  barcode !~ '^\d{8}$'
ORDER BY created_at DESC;

-- Passo 2: CONTAR registros corrompidos
SELECT 
  CASE 
    WHEN barcode ~ '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$' THEN 'UUID no barcode'
    WHEN LENGTH(barcode) != 8 THEN 'Tamanho incorreto'
    WHEN barcode !~ '^\d{8}$' THEN 'Não numérico'
    ELSE 'VÁLIDO'
  END as tipo_problema,
  COUNT(*) as total
FROM stock_entries
GROUP BY tipo_problema
ORDER BY total DESC;

-- Passo 3: BACKUP antes de deletar (cria tabela temporária)
CREATE TABLE IF NOT EXISTS stock_entries_backup_corrupted AS
SELECT * FROM stock_entries
WHERE 
  barcode ~ '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$'
  OR LENGTH(barcode) != 8
  OR barcode !~ '^\d{8}$';

-- Passo 4: DELETAR registros corrompidos
-- ⚠️ ATENÇÃO: Isso irá deletar permanentemente os registros inválidos
-- Execute apenas se tiver certeza

-- DESCOMENTE A LINHA ABAIXO PARA EXECUTAR A DELEÇÃO:
-- DELETE FROM stock_entries
-- WHERE 
--   barcode ~ '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$'
--   OR LENGTH(barcode) != 8
--   OR barcode !~ '^\d{8}$';

-- Passo 5: VERIFICAR resultado
SELECT 
  COUNT(*) as total_registros,
  COUNT(CASE WHEN barcode ~ '^\d{8}$' THEN 1 END) as barcodes_validos,
  COUNT(CASE WHEN barcode !~ '^\d{8}$' THEN 1 END) as barcodes_invalidos
FROM stock_entries;

-- Passo 6: ADICIONAR constraint para prevenir futuras corrupções
-- ⚠️ Execute apenas após limpar os dados corrompidos

-- DESCOMENTE AS LINHAS ABAIXO PARA ADICIONAR CONSTRAINT:
-- ALTER TABLE stock_entries
-- DROP CONSTRAINT IF EXISTS stock_entries_barcode_format_check;
--
-- ALTER TABLE stock_entries
-- ADD CONSTRAINT stock_entries_barcode_format_check
-- CHECK (barcode ~ '^\d{8}$');
