-- =====================================================
-- FIX: Habilitar Exclusão de Status (tire_status)
-- Problema: Não é possível excluir status na página "Cadastro de Status"
-- Solução: Adicionar políticas RLS e verificar foreign keys
-- =====================================================

-- PASSO 1: Verificar RLS policies existentes
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual,
  with_check
FROM pg_policies
WHERE tablename = 'tire_status';

-- PASSO 2: Verificar foreign keys que referenciam tire_status
SELECT
  tc.table_name, 
  kcu.column_name,
  ccu.table_name AS foreign_table_name,
  ccu.column_name AS foreign_column_name,
  rc.delete_rule
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
  ON tc.constraint_name = kcu.constraint_name
  AND tc.table_schema = kcu.table_schema
JOIN information_schema.constraint_column_usage AS ccu
  ON ccu.constraint_name = tc.constraint_name
  AND ccu.table_schema = tc.table_schema
JOIN information_schema.referential_constraints AS rc
  ON tc.constraint_name = rc.constraint_name
WHERE ccu.table_name = 'tire_status' 
  AND tc.constraint_type = 'FOREIGN KEY';

-- =====================================================
-- PASSO 3: Habilitar RLS (se não estiver habilitado)
-- =====================================================

-- Ativa RLS na tabela tire_status
ALTER TABLE tire_status ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- PASSO 4: Adicionar políticas RLS para DELETE
-- =====================================================

-- Remove políticas antigas (se existirem)
DROP POLICY IF EXISTS "Usuários autenticados podem deletar status" ON tire_status;
DROP POLICY IF EXISTS "tire_status_delete_policy" ON tire_status;
DROP POLICY IF EXISTS "Allow delete for authenticated users" ON tire_status;

-- Política: Usuários autenticados podem deletar status
CREATE POLICY "Usuários autenticados podem deletar status"
ON tire_status
FOR DELETE
TO authenticated
USING (true);

-- =====================================================
-- PASSO 5: Adicionar políticas RLS para SELECT, INSERT, UPDATE
-- (caso ainda não existam)
-- =====================================================

-- SELECT: Todos podem ler (incluindo anônimos para o app funcionar)
DROP POLICY IF EXISTS "Todos podem ler status" ON tire_status;
CREATE POLICY "Todos podem ler status"
ON tire_status
FOR SELECT
TO public
USING (true);

-- INSERT: Apenas usuários autenticados podem criar
DROP POLICY IF EXISTS "Usuários autenticados podem criar status" ON tire_status;
CREATE POLICY "Usuários autenticados podem criar status"
ON tire_status
FOR INSERT
TO authenticated
WITH CHECK (true);

-- UPDATE: Apenas usuários autenticados podem atualizar
DROP POLICY IF EXISTS "Usuários autenticados podem atualizar status" ON tire_status;
CREATE POLICY "Usuários autenticados podem atualizar status"
ON tire_status
FOR UPDATE
TO authenticated
USING (true)
WITH CHECK (true);

-- =====================================================
-- PASSO 6: Verificar se as políticas foram criadas
-- =====================================================

SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd
FROM pg_policies
WHERE tablename = 'tire_status'
ORDER BY cmd, policyname;

-- =====================================================
-- PASSO 7: Testar exclusão (COMENTADO - descomente para testar)
-- =====================================================

-- IMPORTANTE: Substitua 'ID_DO_STATUS' pelo ID real de um status personalizado
-- NÃO DELETE STATUS PADRÃO DO SISTEMA!

-- DELETE FROM tire_status WHERE id = 'ID_DO_STATUS';

-- =====================================================
-- VERIFICAÇÃO FINAL
-- =====================================================

-- Exibe todos os status
SELECT 
  id,
  name,
  color,
  display_order,
  created_at
FROM tire_status
ORDER BY display_order ASC, name ASC;

-- =====================================================
-- NOTAS IMPORTANTES
-- =====================================================

/*
1. RLS POLICIES:
   - Se você estiver usando Supabase Auth, o usuário precisa estar autenticado
   - A política "authenticated" só funciona se o token JWT estiver correto
   
2. FOREIGN KEYS:
   - Se stock_entries ou outras tabelas referenciam tire_status com ON DELETE RESTRICT,
     você NÃO poderá deletar um status que está sendo usado
   - Solução: Use ON DELETE SET NULL ou ON DELETE CASCADE nas foreign keys
   
3. DEBUGGING:
   - Verifique o console do navegador para mensagens de erro
   - Verifique os logs do Edge Function
   - Verifique se o usuário está autenticado (token JWT válido)
   
4. FALLBACK:
   - Se continuar com erro, pode ser necessário:
     a) Desabilitar RLS temporariamente para testes
     b) Usar Service Role Key no backend para deletar
     c) Verificar permissões do role "authenticated"
*/

-- =====================================================
-- OPÇÃO ALTERNATIVA: Desabilitar RLS temporariamente
-- (APENAS PARA TESTES - NÃO RECOMENDADO EM PRODUÇÃO)
-- =====================================================

-- DESCOMENTE APENAS SE NECESSÁRIO PARA TESTE:
-- ALTER TABLE tire_status DISABLE ROW LEVEL SECURITY;

-- =====================================================
-- ROLLBACK (se algo der errado)
-- =====================================================

-- Para reverter as políticas:
-- DROP POLICY IF EXISTS "Usuários autenticados podem deletar status" ON tire_status;
-- DROP POLICY IF EXISTS "Todos podem ler status" ON tire_status;
-- DROP POLICY IF EXISTS "Usuários autenticados podem criar status" ON tire_status;
-- DROP POLICY IF EXISTS "Usuários autenticados podem atualizar status" ON tire_status;
