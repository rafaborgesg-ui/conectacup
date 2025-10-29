# 🚀 Script de Reorganização da Documentação

**Executar:** Copiar e colar comandos no terminal  
**Tempo:** ~5 minutos  
**Seguro:** Usa `git mv` (mantém histórico)

---

## ⚠️ PRÉ-REQUISITO

```bash
# Certifique-se de estar na raiz do projeto
cd /caminho/para/projeto
pwd  # Deve mostrar: /seu/caminho/porsche-cup-pneus
```

---

## 📁 Passo 1: Criar Estrutura de Pastas (30 segundos)

```bash
# Criar todas as subpastas necessárias
mkdir -p docs/migrations/{sql,guides}
mkdir -p docs/troubleshooting/{auth,database,import,status,other}
mkdir -p docs/features/{pwa,loading-states,modo-rapido,mobile,performance,quick-wins,components}
mkdir -p docs/ux-audit/{audits,improvements,reviews}
mkdir -p docs/releases
mkdir -p docs/business
mkdir -p docs/guides
mkdir -p docs/archive

echo "✅ Estrutura de pastas criada!"
```

---

## 🗄️ Passo 2: Mover Migrations & SQL (1 minuto)

```bash
# SQL Files para /docs/migrations/sql/
git mv MIGRATION_*.sql docs/migrations/sql/ 2>/dev/null || true
git mv FIX_*_SQL_*.sql docs/migrations/sql/ 2>/dev/null || true
git mv SETUP_*.sql docs/migrations/sql/ 2>/dev/null || true
git mv INSERT_*.sql docs/migrations/sql/ 2>/dev/null || true
git mv RESET_*.sql docs/migrations/sql/ 2>/dev/null || true
git mv UPDATE_*.sql docs/migrations/sql/ 2>/dev/null || true
git mv CLEAR_*.sql docs/migrations/sql/ 2>/dev/null || true
git mv DELETE_*.sql docs/migrations/sql/ 2>/dev/null || true
git mv VERIFY_*.sql docs/migrations/sql/ 2>/dev/null || true
git mv QUICK_FIX.sql docs/migrations/sql/ 2>/dev/null || true
git mv DEBUG_STATUS_PILOTO.sql docs/migrations/sql/ 2>/dev/null || true

# Fixes SQL específicos
git mv FIX_ALL_CONTAINER_CONSTRAINTS.sql docs/migrations/sql/ 2>/dev/null || true
git mv FIX_CONTAINERS_*.sql docs/migrations/sql/ 2>/dev/null || true
git mv FIX_CONTAINER_*.sql docs/migrations/sql/ 2>/dev/null || true
git mv FIX_CORRUPTED_BARCODES.sql docs/migrations/sql/ 2>/dev/null || true
git mv FIX_DESCARTADO_DSI_*.sql docs/migrations/sql/ 2>/dev/null || true
git mv FIX_DESCARTE_STATUS.sql docs/migrations/sql/ 2>/dev/null || true
git mv FIX_STATUS_*.sql docs/migrations/sql/ 2>/dev/null || true
git mv FIX_TIRE_STATUS_*.sql docs/migrations/sql/ 2>/dev/null || true
git mv FIX_BARCODE_*.sql docs/migrations/sql/ 2>/dev/null || true

# Guias de Migração para /docs/migrations/guides/
git mv MIGRATION_STEP_BY_STEP.md docs/migrations/guides/ 2>/dev/null || true
git mv MIGRATION_NOTES.md docs/migrations/guides/ 2>/dev/null || true
git mv README_MIGRATION.md docs/migrations/guides/ 2>/dev/null || true

echo "✅ Migrations movidos!"
```

---

## 🐛 Passo 3: Mover Troubleshooting (1 minuto)

```bash
# Auth
git mv FIX_AUTH_*.md docs/troubleshooting/auth/ 2>/dev/null || true
git mv INSTRUCOES_URGENTES_LOGIN.md docs/troubleshooting/auth/ 2>/dev/null || true
git mv FIX_HOOKS_ERROR.md docs/troubleshooting/auth/ 2>/dev/null || true

# Database
git mv FIX_CONTAINERS_CHECK_*.md docs/troubleshooting/database/ 2>/dev/null || true
git mv FIX_UUID_*.md docs/troubleshooting/database/ 2>/dev/null || true
git mv TROUBLESHOOTING_*.md docs/troubleshooting/database/ 2>/dev/null || true
git mv SOLUCAO_*.md docs/troubleshooting/database/ 2>/dev/null || true

# Import/Data
git mv DEBUG_ENTRADA_PLANILHA.md docs/troubleshooting/import/ 2>/dev/null || true
git mv FIX_DATA_IMPORT_*.md docs/troubleshooting/import/ 2>/dev/null || true
git mv FIX_ENTRADA_PLANILHA_*.md docs/troubleshooting/import/ 2>/dev/null || true
git mv FIX_DUPLICATE_EXPORT_*.md docs/troubleshooting/import/ 2>/dev/null || true

# Status
git mv CORRECAO_STATUS_*.md docs/troubleshooting/status/ 2>/dev/null || true
git mv DEBUG_STATUS_*.md docs/troubleshooting/status/ 2>/dev/null || true
git mv INSTRUCOES_CORRECAO_STATUS.md docs/troubleshooting/status/ 2>/dev/null || true
git mv FIX_STATUS_*.md docs/troubleshooting/status/ 2>/dev/null || true

# Other Fixes
git mv FIX_BARCODE_*.md docs/troubleshooting/other/ 2>/dev/null || true
git mv FIX_BULK_*.md docs/troubleshooting/other/ 2>/dev/null || true
git mv FIX_CHECKBARCODEEXISTS_*.md docs/troubleshooting/other/ 2>/dev/null || true
git mv FIX_EDGE_FUNCTION_*.md docs/troubleshooting/other/ 2>/dev/null || true
git mv FIX_LIMIT_*.md docs/troubleshooting/other/ 2>/dev/null || true
git mv FIX_POSTGREST_*.md docs/troubleshooting/other/ 2>/dev/null || true
git mv FIX_TIRE_*.md docs/troubleshooting/other/ 2>/dev/null || true
git mv FIX_DELETE_UUID_*.md docs/troubleshooting/other/ 2>/dev/null || true

echo "✅ Troubleshooting movido!"
```

---

## ✨ Passo 4: Mover Features (1.5 minutos)

```bash
# PWA
git mv PWA_*.md docs/features/pwa/ 2>/dev/null || true

# Loading States
git mv LOADING_STATES_*.md docs/features/loading-states/ 2>/dev/null || true

# Modo Rápido
git mv MODO_RAPIDO_*.md docs/features/modo-rapido/ 2>/dev/null || true

# Mobile
git mv MOBILE_*.md docs/features/mobile/ 2>/dev/null || true
git mv SPRINT_5_MOBILE_*.md docs/features/mobile/ 2>/dev/null || true

# Performance
git mv PERFORMANCE_*.md docs/features/performance/ 2>/dev/null || true
git mv QUERIES_OPTIMIZATION_*.md docs/features/performance/ 2>/dev/null || true
git mv USE_DATA_FETCH_*.md docs/features/performance/ 2>/dev/null || true
git mv OPTIMIZATION_INDEX.md docs/features/performance/ 2>/dev/null || true

# Quick Wins
git mv QUICK_WIN*.md docs/features/quick-wins/ 2>/dev/null || true

# Components
git mv STATCARD_*.md docs/features/components/ 2>/dev/null || true
git mv TOAST_*.md docs/features/components/ 2>/dev/null || true
git mv VALIDACAO_FORMS_*.md docs/features/components/ 2>/dev/null || true
git mv COLUMN_PREFERENCES_*.md docs/features/components/ 2>/dev/null || true
git mv DASHBOARD_GRAFICOS_*.md docs/features/components/ 2>/dev/null || true

echo "✅ Features movidas!"
```

---

## 🎨 Passo 5: Mover UX/UI Audits (30 segundos)

```bash
# Audits
git mv UX_AUDIT_*.md docs/ux-audit/audits/ 2>/dev/null || true
git mv UX_UI_ANALISE_*.md docs/ux-audit/audits/ 2>/dev/null || true

# Improvements
git mv UX_IMPROVEMENTS_*.md docs/ux-audit/improvements/ 2>/dev/null || true
git mv UX_MELHORIAS_*.md docs/ux-audit/improvements/ 2>/dev/null || true
git mv ACESSIBILIDADE_*.md docs/ux-audit/improvements/ 2>/dev/null || true
git mv MELHORIAS_UX_*.md docs/ux-audit/improvements/ 2>/dev/null || true

# Reviews
git mv UX_REVIEW_*.md docs/ux-audit/reviews/ 2>/dev/null || true

echo "✅ UX/UI Audits movidos!"
```

---

## 📦 Passo 6: Mover Releases & Status (30 segundos)

```bash
git mv STATUS_PROJETO.md docs/releases/ 2>/dev/null || true
git mv PROGRESSO_*.md docs/releases/ 2>/dev/null || true
git mv MELHORIAS_IMPLEMENTADAS_*.md docs/releases/ 2>/dev/null || true
git mv INTEGRACAO_*.md docs/releases/ 2>/dev/null || true
git mv INTEGRACOES_*.md docs/releases/ 2>/dev/null || true
git mv LIMPEZA_*.md docs/releases/ 2>/dev/null || true

echo "✅ Releases movidos!"
```

---

## 💼 Passo 7: Mover Business Rules (15 segundos)

```bash
git mv BUSINESS_RULES_*.md docs/business/ 2>/dev/null || true
git mv ARCS_*.md docs/business/ 2>/dev/null || true

echo "✅ Business Rules movidos!"
```

---

## 📖 Passo 8: Mover Guides (30 segundos)

```bash
git mv DEPLOYMENT.md docs/guides/ 2>/dev/null || true
git mv COMO_COMPLETAR_*.md docs/guides/ 2>/dev/null || true
git mv LOCALIZACAO_*.md docs/guides/ 2>/dev/null || true
git mv VISUAL_BOTAO_*.md docs/guides/ 2>/dev/null || true
git mv VISUAL_FEEDBACK_*.md docs/guides/ 2>/dev/null || true
git mv VISUAL_CONSISTENCY_*.md docs/guides/ 2>/dev/null || true

echo "✅ Guides movidos!"
```

---

## 📦 Passo 9: Mover para Archive (Arquivos Obsoletos) (15 segundos)

```bash
# Arquivos que podem estar obsoletos ou duplicados
git mv REFATORACAO_*.md docs/archive/ 2>/dev/null || true
git mv SYNC_DASHBOARD_*.md docs/archive/ 2>/dev/null || true
git mv RESUMO_INTEGRACOES.md docs/archive/ 2>/dev/null || true

echo "✅ Arquivos obsoletos movidos para archive!"
```

---

## 📋 Passo 10: Mover Roadmap & Próximos Passos (15 segundos)

```bash
git mv ROADMAP_*.md docs/releases/ 2>/dev/null || true
git mv PROXIMAS_MELHORIAS_*.md docs/releases/ 2>/dev/null || true
git mv PROXIMOS_PASSOS.md docs/releases/ 2>/dev/null || true

echo "✅ Roadmap movido!"
```

---

## ✅ Passo 11: Commit das Mudanças (30 segundos)

```bash
# Ver o que foi movido
git status

# Adicionar tudo
git add .

# Commit
git commit -m "docs: reorganizar 120+ arquivos .md em estrutura lógica

- Criar /docs/migrations/, /troubleshooting/, /features/, etc.
- Mover SQL files para /docs/migrations/sql/
- Organizar troubleshooting por categoria (auth, database, import, status)
- Agrupar features (PWA, Loading States, Modo Rápido, Mobile, Performance)
- Consolidar UX audits em /docs/ux-audit/
- Mover releases e status para /docs/releases/
- Criar índice master em /docs/README.md
- Melhora drasticamente navegabilidade e onboarding
"

echo "✅ Commit realizado!"
```

---

## 🎉 Passo 12: Verificar Resultado

```bash
# Ver a nova estrutura
tree docs/ -L 2

# Ou se não tiver tree:
ls -R docs/

echo "🎉 Reorganização completa!"
```

---

## 📊 Resultado Esperado

```
docs/
├── README.md                       ⭐ Índice master
├── CHANGELOG.md
├── FAQ.md
│
├── migrations/
│   ├── sql/ (40+ arquivos)        ✅
│   └── guides/ (3 arquivos)       ✅
│
├── troubleshooting/
│   ├── auth/ (4 arquivos)         ✅
│   ├── database/ (10+ arquivos)   ✅
│   ├── import/ (4 arquivos)       ✅
│   ├── status/ (5 arquivos)       ✅
│   └── other/ (10+ arquivos)      ✅
│
├── features/
│   ├── pwa/ (7 arquivos)          ✅
│   ├── loading-states/ (6)        ✅
│   ├── modo-rapido/ (6)           ✅
│   ├── mobile/ (5)                ✅
│   ├── performance/ (6)           ✅
│   ├── quick-wins/ (10)           ✅
│   └── components/ (6)            ✅
│
├── ux-audit/
│   ├── audits/ (4 arquivos)       ✅
│   ├── improvements/ (5)          ✅
│   └── reviews/ (2)               ✅
│
├── releases/ (9 arquivos)         ✅
├── business/ (3 arquivos)         ✅
├── guides/ (7+ arquivos)          ✅
└── archive/ (poucos)              ✅
```

---

## 🚨 Troubleshooting

### **Erro: "fatal: not a git repository"**
```bash
# Inicialize git primeiro
git init
git add .
git commit -m "Initial commit"
```

### **Erro: "No such file or directory"**
```bash
# O arquivo pode já ter sido movido ou não existir
# Apenas continue - os 2>/dev/null || true ignoram erros
```

### **Quero desfazer tudo**
```bash
# Se ainda não deu commit:
git reset --hard

# Se já deu commit:
git revert HEAD
```

---

## 🎯 Próximos Passos Após Reorganização

1. ✅ **Criar READMEs** em cada subpasta
2. ✅ **Atualizar links** entre documentos (opcional - git mv mantém histórico)
3. ✅ **Revisar** arquivos em /docs/archive/ e deletar se obsoletos
4. ✅ **Comunicar equipe** sobre nova estrutura

---

## 📚 Referências

- 📖 [Guia de Reorganização Completo](/docs/REORGANIZACAO_DOCUMENTACAO.md)
- 📋 [Novo Índice Master](/docs/README.md)
- 🎯 [Status Final](/docs/releases/STATUS_PROJETO.md)

---

**Tempo total:** ~5 minutos  
**Risco:** Baixo (git mv mantém histórico)  
**Benefício:** 🔥 **ALTO** - Navegação 10x melhor

🎉 **Boa reorganização!**
