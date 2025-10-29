-- ========================================================================
-- CORREÇÃO DE STATUS: Descarte Piloto -> Descartado DSI
-- ========================================================================
-- 
-- OBJETIVO:
-- Atualizar pneus das Etapas 4, 5, 6 e 7 da temporada 2025
-- que possuem status "Descarte Piloto" para "Descartado DSI"
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
    etapa,
    temporada,
    status,
    modelo_code,
    container_id,
    created_at
FROM stock_entries
WHERE 
    temporada = '2025'
    AND etapa IN ('4', '5', '6', '7')
    AND status = 'Descarte Piloto'
ORDER BY etapa, created_at;

-- RESULTADO ESPERADO:
-- Este SELECT mostrará todos os registros que serão atualizados
-- Verifique se os dados estão corretos antes de prosseguir

-- ========================================================================

-- PASSO 2: Executar a atualização
-- ATENÇÃO: Esta operação é IRREVERSÍVEL!
-- Certifique-se de que o PASSO 1 retornou os registros corretos

UPDATE stock_entries
SET 
    status = 'Descartado DSI',
    updated_at = NOW()
WHERE 
    temporada = '2025'
    AND etapa IN ('4', '5', '6', '7')
    AND status = 'Descarte Piloto';

-- ========================================================================

-- PASSO 3: Verificar o resultado da atualização
-- Execute este SELECT após o UPDATE para confirmar a correção

SELECT 
    etapa,
    COUNT(*) as total_corrigidos,
    status
FROM stock_entries
WHERE 
    temporada = '2025'
    AND etapa IN ('4', '5', '6', '7')
    AND status = 'Descartado DSI'
GROUP BY etapa, status
ORDER BY etapa;

-- RESULTADO ESPERADO:
-- Você deve ver a contagem de registros atualizados agrupados por etapa
-- Exemplo:
-- | etapa | total_corrigidos | status          |
-- |-------|------------------|-----------------|
-- | 4     | 15               | Descartado DSI  |
-- | 5     | 20               | Descartado DSI  |
-- | 6     | 18               | Descartado DSI  |
-- | 7     | 12               | Descartado DSI  |

-- ========================================================================

-- PASSO 4: Verificar se ainda existem registros com "Descarte Piloto" nas etapas 4-7
-- Este SELECT NÃO deve retornar nenhum resultado

SELECT 
    id,
    barcode,
    etapa,
    temporada,
    status,
    modelo_code
FROM stock_entries
WHERE 
    temporada = '2025'
    AND etapa IN ('4', '5', '6', '7')
    AND status = 'Descarte Piloto';

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
        temporada = '2025'
        AND etapa IN ('4', '5', '6', '7')
        AND status = 'Descartado DSI'
        AND updated_at > NOW() - INTERVAL '5 minutes';
    
    -- Exibe mensagem de confirmação
    RAISE NOTICE '✅ Correção concluída com sucesso!';
    RAISE NOTICE '📊 Total de registros atualizados: %', affected_count;
    RAISE NOTICE '📅 Data/Hora da correção: %', NOW();
    RAISE NOTICE '🎯 Escopo: Etapas 4, 5, 6, 7 - Temporada 2025';
    RAISE NOTICE '🔄 Status alterado: "Descarte Piloto" → "Descartado DSI"';
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
--    - PASSO 3: Verificar resultado da atualização
--    - PASSO 4: Confirmar que não há mais registros com status antigo
--
-- 4. REVERSÃO: Se precisar reverter (fazer SOMENTE se necessário):
--    UPDATE stock_entries
--    SET status = 'Descarte Piloto', updated_at = NOW()
--    WHERE temporada = '2025' AND etapa IN ('4', '5', '6', '7') 
--    AND status = 'Descartado DSI' AND updated_at > 'DATA_DO_UPDATE';
--
-- 5. IMPACTO: Esta correção afeta apenas dados históricos
--    Não afeta a lógica da aplicação ou regras de negócio futuras
--
-- ========================================================================
