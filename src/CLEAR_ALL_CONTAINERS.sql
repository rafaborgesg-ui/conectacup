-- ========================================================================
-- LIMPEZA GLOBAL: Remover TODOS os containers de TODOS os pneus
-- ========================================================================
-- 
-- ⚠️ ATENÇÃO: OPERAÇÃO CRÍTICA - LEIA ANTES DE EXECUTAR! ⚠️
--
-- OBJETIVO:
-- Limpar os campos container_name e container_id de TODOS os pneus
-- no banco de dados, independente do status
--
-- IMPACTO:
-- - TODOS os pneus ficarão sem container associado
-- - A ocupação de TODOS os containers será zerada
-- - Esta operação afeta TODOS os registros da tabela stock_entries
-- - NÃO é possível reverter após a execução (irreversível)
--
-- QUANDO EXECUTAR:
-- - Apenas se você precisa resetar COMPLETAMENTE a associação de containers
-- - Útil para reorganização total do estoque físico
-- - NÃO execute este script sem confirmação da equipe
--
-- COMO EXECUTAR:
-- 1. Acesse o Supabase Dashboard
-- 2. Vá em SQL Editor
-- 3. Cole este script completo
-- 4. Execute PASSO por PASSO (não execute tudo de uma vez)
--
-- ========================================================================

-- ========================================================================
-- PASSO 1: VERIFICAR O ESTADO ATUAL (PREVIEW)
-- ========================================================================
-- Execute este SELECT primeiro para ver quantos pneus serão afetados

SELECT 
    COUNT(*) as total_pneus,
    COUNT(CASE WHEN container_name IS NOT NULL THEN 1 END) as com_container,
    COUNT(CASE WHEN container_name IS NULL THEN 1 END) as sem_container,
    COUNT(DISTINCT container_id) as containers_unicos
FROM stock_entries;

-- RESULTADO ESPERADO:
-- Você verá quantos pneus atualmente têm container associado
-- Exemplo:
-- | total_pneus | com_container | sem_container | containers_unicos |
-- |-------------|---------------|---------------|-------------------|
-- | 5000        | 4850          | 150           | 25                |

-- ========================================================================

-- PASSO 2: VISUALIZAR DISTRIBUIÇÃO POR CONTAINER
-- ========================================================================
-- Veja quantos pneus existem em cada container antes da limpeza

SELECT 
    COALESCE(container_name, 'SEM CONTAINER') as container,
    COUNT(*) as quantidade_pneus,
    COUNT(CASE WHEN status = 'Novo' THEN 1 END) as novos,
    COUNT(CASE WHEN status = 'Pneu CUP' THEN 1 END) as em_uso,
    COUNT(CASE WHEN status = 'Descartado DSI' THEN 1 END) as descartados,
    COUNT(CASE WHEN status = 'Piloto' THEN 1 END) as piloto
FROM stock_entries
GROUP BY container_name
ORDER BY quantidade_pneus DESC
LIMIT 20;

-- ========================================================================

-- PASSO 3: VISUALIZAR DISTRIBUIÇÃO POR STATUS
-- ========================================================================
-- Veja a distribuição de status dos pneus que serão afetados

SELECT 
    status,
    COUNT(*) as total,
    COUNT(CASE WHEN container_name IS NOT NULL THEN 1 END) as com_container,
    COUNT(CASE WHEN container_name IS NULL THEN 1 END) as sem_container
FROM stock_entries
GROUP BY status
ORDER BY total DESC;

-- ========================================================================

-- 🚨🚨🚨 ZONA DE PERIGO - OPERAÇÃO IRREVERSÍVEL 🚨🚨🚨

-- ========================================================================
-- PASSO 4: BACKUP DE SEGURANÇA (RECOMENDADO)
-- ========================================================================
-- Crie uma tabela temporária com backup dos dados ANTES de limpar

CREATE TABLE IF NOT EXISTS stock_entries_backup_containers AS
SELECT 
    id,
    barcode,
    container_id,
    container_name,
    status,
    created_at,
    updated_at
FROM stock_entries
WHERE container_name IS NOT NULL OR container_id IS NOT NULL;

-- Verifique se o backup foi criado
SELECT COUNT(*) as registros_no_backup FROM stock_entries_backup_containers;

-- ========================================================================

-- ========================================================================
-- PASSO 5: EXECUTAR A LIMPEZA GLOBAL
-- ========================================================================
-- ⚠️⚠️⚠️ ATENÇÃO: ESTA OPERAÇÃO É IRREVERSÍVEL! ⚠️⚠️⚠️
-- ⚠️⚠️⚠️ TODOS OS PNEUS PERDERÃO A ASSOCIAÇÃO COM CONTAINERS! ⚠️⚠️⚠️
-- 
-- CERTIFIQUE-SE DE QUE:
-- ✓ Você executou os PASSOS 1, 2 e 3 para validar os dados
-- ✓ Você criou o backup no PASSO 4
-- ✓ A equipe autorizou esta operação
-- ✓ Você está preparado para reasociar os pneus aos containers após a limpeza

UPDATE stock_entries
SET 
    container_name = NULL,
    container_id = NULL,
    updated_at = NOW()
WHERE 
    container_name IS NOT NULL 
    OR container_id IS NOT NULL;

-- ========================================================================

-- ========================================================================
-- PASSO 6: VERIFICAR O RESULTADO DA LIMPEZA
-- ========================================================================
-- Execute este SELECT após o UPDATE para confirmar a limpeza

SELECT 
    COUNT(*) as total_pneus,
    COUNT(CASE WHEN container_name IS NOT NULL THEN 1 END) as com_container,
    COUNT(CASE WHEN container_name IS NULL THEN 1 END) as sem_container,
    COUNT(CASE WHEN container_id IS NOT NULL THEN 1 END) as com_container_id
FROM stock_entries;

-- RESULTADO ESPERADO:
-- Todos os pneus devem ter container_name = NULL e container_id = NULL
-- | total_pneus | com_container | sem_container | com_container_id |
-- |-------------|---------------|---------------|------------------|
-- | 5000        | 0             | 5000          | 0                |

-- ========================================================================

-- PASSO 7: VERIFICAR SE AINDA EXISTEM PNEUS COM CONTAINER
-- ========================================================================
-- Este SELECT NÃO deve retornar nenhum resultado

SELECT 
    id,
    barcode,
    container_name,
    container_id,
    status
FROM stock_entries
WHERE 
    container_name IS NOT NULL 
    OR container_id IS NOT NULL
LIMIT 10;

-- RESULTADO ESPERADO:
-- 0 registros (a query não deve retornar nada)

-- ========================================================================

-- PASSO 8: ATUALIZAR ESTATÍSTICAS DOS CONTAINERS
-- ========================================================================
-- Verifique que todos os containers agora têm ocupação ZERO

SELECT 
    c.id,
    c.name,
    c.location,
    c.capacity,
    COUNT(s.id) as ocupacao_atual,
    c.capacity - COUNT(s.id) as espaco_disponivel
FROM containers c
LEFT JOIN stock_entries s ON s.container_id = c.id 
    AND s.container_name IS NOT NULL
GROUP BY c.id, c.name, c.location, c.capacity
ORDER BY c.name;

-- RESULTADO ESPERADO:
-- Todos os containers devem mostrar ocupacao_atual = 0
-- e espaco_disponivel = capacity

-- ========================================================================

-- PASSO 9: LOGS E AUDITORIA
-- ========================================================================

DO $$
DECLARE
    total_limpos INTEGER;
    backup_count INTEGER;
BEGIN
    -- Conta quantos registros estão agora sem container
    SELECT COUNT(*) INTO total_limpos
    FROM stock_entries
    WHERE container_name IS NULL AND container_id IS NULL;
    
    -- Conta quantos registros estão no backup
    SELECT COUNT(*) INTO backup_count
    FROM stock_entries_backup_containers;
    
    -- Exibe mensagem de confirmação
    RAISE NOTICE '═══════════════════════════════════════════════════════';
    RAISE NOTICE '✅ Limpeza global de containers concluída!';
    RAISE NOTICE '═══════════════════════════════════════════════════════';
    RAISE NOTICE '📊 Total de pneus sem container: %', total_limpos;
    RAISE NOTICE '💾 Registros salvos no backup: %', backup_count;
    RAISE NOTICE '📅 Data/Hora da operação: %', NOW();
    RAISE NOTICE '🗑️ TODOS os pneus foram removidos dos containers';
    RAISE NOTICE '📦 Campos container_name e container_id = NULL';
    RAISE NOTICE '═══════════════════════════════════════════════════════';
    RAISE NOTICE '⚠️  PRÓXIMOS PASSOS:';
    RAISE NOTICE '1. Reassocie os pneus aos containers conforme necessário';
    RAISE NOTICE '2. Use o módulo "Mover Pneus" da aplicação';
    RAISE NOTICE '3. Ou execute scripts SQL para associação em massa';
    RAISE NOTICE '═══════════════════════════════════════════════════════';
END $$;

-- ========================================================================

-- ========================================================================
-- PASSO 10 (OPCIONAL): RESTAURAR DO BACKUP
-- ========================================================================
-- ⚠️ USE APENAS SE VOCÊ EXECUTOU O PASSO 5 POR ENGANO! ⚠️
-- 
-- Este comando restaura os containers a partir do backup criado no PASSO 4
-- ATENÇÃO: Só funciona se você criou o backup ANTES da limpeza

-- DESCOMENTE AS LINHAS ABAIXO APENAS SE PRECISAR RESTAURAR:

/*
UPDATE stock_entries s
SET 
    container_id = b.container_id,
    container_name = b.container_name,
    updated_at = NOW()
FROM stock_entries_backup_containers b
WHERE s.id = b.id
    AND (b.container_name IS NOT NULL OR b.container_id IS NOT NULL);

-- Verifique a restauração
SELECT 
    COUNT(*) as total_restaurados
FROM stock_entries
WHERE container_name IS NOT NULL OR container_id IS NOT NULL;
*/

-- ========================================================================

-- PASSO 11 (OPCIONAL): REMOVER TABELA DE BACKUP
-- ========================================================================
-- Execute apenas APÓS confirmar que a limpeza está correta
-- e você NÃO precisará restaurar os dados

-- DESCOMENTE APENAS SE TIVER CERTEZA:
-- DROP TABLE IF EXISTS stock_entries_backup_containers;

-- ========================================================================
-- FIM DO SCRIPT
-- ========================================================================

-- ========================================================================
-- NOTAS IMPORTANTES:
-- ========================================================================
--
-- 1. BACKUP OBRIGATÓRIO:
--    - SEMPRE execute o PASSO 4 antes do PASSO 5
--    - Mantenha o backup até confirmar que tudo está correto
--
-- 2. VALIDAÇÃO:
--    - Execute os PASSOS 1, 2 e 3 para entender o impacto
--    - Revise os números com a equipe antes de prosseguir
--
-- 3. EXECUÇÃO SEQUENCIAL:
--    - Execute os comandos NA ORDEM (não execute tudo de uma vez)
--    - Valide cada resultado antes de prosseguir
--
-- 4. REVERSÃO:
--    - Se executar por engano, use o PASSO 10 imediatamente
--    - A restauração só funciona se o backup foi criado ANTES
--
-- 5. IMPACTO NA APLICAÇÃO:
--    - Após esta limpeza, TODOS os pneus aparecerão como "Sem Container"
--    - Você precisará reasociar os pneus aos containers manualmente
--    - Use o módulo "Mover Pneus" na aplicação para reorganizar
--
-- 6. OCUPAÇÃO DOS CONTAINERS:
--    - Todos os containers mostrarão ocupação = 0
--    - O espaço disponível será igual à capacidade total
--
-- 7. CASOS DE USO:
--    - Reorganização completa do estoque físico
--    - Mudança de layout do armazém
--    - Resetar sistema após inventário físico
--    - Corrigir inconsistências globais de associação
--
-- 8. ALTERNATIVAS MENOS DRÁSTICAS:
--    - Se você só quer limpar containers de pneus descartados,
--      use o script: /FIX_DESCARTADO_DSI_CLEAR_CONTAINER.sql
--    - Se você quer mover pneus entre containers,
--      use o módulo "Mover Pneus" da aplicação
--
-- 9. SUPORTE:
--    - Em caso de dúvidas, consulte a equipe de desenvolvimento
--    - NÃO execute este script sem autorização
--
-- ========================================================================
