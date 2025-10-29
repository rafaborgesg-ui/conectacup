-- ═══════════════════════════════════════════════════════════════
-- 🎨 CORRIGIR COR DO STATUS "PILOTO" PARA VERDE
-- ═══════════════════════════════════════════════════════════════

-- PROBLEMA: Status "Piloto" estava com cor ROSA (#EC4899)
-- SOLUÇÃO: Atualizar para VERDE (#10B981) conforme cadastro

-- ═══════════════════════════════════════════════════════════════

-- PASSO 1: Verificar cor atual
-- ─────────────────────────────────────────────────────────────

SELECT 
  id,
  name,
  color,
  CASE 
    WHEN color = '#10B981' THEN '✅ VERDE (correto)'
    WHEN color = '#EC4899' THEN '❌ ROSA (precisa corrigir)'
    ELSE '⚠️ OUTRA COR: ' || color
  END as status
FROM tire_status
WHERE name = 'Piloto';

-- ═══════════════════════════════════════════════════════════════

-- PASSO 2: Atualizar para VERDE (se necessário)
-- ─────────────────────────────────────────────────────────────

UPDATE tire_status
SET color = '#10B981'
WHERE name = 'Piloto'
  AND color != '#10B981';

-- Resultado esperado: 
-- - "Success. 1 row updated" (se estava com cor errada)
-- - "Success. 0 rows updated" (se já estava verde)

-- ═══════════════════════════════════════════════════════════════

-- PASSO 3: Verificar resultado
-- ─────────────────────────────────────────────────────────────

SELECT 
  name,
  color,
  '✅ Corrigido!' as status
FROM tire_status
WHERE name = 'Piloto'
  AND color = '#10B981';

-- ═══════════════════════════════════════════════════════════════

-- PASSO 4: Ver todos os status com cores
-- ─────────────────────────────────────────────────────────────

SELECT 
  name,
  color,
  CASE color
    WHEN '#3B82F6' THEN '🔵 Azul'
    WHEN '#10B981' THEN '🟢 Verde'
    WHEN '#F59E0B' THEN '🟠 Laranja'
    WHEN '#8B5CF6' THEN '🟣 Roxo'
    WHEN '#DC2626' THEN '🔴 Vermelho'
    WHEN '#EF4444' THEN '🔴 Vermelho claro'
    WHEN '#EC4899' THEN '🌸 Rosa (ANTIGO)'
    ELSE '⚪ Outra cor'
  END as cor_visual,
  display_order
FROM tire_status
ORDER BY display_order NULLS LAST, name;

-- ═══════════════════════════════════════════════════════════════
-- ✅ PRONTO! Status "Piloto" agora está VERDE
-- ═══════════════════════════════════════════════════════════════
