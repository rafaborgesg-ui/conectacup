@echo off
REM Solucao Definitiva - Build Error Vercel
REM Conecta Cup - 29 Outubro 2025

chcp 65001 >nul
setlocal enabledelayedexpansion
color 0A

echo.
echo ═══════════════════════════════════════════
echo    CORRECAO DEFINITIVA - Build Error
echo ═══════════════════════════════════════════
echo.

echo 📥 Sincronizando com GitHub...
git pull origin main 2>nul
echo.

echo 🗑️  Removendo arquivo .ts...
git rm utils\useKeyboardAdjustment.ts 2>nul
git rm --cached utils\useKeyboardAdjustment.ts 2>nul
del utils\useKeyboardAdjustment.ts 2>nul
echo ✅ Arquivo .ts removido
echo.

echo 📦 Adicionando arquivo .tsx...
git add utils\useKeyboardAdjustment.tsx -f
echo ✅ Arquivo .tsx adicionado
echo.

echo 📊 Status atual:
git status --short | findstr useKeyboardAdjustment
echo.

echo 💾 Fazendo commit...
git commit -m "fix: force .tsx extension for useKeyboardAdjustment" -m "" -m "- Remove arquivo .ts do Git e local" -m "- Adiciona arquivo .tsx com JSX suportado" -m "- Corrige build error no Vercel" -m "- Garante que apenas .tsx existe no repo" --allow-empty

if !errorlevel! equ 0 (
    echo ✅ Commit realizado
    echo.
    
    echo 🚀 Fazendo push...
    git push origin main --force-with-lease
    
    if !errorlevel! equ 0 (
        echo ✅ Push realizado
        echo.
        
        echo.
        echo ╔════════════════════════════════════════════╗
        echo ║                                            ║
        echo ║  ✅ CORRECAO APLICADA COM SUCESSO!        ║
        echo ║                                            ║
        echo ╚════════════════════════════════════════════╝
        echo.
        
        echo 📊 Proximos passos:
        echo    1. ✅ Mudancas enviadas para GitHub
        echo    2. ⏳ Aguarde build no Vercel (2-3 min^)
        echo    3. 🔍 Verifique deploy no dashboard Vercel
        echo    4. 🎉 Teste a aplicacao
        echo.
        
        echo 🔗 Links Uteis:
        echo    GitHub: https://github.com/rafaborgesg-ui/Porschecup2
        echo    Vercel: https://vercel.com/dashboard
        echo.
        
        echo ✅ Script concluido com sucesso!
    ) else (
        echo ❌ Erro no push
    )
) else (
    echo ❌ Erro no commit
)

echo.
pause
