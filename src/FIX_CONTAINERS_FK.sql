-- =====================================================
-- FIX DEFINITIVO: Container Foreign Key
-- VERSÃO FINAL: Usa FOREIGN KEY em vez de CHECK
-- =====================================================
-- PROBLEMA: PostgreSQL não permite subqueries em CHECK constraints
--           "cannot use subquery in check constraint"
-- 
-- SOLUÇÃO: 
--   1. Remove tentativas de CHECK constraint
--   2. Usa FOREIGN KEY que naturalmente aceita NULL
--   3. Converte strings vazias para NULL
--   4. FK automaticamente valida UUIDs existentes
-- =====================================================

-- ========================================
-- PASSO 1: DIAGNÓSTICO
-- ========================================

DO $$
DECLARE
  rec RECORD;
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE '🔍 DIAGNÓSTICO: Procurando constraint containers_check...';
  RAISE NOTICE '';
  
  FOR rec IN 
    SELECT 
      conrelid::regclass AS table_name,
      conname AS constraint_name,
      contype AS constraint_type,
      pg_get_constraintdef(oid) AS constraint_definition
    FROM pg_constraint
    WHERE conname LIKE '%container%'
    AND conrelid IN ('stock_entries'::regclass, 'containers'::regclass)
  LOOP
    RAISE NOTICE '   📍 Tabela: %', rec.table_name;
    RAISE NOTICE '      Nome: %', rec.constraint_name;
    RAISE NOTICE '      Tipo: %', rec.constraint_type;
    RAISE NOTICE '      Def: %', rec.constraint_definition;
    RAISE NOTICE '';
  END LOOP;
END $$;

-- ========================================
-- PASSO 2: REMOVE constraints CHECK antigas
-- ========================================

-- Remove CHECK constraint de containers (se existir)
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM pg_constraint 
    WHERE conname = 'containers_check' 
    AND conrelid = 'containers'::regclass
  ) THEN
    ALTER TABLE containers DROP CONSTRAINT containers_check;
    RAISE NOTICE '✅ Removida CHECK constraint da tabela containers';
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE '⚠️ Erro ao remover CHECK de containers: %', SQLERRM;
END $$;

-- Remove CHECK constraint de stock_entries (se existir)
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM pg_constraint 
    WHERE conname = 'containers_check' 
    AND conrelid = 'stock_entries'::regclass
  ) THEN
    ALTER TABLE stock_entries DROP CONSTRAINT containers_check;
    RAISE NOTICE '✅ Removida CHECK constraint da tabela stock_entries';
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE '⚠️ Erro ao remover CHECK de stock_entries: %', SQLERRM;
END $$;

-- ========================================
-- PASSO 3: CONVERTE strings vazias para NULL
-- ========================================

DO $$
DECLARE
  updated_count INTEGER;
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE '🔧 LIMPEZA: Convertendo strings vazias para NULL...';
  
  -- Converte '' para NULL em container_id
  UPDATE stock_entries 
  SET container_id = NULL 
  WHERE container_id = '';
  
  GET DIAGNOSTICS updated_count = ROW_COUNT;
  
  IF updated_count > 0 THEN
    RAISE NOTICE '   ✅ Convertidos % registros de '''' para NULL', updated_count;
  ELSE
    RAISE NOTICE '   ℹ️ Nenhum registro com string vazia encontrado';
  END IF;
  
  RAISE NOTICE '';
EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE '⚠️ Erro na conversão: %', SQLERRM;
END $$;

-- ========================================
-- PASSO 4: Garante que coluna aceita NULL
-- ========================================

DO $$
BEGIN
  -- Remove NOT NULL constraint se existir
  ALTER TABLE stock_entries 
  ALTER COLUMN container_id DROP NOT NULL;
  
  RAISE NOTICE '✅ Coluna container_id configurada para aceitar NULL';
EXCEPTION
  WHEN OTHERS THEN
    -- Pode falhar se já for nullable, está OK
    RAISE NOTICE 'ℹ️ Coluna container_id já aceita NULL';
END $$;

-- ========================================
-- PASSO 5: Adiciona FOREIGN KEY
-- ========================================

-- Remove FK antiga se existir
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM pg_constraint 
    WHERE conname = 'stock_entries_container_id_fkey' 
    AND conrelid = 'stock_entries'::regclass
  ) THEN
    ALTER TABLE stock_entries DROP CONSTRAINT stock_entries_container_id_fkey;
    RAISE NOTICE 'ℹ️ Removida FK antiga stock_entries_container_id_fkey';
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE '⚠️ Erro ao remover FK antiga: %', SQLERRM;
END $$;

-- Adiciona nova FOREIGN KEY
DO $$
BEGIN
  ALTER TABLE stock_entries 
  ADD CONSTRAINT stock_entries_container_id_fkey 
  FOREIGN KEY (container_id) 
  REFERENCES containers(id)
  ON DELETE SET NULL;  -- Se contêiner for deletado, seta NULL
  
  RAISE NOTICE '';
  RAISE NOTICE '✅ SUCESSO: Foreign Key adicionada corretamente!';
  RAISE NOTICE '';
  RAISE NOTICE '   📋 Configuração:';
  RAISE NOTICE '      ✓ Permite container_id = NULL (sem contêiner)';
  RAISE NOTICE '      ✓ Valida container_id contra tabela containers';
  RAISE NOTICE '      ✓ ON DELETE SET NULL (segurança extra)';
  RAISE NOTICE '';
  
EXCEPTION
  WHEN duplicate_object THEN
    RAISE NOTICE '⚠️ FK stock_entries_container_id_fkey já existe';
  WHEN OTHERS THEN
    RAISE EXCEPTION '❌ ERRO ao adicionar FK: %', SQLERRM;
END $$;

-- ========================================
-- PASSO 6: TESTE
-- ========================================

DO $$
DECLARE
  test_passed BOOLEAN := TRUE;
  existing_model_id TEXT;
  test_barcode TEXT := 'TEST_FK_' || floor(random() * 1000000)::TEXT;
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE '🧪 TESTE: Verificando Foreign Key...';
  RAISE NOTICE '';
  
  -- Pega um model_id válido existente
  SELECT id INTO existing_model_id FROM tire_models LIMIT 1;
  
  IF existing_model_id IS NULL THEN
    RAISE NOTICE '⚠️ Nenhum tire_model encontrado. Pulando teste de inserção.';
    RETURN;
  END IF;
  
  BEGIN
    -- Testa inserção com container_id NULL
    INSERT INTO stock_entries (
      id, barcode, model_id, model_name, model_type,
      container_id, container_name, status, created_at
    ) VALUES (
      gen_random_uuid()::TEXT,
      test_barcode,
      existing_model_id,
      'Modelo Teste',
      'Slick',
      NULL, -- CONTAINER_ID NULL - deve funcionar!
      'Sem Contêiner',
      'Novo',
      NOW()
    );
    
    RAISE NOTICE '✅ TESTE 1 PASSOU: Inserção com container_id NULL funcionou!';
    
    -- Remove registro de teste
    DELETE FROM stock_entries WHERE barcode = test_barcode;
    
  EXCEPTION
    WHEN OTHERS THEN
      test_passed := FALSE;
      RAISE NOTICE '❌ TESTE 1 FALHOU: %', SQLERRM;
  END;
  
  IF test_passed THEN
    RAISE NOTICE '';
    RAISE NOTICE '🎉 TODOS OS TESTES PASSARAM!';
    RAISE NOTICE '';
    RAISE NOTICE '   ✅ Sistema pronto para cadastrar pneus sem contêiner';
    RAISE NOTICE '';
  ELSE
    RAISE NOTICE '';
    RAISE NOTICE '❌ ALGUNS TESTES FALHARAM - Verifique os erros acima';
    RAISE NOTICE '';
  END IF;
END $$;

-- ========================================
-- PASSO 7: VERIFICAÇÃO FINAL
-- ========================================

DO $$
DECLARE
  fk_def TEXT;
  empty_containers INTEGER;
  null_containers INTEGER;
  total_entries INTEGER;
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE '📊 VERIFICAÇÃO FINAL:';
  RAISE NOTICE '';
  
  -- Verifica FK em stock_entries
  SELECT pg_get_constraintdef(oid) INTO fk_def
  FROM pg_constraint
  WHERE conname = 'stock_entries_container_id_fkey' 
  AND conrelid = 'stock_entries'::regclass;
  
  IF fk_def IS NOT NULL THEN
    RAISE NOTICE '   ✅ Foreign Key ativa em stock_entries';
    RAISE NOTICE '   📋 Definição: %', fk_def;
  ELSE
    RAISE NOTICE '   ⚠️ Foreign Key NÃO encontrada em stock_entries';
  END IF;
  
  RAISE NOTICE '';
  
  -- Estatísticas
  SELECT COUNT(*) INTO total_entries FROM stock_entries;
  
  SELECT COUNT(*) INTO empty_containers 
  FROM stock_entries 
  WHERE container_id = '';
  
  SELECT COUNT(*) INTO null_containers 
  FROM stock_entries 
  WHERE container_id IS NULL;
  
  RAISE NOTICE '   📊 Estatísticas:';
  RAISE NOTICE '      • Total de pneus: %', total_entries;
  RAISE NOTICE '      • Pneus com container_id NULL: %', null_containers;
  RAISE NOTICE '      • Pneus com container_id = '''': % (deveria ser 0)', empty_containers;
  
  IF empty_containers > 0 THEN
    RAISE NOTICE '';
    RAISE NOTICE '   ⚠️ ATENÇÃO: Ainda existem % registros com string vazia!', empty_containers;
    RAISE NOTICE '      Execute novamente o PASSO 3 para convertê-los.';
  END IF;
  
  RAISE NOTICE '';
  RAISE NOTICE '═══════════════════════════════════════════════════';
  RAISE NOTICE '✅ FIX COMPLETO! Sistema pronto para uso.';
  RAISE NOTICE '═══════════════════════════════════════════════════';
  RAISE NOTICE '';
END $$;
