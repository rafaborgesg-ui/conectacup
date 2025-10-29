#!/bin/bash

# ============================================
# Script de Instalação de Ícones PWA
# Porsche Cup Brasil - Sistema de Gestão de Pneus
# ============================================

echo "🏁 Porsche Cup Brasil - PWA Icons Installer"
echo "============================================"
echo ""

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Verifica se o ZIP existe
if [ ! -f "porsche-cup-pwa-icons.zip" ]; then
    echo -e "${RED}❌ Erro: Arquivo porsche-cup-pwa-icons.zip não encontrado${NC}"
    echo ""
    echo "Por favor, siga os passos:"
    echo "1. Abra: http://localhost:5173/pwa-icon-generator.html"
    echo "2. Clique em 'Gerar Todos os Ícones PWA'"
    echo "3. Clique em 'Baixar ZIP com Todos os Ícones'"
    echo "4. Salve o arquivo nesta pasta"
    echo "5. Execute este script novamente"
    echo ""
    exit 1
fi

echo -e "${BLUE}📦 Arquivo ZIP encontrado!${NC}"
echo ""

# Cria diretório temporário
echo -e "${YELLOW}📂 Criando diretório temporário...${NC}"
rm -rf pwa-icons-temp
mkdir -p pwa-icons-temp

# Extrai o ZIP
echo -e "${YELLOW}📤 Extraindo arquivo ZIP...${NC}"
unzip -q porsche-cup-pwa-icons.zip -d pwa-icons-temp

# Verifica se a pasta pwa-icons existe
if [ ! -d "pwa-icons-temp/pwa-icons" ]; then
    echo -e "${RED}❌ Erro: Pasta pwa-icons não encontrada no ZIP${NC}"
    rm -rf pwa-icons-temp
    exit 1
fi

# Cria pasta public se não existir
mkdir -p public

# Copia os ícones
echo -e "${YELLOW}📋 Copiando ícones para /public...${NC}"
cp pwa-icons-temp/pwa-icons/*.png public/

# Verifica se os arquivos foram copiados
ICON_COUNT=$(ls -1 public/icon-*.png 2>/dev/null | wc -l)

if [ $ICON_COUNT -eq 8 ]; then
    echo -e "${GREEN}✅ Sucesso! 8 ícones copiados para /public${NC}"
    echo ""
    echo "Ícones instalados:"
    ls -lh public/icon-*.png | awk '{print "  ✓", $9, "(" $5 ")"}'
    echo ""
    
    # Copia README se existir
    if [ -f "pwa-icons-temp/pwa-icons/README.md" ]; then
        cp pwa-icons-temp/pwa-icons/README.md public/PWA_ICONS_README.md
        echo -e "${BLUE}📝 README copiado para /public/PWA_ICONS_README.md${NC}"
        echo ""
    fi
    
    echo -e "${GREEN}🎉 Instalação concluída com sucesso!${NC}"
    echo ""
    echo "Próximos passos:"
    echo "1. Verifique os ícones: ls -la public/icon-*.png"
    echo "2. Inicie o servidor: npm run dev"
    echo "3. Abra DevTools (F12) → Application → Manifest"
    echo "4. Confirme que todos os ícones aparecem sem erros"
    echo ""
    echo -e "${GREEN}✅ Seu PWA está 100% completo!${NC}"
    
else
    echo -e "${RED}❌ Erro: Esperado 8 ícones, encontrado $ICON_COUNT${NC}"
    echo ""
    echo "Ícones encontrados:"
    ls -1 public/icon-*.png 2>/dev/null || echo "  Nenhum ícone encontrado"
    echo ""
    exit 1
fi

# Limpa arquivos temporários
echo ""
echo -e "${YELLOW}🧹 Limpando arquivos temporários...${NC}"
rm -rf pwa-icons-temp

echo ""
echo -e "${GREEN}✨ Processo finalizado!${NC}"
echo ""

# Opcional: Move o ZIP para backup
mkdir -p backups
mv porsche-cup-pwa-icons.zip backups/porsche-cup-pwa-icons-$(date +%Y%m%d-%H%M%S).zip
echo -e "${BLUE}💾 ZIP movido para /backups${NC}"
echo ""
