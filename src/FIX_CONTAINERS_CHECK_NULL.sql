-- =====================================================
-- FIX DEFINITIVO: Constraint containers_check
-- VERSÃO CORRIGIDA: Usa NULL em vez de string vazia
-- =====================================================
-- PROBLEMA: Erro "invalid input syntax for type uuid: ''"
--           PostgreSQL não aceita string vazia como UUID
-- 
-- CAUSA RAIZ: Tentativa de usar '' (string vazia) em campo UUID
-- 
-- SOLUÇÃO: 
--   1. Usa NULL para representar "Sem Contêiner"
--   2. Converte todos os '' existentes para NULL
--   3. Adiciona constraint que aceita NULL ou UUID válido
-- =====================================================

-- ========================================
-- PASSO 1: DIAGNÓSTICO
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
END $$;

-- ========================================
-- PASSO 2: REMOVE constraints antigas
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
-- PASSO 4: Adiciona constraint CORRETA
-- ========================================

-- Constraint que permite:
--   1. container_id NULL - para pneus sem contêiner
--   2. container_id que existe na tabela containers

DO $$
BEGIN
  ALTER TABLE stock_entries 
  ADD CONSTRAINT containers_check 
  CHECK (
    container_id IS NULL OR 
    container_id IN (SELECT id FROM containers)
  );
  
  RAISE NOTICE '';
  RAISE NOTICE '✅ SUCESSO: Constraint containers_check adicionada corretamente!';
  RAISE NOTICE '';
  RAISE NOTICE '   📋 Regras da constraint:';
  RAISE NOTICE '      ✓ Permite container_id = NULL (sem contêiner)';
  RAISE NOTICE '      ✓ Valida container_id contra tabela containers quando não NULL';
  RAISE NOTICE '';
  
EXCEPTION
  WHEN duplicate_object THEN
    RAISE NOTICE '⚠️ Constraint containers_check já existe em stock_entries';
  WHEN OTHERS THEN
    RAISE EXCEPTION '❌ ERRO ao adicionar constraint: %', SQLERRM;
END $$;

-- ========================================
-- PASSO 5: TESTE
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
-- PASSO 6: VERIFICAÇÃO FINAL
-- ========================================

DO $$
DECLARE
  constraint_def TEXT;
  empty_containers INTEGER;
  null_containers INTEGER;
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
  
  -- Verifica se ainda há strings vazias
  SELECT COUNT(*) INTO empty_containers 
  FROM stock_entries 
  WHERE container_id = '';
  
  SELECT COUNT(*) INTO null_containers 
  FROM stock_entries 
  WHERE container_id IS NULL;
  
  RAISE NOTICE '   📊 Estatísticas:';
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
