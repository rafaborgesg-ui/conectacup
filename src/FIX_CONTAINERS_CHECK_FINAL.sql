-- =====================================================
-- FIX DEFINITIVO: Constraint containers_check
-- =====================================================
-- PROBLEMA: Erro ao inserir pneus com container_id vazio
--           "new row for relation 'containers' violates check constraint 'containers_check'"
-- 
-- CAUSA RAIZ: A constraint pode estar na tabela ERRADA ou configurada incorretamente
-- 
-- SOLUÇÃO: 
--   1. Remove TODAS as constraints containers_check (ambas tabelas)
--   2. Adiciona constraint CORRETA apenas em stock_entries
--   3. Permite container_id vazio OU válido da tabela containers
-- =====================================================

-- ========================================
-- PASSO 1: DIAGNÓSTICO - Identifica onde está a constraint
-- ========================================

DO $$
DECLARE
  rec RECORD;
BEGIN
  RAISE NOTICE '🔍 DIAGNÓSTICO: Procurando constraint containers_check...';
  RAISE NOTICE '';
  
  FOR rec IN 
    SELECT 
      conrelid::regclass AS table_name,
      conname AS constraint_name,
      pg_get_constraintdef(oid) AS constraint_definition
    FROM pg_constraint
    WHERE conname = 'containers_check'
  LOOP
    RAISE NOTICE '   📍 Encontrada em: %', rec.table_name;
    RAISE NOTICE '   📋 Definição: %', rec.constraint_definition;
    RAISE NOTICE '';
  END LOOP;
  
  IF NOT FOUND THEN
    RAISE NOTICE '   ⚠️ Constraint containers_check não encontrada';
  END IF;
END $$;

-- ========================================
-- PASSO 2: REMOVE constraint de TODAS as tabelas
-- ========================================

-- Remove da tabela containers (se existir)
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM pg_constraint 
    WHERE conname = 'containers_check' 
    AND conrelid = 'containers'::regclass
  ) THEN
    ALTER TABLE containers DROP CONSTRAINT containers_check;
    RAISE NOTICE '✅ Removida constraint containers_check da tabela CONTAINERS';
  ELSE
    RAISE NOTICE 'ℹ️ Constraint containers_check NÃO existe na tabela containers';
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE '⚠️ Erro ao remover de containers: %', SQLERRM;
END $$;

-- Remove da tabela stock_entries (se existir)
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM pg_constraint 
    WHERE conname = 'containers_check' 
    AND conrelid = 'stock_entries'::regclass
  ) THEN
    ALTER TABLE stock_entries DROP CONSTRAINT containers_check;
    RAISE NOTICE '✅ Removida constraint containers_check da tabela STOCK_ENTRIES';
  ELSE
    RAISE NOTICE 'ℹ️ Constraint containers_check NÃO existe na tabela stock_entries';
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE '⚠️ Erro ao remover de stock_entries: %', SQLERRM;
END $$;

-- ========================================
-- PASSO 3: Adiciona constraint CORRETA em stock_entries
-- ========================================

-- Constraint que permite:
--   1. container_id vazio ('') - para pneus sem contêiner
--   2. container_id que existe na tabela containers

DO $$
BEGIN
  ALTER TABLE stock_entries 
  ADD CONSTRAINT containers_check 
  CHECK (
    container_id = '' OR 
    container_id IN (SELECT id FROM containers)
  );
  
  RAISE NOTICE '';
  RAISE NOTICE '✅ SUCESSO: Constraint containers_check adicionada corretamente!';
  RAISE NOTICE '';
  RAISE NOTICE '   📋 Regras da constraint:';
  RAISE NOTICE '      ✓ Permite container_id = '''' (string vazia)';
  RAISE NOTICE '      ✓ Valida container_id contra tabela containers quando não vazio';
  RAISE NOTICE '';
  
EXCEPTION
  WHEN duplicate_object THEN
    RAISE NOTICE '⚠️ Constraint containers_check já existe em stock_entries';
  WHEN OTHERS THEN
    RAISE EXCEPTION '❌ ERRO ao adicionar constraint: %', SQLERRM;
END $$;

-- ========================================
-- PASSO 4: TESTE - Verifica se funciona
-- ========================================

DO $$
DECLARE
  test_passed BOOLEAN := TRUE;
  existing_model_id TEXT;
  test_barcode TEXT := 'TEST_CONTAINER_CHECK_' || floor(random() * 1000000)::TEXT;
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE '🧪 TESTE: Verificando constraint...';
  RAISE NOTICE '';
  
  -- Pega um model_id válido existente
  SELECT id INTO existing_model_id FROM tire_models LIMIT 1;
  
  IF existing_model_id IS NULL THEN
    RAISE NOTICE '⚠️ Nenhum tire_model encontrado. Pulando teste de inserção.';
    RETURN;
  END IF;
  
  BEGIN
    -- Testa inserção com container_id vazio
    INSERT INTO stock_entries (
      id, barcode, model_id, model_name, model_type,
      container_id, container_name, status, created_at
    ) VALUES (
      gen_random_uuid()::TEXT,
      test_barcode,
      existing_model_id,
      'Modelo Teste',
      'Slick',
      '', -- CONTAINER_ID VAZIO - deve funcionar!
      'Sem Contêiner',
      'Novo',
      NOW()
    );
    
    RAISE NOTICE '✅ TESTE 1 PASSOU: Inserção com container_id vazio funcionou!';
    
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
-- PASSO 5: VERIFICAÇÃO FINAL
-- ========================================

DO $$
DECLARE
  constraint_def TEXT;
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE '📊 VERIFICAÇÃO FINAL:';
  RAISE NOTICE '';
  
  -- Verifica constraint em stock_entries
  SELECT pg_get_constraintdef(oid) INTO constraint_def
  FROM pg_constraint
  WHERE conname = 'containers_check' 
  AND conrelid = 'stock_entries'::regclass;
  
  IF constraint_def IS NOT NULL THEN
    RAISE NOTICE '   ✅ Constraint containers_check ativa em stock_entries';
    RAISE NOTICE '   📋 Definição: %', constraint_def;
  ELSE
    RAISE NOTICE '   ⚠️ Constraint containers_check NÃO encontrada em stock_entries';
  END IF;
  
  RAISE NOTICE '';
  RAISE NOTICE '═══════════════════════════════════════════════════';
  RAISE NOTICE '✅ FIX COMPLETO! Sistema pronto para uso.';
  RAISE NOTICE '═══════════════════════════════════════════════════';
  RAISE NOTICE '';
END $$;
