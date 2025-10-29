-- ═══════════════════════════════════════════════════════════════
-- 🚨 EXECUTAR AGORA - Fix COMPLETO (Tabela + Usuário)
-- ═══════════════════════════════════════════════════════════════

-- ╔═══════════════════════════════════════════════════════════════╗
-- ║  PASSO 1: LIMPAR TABELA access_profiles                       ║
-- ╚═══════════════════════════════════════════════════════════════╝

-- 1.1 - Deletar registros inválidos
DELETE FROM access_profiles
WHERE id IN (
  'stock_entries_backup_completed',
  'stock_entries_backup_date'
);

-- Resultado esperado: "Success. 2 rows deleted"

-- 1.2 - Adicionar proteções
ALTER TABLE access_profiles
  ALTER COLUMN name SET NOT NULL,
  ALTER COLUMN pages SET NOT NULL,
  ALTER COLUMN features SET NOT NULL;

ALTER TABLE access_profiles
  DROP CONSTRAINT IF EXISTS check_pages_is_array,
  ADD CONSTRAINT check_pages_is_array 
    CHECK (jsonb_typeof(pages) = 'array');

ALTER TABLE access_profiles
  DROP CONSTRAINT IF EXISTS check_features_is_array,
  ADD CONSTRAINT check_features_is_array 
    CHECK (jsonb_typeof(features) = 'array');

-- ╔═══════════════════════════════════════════════════════════════╗
-- ║  PASSO 2: ATUALIZAR USUÁRIO rafael.borges                     ║
-- ╚═══════════════════════════════════════════════════════════════╝

UPDATE auth.users
SET raw_user_meta_data = raw_user_meta_data || '{"profileId": "admin"}'::jsonb
WHERE email = 'rafael.borges@porschegt3cup.com.br';

-- Resultado esperado: "Success. 1 row updated"

-- ═══════════════════════════════════════════════════════════════

-- PASSO 2: Verificar se atualizou corretamente
-- ─────────────────────────────────────────────────────────────

SELECT 
  email,
  raw_user_meta_data->>'profileId' as profile_id,
  raw_user_meta_data->>'name' as name
FROM auth.users
WHERE email = 'rafael.borges@porschegt3cup.com.br';

-- Resultado esperado:
-- email: rafael.borges@porschegt3cup.com.br
-- profile_id: admin
-- name: Rafael Borges

-- ═══════════════════════════════════════════════════════════════

-- PASSO 3: Verificar se perfil "admin" existe
-- ─────────────────────────────────────────────────────────────

SELECT id, name, is_system 
FROM access_profiles 
WHERE id = 'admin';

-- Resultado esperado:
-- id: admin
-- name: Administrador
-- is_system: true

-- ═══════════════════════════════════════════════════════════════

-- ✅ PRONTO!
-- 
-- PRÓXIMOS PASSOS (NO NAVEGADOR):
-- 
-- 1. Abra Console (F12)
-- 2. Execute:
--    localStorage.clear();
--    sessionStorage.clear();
--    location.href = '/';
-- 3. Faça login com rafael.borges@porschegt3cup.com.br
-- 4. ✅ Deve funcionar perfeitamente!
-- 
-- ═══════════════════════════════════════════════════════════════
