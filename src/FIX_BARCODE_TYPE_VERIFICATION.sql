-- =====================================================
-- VERIFICAÇÃO E CORREÇÃO DO TIPO DA COLUNA BARCODE
-- Garante que barcode é TEXT, não UUID
-- =====================================================

-- IMPORTANTE: Execute este SQL no Supabase SQL Editor
-- Link: https://supabase.com/dashboard/project/nflgqugaabtxzifyhjor/sql

BEGIN;

-- =====================================================
-- 1. VERIFICAR TIPO ATUAL DA COLUNA BARCODE
-- =====================================================

SELECT 
  column_name,
  data_type,
  character_maximum_length,
  is_nullable,
  column_default
FROM information_schema.columns
WHERE table_name = 'stock_entries' 
  AND column_name IN ('id', 'barcode');

-- Resultado esperado:
-- column_name | data_type              | character_maximum_length | is_nullable | column_default
-- id          | uuid                   | NULL                     | NO          | gen_random_uuid()
-- barcode     | text (ou character varying) | NULL (ou número)  | NO          | NULL

-- =====================================================
-- 2. SE BARCODE ESTIVER COMO UUID - CORRIGIR
-- =====================================================

-- ATENÇÃO: Só execute isso se a coluna barcode estiver como UUID
-- Verifique o resultado da query acima PRIMEIRO!

/*
-- Passo 1: Remove constraints e índices
ALTER TABLE stock_entries DROP CONSTRAINT IF EXISTS stock_entries_barcode_key CASCADE;
DROP INDEX IF EXISTS idx_stock_entries_barcode CASCADE;

-- Passo 2: Altera tipo da coluna de UUID para TEXT
ALTER TABLE stock_entries 
  ALTER COLUMN barcode TYPE TEXT USING barcode::TEXT;

-- Passo 3: Adiciona constraint de formato (8 dígitos numéricos)
ALTER TABLE stock_entries
  ADD CONSTRAINT barcode_format_check 
  CHECK (barcode ~ '^\d{8}$');

-- Passo 4: Recria índice único
CREATE UNIQUE INDEX idx_stock_entries_barcode 
  ON stock_entries(barcode);

-- Passo 5: Adiciona constraint UNIQUE
ALTER TABLE stock_entries
  ADD CONSTRAINT stock_entries_barcode_key UNIQUE USING INDEX idx_stock_entries_barcode;

COMMIT;

SELECT 'Coluna barcode corrigida de UUID para TEXT' AS resultado;
*/

-- =====================================================
-- 3. SE BARCODE JÁ ESTIVER COMO TEXT - ADICIONAR CONSTRAINT
-- =====================================================

-- Garante que barcode tem formato correto (8 dígitos numéricos)
DO $$
BEGIN
  -- Remove constraint antiga se existir
  ALTER TABLE stock_entries DROP CONSTRAINT IF EXISTS barcode_format_check;
  
  -- Adiciona nova constraint
  ALTER TABLE stock_entries
    ADD CONSTRAINT barcode_format_check 
    CHECK (barcode ~ '^\d{8}$');
    
  RAISE NOTICE 'Constraint de formato adicionada';
EXCEPTION
  WHEN duplicate_object THEN
    RAISE NOTICE 'Constraint já existe';
END $$;

-- =====================================================
-- 4. VERIFICAR DADOS INVÁLIDOS
-- =====================================================

-- Verifica se há barcodes que NÃO têm 8 dígitos numéricos
SELECT 
  barcode,
  length(barcode) as tamanho,
  CASE 
    WHEN barcode ~ '^\d{8}$' THEN 'VÁLIDO'
    ELSE 'INVÁLIDO'
  END as status
FROM stock_entries
WHERE NOT (barcode ~ '^\d{8}$')
LIMIT 10;

-- Se esta query retornar linhas, há dados inválidos que precisam ser corrigidos

-- =====================================================
-- 5. VERIFICAR ESTRUTURA FINAL
-- =====================================================

SELECT 
  column_name,
  data_type,
  character_maximum_length,
  is_nullable,
  column_default
FROM information_schema.columns
WHERE table_name = 'stock_entries' 
  AND column_name IN ('id', 'barcode')
ORDER BY ordinal_position;

-- =====================================================
-- 6. VERIFICAR CONSTRAINTS
-- =====================================================

SELECT 
  conname AS constraint_name,
  contype AS constraint_type,
  pg_get_constraintdef(c.oid) AS constraint_definition
FROM pg_constraint c
JOIN pg_namespace n ON n.oid = c.connamespace
WHERE conrelid = 'stock_entries'::regclass
  AND conname LIKE '%barcode%';

-- =====================================================
-- 7. TESTAR OPERAÇÕES
-- =====================================================

-- Teste 1: INSERT com barcode válido (deve funcionar)
DO $$
DECLARE
  test_barcode TEXT := '99999999';
BEGIN
  -- Limpa teste anterior
  DELETE FROM stock_entries WHERE barcode = test_barcode;
  
  -- Insere teste
  INSERT INTO stock_entries (
    barcode, 
    model_id, 
    model_name, 
    model_type, 
    container_id, 
    container_name, 
    status
  ) VALUES (
    test_barcode,
    'model-test',
    'Modelo Teste',
    'Slick',
    'container-test',
    'Container Teste',
    'Novo'
  );
  
  RAISE NOTICE 'INSERT com barcode TEXT funcionou';
  
  -- Limpa
  DELETE FROM stock_entries WHERE barcode = test_barcode;
END $$;

-- Teste 2: DELETE com barcode TEXT (deve funcionar)
DO $$
DECLARE
  test_barcode TEXT := '88888888';
BEGIN
  -- Insere teste
  INSERT INTO stock_entries (
    barcode, 
    model_id, 
    model_name, 
    model_type, 
    container_id, 
    container_name, 
    status
  ) VALUES (
    test_barcode,
    'model-test',
    'Modelo Teste',
    'Slick',
    'container-test',
    'Container Teste',
    'Novo'
  );
  
  -- Deleta usando TEXT explícito
  DELETE FROM stock_entries WHERE barcode = test_barcode::TEXT;
  
  RAISE NOTICE 'DELETE com barcode TEXT funcionou';
END $$;

-- Teste 3: UPDATE com barcode TEXT (deve funcionar)
DO $$
DECLARE
  test_barcode TEXT := '77777777';
BEGIN
  -- Insere teste
  INSERT INTO stock_entries (
    barcode, 
    model_id, 
    model_name, 
    model_type, 
    container_id, 
    container_name, 
    status
  ) VALUES (
    test_barcode,
    'model-test',
    'Modelo Teste',
    'Slick',
    'container-test',
    'Container Teste',
    'Novo'
  );
  
  -- Atualiza usando TEXT explícito
  UPDATE stock_entries 
  SET status = 'Pneu CUP'
  WHERE barcode = test_barcode::TEXT;
  
  RAISE NOTICE 'UPDATE com barcode TEXT funcionou';
  
  -- Limpa
  DELETE FROM stock_entries WHERE barcode = test_barcode;
END $$;

COMMIT;

-- =====================================================
-- ✅ VERIFICAÇÕES FINAIS
-- =====================================================

-- Se todos os testes acima passarem, você verá:
-- NOTICE: Constraint de formato adicionada (ou já existe)
-- NOTICE: INSERT com barcode TEXT funcionou
-- NOTICE: DELETE com barcode TEXT funcionou
-- NOTICE: UPDATE com barcode TEXT funcionou

-- =====================================================
-- 📋 RESULTADO ESPERADO
-- =====================================================

/*
A coluna barcode DEVE ser:
- Tipo: text (ou character varying)
- Tamanho: Sem limite (ou suficiente para 8 dígitos)
- Nullable: NO
- Unique: YES
- Constraint: CHECK (barcode ~ '^\d{8}$')

A coluna id DEVE ser:
- Tipo: uuid
- Nullable: NO
- Default: gen_random_uuid()
- Primary Key: YES
*/

-- =====================================================
-- 🔧 TROUBLESHOOTING
-- =====================================================

/*
Se ainda houver erros de "invalid input syntax for type uuid":

1. Verifique políticas RLS:
   SELECT * FROM pg_policies WHERE tablename = 'stock_entries';

2. Verifique triggers:
   SELECT * FROM pg_trigger WHERE tgrelid = 'stock_entries'::regclass;

3. Verifique funções customizadas:
   SELECT routine_name, routine_definition
   FROM information_schema.routines
   WHERE routine_schema = 'public'
   AND routine_definition LIKE '%stock_entries%';

4. Verifique views:
   SELECT table_name, view_definition
   FROM information_schema.views
   WHERE table_schema = 'public'
   AND view_definition LIKE '%stock_entries%';
*/

-- =====================================================
-- 🎯 SOLUÇÃO ALTERNATIVA SE NADA FUNCIONAR
-- =====================================================

/*
Se o problema persistir, pode ser necessário recriar a tabela:

1. Backup dos dados:
   CREATE TABLE stock_entries_backup AS SELECT * FROM stock_entries;

2. Drop da tabela:
   DROP TABLE stock_entries CASCADE;

3. Recriar usando SETUP_STOCK_ENTRIES_TABLE.sql

4. Restaurar dados:
   INSERT INTO stock_entries SELECT * FROM stock_entries_backup;

5. Limpar backup:
   DROP TABLE stock_entries_backup;
*/

SELECT 'Verificação concluída. Revise os resultados acima.' AS status;
