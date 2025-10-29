-- ═══════════════════════════════════════════════════════════════
-- 🚨 FIX: Registros inválidos na tabela access_profiles
-- ═══════════════════════════════════════════════════════════════
-- 
-- PROBLEMA: 2 registros inválidos (timestamps) na tabela
-- - stock_entries_backup_completed
-- - stock_entries_backup_date
-- 
-- CAUSA: Inserção incorreta de dados de backup na tabela errada
-- ═══════════════════════════════════════════════════════════════

-- PASSO 1: Verificar registros inválidos
-- ────────────────────────────────────────────────────────────────

SELECT 
  id,
  name,
  description,
  pages,
  features,
  is_system,
  is_default,
  created_at
FROM access_profiles
ORDER BY id;

-- Identificar quais são inválidos (não têm campos obrigatórios)
SELECT 
  id,
  name,
  CASE 
    WHEN name IS NULL THEN '❌ SEM NOME'
    WHEN pages IS NULL THEN '❌ SEM PÁGINAS'
    WHEN features IS NULL THEN '❌ SEM FEATURES'
    WHEN id LIKE 'stock_entries_%' THEN '❌ ID INVÁLIDO (backup)'
    ELSE '✅ OK'
  END as status
FROM access_profiles
ORDER BY id;

-- ═══════════════════════════════════════════════════════════════

-- PASSO 2: DELETAR registros inválidos
-- ────────────────────────────────────────────────────────────────

-- Deletar registros de backup que foram inseridos na tabela errada
DELETE FROM access_profiles
WHERE id IN (
  'stock_entries_backup_completed',
  'stock_entries_backup_date'
);

-- Resultado esperado: "2 rows deleted" ou "Success. 2 rows deleted"

-- ═══════════════════════════════════════════════════════════════

-- PASSO 3: Verificar se há outros registros inválidos
-- ────────────────────────────────────────────────────────────────

-- Procurar registros sem name, pages ou features
SELECT 
  id,
  name,
  is_system,
  is_default
FROM access_profiles
WHERE name IS NULL 
   OR pages IS NULL 
   OR features IS NULL
   OR id NOT IN ('admin', 'operator', 'supervisor', 'viewer')
   AND is_system = false
   AND name IS NULL;

-- Se retornar algo, executar:
-- DELETE FROM access_profiles WHERE name IS NULL OR pages IS NULL OR features IS NULL;

-- ═══════════════════════════════════════════════════════════════

-- PASSO 4: Verificar perfis válidos restantes
-- ────────────────────────────────────────────────────────────────

SELECT 
  id,
  name,
  is_system,
  is_default,
  jsonb_array_length(pages) as num_pages,
  jsonb_array_length(features) as num_features,
  created_at
FROM access_profiles
ORDER BY is_system DESC, name;

-- Resultado esperado:
-- ┌──────────────┬───────────────┬───────────┬────────────┬───────────┬──────────────┐
-- │ id           │ name          │ is_system │ is_default │ num_pages │ num_features │
-- ├──────────────┼───────────────┼───────────┼────────────┼───────────┼──────────────┤
-- │ admin        │ Administrador │ TRUE      │ TRUE       │ 14        │ 28           │
-- │ operator     │ Operador      │ TRUE      │ FALSE      │ 10        │ 15           │
-- │ supervisor   │ Supervisor    │ TRUE      │ FALSE      │ 12        │ 20           │
-- │ viewer       │ Visualizador  │ TRUE      │ FALSE      │ 5         │ 5            │
-- └──────────────┴───────────────┴───────────┴────────────┴───────────┴──────────────┘

-- ═══════════════════════════════════════════════════════════════

-- PASSO 5: Adicionar constraint para prevenir inserções inválidas
-- ────────────────────────────────────────────────────────────────

-- Garantir que campos obrigatórios não sejam NULL
ALTER TABLE access_profiles
  ALTER COLUMN name SET NOT NULL,
  ALTER COLUMN pages SET NOT NULL,
  ALTER COLUMN features SET NOT NULL;

-- Adicionar check constraint para validar estrutura dos JSONBs
ALTER TABLE access_profiles
  ADD CONSTRAINT check_pages_is_array 
    CHECK (jsonb_typeof(pages) = 'array');

ALTER TABLE access_profiles
  ADD CONSTRAINT check_features_is_array 
    CHECK (jsonb_typeof(features) = 'array');

-- ═══════════════════════════════════════════════════════════════

-- PASSO 6: Verificar usuários afetados
-- ────────────────────────────────────────────────────────────────

-- Ver se algum usuário está usando perfis inválidos
SELECT 
  u.email,
  u.raw_user_meta_data->>'profileId' as profile_id,
  p.name as profile_name,
  CASE 
    WHEN p.id IS NULL THEN '❌ PERFIL INVÁLIDO'
    ELSE '✅ OK'
  END as status
FROM auth.users u
LEFT JOIN access_profiles p ON p.id = u.raw_user_meta_data->>'profileId'
WHERE u.raw_user_meta_data->>'profileId' IS NOT NULL
ORDER BY status, u.email;

-- Se algum usuário tiver perfil inválido, atualizar para 'admin':
-- UPDATE auth.users
-- SET raw_user_meta_data = raw_user_meta_data || '{"profileId": "admin"}'::jsonb
-- WHERE raw_user_meta_data->>'profileId' IN ('stock_entries_backup_completed', 'stock_entries_backup_date');

-- ═══════════════════════════════════════════════════════════════

-- ✅ RESUMO DE AÇÕES
-- ────────────────────────────────────────────────────────────────
-- 
-- 1. ✅ Deletar 2 registros inválidos (stock_entries_backup_*)
-- 2. ✅ Adicionar constraints NOT NULL
-- 3. ✅ Validar estrutura JSONB (arrays)
-- 4. ✅ Verificar se usuários foram afetados
-- 5. ✅ Tabela limpa e protegida
-- 
-- ═══════════════════════════════════════════════════════════════

-- 🎯 COMANDO RÁPIDO (EXECUTAR TUDO DE UMA VEZ)
-- ────────────────────────────────────────────────────────────────

DO $$
BEGIN
  -- 1. Deletar registros inválidos
  DELETE FROM access_profiles
  WHERE id IN (
    'stock_entries_backup_completed',
    'stock_entries_backup_date'
  );
  
  RAISE NOTICE '✅ Registros inválidos deletados';
  
  -- 2. Adicionar constraints (se ainda não existirem)
  BEGIN
    ALTER TABLE access_profiles ALTER COLUMN name SET NOT NULL;
    RAISE NOTICE '✅ Constraint NOT NULL adicionada em name';
  EXCEPTION WHEN others THEN
    RAISE NOTICE 'ℹ️ Constraint NOT NULL em name já existe';
  END;
  
  BEGIN
    ALTER TABLE access_profiles ALTER COLUMN pages SET NOT NULL;
    RAISE NOTICE '✅ Constraint NOT NULL adicionada em pages';
  EXCEPTION WHEN others THEN
    RAISE NOTICE 'ℹ️ Constraint NOT NULL em pages já existe';
  END;
  
  BEGIN
    ALTER TABLE access_profiles ALTER COLUMN features SET NOT NULL;
    RAISE NOTICE '✅ Constraint NOT NULL adicionada em features';
  EXCEPTION WHEN others THEN
    RAISE NOTICE 'ℹ️ Constraint NOT NULL em features já existe';
  END;
  
  BEGIN
    ALTER TABLE access_profiles
      ADD CONSTRAINT check_pages_is_array 
        CHECK (jsonb_typeof(pages) = 'array');
    RAISE NOTICE '✅ Check constraint adicionada em pages (array)';
  EXCEPTION WHEN others THEN
    RAISE NOTICE 'ℹ️ Check constraint em pages já existe';
  END;
  
  BEGIN
    ALTER TABLE access_profiles
      ADD CONSTRAINT check_features_is_array 
        CHECK (jsonb_typeof(features) = 'array');
    RAISE NOTICE '✅ Check constraint adicionada em features (array)';
  EXCEPTION WHEN others THEN
    RAISE NOTICE 'ℹ️ Check constraint em features já existe';
  END;
  
  RAISE NOTICE '';
  RAISE NOTICE '═══════════════════════════════════════════════════════';
  RAISE NOTICE '✅ CORREÇÃO COMPLETA!';
  RAISE NOTICE '═══════════════════════════════════════════════════════';
END $$;

-- Verificar resultado final
SELECT 
  id,
  name,
  is_system,
  jsonb_array_length(pages) as num_pages,
  jsonb_array_length(features) as num_features
FROM access_profiles
ORDER BY is_system DESC, name;
