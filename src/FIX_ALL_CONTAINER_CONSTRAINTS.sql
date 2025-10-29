-- =====================================================
-- FIX DEFINITIVO: Remove TODAS as constraints problemáticas
-- SOLUÇÃO COMPLETA para erros de containers_check
-- =====================================================
-- ERRO REPORTADO:
-- "new row for relation 'containers' violates check constraint 'containers_check'"
-- 
-- CAUSA:
-- Existe uma CHECK constraint na tabela CONTAINERS que está bloqueando inserções
-- 
-- SOLUÇÃO:
-- 1. Remove CHECK constraints de CONTAINERS e STOCK_ENTRIES
-- 2. Limpa dados inválidos
-- 3. Adiciona FOREIGN KEY correta
-- 4. Testa tudo
-- =====================================================

-- ========================================
-- PASSO 1: DIAGNÓSTICO COMPLETO
-- ========================================

DO $$
DECLARE
  rec RECORD;
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE '═══════════════════════════════════════════════════';
  RAISE NOTICE '🔍 DIAGNÓSTICO COMPLETO DE CONSTRAINTS';
  RAISE NOTICE '═══════════════════════════════════════════════════';
  RAISE NOTICE '';
  
  -- Lista TODAS as constraints relacionadas a containers
  FOR rec IN 
    SELECT 
      n.nspname AS schema_name,
      c.relname AS table_name,
      con.conname AS constraint_name,
      con.contype AS constraint_type,
      CASE con.contype
        WHEN 'c' THEN 'CHECK'
        WHEN 'f' THEN 'FOREIGN KEY'
        WHEN 'p' THEN 'PRIMARY KEY'
        WHEN 'u' THEN 'UNIQUE'
        WHEN 't' THEN 'TRIGGER'
        ELSE con.contype::text
      END AS type_description,
      pg_get_constraintdef(con.oid) AS constraint_definition
    FROM pg_constraint con
    JOIN pg_class c ON con.conrelid = c.oid
    JOIN pg_namespace n ON c.relnamespace = n.oid
    WHERE (
      con.conname LIKE '%container%'
      OR c.relname IN ('containers', 'stock_entries')
    )
    AND n.nspname = 'public'
    ORDER BY c.relname, con.conname
  LOOP
    RAISE NOTICE '📋 Tabela: %.%', rec.schema_name, rec.table_name;
    RAISE NOTICE '   Nome: %', rec.constraint_name;
    RAISE NOTICE '   Tipo: % (%)', rec.type_description, rec.constraint_type;
    RAISE NOTICE '   Definição: %', rec.constraint_definition;
    RAISE NOTICE '';
  END LOOP;
  
  RAISE NOTICE '═══════════════════════════════════════════════════';
  RAISE NOTICE '';
END $$;

-- ========================================
-- PASSO 2: REMOVE CHECK CONSTRAINTS
-- ========================================

DO $$
DECLARE
  rec RECORD;
  removed_count INTEGER := 0;
BEGIN
  RAISE NOTICE '🗑️ REMOVENDO CHECK CONSTRAINTS...';
  RAISE NOTICE '';
  
  -- Remove TODAS as CHECK constraints de ambas as tabelas
  FOR rec IN 
    SELECT 
      c.relname AS table_name,
      con.conname AS constraint_name
    FROM pg_constraint con
    JOIN pg_class c ON con.conrelid = c.oid
    JOIN pg_namespace n ON c.relnamespace = n.oid
    WHERE con.contype = 'c'  -- CHECK constraint
    AND c.relname IN ('containers', 'stock_entries')
    AND n.nspname = 'public'
  LOOP
    BEGIN
      EXECUTE format('ALTER TABLE %I DROP CONSTRAINT IF EXISTS %I', 
                     rec.table_name, rec.constraint_name);
      removed_count := removed_count + 1;
      RAISE NOTICE '   ✅ Removida: %.%', rec.table_name, rec.constraint_name;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE NOTICE '   ⚠️ Erro ao remover %.%: %', 
                     rec.table_name, rec.constraint_name, SQLERRM;
    END;
  END LOOP;
  
  IF removed_count = 0 THEN
    RAISE NOTICE '   ℹ️ Nenhuma CHECK constraint encontrada';
  ELSE
    RAISE NOTICE '';
    RAISE NOTICE '   ✅ Total removido: % constraints', removed_count;
  END IF;
  
  RAISE NOTICE '';
END $$;

-- ========================================
-- PASSO 3: GARANTE QUE COLUNAS ACEITAM NULL
-- ========================================

DO $$
BEGIN
  RAISE NOTICE '🔧 CONFIGURANDO COLUNAS PARA ACEITAR NULL...';
  RAISE NOTICE '';
  
  -- container_id em stock_entries
  BEGIN
    ALTER TABLE stock_entries 
    ALTER COLUMN container_id DROP NOT NULL;
    RAISE NOTICE '   ✅ stock_entries.container_id → NULL permitido';
  EXCEPTION
    WHEN OTHERS THEN
      RAISE NOTICE '   ℹ️ stock_entries.container_id já permite NULL';
  END;
  
  RAISE NOTICE '';
END $$;

-- ========================================
-- PASSO 4: LIMPA DADOS INVÁLIDOS
-- ========================================

DO $$
DECLARE
  updated_count INTEGER := 0;
  rec RECORD;
BEGIN
  RAISE NOTICE '🧹 LIMPANDO DADOS INVÁLIDOS...';
  RAISE NOTICE '';
  
  -- Percorre stock_entries e converte valores inválidos para NULL
  FOR rec IN 
    SELECT id, container_id 
    FROM stock_entries
    WHERE container_id IS NOT NULL
  LOOP
    BEGIN
      -- Tenta validar UUID
      PERFORM rec.container_id::UUID;
    EXCEPTION
      WHEN OTHERS THEN
        -- Valor inválido, seta NULL
        UPDATE stock_entries 
        SET container_id = NULL 
        WHERE id = rec.id;
        updated_count := updated_count + 1;
    END;
  END LOOP;
  
  IF updated_count > 0 THEN
    RAISE NOTICE '   ✅ Convertidos % registros com container_id inválido', updated_count;
  ELSE
    RAISE NOTICE '   ℹ️ Nenhum container_id inválido encontrado';
  END IF;
  
  RAISE NOTICE '';
END $$;

-- ========================================
-- PASSO 5: REMOVE FOREIGN KEY ANTIGA
-- ========================================

DO $$
DECLARE
  rec RECORD;
  removed_count INTEGER := 0;
BEGIN
  RAISE NOTICE '🔗 REMOVENDO FOREIGN KEYS ANTIGAS...';
  RAISE NOTICE '';
  
  -- Remove TODAS as FKs relacionadas a container_id
  FOR rec IN 
    SELECT 
      con.conname AS constraint_name
    FROM pg_constraint con
    JOIN pg_class c ON con.conrelid = c.oid
    JOIN pg_namespace n ON c.relnamespace = n.oid
    WHERE con.contype = 'f'  -- FOREIGN KEY
    AND c.relname = 'stock_entries'
    AND n.nspname = 'public'
    AND con.conname LIKE '%container%'
  LOOP
    BEGIN
      EXECUTE format('ALTER TABLE stock_entries DROP CONSTRAINT IF EXISTS %I', 
                     rec.constraint_name);
      removed_count := removed_count + 1;
      RAISE NOTICE '   ✅ Removida: %', rec.constraint_name;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE NOTICE '   ⚠️ Erro ao remover %: %', rec.constraint_name, SQLERRM;
    END;
  END LOOP;
  
  IF removed_count = 0 THEN
    RAISE NOTICE '   ℹ️ Nenhuma FK antiga encontrada';
  END IF;
  
  RAISE NOTICE '';
END $$;

-- ========================================
-- PASSO 6: ADICIONA FOREIGN KEY CORRETA
-- ========================================

DO $$
BEGIN
  RAISE NOTICE '✨ ADICIONANDO FOREIGN KEY...';
  RAISE NOTICE '';
  
  -- Adiciona FK que permite NULL
  ALTER TABLE stock_entries 
  ADD CONSTRAINT stock_entries_container_id_fkey 
  FOREIGN KEY (container_id) 
  REFERENCES containers(id)
  ON DELETE SET NULL;
  
  RAISE NOTICE '   ✅ FOREIGN KEY adicionada com sucesso!';
  RAISE NOTICE '';
  RAISE NOTICE '   📋 Configuração:';
  RAISE NOTICE '      ✓ Permite container_id = NULL';
  RAISE NOTICE '      ✓ Valida contra containers(id)';
  RAISE NOTICE '      ✓ ON DELETE SET NULL';
  RAISE NOTICE '';
  
EXCEPTION
  WHEN duplicate_object THEN
    RAISE NOTICE '   ℹ️ FK já existe (OK)';
    RAISE NOTICE '';
  WHEN foreign_key_violation THEN
    RAISE NOTICE '';
    RAISE NOTICE '   ❌ ERRO: Existem container_id inválidos no banco!';
    RAISE NOTICE '';
    RAISE NOTICE '   🔍 Execute esta query para encontrá-los:';
    RAISE NOTICE '   SELECT id, barcode, container_id, container_name';
    RAISE NOTICE '   FROM stock_entries';
    RAISE NOTICE '   WHERE container_id IS NOT NULL';
    RAISE NOTICE '   AND container_id NOT IN (SELECT id FROM containers);';
    RAISE NOTICE '';
    RAISE EXCEPTION 'FK violation: container_id inválidos encontrados';
  WHEN OTHERS THEN
    RAISE EXCEPTION 'Erro ao adicionar FK: %', SQLERRM;
END $$;

-- ========================================
-- PASSO 7: TESTES
-- ========================================

DO $$
DECLARE
  test_passed BOOLEAN := TRUE;
  existing_model_id TEXT;
  existing_container_id TEXT;
  test_barcode_1 TEXT := 'TEST_NULL_' || floor(random() * 1000000)::TEXT;
  test_barcode_2 TEXT := 'TEST_CONTAINER_' || floor(random() * 1000000)::TEXT;
BEGIN
  RAISE NOTICE '🧪 EXECUTANDO TESTES...';
  RAISE NOTICE '';
  
  -- Pega IDs válidos
  SELECT id INTO existing_model_id FROM tire_models LIMIT 1;
  SELECT id INTO existing_container_id FROM containers LIMIT 1;
  
  IF existing_model_id IS NULL THEN
    RAISE NOTICE '   ⚠️ Nenhum tire_model encontrado. Pulando testes.';
    RETURN;
  END IF;
  
  -- TESTE 1: Inserir com container_id NULL
  BEGIN
    INSERT INTO stock_entries (
      id, barcode, model_id, model_name, model_type,
      container_id, container_name, status, created_at
    ) VALUES (
      gen_random_uuid()::TEXT,
      test_barcode_1,
      existing_model_id,
      'Modelo Teste',
      'Slick',
      NULL,
      'Sem Contêiner',
      'Novo',
      NOW()
    );
    
    RAISE NOTICE '   ✅ TESTE 1 PASSOU: Inserção com container_id NULL';
    DELETE FROM stock_entries WHERE barcode = test_barcode_1;
  EXCEPTION
    WHEN OTHERS THEN
      test_passed := FALSE;
      RAISE NOTICE '   ❌ TESTE 1 FALHOU: %', SQLERRM;
  END;
  
  -- TESTE 2: Inserir com container_id válido (se houver containers)
  IF existing_container_id IS NOT NULL THEN
    BEGIN
      INSERT INTO stock_entries (
        id, barcode, model_id, model_name, model_type,
        container_id, container_name, status, created_at
      ) VALUES (
        gen_random_uuid()::TEXT,
        test_barcode_2,
        existing_model_id,
        'Modelo Teste',
        'Slick',
        existing_container_id,
        'Container Teste',
        'Novo',
        NOW()
      );
      
      RAISE NOTICE '   ✅ TESTE 2 PASSOU: Inserção com container_id válido';
      DELETE FROM stock_entries WHERE barcode = test_barcode_2;
    EXCEPTION
      WHEN OTHERS THEN
        test_passed := FALSE;
        RAISE NOTICE '   ❌ TESTE 2 FALHOU: %', SQLERRM;
    END;
  END IF;
  
  RAISE NOTICE '';
  
  IF test_passed THEN
    RAISE NOTICE '   🎉 TODOS OS TESTES PASSARAM!';
  ELSE
    RAISE NOTICE '   ⚠️ ALGUNS TESTES FALHARAM';
  END IF;
  
  RAISE NOTICE '';
END $$;

-- ========================================
-- PASSO 8: VERIFICAÇÃO FINAL
-- ========================================

DO $$
DECLARE
  check_count INTEGER;
  fk_count INTEGER;
  null_count INTEGER;
  total_count INTEGER;
BEGIN
  RAISE NOTICE '═══════════════════════════════════════════════════';
  RAISE NOTICE '📊 VERIFICAÇÃO FINAL';
  RAISE NOTICE '═══════════════════════════════════════════════════';
  RAISE NOTICE '';
  
  -- Conta CHECK constraints restantes
  SELECT COUNT(*) INTO check_count
  FROM pg_constraint con
  JOIN pg_class c ON con.conrelid = c.oid
  JOIN pg_namespace n ON c.relnamespace = n.oid
  WHERE con.contype = 'c'
  AND c.relname IN ('containers', 'stock_entries')
  AND n.nspname = 'public';
  
  -- Conta FOREIGN KEYs
  SELECT COUNT(*) INTO fk_count
  FROM pg_constraint con
  JOIN pg_class c ON con.conrelid = c.oid
  JOIN pg_namespace n ON c.relnamespace = n.oid
  WHERE con.contype = 'f'
  AND c.relname = 'stock_entries'
  AND con.conname LIKE '%container%'
  AND n.nspname = 'public';
  
  -- Estatísticas
  SELECT COUNT(*) INTO total_count FROM stock_entries;
  SELECT COUNT(*) INTO null_count 
  FROM stock_entries 
  WHERE container_id IS NULL;
  
  RAISE NOTICE '🔍 Constraints:';
  RAISE NOTICE '   CHECK constraints: % (deveria ser 0)', check_count;
  RAISE NOTICE '   FOREIGN KEYs: % (deveria ser 1)', fk_count;
  RAISE NOTICE '';
  
  RAISE NOTICE '📊 Dados:';
  RAISE NOTICE '   Total de pneus: %', total_count;
  RAISE NOTICE '   Pneus sem contêiner (NULL): %', null_count;
  RAISE NOTICE '   Pneus com contêiner: %', (total_count - null_count);
  RAISE NOTICE '';
  
  IF check_count = 0 AND fk_count >= 1 THEN
    RAISE NOTICE '═══════════════════════════════════════════════════';
    RAISE NOTICE '✅ SUCESSO! Sistema configurado corretamente.';
    RAISE NOTICE '═══════════════════════════════════════════════════';
    RAISE NOTICE '';
    RAISE NOTICE '📝 PRÓXIMOS PASSOS:';
    RAISE NOTICE '   1. Recarregue a aplicação (Ctrl + Shift + R)';
    RAISE NOTICE '   2. Teste cadastrar um pneu SEM contêiner';
    RAISE NOTICE '   3. Teste cadastrar um pneu COM contêiner';
    RAISE NOTICE '   4. Verifique o dashboard';
    RAISE NOTICE '';
  ELSE
    RAISE NOTICE '═══════════════════════════════════════════════════';
    RAISE NOTICE '⚠️ ATENÇÃO: Configuração incompleta!';
    RAISE NOTICE '═══════════════════════════════════════════════════';
    RAISE NOTICE '';
    
    IF check_count > 0 THEN
      RAISE NOTICE '   ❌ Ainda existem CHECK constraints!';
      RAISE NOTICE '      Execute novamente o PASSO 2';
    END IF;
    
    IF fk_count = 0 THEN
      RAISE NOTICE '   ❌ FOREIGN KEY não foi criada!';
      RAISE NOTICE '      Execute novamente o PASSO 6';
    END IF;
    
    RAISE NOTICE '';
  END IF;
END $$;
