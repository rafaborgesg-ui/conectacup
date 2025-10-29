-- ============================================
-- FIX: Atualiza profileId do usuário no Supabase Auth
-- ============================================

-- PASSO 1: Verificar situação atual
-- ============================================

-- 1.1 - Verificar se perfil "teste" existe
SELECT 
  id,
  name,
  description,
  jsonb_array_length(pages) as num_pages,
  jsonb_array_length(features) as num_features,
  is_system,
  is_default
FROM access_profiles
WHERE id = 'teste';
-- Resultado esperado: 1 linha com id='teste', 14 páginas, 27 funcionalidades

-- 1.2 - Verificar usuário rafael.borges
SELECT 
  id,
  email,
  raw_user_meta_data,
  raw_user_meta_data->>'profileId' as profile_id,
  raw_user_meta_data->>'name' as name
FROM auth.users
WHERE email = 'rafael.borges@porschegt3cup.com.br';
-- Resultado esperado: Deve ter profileId = 'teste'

-- PASSO 2: Diagnóstico
-- ============================================

-- Se profileId estiver NULL ou diferente de "teste", execute:

DO $$
DECLARE
  user_id uuid;
  current_profile_id text;
  profile_exists boolean;
BEGIN
  -- Pega ID do usuário
  SELECT id, raw_user_meta_data->>'profileId'
  INTO user_id, current_profile_id
  FROM auth.users
  WHERE email = 'rafael.borges@porschegt3cup.com.br';
  
  RAISE NOTICE '👤 User ID: %', user_id;
  RAISE NOTICE '🆔 Current profileId: %', current_profile_id;
  
  -- Verifica se perfil "teste" existe
  SELECT EXISTS(
    SELECT 1 FROM access_profiles WHERE id = 'teste'
  ) INTO profile_exists;
  
  RAISE NOTICE '🧪 Perfil "teste" existe: %', profile_exists;
  
  -- Diagnóstico
  IF user_id IS NULL THEN
    RAISE NOTICE '❌ PROBLEMA: Usuário não encontrado!';
  ELSIF current_profile_id IS NULL THEN
    RAISE NOTICE '❌ PROBLEMA: ProfileId está NULL!';
    RAISE NOTICE '💡 SOLUÇÃO: Execute PASSO 3';
  ELSIF current_profile_id != 'teste' THEN
    RAISE NOTICE '⚠️ PROBLEMA: ProfileId está incorreto: %', current_profile_id;
    RAISE NOTICE '💡 SOLUÇÃO: Execute PASSO 3';
  ELSIF NOT profile_exists THEN
    RAISE NOTICE '❌ PROBLEMA: Perfil "teste" não existe na tabela!';
    RAISE NOTICE '💡 SOLUÇÃO: Recrie o perfil via interface';
  ELSE
    RAISE NOTICE '✅ TUDO OK: ProfileId correto e perfil existe!';
    RAISE NOTICE '💡 Problema pode ser no cache do navegador';
  END IF;
END $$;

-- PASSO 3: Correção (SE NECESSÁRIO)
-- ============================================

-- 3.1 - Atualizar profileId do usuário
-- EXECUTE APENAS SE O DIAGNÓSTICO INDICOU PROBLEMA!

UPDATE auth.users
SET raw_user_meta_data = jsonb_set(
  COALESCE(raw_user_meta_data, '{}'::jsonb),
  '{profileId}',
  '"teste"'::jsonb
)
WHERE email = 'rafael.borges@porschegt3cup.com.br';

-- 3.2 - Verificar se atualizou
SELECT 
  email,
  raw_user_meta_data->>'profileId' as profile_id,
  raw_user_meta_data->>'name' as name,
  raw_user_meta_data
FROM auth.users
WHERE email = 'rafael.borges@porschegt3cup.com.br';
-- Resultado esperado: profileId = 'teste'

-- PASSO 4: Verificação Completa
-- ============================================

-- 4.1 - Listar todos os perfis disponíveis
SELECT id, name, is_system, is_default
FROM access_profiles
ORDER BY is_system DESC, name;

-- 4.2 - Listar todos os usuários e seus perfis
SELECT 
  u.email,
  u.raw_user_meta_data->>'name' as name,
  u.raw_user_meta_data->>'profileId' as profile_id,
  p.name as profile_name,
  u.created_at
FROM auth.users u
LEFT JOIN access_profiles p ON p.id = u.raw_user_meta_data->>'profileId'
ORDER BY u.created_at DESC;

-- 4.3 - Verificar se há usuários sem perfil
SELECT 
  email,
  raw_user_meta_data->>'name' as name,
  raw_user_meta_data->>'profileId' as profile_id,
  CASE 
    WHEN raw_user_meta_data->>'profileId' IS NULL THEN '❌ SEM PERFIL'
    ELSE '✅ TEM PERFIL'
  END as status
FROM auth.users
WHERE raw_user_meta_data->>'profileId' IS NULL;

-- PASSO 5: Limpeza e Manutenção
-- ============================================

-- 5.1 - Atualizar todos os usuários sem profileId para "operator" (padrão)
UPDATE auth.users
SET raw_user_meta_data = jsonb_set(
  COALESCE(raw_user_meta_data, '{}'::jsonb),
  '{profileId}',
  '"operator"'::jsonb
)
WHERE raw_user_meta_data->>'profileId' IS NULL
  OR raw_user_meta_data->>'profileId' = '';
-- CUIDADO: Isso vai atribuir perfil "operator" para todos sem perfil!

-- 5.2 - Listar usuários com perfis inexistentes
SELECT 
  u.email,
  u.raw_user_meta_data->>'profileId' as profile_id,
  CASE 
    WHEN p.id IS NULL THEN '❌ PERFIL NÃO EXISTE'
    ELSE '✅ PERFIL OK'
  END as status
FROM auth.users u
LEFT JOIN access_profiles p ON p.id = u.raw_user_meta_data->>'profileId'
WHERE u.raw_user_meta_data->>'profileId' IS NOT NULL
ORDER BY status, u.email;

-- ============================================
-- COMANDOS RÁPIDOS
-- ============================================

-- Ver perfil do rafael.borges
SELECT 
  u.email,
  u.raw_user_meta_data->>'profileId' as profile_id,
  p.name as profile_name,
  jsonb_array_length(p.pages) as num_pages,
  p.pages
FROM auth.users u
LEFT JOIN access_profiles p ON p.id = u.raw_user_meta_data->>'profileId'
WHERE u.email = 'rafael.borges@porschegt3cup.com.br';

-- Forçar profileId = 'teste' para rafael.borges
UPDATE auth.users
SET raw_user_meta_data = raw_user_meta_data || '{"profileId": "teste"}'::jsonb
WHERE email = 'rafael.borges@porschegt3cup.com.br';

-- Ver todos os perfis
SELECT * FROM access_profiles ORDER BY is_system DESC, name;

-- Ver todos os usuários e perfis
SELECT 
  u.email,
  u.raw_user_meta_data->>'profileId' as profile_id,
  p.name as profile_name
FROM auth.users u
LEFT JOIN access_profiles p ON p.id = u.raw_user_meta_data->>'profileId'
ORDER BY u.email;
