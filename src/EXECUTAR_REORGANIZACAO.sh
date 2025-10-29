#!/bin/bash

# 🚀 Script de Reorganização da Documentação
# Porsche Cup Brasil - Sistema de Gestão de Pneus
# Data: 2025-01-24
# 
# Este script move 150+ arquivos .md e .sql da raiz para estrutura organizada em /docs

echo "🚀 Iniciando reorganização da documentação..."
echo ""

# ============================================================================
# PASSO 1: Criar Estrutura de Pastas
# ============================================================================

echo "📁 Passo 1/11: Criando estrutura de pastas..."

mkdir -p docs/migrations/sql
mkdir -p docs/migrations/guides
mkdir -p docs/troubleshooting/auth
mkdir -p docs/troubleshooting/database
mkdir -p docs/troubleshooting/import
mkdir -p docs/troubleshooting/status
mkdir -p docs/troubleshooting/other
mkdir -p docs/features/pwa
mkdir -p docs/features/loading-states
mkdir -p docs/features/modo-rapido
mkdir -p docs/features/mobile
mkdir -p docs/features/performance
mkdir -p docs/features/quick-wins
mkdir -p docs/features/components
mkdir -p docs/ux-audit/audits
mkdir -p docs/ux-audit/improvements
mkdir -p docs/ux-audit/reviews
mkdir -p docs/releases
mkdir -p docs/business
mkdir -p docs/guides
mkdir -p docs/archive

echo "✅ Estrutura de pastas criada!"
echo ""

# ============================================================================
# PASSO 2: Mover SQL Files para /docs/migrations/sql/
# ============================================================================

echo "🗄️ Passo 2/11: Movendo arquivos SQL..."

# Migrations
mv MIGRATION_BUSINESS_RULES_TABLE.sql docs/migrations/sql/ 2>/dev/null || true
mv MIGRATION_STATUS_COMPLETA.sql docs/migrations/sql/ 2>/dev/null || true

# Setup
mv SETUP_STOCK_ENTRIES_TABLE.sql docs/migrations/sql/ 2>/dev/null || true
mv INSERT_BUSINESS_RULES_DATA.sql docs/migrations/sql/ 2>/dev/null || true
mv RESET_BUSINESS_RULES_TABLE.sql docs/migrations/sql/ 2>/dev/null || true

# Containers Fixes
mv FIX_ALL_CONTAINER_CONSTRAINTS.sql docs/migrations/sql/ 2>/dev/null || true
mv FIX_CONTAINERS_CHECK_EMPTY_ID.sql docs/migrations/sql/ 2>/dev/null || true
mv FIX_CONTAINERS_CHECK_FINAL.sql docs/migrations/sql/ 2>/dev/null || true
mv FIX_CONTAINERS_CHECK_NULL.sql docs/migrations/sql/ 2>/dev/null || true
mv FIX_CONTAINERS_FK.sql docs/migrations/sql/ 2>/dev/null || true
mv FIX_CONTAINERS_FK_SAFE.sql docs/migrations/sql/ 2>/dev/null || true

# Status Fixes
mv FIX_STATUS_DESCARTE_PILOTO_2025.sql docs/migrations/sql/ 2>/dev/null || true
mv FIX_DESCARTE_STATUS.sql docs/migrations/sql/ 2>/dev/null || true
mv FIX_DESCARTADO_DSI_CLEAR_CONTAINER.sql docs/migrations/sql/ 2>/dev/null || true
mv FIX_CONTAINER_OCCUPANCY_DESCARTADO_DSI.sql docs/migrations/sql/ 2>/dev/null || true
mv FIX_TIRE_STATUS_DELETE.sql docs/migrations/sql/ 2>/dev/null || true
mv UPDATE_STATUS_DESCARTADO_DSI.sql docs/migrations/sql/ 2>/dev/null || true

# Barcode Fixes
mv FIX_CORRUPTED_BARCODES.sql docs/migrations/sql/ 2>/dev/null || true
mv FIX_BARCODE_TYPE_VERIFICATION.sql docs/migrations/sql/ 2>/dev/null || true
mv VERIFY_NO_UUID_BARCODES.sql docs/migrations/sql/ 2>/dev/null || true

# Cleanup
mv CLEAR_ALL_CONTAINERS.sql docs/migrations/sql/ 2>/dev/null || true
mv DELETE_UUID_AGORA.sql docs/migrations/sql/ 2>/dev/null || true
mv QUICK_FIX.sql docs/migrations/sql/ 2>/dev/null || true
mv DEBUG_STATUS_PILOTO.sql docs/migrations/sql/ 2>/dev/null || true

echo "✅ SQL files movidos! (~25 arquivos)"
echo ""

# ============================================================================
# PASSO 3: Mover Guias de Migração para /docs/migrations/guides/
# ============================================================================

echo "📚 Passo 3/11: Movendo guias de migração..."

mv MIGRATION_STEP_BY_STEP.md docs/migrations/guides/ 2>/dev/null || true
mv MIGRATION_NOTES.md docs/migrations/guides/ 2>/dev/null || true
mv README_MIGRATION.md docs/migrations/guides/ 2>/dev/null || true

echo "✅ Guias de migração movidos!"
echo ""

# ============================================================================
# PASSO 4: Mover Troubleshooting - Auth
# ============================================================================

echo "🔐 Passo 4/11: Movendo troubleshooting/auth..."

mv FIX_AUTH_401_ERRORS.md docs/troubleshooting/auth/ 2>/dev/null || true
mv FIX_AUTH_LOGIN_REQUIRED.md docs/troubleshooting/auth/ 2>/dev/null || true
mv INSTRUCOES_URGENTES_LOGIN.md docs/troubleshooting/auth/ 2>/dev/null || true
mv FIX_HOOKS_ERROR.md docs/troubleshooting/auth/ 2>/dev/null || true

echo "✅ Auth troubleshooting movido! (4 arquivos)"
echo ""

# ============================================================================
# PASSO 5: Mover Troubleshooting - Database
# ============================================================================

echo "🗄️ Passo 5/11: Movendo troubleshooting/database..."

git mv FIX_CONTAINERS_CHECK_CONSTRAINT.md docs/troubleshooting/database/ 2>/dev/null || true
git mv TROUBLESHOOTING_CONTAINERS_CHECK.md docs/troubleshooting/database/ 2>/dev/null || true
git mv SOLUCAO_CONTAINERS_CHECK_RESUMO.md docs/troubleshooting/database/ 2>/dev/null || true
git mv SOLUCAO_CONTAINER_NULL.md docs/troubleshooting/database/ 2>/dev/null || true

git mv FIX_UUID_BARCODE_ERROR.md docs/troubleshooting/database/ 2>/dev/null || true
git mv FIX_UUID_ERROR_FINAL_SOLUTION.md docs/troubleshooting/database/ 2>/dev/null || true
git mv FIX_UUID_MODEL_ID_ERROR.md docs/troubleshooting/database/ 2>/dev/null || true
git mv SOLUCAO_FINAL_UUID_BARCODE.md docs/troubleshooting/database/ 2>/dev/null || true

git mv TROUBLESHOOTING_MIGRATION.md docs/troubleshooting/database/ 2>/dev/null || true
git mv SOLUCAO_IMEDIATA.md docs/troubleshooting/database/ 2>/dev/null || true

echo "✅ Database troubleshooting movido! (10 arquivos)"
echo ""

# ============================================================================
# PASSO 6: Mover Troubleshooting - Import
# ============================================================================

echo "📥 Passo 6/11: Movendo troubleshooting/import..."

git mv DEBUG_ENTRADA_PLANILHA.md docs/troubleshooting/import/ 2>/dev/null || true
git mv FIX_DATA_IMPORT_COUNT.md docs/troubleshooting/import/ 2>/dev/null || true
git mv FIX_DATA_IMPORT_RESET.md docs/troubleshooting/import/ 2>/dev/null || true
git mv FIX_ENTRADA_PLANILHA_MODELO_CODE.md docs/troubleshooting/import/ 2>/dev/null || true

echo "✅ Import troubleshooting movido! (4 arquivos)"
echo ""

# ============================================================================
# PASSO 7: Mover Troubleshooting - Status
# ============================================================================

echo "📊 Passo 7/11: Movendo troubleshooting/status..."

git mv CORRECAO_STATUS_DESCARTADO_DSI.md docs/troubleshooting/status/ 2>/dev/null || true
git mv CORRECAO_STATUS_DESCARTE.md docs/troubleshooting/status/ 2>/dev/null || true
git mv DEBUG_STATUS_PILOTO_ZERO.md docs/troubleshooting/status/ 2>/dev/null || true
git mv FIX_STATUS_COUNT_ACTIVE_ENTRIES.md docs/troubleshooting/status/ 2>/dev/null || true
git mv FIX_STATUS_DELETE_INSTRUCTIONS.md docs/troubleshooting/status/ 2>/dev/null || true
git mv FIX_STATUS_ERRORS_FINAL.md docs/troubleshooting/status/ 2>/dev/null || true
git mv INSTRUCOES_CORRECAO_STATUS.md docs/troubleshooting/status/ 2>/dev/null || true

echo "✅ Status troubleshooting movido! (7 arquivos)"
echo ""

# ============================================================================
# PASSO 8: Mover Troubleshooting - Other
# ============================================================================

echo "🔧 Passo 8/11: Movendo troubleshooting/other..."

git mv FIX_BARCODE_CHECK_SQL_TABLE.md docs/troubleshooting/other/ 2>/dev/null || true
git mv FIX_BARCODE_DUPLICATE_FALSE_POSITIVE.md docs/troubleshooting/other/ 2>/dev/null || true

git mv FIX_BULK_DELETE_UUID_ERROR.md docs/troubleshooting/other/ 2>/dev/null || true
git mv FIX_BULK_DELETE_UUID_FINAL.md docs/troubleshooting/other/ 2>/dev/null || true
git mv FIX_BULK_ENTRY_UUID_ERROR.md docs/troubleshooting/other/ 2>/dev/null || true

git mv FIX_CHECKBARCODEEXISTS_ERROR.md docs/troubleshooting/other/ 2>/dev/null || true
git mv FIX_EDGE_FUNCTION_TSLIB_ERROR.md docs/troubleshooting/other/ 2>/dev/null || true
git mv FIX_LIMIT_1000_SUPABASE.md docs/troubleshooting/other/ 2>/dev/null || true
git mv FIX_POSTGREST_1000_LIMIT.md docs/troubleshooting/other/ 2>/dev/null || true

git mv FIX_TIRE_DISCARD_ERRORS.md docs/troubleshooting/other/ 2>/dev/null || true
git mv FIX_TIRE_DISCARD_SUPABASE.md docs/troubleshooting/other/ 2>/dev/null || true
git mv FIX_TIRE_STOCK_ENTRY_SQL_INTEGRATION.md docs/troubleshooting/other/ 2>/dev/null || true

git mv FIX_DUPLICATE_EXPORT_SUMMARY.md docs/troubleshooting/other/ 2>/dev/null || true
git mv FIX_DELETE_UUID_BARCODE_CONFUSION.md docs/troubleshooting/other/ 2>/dev/null || true

echo "✅ Other troubleshooting movido! (14 arquivos)"
echo ""

# ============================================================================
# PASSO 9: Mover Features
# ============================================================================

echo "✨ Passo 9/11: Movendo features..."

# PWA
git mv PWA_README.md docs/features/pwa/ 2>/dev/null || true
git mv PWA_QUICK_START.md docs/features/pwa/ 2>/dev/null || true
git mv PWA_SETUP_GUIDE.md docs/features/pwa/ 2>/dev/null || true
git mv PWA_STATUS.md docs/features/pwa/ 2>/dev/null || true
git mv PWA_ICONS_STATUS.md docs/features/pwa/ 2>/dev/null || true
git mv PWA_INDEX.md docs/features/pwa/ 2>/dev/null || true
git mv PWA_RESUMO.md docs/features/pwa/ 2>/dev/null || true

# Loading States
git mv LOADING_STATES_COMPLETADOS.md docs/features/loading-states/ 2>/dev/null || true
git mv LOADING_STATES_COMPLETO.md docs/features/loading-states/ 2>/dev/null || true
git mv LOADING_STATES_FINAL_STATUS.md docs/features/loading-states/ 2>/dev/null || true
git mv LOADING_STATES_IMPLEMENTADO.md docs/features/loading-states/ 2>/dev/null || true
git mv LOADING_STATES_QUICK_GUIDE.md docs/features/loading-states/ 2>/dev/null || true
git mv LOADING_STATES_STATUS.md docs/features/loading-states/ 2>/dev/null || true

# Modo Rápido
git mv MODO_RAPIDO_README.md docs/features/modo-rapido/ 2>/dev/null || true
git mv MODO_RAPIDO_1MIN.md docs/features/modo-rapido/ 2>/dev/null || true
git mv MODO_RAPIDO_GUIA.md docs/features/modo-rapido/ 2>/dev/null || true
git mv MODO_RAPIDO_IMPLEMENTADO.md docs/features/modo-rapido/ 2>/dev/null || true
git mv MODO_RAPIDO_INDICE.md docs/features/modo-rapido/ 2>/dev/null || true
git mv MODO_RAPIDO_VISUAL.md docs/features/modo-rapido/ 2>/dev/null || true

# Mobile
git mv MOBILE_ENHANCEMENTS_GUIDE.md docs/features/mobile/ 2>/dev/null || true
git mv MOBILE_UX_SUMMARY.md docs/features/mobile/ 2>/dev/null || true
git mv SPRINT_5_MOBILE_INTEGRADO.md docs/features/mobile/ 2>/dev/null || true

# Performance
git mv PERFORMANCE_OPTIMIZATION_SUMMARY.md docs/features/performance/ 2>/dev/null || true
git mv PERFORMANCE_QUICK_START.md docs/features/performance/ 2>/dev/null || true
git mv PERFORMANCE_VISUAL_GUIDE.md docs/features/performance/ 2>/dev/null || true
git mv QUERIES_OPTIMIZATION_IMPLEMENTADO.md docs/features/performance/ 2>/dev/null || true
git mv USE_DATA_FETCH_IMPLEMENTADO.md docs/features/performance/ 2>/dev/null || true

# Quick Wins
git mv QUICK_WINS_SUMMARY.md docs/features/quick-wins/ 2>/dev/null || true
git mv QUICK_WINS_FINAL_SUMMARY.md docs/features/quick-wins/ 2>/dev/null || true
git mv QUICK_WINS_ANIMATIONS.md docs/features/quick-wins/ 2>/dev/null || true
git mv QUICK_WINS_CLEANUP.md docs/features/quick-wins/ 2>/dev/null || true
git mv QUICK_WINS_EXPORT_MENU.md docs/features/quick-wins/ 2>/dev/null || true
git mv QUICK_WINS_MOBILE_FILTERS.md docs/features/quick-wins/ 2>/dev/null || true
git mv QUICK_WIN_EXPORT_MENU_DONE.md docs/features/quick-wins/ 2>/dev/null || true
git mv QUICK_WIN_MOBILE_FILTERS_DONE.md docs/features/quick-wins/ 2>/dev/null || true
git mv QUICK_WIN_SPACING_TOKENS_DONE.md docs/features/quick-wins/ 2>/dev/null || true
git mv QUICK_WIN_SPACING_TOKENS_GUIDE.md docs/features/quick-wins/ 2>/dev/null || true

# Components
git mv STATCARD_REUTILIZAVEL_IMPLEMENTADO.md docs/features/components/ 2>/dev/null || true
git mv TOAST_UNDOABLE_IMPLEMENTADO.md docs/features/components/ 2>/dev/null || true
git mv TOAST_UNDOABLE_INTEGRADO_COMPLETO.md docs/features/components/ 2>/dev/null || true
git mv VALIDACAO_FORMS_IMPLEMENTADO.md docs/features/components/ 2>/dev/null || true
git mv COLUMN_PREFERENCES_FEATURE.md docs/features/components/ 2>/dev/null || true
git mv DASHBOARD_GRAFICOS_IMPLEMENTADO.md docs/features/components/ 2>/dev/null || true

echo "✅ Features movidas! (~42 arquivos)"
echo ""

# ============================================================================
# PASSO 10: Mover UX/UI Audits
# ============================================================================

echo "🎨 Passo 10/11: Movendo UX/UI audits..."

# Audits
git mv UX_AUDIT_COMPLETO_2025.md docs/ux-audit/audits/ 2>/dev/null || true
git mv UX_AUDIT_REVISADO_2025.md docs/ux-audit/audits/ 2>/dev/null || true
git mv UX_AUDIT_STATUS_FINAL.md docs/ux-audit/audits/ 2>/dev/null || true
git mv UX_UI_ANALISE_ESPECIALIZADA_2025.md docs/ux-audit/audits/ 2>/dev/null || true

# Improvements
git mv UX_IMPROVEMENTS_INDEX.md docs/ux-audit/improvements/ 2>/dev/null || true
git mv UX_IMPROVEMENTS_PRIORITY_1.md docs/ux-audit/improvements/ 2>/dev/null || true
git mv UX_MELHORIAS_IMPLEMENTADAS_FINAL.md docs/ux-audit/improvements/ 2>/dev/null || true
git mv MELHORIAS_UX_IMPLEMENTADAS.md docs/ux-audit/improvements/ 2>/dev/null || true
git mv ACESSIBILIDADE_FASE1_PROGRESSO.md docs/ux-audit/improvements/ 2>/dev/null || true

# Reviews
git mv UX_REVIEW_RESUMO_EXECUTIVO.md docs/ux-audit/reviews/ 2>/dev/null || true

echo "✅ UX/UI audits movidos! (10 arquivos)"
echo ""

# ============================================================================
# PASSO 11: Mover Releases, Business, Guides
# ============================================================================

echo "📦 Passo 11/11: Movendo releases, business e guides..."

# Releases
git mv STATUS_PROJETO.md docs/releases/ 2>/dev/null || true
git mv PROGRESSO_SESSAO_ATUAL.md docs/releases/ 2>/dev/null || true
git mv MELHORIAS_IMPLEMENTADAS_RESUMO.md docs/releases/ 2>/dev/null || true
git mv INTEGRACAO_CONCLUIDA.md docs/releases/ 2>/dev/null || true
git mv INTEGRACOES_100_COMPLETO.md docs/releases/ 2>/dev/null || true
git mv LIMPEZA_COMPLETA.md docs/releases/ 2>/dev/null || true
git mv ROADMAP_MELHORIAS_2025.md docs/releases/ 2>/dev/null || true
git mv PROXIMAS_MELHORIAS_SUGERIDAS.md docs/releases/ 2>/dev/null || true
git mv PROXIMOS_PASSOS.md docs/releases/ 2>/dev/null || true

# Business
git mv BUSINESS_RULES_SCHEMA.md docs/business/ 2>/dev/null || true
git mv ARCS_AUTO_REGISTRATION_LOGIC.md docs/business/ 2>/dev/null || true
git mv ARCS_DATA_UPDATE_FIELDS.md docs/business/ 2>/dev/null || true

# Guides
git mv DEPLOYMENT.md docs/guides/ 2>/dev/null || true
git mv OPTIMIZATION_INDEX.md docs/guides/ 2>/dev/null || true
git mv COMO_COMPLETAR_LIMPEZA.md docs/guides/ 2>/dev/null || true
git mv LOCALIZACAO_BOTAO_COLUNAS.md docs/guides/ 2>/dev/null || true
git mv VISUAL_BOTAO_COLUNAS.md docs/guides/ 2>/dev/null || true
git mv VISUAL_FEEDBACK_SUMMARY.md docs/guides/ 2>/dev/null || true
git mv USE_DATA_FETCH_QUICK_REFERENCE.md docs/guides/ 2>/dev/null || true

# Archive (obsoletos)
git mv REFATORACAO_TIRESTOCK_VALIDACAO.md docs/archive/ 2>/dev/null || true
git mv SYNC_DASHBOARD_DISCARD_REPORTS.md docs/archive/ 2>/dev/null || true
git mv RESUMO_INTEGRACOES.md docs/archive/ 2>/dev/null || true

echo "✅ Releases, business e guides movidos!"
echo ""

# ============================================================================
# FINALIZAÇÃO
# ============================================================================

echo "🎉 REORGANIZAÇÃO COMPLETA!"
echo ""
echo "📊 Resumo:"
echo "  ✅ SQL files: ~25 arquivos → /docs/migrations/sql/"
echo "  ✅ Troubleshooting: ~39 arquivos → /docs/troubleshooting/"
echo "  ✅ Features: ~42 arquivos → /docs/features/"
echo "  ✅ UX Audits: ~10 arquivos → /docs/ux-audit/"
echo "  ✅ Releases: ~9 arquivos → /docs/releases/"
echo "  ✅ Business: 3 arquivos → /docs/business/"
echo "  ✅ Guides: ~7 arquivos → /docs/guides/"
echo "  ✅ Archive: 3 arquivos → /docs/archive/"
echo ""
echo "📁 Estrutura final:"
tree docs/ -L 2 || ls -R docs/
echo ""
echo "📝 Próximos passos:"
echo "  1. Revise os arquivos movidos"
echo "  2. Verifique se há arquivos faltando na raiz"
echo "  3. Commit das mudanças:"
echo "     git add ."
echo "     git commit -m 'docs: reorganizar 120+ arquivos em estrutura lógica'"
echo ""
echo "✅ Script executado com sucesso!"
