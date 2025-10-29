-- ═══════════════════════════════════════════════════════════════
-- 🚨 EXECUTAR AGORA - Limpar registros inválidos da access_profiles
-- ═══════════════════════════════════════════════════════════════
--
-- PROBLEMA: 2 registros inválidos na tabela access_profiles:
--   - stock_entries_backup_completed
--   - stock_entries_backup_date
--
-- SOLUÇÃO: Deletar + adicionar constraints de proteção
-- ═══════════════════════════════════════════════════════════════

-- ╔═══════════════════════════════════════════════════════════════╗
-- ║  PASSO 1: DELETAR REGISTROS INVÁLIDOS                         ║
-- ╚═══════════════════════════════════════════════════════════════╝

DELETE FROM access_profiles
WHERE id IN (
  'stock_entries_backup_completed',
  'stock_entries_backup_date'
);

-- Resultado esperado: "Success. 2 rows deleted"

-- ╔═══════════════════════════════════════════════════════════════╗
-- ║  PASSO 2: ADICIONAR CONSTRAINTS DE PROTEÇÃO                   ║
-- ╚═══════════════════════════════════════════════════════════════╝

-- Impedir campos NULL
ALTER TABLE access_profiles
  ALTER COLUMN name SET NOT NULL,
  ALTER COLUMN pages SET NOT NULL,
  ALTER COLUMN features SET NOT NULL;

-- Validar que pages e features são arrays JSONB
ALTER TABLE access_profiles
  DROP CONSTRAINT IF EXISTS check_pages_is_array,
  ADD CONSTRAINT check_pages_is_array 
    CHECK (jsonb_typeof(pages) = 'array');

ALTER TABLE access_profiles
  DROP CONSTRAINT IF EXISTS check_features_is_array,
  ADD CONSTRAINT check_features_is_array 
    CHECK (jsonb_typeof(features) = 'array');

-- ╔═══════════════════════════════════════════════════════════════╗
-- ║  PASSO 3: VERIFICAR RESULTADO                                 ║
-- ╚═══════════════════════════════════════════════════════════════╝

SELECT 
  id,
  name,
  is_system,
  is_default,
  jsonb_array_length(pages) as num_pages,
  jsonb_array_length(features) as num_features
FROM access_profiles
ORDER BY is_system DESC, name;

-- Resultado esperado (4 perfis do sistema):
-- ┌──────────────┬───────────────┬───────────┬────────────┬───────────┬──────────────┐
-- │ id           │ name          │ is_system │ is_default │ num_pages │ num_features │
-- ├──────────────┼───────────────┼───────────┼────────────┼───────────┼──────────────┤
-- │ admin        │ Administrador │ TRUE      │ TRUE       │ 14        │ 28           │
-- │ operator     │ Operador      │ TRUE      │ FALSE      │ 10        │ 15           │
-- │ supervisor   │ Supervisor    │ TRUE      │ FALSE      │ 12        │ 20           │
-- │ viewer       │ Visualizador  │ TRUE      │ FALSE      │ 5         │ 5            │
-- └──────────────┴───────────────┴───────────┴────────────┴───────────┴──────────────┘

-- ╔═══════════════════════════════════════════════════════════════╗
-- ║  PASSO 4: VERIFICAR SE USUÁRIOS FORAM AFETADOS                ║
-- ╚═══════════════════════════════════════════════════════════════╝

SELECT 
  u.email,
  u.raw_user_meta_data->>'profileId' as profile_id,
  p.name as profile_name,
  CASE 
    WHEN p.id IS NULL THEN '❌ INVÁLIDO'
    ELSE '✅ OK'
  END as status
FROM auth.users u
LEFT JOIN access_profiles p ON p.id = u.raw_user_meta_data->>'profileId'
WHERE u.raw_user_meta_data->>'profileId' IS NOT NULL
ORDER BY status, u.email;

-- Se algum usuário estiver com perfil inválido, execute:
-- UPDATE auth.users
-- SET raw_user_meta_data = raw_user_meta_data || '{"profileId": "admin"}'::jsonb
-- WHERE raw_user_meta_data->>'profileId' IN (
--   'stock_entries_backup_completed', 
--   'stock_entries_backup_date'
-- );

-- ═══════════════════════════════════════════════════════════════
-- ✅ PRONTO! Tabela limpa e protegida contra inserções inválidas
-- ═══════════════════════════════════════════════════════════════
