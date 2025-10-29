-- ═══════════════════════════════════════════════════════════════
-- 🔍 VERIFICAR COR DO STATUS "PILOTO" NO BANCO
-- ═══════════════════════════════════════════════════════════════

-- Ver todos os status com suas cores
SELECT 
  id,
  name,
  color,
  display_order,
  created_at
FROM tire_status
ORDER BY display_order NULLS LAST, name;

-- Ver especificamente o status "Piloto"
SELECT 
  name,
  color,
  CASE 
    WHEN color = '#10B981' THEN '✅ VERDE (correto)'
    WHEN color = '#EC4899' THEN '❌ ROSA (antigo - precisa atualizar)'
    ELSE '⚠️ OUTRA COR'
  END as status_cor
FROM tire_status
WHERE name = 'Piloto';

-- ═══════════════════════════════════════════════════════════════
-- Se a cor estiver ROSA (#EC4899), execute:
-- ═══════════════════════════════════════════════════════════════

-- UPDATE tire_status
-- SET color = '#10B981'
-- WHERE name = 'Piloto';

-- ═══════════════════════════════════════════════════════════════
