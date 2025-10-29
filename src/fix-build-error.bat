@echo off
REM Script para corrigir erro de build - useKeyboardAdjustment
REM Conecta Cup - 29 de Outubro de 2025

chcp 65001 >nul
setlocal enabledelayedexpansion

color 0A

echo 🔧 Corrigindo erro de build - useKeyboardAdjustment
echo.

REM 1. Verificar diretório
if not exist "App.tsx" (
    echo ❌ Erro: Execute este script do diretório raiz do projeto
    pause
    exit /b 1
)

echo ✅ Diretório correto
echo.

REM 2. Verificar se .tsx existe
if not exist "utils\useKeyboardAdjustment.tsx" (
    echo ❌ Erro: utils\useKeyboardAdjustment.tsx não encontrado
    pause
    exit /b 1
)

echo ✅ Arquivo .tsx existe
echo.

REM 3. Remover .ts se existir
if exist "utils\useKeyboardAdjustment.ts" (
    echo ⚠️  Removendo arquivo .ts antigo...
    del utils\useKeyboardAdjustment.ts
    echo ✅ Arquivo .ts removido
) else (
    echo ✅ Arquivo .ts já não existe localmente
)
echo.

REM 4. Remover do Git se rastreado
echo 🔍 Verificando Git...
git ls-files | findstr "utils/useKeyboardAdjustment.ts" >nul 2>&1
if !errorlevel! equ 0 (
    echo ⚠️  Removendo do Git...
    git rm --cached utils/useKeyboardAdjustment.ts 2>nul
    echo ✅ Removido do Git
) else (
    echo ✅ Git não rastreia o arquivo .ts
)
echo.

REM 5. Adicionar .tsx
echo 📦 Adicionando arquivo .tsx...
git add utils/useKeyboardAdjustment.tsx
git add -u
echo ✅ Arquivo .tsx adicionado
echo.

REM 6. Adicionar documentação
echo 📚 Adicionando documentação...
git add FIX_BUILD_ERROR_USEKEYBOARDADJUSTMENT.md 2>nul
git add FIX_BUILD_GIT_CACHE.md 2>nul
git add COMMIT_MESSAGE_FIX_BUILD.md 2>nul
git add fix-build-error.sh 2>nul
git add fix-build-error.bat 2>nul
echo ✅ Documentação adicionada
echo.

REM 7. Status
echo 🔍 Status atual:
git status --short | findstr useKeyboardAdjustment
echo.

REM 8. Confirmar
echo Deseja fazer commit e push? [s/N]
set /p confirm=

if /i "!confirm!"=="s" (
    echo.
    echo 📦 Fazendo commit...
    
    git commit -m "fix: rename useKeyboardAdjustment.ts to .tsx (contains JSX)" -m "" -m "- Remove arquivo .ts antigo do Git" -m "- Adiciona arquivo .tsx com JSX suportado" -m "- Corrige erro de build no Vercel" -m "- Sem breaking changes nas importações"
    
    if !errorlevel! equ 0 (
        echo ✅ Commit realizado
        echo.
        
        echo 🚀 Fazendo push...
        git push origin main
        
        if !errorlevel! equ 0 (
            echo ✅ Push realizado
            echo.
            
            echo ╔════════════════════════════════════════════╗
            echo ║                                            ║
            echo ║  ✅ Correção Aplicada com Sucesso!        ║
            echo ║                                            ║
            echo ╚════════════════════════════════════════════╝
            echo.
            echo 📊 Próximos passos:
            echo    1. Aguarde o build no Vercel
            echo    2. Verifique o deploy
            echo    3. Teste a aplicação
        ) else (
            echo ❌ Erro no push
        )
    ) else (
        echo ❌ Erro no commit
    )
) else (
    echo.
    echo ⚠️  Commit cancelado
    echo.
    echo As mudanças foram staged. Para commitar manualmente:
    echo    git commit -m "fix: rename useKeyboardAdjustment.ts to .tsx"
    echo    git push origin main
)

echo.
echo 🎉 Script concluído!
echo.
pause
