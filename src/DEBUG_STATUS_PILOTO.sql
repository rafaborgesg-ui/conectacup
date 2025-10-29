-- =========================================
-- DEBUG: Status "Piloto" mostrando ZERO
-- Execute este script no Supabase SQL Editor
-- =========================================

-- 1. VERIFICAR TODOS OS STATUS ÚNICOS
SELECT 
  '1. Status Únicos em stock_entries' as diagnostico;

SELECT 
  status,
  LENGTH(status) as tamanho,
  COUNT(*) as quantidade,
  -- Mostra os primeiros 50 caracteres ASCII
  ARRAY_TO_STRING(
    ARRAY(
      SELECT ASCII(SUBSTRING(status FROM n FOR 1))
      FROM generate_series(1, LEAST(LENGTH(status), 10)) n
    ),
    ','
  ) as char_codes
FROM stock_entries
WHERE status IS NOT NULL
GROUP BY status
ORDER BY quantidade DESC;

-- =========================================

-- 2. PROCURAR ESPECIFICAMENTE POR "PILOTO" (case-insensitive)
SELECT 
  '2. Status contendo "piloto" (case-insensitive)' as diagnostico;

SELECT 
  status,
  LENGTH(status) as tamanho,
  COUNT(*) as quantidade
FROM stock_entries
WHERE LOWER(status) LIKE '%piloto%'
GROUP BY status
ORDER BY quantidade DESC;

-- =========================================

-- 3. VERIFICAR STATUS CADASTRADOS NA TABELA tire_status
SELECT 
  '3. Status cadastrados em tire_status' as diagnostico;

SELECT 
  name,
  LENGTH(name) as tamanho,
  color,
  display_order,
  -- Mostra os primeiros 50 caracteres ASCII
  ARRAY_TO_STRING(
    ARRAY(
      SELECT ASCII(SUBSTRING(name FROM n FOR 1))
      FROM generate_series(1, LEAST(LENGTH(name), 10)) n
    ),
    ','
  ) as char_codes
FROM tire_status
ORDER BY display_order, name;

-- =========================================

-- 4. COMPARAR: Status em stock_entries que NÃO existem em tire_status
SELECT 
  '4. Status em stock_entries NÃO cadastrados em tire_status' as diagnostico;

SELECT 
  se.status,
  COUNT(*) as quantidade_pneus,
  'ATENÇÃO: Este status não está cadastrado!' as alerta
FROM stock_entries se
LEFT JOIN tire_status ts ON se.status = ts.name
WHERE ts.name IS NULL 
  AND se.status IS NOT NULL
GROUP BY se.status
ORDER BY quantidade_pneus DESC;

-- =========================================

-- 5. VERIFICAR ESPAÇOS EXTRAS
SELECT 
  '5. Status com espaços extras' as diagnostico;

SELECT 
  status,
  LENGTH(status) as tamanho_original,
  LENGTH(TRIM(status)) as tamanho_sem_espacos,
  CASE 
    WHEN status != TRIM(status) THEN '⚠️ TEM ESPAÇOS EXTRAS'
    ELSE '✅ OK'
  END as verificacao,
  COUNT(*) as quantidade
FROM stock_entries
WHERE status IS NOT NULL
GROUP BY status
HAVING status != TRIM(status);

-- =========================================

-- 6. ESPECÍFICO: Detalhes do status "Piloto"
SELECT 
  '6. Análise detalhada do status "Piloto"' as diagnostico;

SELECT 
  status,
  LENGTH(status) as tamanho,
  status = 'Piloto' as match_exato,
  LOWER(status) = 'piloto' as match_case_insensitive,
  TRIM(status) = 'Piloto' as match_sem_espacos,
  COUNT(*) as quantidade
FROM stock_entries
WHERE LOWER(status) = 'piloto'
GROUP BY status;

-- =========================================

-- 7. COMPARAÇÃO DIRETA: tire_status.name vs stock_entries.status
SELECT 
  '7. Comparação direta entre tire_status e stock_entries para "Piloto"' as diagnostico;

SELECT 
  'tire_status' as origem,
  name as valor,
  LENGTH(name) as tamanho,
  ARRAY_TO_STRING(
    ARRAY(
      SELECT ASCII(SUBSTRING(name FROM n FOR 1))
      FROM generate_series(1, LENGTH(name)) n
    ),
    ','
  ) as char_codes
FROM tire_status
WHERE LOWER(name) = 'piloto'

UNION ALL

SELECT 
  'stock_entries' as origem,
  DISTINCT status as valor,
  LENGTH(status) as tamanho,
  ARRAY_TO_STRING(
    ARRAY(
      SELECT ASCII(SUBSTRING(status FROM n FOR 1))
      FROM generate_series(1, LENGTH(status)) n
    ),
    ','
  ) as char_codes
FROM stock_entries
WHERE LOWER(status) = 'piloto';

-- =========================================

-- 8. CONTAGEM POR STATUS (incluindo NULL)
SELECT 
  '8. Resumo geral de todos os status' as diagnostico;

SELECT 
  COALESCE(status, '(NULL)') as status,
  COUNT(*) as quantidade,
  ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) as percentual
FROM stock_entries
GROUP BY status
ORDER BY quantidade DESC;

-- =========================================

-- 9. VERIFICAR SE HÁ STATUS "DESCARTADO" QUE PODE ESTAR FILTRANDO "Piloto"
SELECT 
  '9. Status que contêm "descart" (podem ser filtrados)' as diagnostico;

SELECT 
  status,
  COUNT(*) as quantidade,
  CASE 
    WHEN status IN ('Descartado DSI', 'Descarte DSI', 'Descarte') 
    THEN '🗑️ FILTRADO pelo Dashboard'
    ELSE '✅ NÃO filtrado'
  END as sera_filtrado
FROM stock_entries
WHERE LOWER(status) LIKE '%descart%'
GROUP BY status
ORDER BY quantidade DESC;

-- =========================================

-- 10. ANÁLISE FINAL: Resumo do problema
SELECT 
  '10. RESUMO FINAL' as diagnostico;

WITH 
  total_piloto_banco AS (
    SELECT COUNT(*) as qtd
    FROM stock_entries
    WHERE LOWER(status) = 'piloto'
  ),
  piloto_cadastrado AS (
    SELECT COUNT(*) as existe
    FROM tire_status
    WHERE LOWER(name) = 'piloto'
  ),
  piloto_exato AS (
    SELECT COUNT(*) as qtd
    FROM stock_entries
    WHERE status = 'Piloto'  -- Case-sensitive
  )
SELECT 
  (SELECT qtd FROM total_piloto_banco) as pneus_com_piloto_banco,
  (SELECT existe FROM piloto_cadastrado) as piloto_existe_tire_status,
  (SELECT qtd FROM piloto_exato) as match_case_sensitive,
  CASE 
    WHEN (SELECT qtd FROM total_piloto_banco) = 0 
    THEN '❌ Não há pneus com status "Piloto" no banco'
    WHEN (SELECT existe FROM piloto_cadastrado) = 0 
    THEN '❌ Status "Piloto" NÃO está cadastrado em tire_status'
    WHEN (SELECT qtd FROM piloto_exato) = 0 
    THEN '⚠️ Problema de case-sensitivity ou espaços'
    ELSE '✅ Dados parecem OK - problema pode estar no código'
  END as diagnostico_final;

-- =========================================
-- FIM DO DEBUG
-- =========================================

-- INSTRUÇÕES:
-- 1. Execute TODOS os comandos acima sequencialmente
-- 2. Copie os resultados de CADA query
-- 3. Compartilhe os resultados para análise
-- 
-- QUERIES MAIS IMPORTANTES:
-- - Query 2: Mostra quantos pneus têm "piloto" no status
-- - Query 4: Mostra se "Piloto" está cadastrado em tire_status
-- - Query 7: Compara exatamente os caracteres
-- - Query 10: Resumo do diagnóstico
