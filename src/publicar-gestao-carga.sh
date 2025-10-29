#!/bin/bash

# Script de Publicação - Menu "Gestão de Carga"
# Conecta Cup - Sistema de Gestão de Pneus
# Data: 29 de Outubro de 2025

# Cores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Banner
echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                                                        ║${NC}"
echo -e "${BLUE}║  📦 Publicação - Menu 'Gestão de Carga'               ║${NC}"
echo -e "${BLUE}║  🏁 Conecta Cup - Porsche Cup Brasil                  ║${NC}"
echo -e "${BLUE}║  📅 $(date +"%d/%m/%Y %H:%M:%S")                                   ║${NC}"
echo -e "${BLUE}║                                                        ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

# Função para erro
error_exit() {
    echo -e "${RED}❌ Erro: $1${NC}" >&2
    exit 1
}

# Função para sucesso
success() {
    echo -e "${GREEN}✅ $1${NC}"
}

# Função para info
info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Função para warning
warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Verificar se está no diretório correto
if [ ! -f "App.tsx" ]; then
    error_exit "Não estamos no diretório raiz do projeto. Execute o script do diretório raiz."
fi

info "Diretório correto verificado"
echo ""

# Verificar se git está instalado
if ! command -v git &> /dev/null; then
    error_exit "Git não está instalado. Instale o Git primeiro."
fi

success "Git instalado"
echo ""

# Verificar status do git
info "Verificando status do repositório..."
git status --short
echo ""

# Perguntar qual método de publicação usar
echo -e "${YELLOW}Escolha o método de publicação:${NC}"
echo "1) Push direto na main/master (rápido)"
echo "2) Criar branch + Pull Request (recomendado)"
echo "3) Apenas preparar (sem push)"
read -p "Escolha [1-3]: " choice
echo ""

case $choice in
    1)
        METHOD="direct"
        info "Método selecionado: Push Direto"
        ;;
    2)
        METHOD="branch"
        info "Método selecionado: Branch + PR"
        ;;
    3)
        METHOD="prepare"
        info "Método selecionado: Apenas Preparar"
        ;;
    *)
        error_exit "Opção inválida. Execute o script novamente."
        ;;
esac
echo ""

# Adicionar arquivos
info "Adicionando arquivos ao staging..."
git add components/Sidebar.tsx
git add components/MobileNav.tsx
git add docs/releases/MENU_GESTAO_CARGA_IMPLEMENTADO.md
git add COMMIT_MESSAGE.md
git add PUBLICAR_GITHUB.md
git add RESUMO_PUBLICACAO_GITHUB.md
git add publicar-gestao-carga.sh

success "Arquivos adicionados ao staging"
echo ""

# Verificar arquivos staged
info "Arquivos prontos para commit:"
git diff --cached --name-status
echo ""

# Criar commit
info "Criando commit..."
if git commit -F COMMIT_MESSAGE.md; then
    success "Commit criado com sucesso"
else
    error_exit "Falha ao criar commit"
fi
echo ""

# Verificar commit
info "Último commit:"
git log -1 --oneline
echo ""

# Executar método escolhido
if [ "$METHOD" = "direct" ]; then
    # Push direto
    warning "Você está prestes a fazer push direto na branch atual."
    read -p "Deseja continuar? [s/N]: " confirm
    
    if [ "$confirm" = "s" ] || [ "$confirm" = "S" ]; then
        CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
        info "Branch atual: $CURRENT_BRANCH"
        
        info "Fazendo push..."
        if git push origin "$CURRENT_BRANCH"; then
            success "Push realizado com sucesso!"
            echo ""
            info "🎉 Publicação concluída!"
            info "Verifique no GitHub: https://github.com/seu-usuario/seu-repo"
        else
            error_exit "Falha no push. Verifique suas permissões e conexão."
        fi
    else
        warning "Push cancelado pelo usuário."
    fi
    
elif [ "$METHOD" = "branch" ]; then
    # Criar branch
    BRANCH_NAME="feature/menu-gestao-carga"
    
    info "Criando branch: $BRANCH_NAME"
    if git checkout -b "$BRANCH_NAME" 2>/dev/null || git checkout "$BRANCH_NAME"; then
        success "Branch criada/selecionada"
    else
        error_exit "Falha ao criar/selecionar branch"
    fi
    echo ""
    
    # Push da branch
    info "Fazendo push da branch..."
    if git push -u origin "$BRANCH_NAME"; then
        success "Branch publicada com sucesso!"
        echo ""
        success "🎉 Branch criada e publicada!"
        echo ""
        info "📝 Próximos passos:"
        echo "   1. Acesse: https://github.com/seu-usuario/seu-repo"
        echo "   2. Clique em 'Compare & pull request'"
        echo "   3. Revise as mudanças"
        echo "   4. Crie o Pull Request"
    else
        error_exit "Falha no push da branch"
    fi
    
elif [ "$METHOD" = "prepare" ]; then
    # Apenas preparar
    success "Commit criado e preparado!"
    echo ""
    info "📝 Próximos passos manuais:"
    echo ""
    echo "   Para push direto:"
    echo "   $ git push origin main"
    echo ""
    echo "   Para criar branch:"
    echo "   $ git checkout -b feature/menu-gestao-carga"
    echo "   $ git push origin feature/menu-gestao-carga"
    echo ""
fi

# Resumo final
echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                                                        ║${NC}"
echo -e "${GREEN}║  ✅ Processo Concluído!                                ║${NC}"
echo -e "${GREEN}║                                                        ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

info "📚 Documentação:"
echo "   - Detalhes: docs/releases/MENU_GESTAO_CARGA_IMPLEMENTADO.md"
echo "   - Guia: PUBLICAR_GITHUB.md"
echo "   - Resumo: RESUMO_PUBLICACAO_GITHUB.md"
echo ""

info "🔍 Verificar publicação:"
echo "   $ git log -1"
echo "   $ git status"
echo ""

info "📊 Estatísticas:"
echo "   - Arquivos modificados: 2"
echo "   - Arquivos criados: 4"
echo "   - Breaking changes: 0"
echo ""

success "Tudo pronto! 🚀"
