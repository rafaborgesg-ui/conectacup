#!/bin/bash

# 🚀 Script de Reorganização da Documentação - OTIMIZADO
# Porsche Cup Brasil - Sistema de Gestão de Pneus
# Data: 2025-01-24

echo "🚀 Iniciando reorganização da documentação..."
echo ""

# Criar estrutura de pastas
echo "📁 Criando estrutura..."
mkdir -p docs/migrations/{sql,guides}
mkdir -p docs/troubleshooting/{auth,database,import,status,other}
mkdir -p docs/features/{pwa,loading-states,modo-rapido,mobile,performance,quick-wins,components}
mkdir -p docs/ux-audit/{audits,improvements,reviews}
mkdir -p docs/{releases,business,guides,archive}
echo "✅ Pastas criadas!"
echo ""

# SQL Files
echo "🗄️ Movendo SQL files..."
mv MIGRATION_*.sql INSERT_*.sql SETUP_*.sql RESET_*.sql docs/migrations/sql/ 2>/dev/null || true
mv FIX_*.sql UPDATE_*.sql CLEAR_*.sql DELETE_*.sql VERIFY_*.sql QUICK_FIX.sql DEBUG_STATUS_PILOTO.sql docs/migrations/sql/ 2>/dev/null || true
echo "✅ SQL movido!"
echo ""

# Guias de Migração
echo "📚 Movendo guias de migração..."
mv MIGRATION_STEP_BY_STEP.md MIGRATION_NOTES.md README_MIGRATION.md docs/migrations/guides/ 2>/dev/null || true
echo "✅ Guias movidos!"
echo ""

# Troubleshooting - Auth
echo "🔐 Movendo troubleshooting/auth..."
mv FIX_AUTH_*.md INSTRUCOES_URGENTES_LOGIN.md FIX_HOOKS_ERROR.md docs/troubleshooting/auth/ 2>/dev/null || true
echo "✅ Auth movido!"
echo ""

# Troubleshooting - Database  
echo "🗄️ Movendo troubleshooting/database..."
mv FIX_CONTAINERS_CHECK_CONSTRAINT.md TROUBLESHOOTING_CONTAINERS_CHECK.md docs/troubleshooting/database/ 2>/dev/null || true
mv SOLUCAO_CONTAINERS_CHECK_RESUMO.md SOLUCAO_CONTAINER_NULL.md docs/troubleshooting/database/ 2>/dev/null || true
mv FIX_UUID_*.md SOLUCAO_FINAL_UUID_BARCODE.md docs/troubleshooting/database/ 2>/dev/null || true
mv TROUBLESHOOTING_MIGRATION.md SOLUCAO_IMEDIATA.md docs/troubleshooting/database/ 2>/dev/null || true
echo "✅ Database movido!"
echo ""

# Troubleshooting - Import
echo "📥 Movendo troubleshooting/import..."
mv DEBUG_ENTRADA_*.md FIX_DATA_IMPORT_*.md FIX_ENTRADA_*.md docs/troubleshooting/import/ 2>/dev/null || true
echo "✅ Import movido!"
echo ""

# Troubleshooting - Status
echo "📊 Movendo troubleshooting/status..."
mv CORRECAO_STATUS_*.md DEBUG_STATUS_PILOTO_ZERO.md docs/troubleshooting/status/ 2>/dev/null || true
mv FIX_STATUS_*.md INSTRUCOES_CORRECAO_STATUS.md docs/troubleshooting/status/ 2>/dev/null || true
echo "✅ Status movido!"
echo ""

# Troubleshooting - Other
echo "🔧 Movendo troubleshooting/other..."
mv FIX_BARCODE_*.md FIX_BULK_*.md FIX_CHECKBARCODEEXISTS_*.md docs/troubleshooting/other/ 2>/dev/null || true
mv FIX_EDGE_*.md FIX_LIMIT_*.md FIX_POSTGREST_*.md docs/troubleshooting/other/ 2>/dev/null || true
mv FIX_TIRE_*.md FIX_DUPLICATE_*.md FIX_DELETE_*.md docs/troubleshooting/other/ 2>/dev/null || true
echo "✅ Other movido!"
echo ""

# Features - PWA
echo "✨ Movendo features/pwa..."
mv PWA_*.md docs/features/pwa/ 2>/dev/null || true
echo "✅ PWA movido!"
echo ""

# Features - Loading States
echo "⏳ Movendo features/loading-states..."
mv LOADING_STATES_*.md docs/features/loading-states/ 2>/dev/null || true
echo "✅ Loading states movido!"
echo ""

# Features - Modo Rápido
echo "⚡ Movendo features/modo-rapido..."
mv MODO_RAPIDO_*.md docs/features/modo-rapido/ 2>/dev/null || true
echo "✅ Modo rápido movido!"
echo ""

# Features - Mobile
echo "📱 Movendo features/mobile..."
mv MOBILE_*.md SPRINT_5_*.md docs/features/mobile/ 2>/dev/null || true
echo "✅ Mobile movido!"
echo ""

# Features - Performance
echo "⚡ Movendo features/performance..."
mv PERFORMANCE_*.md QUERIES_OPTIMIZATION_*.md USE_DATA_FETCH_IMPLEMENTADO.md docs/features/performance/ 2>/dev/null || true
echo "✅ Performance movido!"
echo ""

# Features - Quick Wins
echo "🎯 Movendo features/quick-wins..."
mv QUICK_WIN*.md docs/features/quick-wins/ 2>/dev/null || true
echo "✅ Quick wins movido!"
echo ""

# Features - Components
echo "🎨 Movendo features/components..."
mv STATCARD_*.md TOAST_*.md VALIDACAO_*.md docs/features/components/ 2>/dev/null || true
mv COLUMN_*.md DASHBOARD_GRAFICOS_*.md docs/features/components/ 2>/dev/null || true
echo "✅ Components movido!"
echo ""

# UX Audits
echo "🎨 Movendo ux-audit..."
mv UX_AUDIT_*.md UX_UI_*.md docs/ux-audit/audits/ 2>/dev/null || true
mv UX_IMPROVEMENTS_*.md UX_MELHORIAS_*.md MELHORIAS_UX_*.md docs/ux-audit/improvements/ 2>/dev/null || true
mv ACESSIBILIDADE_*.md docs/ux-audit/improvements/ 2>/dev/null || true
mv UX_REVIEW_*.md docs/ux-audit/reviews/ 2>/dev/null || true
echo "✅ UX audits movido!"
echo ""

# Releases
echo "📦 Movendo releases..."
mv STATUS_PROJETO.md PROGRESSO_*.md MELHORIAS_IMPLEMENTADAS_RESUMO.md docs/releases/ 2>/dev/null || true
mv INTEGRACAO_*.md INTEGRACOES_*.md LIMPEZA_COMPLETA.md docs/releases/ 2>/dev/null || true
mv ROADMAP_*.md PROXIMAS_*.md PROXIMOS_PASSOS.md docs/releases/ 2>/dev/null || true
echo "✅ Releases movido!"
echo ""

# Business
echo "💼 Movendo business..."
mv BUSINESS_RULES_*.md ARCS_*.md docs/business/ 2>/dev/null || true
echo "✅ Business movido!"
echo ""

# Guides
echo "📖 Movendo guides..."
mv DEPLOYMENT.md OPTIMIZATION_INDEX.md COMO_COMPLETAR_*.md docs/guides/ 2>/dev/null || true
mv LOCALIZACAO_*.md VISUAL_BOTAO_*.md VISUAL_FEEDBACK_*.md docs/guides/ 2>/dev/null || true
mv USE_DATA_FETCH_QUICK_REFERENCE.md docs/guides/ 2>/dev/null || true
echo "✅ Guides movido!"
echo ""

# Archive
echo "📦 Movendo archive..."
mv REFATORACAO_*.md SYNC_*.md RESUMO_INTEGRACOES.md docs/archive/ 2>/dev/null || true
echo "✅ Archive movido!"
echo ""

# Verificar resultado
echo ""
echo "📊 Verificando resultado..."
echo ""
echo "Arquivos restantes na raiz:"
ls *.md 2>/dev/null | grep -v "README.md" | grep -v "Attributions.md" | wc -l
echo ""
echo "Nova estrutura:"
ls -d docs/*/ 2>/dev/null
echo ""
echo "🎉 REORGANIZAÇÃO COMPLETA!"
echo ""
echo "Próximo passo: git add . && git commit -m 'docs: reorganizar 150+ arquivos'"
