-- ═══════════════════════════════════════════════════════════════
-- ⚡ EXECUTAR AGORA - Garantir Cores Corretas de Todos os Status
-- ═══════════════════════════════════════════════════════════════
-- 
-- IMPORTANTE: Este script sincroniza as cores do banco com o sistema
-- Execute no Supabase SQL Editor:
-- https://supabase.com/dashboard/project/nflgqugaabtxzifyhjor/sql
-- 
-- ═══════════════════════════════════════════════════════════════

-- 1️⃣ ATUALIZAR TODAS AS CORES (caso estejam desatualizadas)
-- ─────────────────────────────────────────────────────────────

-- Novo (Azul)
UPDATE tire_status SET color = '#3B82F6' WHERE name = 'Novo' AND color != '#3B82F6';

-- Pneu CUP (Verde)
UPDATE tire_status SET color = '#10B981' WHERE name = 'Pneu CUP' AND color != '#10B981';

-- Usado (Laranja)
UPDATE tire_status SET color = '#F59E0B' WHERE name = 'Usado' AND color != '#F59E0B';

-- Recapado (Roxo)
UPDATE tire_status SET color = '#8B5CF6' WHERE name = 'Recapado' AND color != '#8B5CF6';

-- 🎯 PILOTO (VERDE) ← CORREÇÃO PRINCIPAL
UPDATE tire_status SET color = '#10B981' WHERE name = 'Piloto' AND color != '#10B981';

-- Descarte (Vermelho)
UPDATE tire_status SET color = '#DC2626' WHERE name = 'Descarte' AND color != '#DC2626';

-- Descarte Piloto (Vermelho claro)
UPDATE tire_status SET color = '#EF4444' WHERE name = 'Descarte Piloto' AND color != '#EF4444';

-- ═══════════════════════════════════════════════════════════════

-- 2️⃣ VERIFICAR TODAS AS CORES
-- ─────────────────────────────────────────────────────────────

SELECT 
  name,
  color,
  CASE color
    WHEN '#3B82F6' THEN '🔵 Azul (Novo)'
    WHEN '#10B981' THEN '🟢 Verde (Pneu CUP / Piloto)'
    WHEN '#F59E0B' THEN '🟠 Laranja (Usado)'
    WHEN '#8B5CF6' THEN '🟣 Roxo (Recapado)'
    WHEN '#DC2626' THEN '🔴 Vermelho (Descarte)'
    WHEN '#EF4444' THEN '🔴 Vermelho claro (Descarte Piloto)'
    ELSE '⚠️ COR INCORRETA: ' || color
  END as cor_status,
  display_order,
  CASE 
    WHEN name = 'Novo' AND color = '#3B82F6' THEN '✅'
    WHEN name = 'Pneu CUP' AND color = '#10B981' THEN '✅'
    WHEN name = 'Usado' AND color = '#F59E0B' THEN '✅'
    WHEN name = 'Recapado' AND color = '#8B5CF6' THEN '✅'
    WHEN name = 'Piloto' AND color = '#10B981' THEN '✅'
    WHEN name = 'Descarte' AND color = '#DC2626' THEN '✅'
    WHEN name = 'Descarte Piloto' AND color = '#EF4444' THEN '✅'
    ELSE '❌'
  END as check_status
FROM tire_status
ORDER BY display_order NULLS LAST, name;

-- ═══════════════════════════════════════════════════════════════

-- 3️⃣ VERIFICAÇÃO ESPECÍFICA DO STATUS "PILOTO"
-- ─────────────────────────────────────────────────────────────

SELECT 
  '🎯 STATUS PILOTO' as verificacao,
  name,
  color,
  CASE 
    WHEN color = '#10B981' THEN '✅ VERDE (CORRETO!)'
    WHEN color = '#EC4899' THEN '❌ ROSA (ANTIGO - PRECISA CORRIGIR)'
    ELSE '⚠️ OUTRA COR: ' || color
  END as resultado
FROM tire_status
WHERE name = 'Piloto';

-- Resultado esperado:
-- name: "Piloto"
-- color: "#10B981"
-- resultado: "✅ VERDE (CORRETO!)"

-- ═══════════════════════════════════════════════════════════════

-- 4️⃣ CONTAGEM DE STATUS CORRETOS vs INCORRETOS
-- ─────────────────────────────────────────────────────────────

SELECT 
  COUNT(*) FILTER (WHERE 
    (name = 'Novo' AND color = '#3B82F6') OR
    (name = 'Pneu CUP' AND color = '#10B981') OR
    (name = 'Usado' AND color = '#F59E0B') OR
    (name = 'Recapado' AND color = '#8B5CF6') OR
    (name = 'Piloto' AND color = '#10B981') OR
    (name = 'Descarte' AND color = '#DC2626') OR
    (name = 'Descarte Piloto' AND color = '#EF4444')
  ) as cores_corretas,
  COUNT(*) FILTER (WHERE NOT (
    (name = 'Novo' AND color = '#3B82F6') OR
    (name = 'Pneu CUP' AND color = '#10B981') OR
    (name = 'Usado' AND color = '#F59E0B') OR
    (name = 'Recapado' AND color = '#8B5CF6') OR
    (name = 'Piloto' AND color = '#10B981') OR
    (name = 'Descarte' AND color = '#DC2626') OR
    (name = 'Descarte Piloto' AND color = '#EF4444')
  )) as cores_incorretas,
  COUNT(*) as total_status
FROM tire_status
WHERE name IN ('Novo', 'Pneu CUP', 'Usado', 'Recapado', 'Piloto', 'Descarte', 'Descarte Piloto');

-- Resultado esperado:
-- cores_corretas: 7
-- cores_incorretas: 0
-- total_status: 7

-- ═══════════════════════════════════════════════════════════════
-- ✅ PRONTO! Todas as cores estão sincronizadas
-- ═══════════════════════════════════════════════════════════════
-- 
-- 📋 PRÓXIMOS PASSOS:
-- 
-- 1. ✅ Executar este SQL no Supabase
-- 2. 🧹 Limpar cache do navegador:
--    - Abrir console (F12)
--    - Executar: localStorage.clear(); sessionStorage.clear(); location.reload();
-- 3. 👁️ Verificar visualmente:
--    - Dashboard → Clicar em qualquer card → Ver badges coloridos
--    - Reports → Ver coluna "Status" com cores corretas
--    - Stock Adjustment → Ver status com cores do cadastro
-- 4. ✅ Confirmar "Piloto" aparece VERDE 🟢
-- 
-- ═══════════════════════════════════════════════════════════════
