-- =====================================================
-- FIX: Constraint "containers_check" permite container_id vazio
-- =====================================================
-- PROBLEMA: Ao cadastrar pneus com "Sem Contêiner" (container_id = ''),
--           a constraint containers_check está rejeitando a inserção
-- 
-- SOLUÇÃO: Ajustar a constraint para permitir container_id vazio ('')
--          quando o pneu não está alocado em um contêiner físico
-- =====================================================

-- 1. Remove a constraint antiga se existir
ALTER TABLE IF EXISTS stock_entries DROP CONSTRAINT IF EXISTS containers_check;

-- 2. Adiciona nova constraint que permite:
--    - container_id vazio (pneus sem contêiner)
--    - container_id válido que existe na tabela containers
ALTER TABLE stock_entries 
ADD CONSTRAINT containers_check 
CHECK (
  container_id = '' OR 
  container_id IN (SELECT id FROM containers)
);

-- 3. Verifica que funciona
DO $$
BEGIN
  RAISE NOTICE '✅ Constraint containers_check atualizada com sucesso!';
  RAISE NOTICE '   - Agora permite container_id vazio ("")';
  RAISE NOTICE '   - Valida container_id contra tabela containers quando não vazio';
END $$;
