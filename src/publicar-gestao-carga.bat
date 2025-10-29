@echo off
REM Script de Publicação - Menu "Gestão de Carga"
REM Conecta Cup - Sistema de Gestão de Pneus
REM Data: 29 de Outubro de 2025

chcp 65001 >nul
setlocal enabledelayedexpansion

REM Cores (Windows 10+)
color 0A

REM Banner
echo ╔════════════════════════════════════════════════════════╗
echo ║                                                        ║
echo ║  📦 Publicação - Menu 'Gestão de Carga'               ║
echo ║  🏁 Conecta Cup - Porsche Cup Brasil                  ║
echo ║  📅 %date% %time:~0,8%                                         ║
echo ║                                                        ║
echo ╚════════════════════════════════════════════════════════╝
echo.

REM Verificar se está no diretório correto
if not exist "App.tsx" (
    echo ❌ Erro: Não estamos no diretório raiz do projeto.
    echo Execute o script do diretório raiz.
    pause
    exit /b 1
)

echo ✅ Diretório correto verificado
echo.

REM Verificar se git está instalado
where git >nul 2>nul
if %errorlevel% neq 0 (
    echo ❌ Erro: Git não está instalado.
    echo Instale o Git primeiro: https://git-scm.com/download/win
    pause
    exit /b 1
)

echo ✅ Git instalado
echo.

REM Verificar status do git
echo ℹ️  Verificando status do repositório...
git status --short
echo.

REM Perguntar método de publicação
echo Escolha o método de publicação:
echo 1) Push direto na main/master (rápido)
echo 2) Criar branch + Pull Request (recomendado)
echo 3) Apenas preparar (sem push)
echo.
set /p choice="Escolha [1-3]: "
echo.

if "%choice%"=="1" (
    set METHOD=direct
    echo ℹ️  Método selecionado: Push Direto
) else if "%choice%"=="2" (
    set METHOD=branch
    echo ℹ️  Método selecionado: Branch + PR
) else if "%choice%"=="3" (
    set METHOD=prepare
    echo ℹ️  Método selecionado: Apenas Preparar
) else (
    echo ❌ Erro: Opção inválida.
    pause
    exit /b 1
)
echo.

REM Adicionar arquivos
echo ℹ️  Adicionando arquivos ao staging...
git add components/Sidebar.tsx
git add components/MobileNav.tsx
git add docs/releases/MENU_GESTAO_CARGA_IMPLEMENTADO.md
git add COMMIT_MESSAGE.md
git add PUBLICAR_GITHUB.md
git add RESUMO_PUBLICACAO_GITHUB.md
git add publicar-gestao-carga.sh
git add publicar-gestao-carga.bat

if %errorlevel% neq 0 (
    echo ❌ Erro ao adicionar arquivos
    pause
    exit /b 1
)

echo ✅ Arquivos adicionados ao staging
echo.

REM Verificar arquivos staged
echo ℹ️  Arquivos prontos para commit:
git diff --cached --name-status
echo.

REM Criar commit
echo ℹ️  Criando commit...
git commit -F COMMIT_MESSAGE.md

if %errorlevel% neq 0 (
    echo ❌ Erro ao criar commit
    pause
    exit /b 1
)

echo ✅ Commit criado com sucesso
echo.

REM Verificar commit
echo ℹ️  Último commit:
git log -1 --oneline
echo.

REM Executar método escolhido
if "%METHOD%"=="direct" (
    REM Push direto
    echo ⚠️  Você está prestes a fazer push direto na branch atual.
    set /p confirm="Deseja continuar? [s/N]: "
    
    if /i "!confirm!"=="s" (
        for /f "tokens=*" %%a in ('git rev-parse --abbrev-ref HEAD') do set CURRENT_BRANCH=%%a
        echo ℹ️  Branch atual: !CURRENT_BRANCH!
        echo.
        
        echo ℹ️  Fazendo push...
        git push origin !CURRENT_BRANCH!
        
        if !errorlevel! equ 0 (
            echo ✅ Push realizado com sucesso!
            echo.
            echo 🎉 Publicação concluída!
            echo ℹ️  Verifique no GitHub
        ) else (
            echo ❌ Erro no push. Verifique suas permissões e conexão.
            pause
            exit /b 1
        )
    ) else (
        echo ⚠️  Push cancelado pelo usuário.
    )
    
) else if "%METHOD%"=="branch" (
    REM Criar branch
    set BRANCH_NAME=feature/menu-gestao-carga
    
    echo ℹ️  Criando branch: !BRANCH_NAME!
    git checkout -b !BRANCH_NAME! 2>nul || git checkout !BRANCH_NAME!
    
    if !errorlevel! equ 0 (
        echo ✅ Branch criada/selecionada
    ) else (
        echo ❌ Erro ao criar/selecionar branch
        pause
        exit /b 1
    )
    echo.
    
    REM Push da branch
    echo ℹ️  Fazendo push da branch...
    git push -u origin !BRANCH_NAME!
    
    if !errorlevel! equ 0 (
        echo ✅ Branch publicada com sucesso!
        echo.
        echo 🎉 Branch criada e publicada!
        echo.
        echo ℹ️  Próximos passos:
        echo    1. Acesse o GitHub
        echo    2. Clique em 'Compare ^& pull request'
        echo    3. Revise as mudanças
        echo    4. Crie o Pull Request
    ) else (
        echo ❌ Erro no push da branch
        pause
        exit /b 1
    )
    
) else if "%METHOD%"=="prepare" (
    REM Apenas preparar
    echo ✅ Commit criado e preparado!
    echo.
    echo ℹ️  Próximos passos manuais:
    echo.
    echo    Para push direto:
    echo    git push origin main
    echo.
    echo    Para criar branch:
    echo    git checkout -b feature/menu-gestao-carga
    echo    git push origin feature/menu-gestao-carga
    echo.
)

REM Resumo final
echo.
echo ╔════════════════════════════════════════════════════════╗
echo ║                                                        ║
echo ║  ✅ Processo Concluído!                                ║
echo ║                                                        ║
echo ╚════════════════════════════════════════════════════════╝
echo.

echo ℹ️  📚 Documentação:
echo    - Detalhes: docs\releases\MENU_GESTAO_CARGA_IMPLEMENTADO.md
echo    - Guia: PUBLICAR_GITHUB.md
echo    - Resumo: RESUMO_PUBLICACAO_GITHUB.md
echo.

echo ℹ️  🔍 Verificar publicação:
echo    git log -1
echo    git status
echo.

echo ℹ️  📊 Estatísticas:
echo    - Arquivos modificados: 2
echo    - Arquivos criados: 5
echo    - Breaking changes: 0
echo.

echo ✅ Tudo pronto! 🚀
echo.

pause
