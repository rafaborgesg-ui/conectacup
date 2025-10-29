-- ========================================================================
-- CORREÇÃO: Limpar container_name de pneus "Descartado DSI"
-- ========================================================================
-- 
-- OBJETIVO:
-- Atualizar todos os pneus com status "Descartado DSI", "Descarte DSI" ou "Descarte"
-- para remover a associação com containers (container_name = NULL)
--
-- QUANDO EXECUTAR:
-- Esta correção deve ser executada UMA ÚNICA VEZ através do Supabase SQL Editor
--
-- COMO EXECUTAR:
-- 1. Acesse o Supabase Dashboard
-- 2. Vá em SQL Editor
-- 3. Cole este script completo
-- 4. Execute o script
--
-- ========================================================================

-- PASSO 1: Verificar quantos registros serão afetados (PREVIEW)
-- Execute este SELECT primeiro para validar os dados antes de atualizar
SELECT 
    id,
    barcode,
    status,
    container_name,
    container_id,
    etapa,
    temporada,
    created_at
FROM stock_entries
WHERE 
    (status = 'Descartado DSI' OR status = 'Descarte DSI' OR status = 'Descarte')
    AND container_name IS NOT NULL
ORDER BY created_at DESC;

-- RESULTADO ESPERADO:
-- Este SELECT mostrará todos os pneus descartados que ainda têm container_name
-- Verifique se os dados estão corretos antes de prosseguir

-- ========================================================================

-- PASSO 2: Executar a atualização
-- ATENÇÃO: Esta operação é IRREVERSÍVEL!
-- Certifique-se de que o PASSO 1 retornou os registros corretos

UPDATE stock_entries
SET 
    container_name = NULL,
    updated_at = NOW()
WHERE 
    (status = 'Descartado DSI' OR status = 'Descarte DSI' OR status = 'Descarte')
    AND container_name IS NOT NULL;

-- ========================================================================

-- PASSO 3: Verificar o resultado da atualização
-- Execute este SELECT após o UPDATE para confirmar a correção

SELECT 
    status,
    COUNT(*) as total_pneus,
    COUNT(CASE WHEN container_name IS NULL THEN 1 END) as sem_container,
    COUNT(CASE WHEN container_name IS NOT NULL THEN 1 END) as com_container
FROM stock_entries
WHERE 
    status = 'Descartado DSI' 
    OR status = 'Descarte DSI' 
    OR status = 'Descarte'
GROUP BY status
ORDER BY status;

-- RESULTADO ESPERADO:
-- Todos os pneus descartados devem ter container_name = NULL
-- A coluna "com_container" deve mostrar 0 para todos os status de descarte
-- Exemplo:
-- | status         | total_pneus | sem_container | com_container |
-- |----------------|-------------|---------------|---------------|
-- | Descartado DSI | 150         | 150           | 0             |
-- | Descarte DSI   | 20          | 20            | 0             |
-- | Descarte       | 5           | 5             | 0             |

-- ========================================================================

-- PASSO 4: Verificar se ainda existem pneus descartados COM container
-- Este SELECT NÃO deve retornar nenhum resultado

SELECT 
    id,
    barcode,
    status,
    container_name,
    container_id
FROM stock_entries
WHERE 
    (status = 'Descartado DSI' OR status = 'Descarte DSI' OR status = 'Descarte')
    AND container_name IS NOT NULL;

-- RESULTADO ESPERADO:
-- 0 registros (a query não deve retornar nada)

-- ========================================================================

-- LOGS E AUDITORIA
-- Registro da operação para histórico
DO $$
DECLARE
    affected_count INTEGER;
BEGIN
    -- Conta quantos registros foram afetados
    SELECT COUNT(*) INTO affected_count
    FROM stock_entries
    WHERE 
        (status = 'Descartado DSI' OR status = 'Descarte DSI' OR status = 'Descarte')
        AND container_name IS NULL
        AND updated_at > NOW() - INTERVAL '5 minutes';
    
    -- Exibe mensagem de confirmação
    RAISE NOTICE '✅ Correção concluída com sucesso!';
    RAISE NOTICE '📊 Total de registros atualizados: %', affected_count;
    RAISE NOTICE '📅 Data/Hora da correção: %', NOW();
    RAISE NOTICE '🗑️ Pneus descartados agora estão sem container associado';
    RAISE NOTICE '📦 Campo container_name foi definido como NULL';
END $$;

-- ========================================================================
-- FIM DO SCRIPT
-- ========================================================================

-- NOTAS IMPORTANTES:
--
-- 1. BACKUP: Certifique-se de ter um backup recente antes de executar
--
-- 2. VALIDAÇÃO: Execute o PASSO 1 primeiro para validar os dados
--
-- 3. EXECUÇÃO: Execute os comandos na ordem:
--    - PASSO 1: Visualizar registros que serão alterados
--    - PASSO 2: Executar o UPDATE (irreversível)
--    - PASSO 3: Verificar resultado agrupado por status
--    - PASSO 4: Confirmar que não há mais pneus descartados com container
--
-- 4. COMPORTAMENTO FUTURO:
--    Após esta correção, os componentes TireDiscard e TireStatusChange
--    automaticamente definirão container_name = NULL quando um pneu
--    for marcado como "Descartado DSI"
--
-- 5. IMPACTO: Esta correção afeta apenas dados históricos
--    Não afeta a lógica da aplicação ou regras de negócio futuras
--
-- 6. OCUPAÇÃO DE CONTAINERS:
--    Esta correção ajuda a manter a ocupação real dos containers
--    já que pneus descartados não devem ocupar espaço físico
--
-- ========================================================================
