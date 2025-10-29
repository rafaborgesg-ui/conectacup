-- ============================================
-- FIX: Perfil "profile-1761463133033" não encontrado
-- ============================================

-- PASSO 1: Diagnóstico Completo
-- ============================================

-- 1.1 - Ver usuário rafael.borges atual
SELECT 
  id,
  email,
  raw_user_meta_data,
  raw_user_meta_data->>'profileId' as profile_id,
  raw_user_meta_data->>'name' as name,
  raw_user_meta_data->>'role' as role
FROM auth.users
WHERE email = 'rafael.borges@porschegt3cup.com.br';

-- 1.2 - Verificar se perfil "profile-1761463133033" existe
SELECT 
  id,
  name,
  description,
  pages,
  features,
  created_at
FROM access_profiles
WHERE id = 'profile-1761463133033';

-- 1.3 - Ver TODOS os perfis disponíveis
SELECT 
  id,
  name,
  is_system,
  is_default,
  jsonb_array_length(pages) as num_pages,
  jsonb_array_length(features) as num_features
FROM access_profiles
ORDER BY is_system DESC, name;

-- PASSO 2: Encontrar o problema
-- ============================================

DO $$
DECLARE
  v_user_id uuid;
  v_profile_id text;
  v_profile_exists boolean;
  v_user_email text := 'rafael.borges@porschegt3cup.com.br';
BEGIN
  -- Pega dados do usuário
  SELECT 
    id, 
    raw_user_meta_data->>'profileId'
  INTO v_user_id, v_profile_id
  FROM auth.users
  WHERE email = v_user_email;
  
  IF v_user_id IS NULL THEN
    RAISE NOTICE '❌ PROBLEMA: Usuário % não existe!', v_user_email;
    RETURN;
  END IF;
  
  RAISE NOTICE '👤 Usuário encontrado: %', v_user_id;
  RAISE NOTICE '🆔 ProfileId atual: %', COALESCE(v_profile_id, 'NULL');
  
  IF v_profile_id IS NULL THEN
    RAISE NOTICE '❌ PROBLEMA: ProfileId está NULL!';
    RAISE NOTICE '💡 SOLUÇÃO: Atribua um perfil válido ao usuário';
    RETURN;
  END IF;
  
  -- Verifica se perfil existe
  SELECT EXISTS(
    SELECT 1 FROM access_profiles WHERE id = v_profile_id
  ) INTO v_profile_exists;
  
  IF NOT v_profile_exists THEN
    RAISE NOTICE '❌ PROBLEMA CRÍTICO: Perfil "%" NÃO EXISTE na tabela!', v_profile_id;
    RAISE NOTICE '📋 O perfil foi deletado ou nunca foi criado no Supabase';
    RAISE NOTICE '';
    RAISE NOTICE '💡 SOLUÇÕES POSSÍVEIS:';
    RAISE NOTICE '   1. Atribuir perfil "admin" ao usuário (RECOMENDADO)';
    RAISE NOTICE '   2. Criar o perfil "%" manualmente', v_profile_id;
    RAISE NOTICE '   3. Atribuir outro perfil existente';
  ELSE
    RAISE NOTICE '✅ Perfil "%" existe!', v_profile_id;
    RAISE NOTICE '🤔 Problema pode estar no cache do navegador';
  END IF;
END $$;

-- PASSO 3: SOLUÇÕES
-- ============================================

-- SOLUÇÃO A: Atribuir perfil "admin" (RECOMENDADO para rafael.borges)
-- Execute APENAS esta linha:

UPDATE auth.users
SET raw_user_meta_data = jsonb_set(
  COALESCE(raw_user_meta_data, '{}'::jsonb),
  '{profileId}',
  '"admin"'::jsonb
)
WHERE email = 'rafael.borges@porschegt3cup.com.br';

-- Verificar se atualizou:
SELECT 
  email,
  raw_user_meta_data->>'profileId' as profile_id,
  raw_user_meta_data->>'name' as name
FROM auth.users
WHERE email = 'rafael.borges@porschegt3cup.com.br';
-- Resultado esperado: profileId = 'admin'

-- ============================================

-- SOLUÇÃO B: Criar o perfil "profile-1761463133033" (SE QUISER MANTER)
-- OBS: Você precisará definir as páginas/funcionalidades

INSERT INTO access_profiles (
  id,
  name,
  description,
  pages,
  features,
  is_system,
  is_default
) VALUES (
  'profile-1761463133033',
  'Perfil Personalizado Rafael',
  'Perfil criado anteriormente para rafael.borges',
  '[
    "dashboard",
    "stock_entry",
    "tire_model",
    "container",
    "reports",
    "tire_movement",
    "tire_consumption",
    "tire_status_change",
    "tire_discard",
    "discard_reports",
    "stock_adjustment",
    "data_import",
    "arcs_update",
    "status_registration"
  ]'::jsonb,
  '[
    "view_dashboard",
    "view_stock",
    "create_stock_entry",
    "edit_stock_entry",
    "delete_stock_entry",
    "view_tire_models",
    "create_tire_model",
    "edit_tire_model",
    "delete_tire_model",
    "view_containers",
    "create_container",
    "edit_container",
    "delete_container",
    "view_reports",
    "export_reports",
    "view_discard_reports",
    "create_discard",
    "edit_discard",
    "delete_discard",
    "view_movements",
    "create_movement",
    "view_status_changes",
    "create_status_change",
    "view_adjustments",
    "create_adjustment",
    "import_data",
    "update_arcs"
  ]'::jsonb,
  false,
  false
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  pages = EXCLUDED.pages,
  features = EXCLUDED.features,
  updated_at = now();

-- Verificar se criou:
SELECT * FROM access_profiles WHERE id = 'profile-1761463133033';

-- ============================================

-- SOLUÇÃO C: Atribuir perfil "operator" (ALTERNATIVA)

UPDATE auth.users
SET raw_user_meta_data = jsonb_set(
  COALESCE(raw_user_meta_data, '{}'::jsonb),
  '{profileId}',
  '"operator"'::jsonb
)
WHERE email = 'rafael.borges@porschegt3cup.com.br';

-- ============================================

-- PASSO 4: Limpeza (APÓS ESCOLHER SOLUÇÃO)
-- ============================================

-- 4.1 - Ver status final do usuário
SELECT 
  u.email,
  u.raw_user_meta_data->>'profileId' as profile_id,
  p.name as profile_name,
  p.is_system,
  jsonb_array_length(p.pages) as num_pages
FROM auth.users u
LEFT JOIN access_profiles p ON p.id = u.raw_user_meta_data->>'profileId'
WHERE u.email = 'rafael.borges@porschegt3cup.com.br';

-- 4.2 - Deletar perfis órfãos (perfis que não têm usuários)
-- CUIDADO: Isso vai deletar todos os perfis personalizados não usados!

WITH used_profiles AS (
  SELECT DISTINCT raw_user_meta_data->>'profileId' as profile_id
  FROM auth.users
  WHERE raw_user_meta_data->>'profileId' IS NOT NULL
)
SELECT 
  p.id,
  p.name,
  p.is_system,
  CASE 
    WHEN up.profile_id IS NULL THEN '❌ ÓRFÃO (pode deletar)'
    ELSE '✅ EM USO'
  END as status
FROM access_profiles p
LEFT JOIN used_profiles up ON up.profile_id = p.id
WHERE p.is_system = false
ORDER BY status, p.name;

-- Para DELETAR perfis órfãos (EXECUTAR COM CUIDADO!):
DELETE FROM access_profiles
WHERE id NOT IN (
  SELECT DISTINCT raw_user_meta_data->>'profileId'
  FROM auth.users
  WHERE raw_user_meta_data->>'profileId' IS NOT NULL
)
AND is_system = false
AND is_default = false;

-- ============================================
-- RESUMO DE COMANDOS RÁPIDOS
-- ============================================

-- 🔍 VER PROBLEMA
SELECT 
  u.email,
  u.raw_user_meta_data->>'profileId' as profile_id,
  p.name as profile_name,
  CASE 
    WHEN p.id IS NULL THEN '❌ PERFIL NÃO EXISTE'
    ELSE '✅ OK'
  END as status
FROM auth.users u
LEFT JOIN access_profiles p ON p.id = u.raw_user_meta_data->>'profileId'
WHERE u.email = 'rafael.borges@porschegt3cup.com.br';

-- ✅ SOLUÇÃO RÁPIDA (atribuir admin)
UPDATE auth.users
SET raw_user_meta_data = raw_user_meta_data || '{"profileId": "admin"}'::jsonb
WHERE email = 'rafael.borges@porschegt3cup.com.br';

-- 📋 VER PERFIS DISPONÍVEIS
SELECT id, name, is_system 
FROM access_profiles 
ORDER BY is_system DESC, name;

-- 👥 VER TODOS USUÁRIOS E SEUS PERFIS
SELECT 
  u.email,
  u.raw_user_meta_data->>'profileId' as profile_id,
  p.name as profile_name,
  CASE WHEN p.id IS NULL THEN '❌' ELSE '✅' END as valid
FROM auth.users u
LEFT JOIN access_profiles p ON p.id = u.raw_user_meta_data->>'profileId'
ORDER BY valid, u.email;
