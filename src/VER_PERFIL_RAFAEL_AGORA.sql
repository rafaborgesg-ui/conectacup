-- ═══════════════════════════════════════════════════════════════
-- ⚡ EXECUTAR AGORA - Ver Perfil do Usuário Rafael
-- ═══════════════════════════════════════════════════════════════
-- 
-- Execute no Supabase SQL Editor:
-- https://supabase.com/dashboard/project/nflgqugaabtxzifyhjor/sql
-- 
-- ═══════════════════════════════════════════════════════════════

-- 1️⃣ VER PERFIL DO RAFAEL ESPECIFICAMENTE
-- ─────────────────────────────────────────────────────────────

SELECT 
  '🎯 RAFAEL' as usuario,
  email,
  raw_user_meta_data->>'name' as nome_completo,
  raw_user_meta_data->>'role' as perfil_acesso,
  CASE 
    WHEN raw_user_meta_data->>'role' = 'admin' THEN '🔴 Administrador (acesso total)'
    WHEN raw_user_meta_data->>'role' = 'operator' THEN '🟢 Operador (criar/editar)'
    WHEN raw_user_meta_data->>'role' = 'supervisor' THEN '🟡 Supervisor (aprovar)'
    WHEN raw_user_meta_data->>'role' = 'viewer' THEN '🔵 Visualizador (somente leitura)'
    ELSE '⚠️ SEM PERFIL DEFINIDO'
  END as descricao_perfil,
  created_at as cadastrado_em,
  last_sign_in_at as ultimo_login
FROM auth.users
WHERE email ILIKE '%rafael%'
ORDER BY created_at DESC;

-- Resultado esperado:
-- email: rafael@email.com
-- nome_completo: Rafael
-- perfil_acesso: operator  ← AQUI ESTÁ O PERFIL!
-- descricao_perfil: 🟢 Operador (criar/editar)

-- ═══════════════════════════════════════════════════════════════

-- 2️⃣ VER TODOS OS USUÁRIOS E SEUS PERFIS
-- ─────────────────────────────────────────────────────────────

SELECT 
  email,
  raw_user_meta_data->>'name' as nome,
  raw_user_meta_data->>'role' as perfil,
  CASE 
    WHEN raw_user_meta_data->>'role' = 'admin' THEN '🔴 Admin'
    WHEN raw_user_meta_data->>'role' = 'operator' THEN '🟢 Operator'
    WHEN raw_user_meta_data->>'role' = 'supervisor' THEN '🟡 Supervisor'
    WHEN raw_user_meta_data->>'role' = 'viewer' THEN '🔵 Viewer'
    ELSE '⚪ Indefinido'
  END as tipo,
  created_at,
  last_sign_in_at
FROM auth.users
ORDER BY created_at DESC
LIMIT 20;

-- ═══════════════════════════════════════════════════════════════

-- 3️⃣ ESTATÍSTICAS: QUANTOS USUÁRIOS POR PERFIL
-- ─────────────────────────────────────────────────────────────

SELECT 
  COALESCE(raw_user_meta_data->>'role', 'sem_perfil') as perfil,
  COUNT(*) as total_usuarios,
  ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) as percentual,
  CASE 
    WHEN raw_user_meta_data->>'role' = 'admin' THEN '🔴 Administrador'
    WHEN raw_user_meta_data->>'role' = 'operator' THEN '🟢 Operador'
    WHEN raw_user_meta_data->>'role' = 'supervisor' THEN '🟡 Supervisor'
    WHEN raw_user_meta_data->>'role' = 'viewer' THEN '🔵 Visualizador'
    ELSE '⚠️ Sem perfil'
  END as descricao
FROM auth.users
GROUP BY raw_user_meta_data->>'role'
ORDER BY COUNT(*) DESC;

-- ═══════════════════════════════════════════════════════════════

-- 4️⃣ VERIFICAR SE RAFAEL TEM PERFIL "OPERATOR"
-- ─────────────────────────────────────────────────────────────

SELECT 
  CASE 
    WHEN COUNT(*) > 0 THEN '✅ SIM - Rafael tem perfil OPERATOR'
    ELSE '❌ NÃO - Rafael NÃO tem perfil operator'
  END as resultado,
  COUNT(*) as usuarios_encontrados
FROM auth.users
WHERE email ILIKE '%rafael%'
  AND raw_user_meta_data->>'role' = 'operator';

-- ═══════════════════════════════════════════════════════════════

-- 5️⃣ VER ESTRUTURA COMPLETA DO METADATA DO RAFAEL
-- ─────────────────────────────────────────────────────────────

SELECT 
  email,
  raw_user_meta_data as metadata_completo,
  jsonb_pretty(raw_user_meta_data) as metadata_formatado
FROM auth.users
WHERE email ILIKE '%rafael%';

-- Exemplo de resultado:
-- metadata_formatado:
-- {
--   "name": "Rafael",
--   "role": "operator",
--   "profileId": "operator"
-- }

-- ═══════════════════════════════════════════════════════════════

-- 6️⃣ COMPARAR PERFIS DISPONÍVEIS vs PERFIS EM USO
-- ─────────────────────────────────────────────────────────────

WITH perfis_disponiveis AS (
  SELECT id, name FROM access_profiles
),
perfis_em_uso AS (
  SELECT DISTINCT raw_user_meta_data->>'role' as role
  FROM auth.users
  WHERE raw_user_meta_data->>'role' IS NOT NULL
)
SELECT 
  pd.id as perfil_id,
  pd.name as perfil_nome,
  CASE 
    WHEN peu.role IS NOT NULL THEN '✅ Em uso'
    ELSE '⚪ Não utilizado'
  END as status,
  (
    SELECT COUNT(*) 
    FROM auth.users 
    WHERE raw_user_meta_data->>'role' = pd.id
  ) as total_usuarios
FROM perfis_disponiveis pd
LEFT JOIN perfis_em_uso peu ON pd.id = peu.role
ORDER BY total_usuarios DESC, pd.name;

-- ═══════════════════════════════════════════════════════════════
-- ✅ PRONTO! Agora você sabe onde está o perfil do Rafael
-- ═══════════════════════════════════════════════════════════════
-- 
-- 📍 LOCALIZAÇÃO DO PERFIL:
-- Tabela: auth.users
-- Coluna: raw_user_meta_data
-- Campo JSON: role
-- 
-- 💡 EXEMPLO:
-- auth.users
--   └── raw_user_meta_data: {"name": "Rafael", "role": "operator"}
--                                                      ↑
--                                              PERFIL AQUI! ✅
-- 
-- ═══════════════════════════════════════════════════════════════

-- 🔧 BONUS: Alterar perfil do Rafael (se necessário)
-- ─────────────────────────────────────────────────────────────

-- DESCOMENTE ABAIXO PARA EXECUTAR:

-- -- Mudar Rafael para ADMIN
-- UPDATE auth.users
-- SET raw_user_meta_data = jsonb_set(
--   raw_user_meta_data,
--   '{role}',
--   '"admin"'
-- )
-- WHERE email ILIKE '%rafael%';

-- -- Mudar Rafael para SUPERVISOR
-- UPDATE auth.users
-- SET raw_user_meta_data = jsonb_set(
--   raw_user_meta_data,
--   '{role}',
--   '"supervisor"'
-- )
-- WHERE email ILIKE '%rafael%';

-- -- Mudar Rafael para VIEWER
-- UPDATE auth.users
-- SET raw_user_meta_data = jsonb_set(
--   raw_user_meta_data,
--   '{role}',
--   '"viewer"'
-- )
-- WHERE email ILIKE '%rafael%';

-- -- DEPOIS DE ALTERAR: Verificar mudança
-- SELECT 
--   email,
--   raw_user_meta_data->>'name' as nome,
--   raw_user_meta_data->>'role' as novo_perfil
-- FROM auth.users
-- WHERE email ILIKE '%rafael%';

-- ═══════════════════════════════════════════════════════════════
