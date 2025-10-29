#!/bin/bash

# Script para corrigir erro de build - useKeyboardAdjustment
# Conecta Cup - 29 de Outubro de 2025

set -e  # Exit on error

echo "🔧 Corrigindo erro de build - useKeyboardAdjustment"
echo ""

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 1. Verificar se estamos no diretório correto
if [ ! -f "App.tsx" ]; then
    echo -e "${RED}❌ Erro: Execute este script do diretório raiz do projeto${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Diretório correto${NC}"
echo ""

# 2. Verificar se o arquivo .tsx existe
if [ ! -f "utils/useKeyboardAdjustment.tsx" ]; then
    echo -e "${RED}❌ Erro: utils/useKeyboardAdjustment.tsx não encontrado${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Arquivo .tsx existe${NC}"
echo ""

# 3. Remover arquivo .ts se existir
if [ -f "utils/useKeyboardAdjustment.ts" ]; then
    echo -e "${YELLOW}⚠️  Removendo arquivo .ts antigo...${NC}"
    rm utils/useKeyboardAdjustment.ts
    echo -e "${GREEN}✅ Arquivo .ts removido${NC}"
else
    echo -e "${GREEN}✅ Arquivo .ts já não existe localmente${NC}"
fi
echo ""

# 4. Remover do Git se ainda estiver rastreado
echo "🔍 Verificando Git..."
if git ls-files | grep -q "utils/useKeyboardAdjustment.ts"; then
    echo -e "${YELLOW}⚠️  Removendo do Git...${NC}"
    git rm --cached utils/useKeyboardAdjustment.ts 2>/dev/null || true
    echo -e "${GREEN}✅ Removido do Git${NC}"
else
    echo -e "${GREEN}✅ Git não rastreia o arquivo .ts${NC}"
fi
echo ""

# 5. Adicionar arquivo .tsx
echo "📦 Adicionando arquivo .tsx..."
git add utils/useKeyboardAdjustment.tsx
git add -u  # Adiciona remoções
echo -e "${GREEN}✅ Arquivo .tsx adicionado${NC}"
echo ""

# 6. Adicionar documentação
echo "📚 Adicionando documentação..."
git add FIX_BUILD_ERROR_USEKEYBOARDADJUSTMENT.md 2>/dev/null || true
git add FIX_BUILD_GIT_CACHE.md 2>/dev/null || true
git add COMMIT_MESSAGE_FIX_BUILD.md 2>/dev/null || true
git add fix-build-error.sh 2>/dev/null || true
echo -e "${GREEN}✅ Documentação adicionada${NC}"
echo ""

# 7. Verificar status
echo "🔍 Status atual:"
git status --short | grep useKeyboardAdjustment || echo "Nenhuma mudança pendente"
echo ""

# 8. Mostrar diff
echo "📝 Mudanças staged:"
git diff --cached --stat | grep useKeyboardAdjustment || echo "Nenhuma mudança"
echo ""

# 9. Confirmar commit
echo -e "${YELLOW}Deseja fazer commit e push? [s/N]${NC}"
read -r confirm

if [ "$confirm" = "s" ] || [ "$confirm" = "S" ]; then
    echo ""
    echo "📦 Fazendo commit..."
    
    git commit -m "fix: rename useKeyboardAdjustment.ts to .tsx (contains JSX)

- Remove arquivo .ts antigo do Git
- Adiciona arquivo .tsx com JSX suportado
- Corrige erro de build no Vercel
- Sem breaking changes nas importações"
    
    echo -e "${GREEN}✅ Commit realizado${NC}"
    echo ""
    
    echo "🚀 Fazendo push..."
    git push origin main
    
    echo -e "${GREEN}✅ Push realizado${NC}"
    echo ""
    
    echo -e "${GREEN}╔════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                                            ║${NC}"
    echo -e "${GREEN}║  ✅ Correção Aplicada com Sucesso!        ║${NC}"
    echo -e "${GREEN}║                                            ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════╝${NC}"
    echo ""
    echo "📊 Próximos passos:"
    echo "   1. Aguarde o build no Vercel"
    echo "   2. Verifique o deploy"
    echo "   3. Teste a aplicação"
    
else
    echo ""
    echo -e "${YELLOW}⚠️  Commit cancelado${NC}"
    echo ""
    echo "As mudanças foram staged. Para commitar manualmente:"
    echo "   git commit -m \"fix: rename useKeyboardAdjustment.ts to .tsx\""
    echo "   git push origin main"
fi

echo ""
echo "🎉 Script concluído!"
