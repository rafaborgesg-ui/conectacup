#!/bin/bash
# Solução Definitiva - Build Error Vercel
# Conecta Cup - 29 Outubro 2025

set -e

echo "🔧 CORREÇÃO DEFINITIVA - Build Error"
echo "====================================="
echo ""

# Cores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}📥 Sincronizando com GitHub...${NC}"
git pull origin main || echo "Já sincronizado"
echo ""

echo -e "${YELLOW}🗑️  Removendo arquivo .ts (se existir)...${NC}"
# Remove do Git
git rm utils/useKeyboardAdjustment.ts 2>/dev/null || true
git rm --cached utils/useKeyboardAdjustment.ts 2>/dev/null || true

# Remove localmente
rm -f utils/useKeyboardAdjustment.ts 2>/dev/null || true
echo -e "${GREEN}✅ Arquivo .ts removido${NC}"
echo ""

echo -e "${YELLOW}📦 Adicionando arquivo .tsx...${NC}"
git add utils/useKeyboardAdjustment.tsx -f
echo -e "${GREEN}✅ Arquivo .tsx adicionado${NC}"
echo ""

echo -e "${YELLOW}📊 Status atual:${NC}"
git status --short | grep useKeyboardAdjustment || echo "Sem mudanças pendentes"
echo ""

echo -e "${YELLOW}💾 Fazendo commit...${NC}"
git commit -m "fix: force .tsx extension for useKeyboardAdjustment

- Remove arquivo .ts do Git e local
- Adiciona arquivo .tsx com JSX suportado
- Corrige build error no Vercel
- Garante que apenas .tsx existe no repo" --allow-empty

echo -e "${GREEN}✅ Commit realizado${NC}"
echo ""

echo -e "${YELLOW}🚀 Fazendo push...${NC}"
git push origin main --force-with-lease

echo -e "${GREEN}✅ Push realizado${NC}"
echo ""

echo -e "${GREEN}╔════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                                            ║${NC}"
echo -e "${GREEN}║  ✅ CORREÇÃO APLICADA COM SUCESSO!        ║${NC}"
echo -e "${GREEN}║                                            ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════╝${NC}"
echo ""

echo "📊 Próximos passos:"
echo "   1. ✅ Mudanças enviadas para GitHub"
echo "   2. ⏳ Aguarde build no Vercel (2-3 min)"
echo "   3. 🔍 Verifique deploy no dashboard Vercel"
echo "   4. 🎉 Teste a aplicação"
echo ""

echo -e "${GREEN}🔗 Links Úteis:${NC}"
echo "   GitHub: https://github.com/rafaborgesg-ui/Porschecup2"
echo "   Vercel: https://vercel.com/dashboard"
echo ""

echo -e "${GREEN}✅ Script concluído com sucesso!${NC}"
