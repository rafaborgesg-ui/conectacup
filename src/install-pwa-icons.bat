@echo off
REM ============================================
REM Script de Instalacao de Icones PWA
REM Porsche Cup Brasil - Sistema de Gestao de Pneus
REM ============================================

echo.
echo ================================================
echo   Porsche Cup Brasil - PWA Icons Installer
echo ================================================
echo.

REM Verifica se o ZIP existe
if not exist "porsche-cup-pwa-icons.zip" (
    echo [ERRO] Arquivo porsche-cup-pwa-icons.zip nao encontrado
    echo.
    echo Por favor, siga os passos:
    echo 1. Abra: http://localhost:5173/pwa-icon-generator.html
    echo 2. Clique em 'Gerar Todos os Icones PWA'
    echo 3. Clique em 'Baixar ZIP com Todos os Icones'
    echo 4. Salve o arquivo nesta pasta
    echo 5. Execute este script novamente
    echo.
    pause
    exit /b 1
)

echo [OK] Arquivo ZIP encontrado!
echo.

REM Cria diretório temporário
echo [INFO] Criando diretorio temporario...
if exist pwa-icons-temp rmdir /s /q pwa-icons-temp
mkdir pwa-icons-temp

REM Extrai o ZIP
echo [INFO] Extraindo arquivo ZIP...
powershell -command "Expand-Archive -Path 'porsche-cup-pwa-icons.zip' -DestinationPath 'pwa-icons-temp' -Force"

REM Verifica se a pasta pwa-icons existe
if not exist "pwa-icons-temp\pwa-icons" (
    echo [ERRO] Pasta pwa-icons nao encontrada no ZIP
    rmdir /s /q pwa-icons-temp
    pause
    exit /b 1
)

REM Cria pasta public se não existir
if not exist "public" mkdir public

REM Copia os ícones
echo [INFO] Copiando icones para \public...
copy /y pwa-icons-temp\pwa-icons\*.png public\ >nul

REM Verifica se os arquivos foram copiados
set /a count=0
for %%f in (public\icon-*.png) do set /a count+=1

if %count%==8 (
    echo.
    echo ================================================
    echo   [SUCESSO] 8 icones copiados para \public
    echo ================================================
    echo.
    
    echo Icones instalados:
    dir /b public\icon-*.png
    echo.
    
    REM Copia README se existir
    if exist "pwa-icons-temp\pwa-icons\README.md" (
        copy /y pwa-icons-temp\pwa-icons\README.md public\PWA_ICONS_README.md >nul
        echo [INFO] README copiado para \public\PWA_ICONS_README.md
        echo.
    )
    
    echo ================================================
    echo   Instalacao concluida com sucesso!
    echo ================================================
    echo.
    echo Proximos passos:
    echo 1. Verifique os icones: dir public\icon-*.png
    echo 2. Inicie o servidor: npm run dev
    echo 3. Abra DevTools (F12) - Application - Manifest
    echo 4. Confirme que todos os icones aparecem sem erros
    echo.
    echo [OK] Seu PWA esta 100%% completo!
    echo.
    
) else (
    echo.
    echo [ERRO] Esperado 8 icones, encontrado %count%
    echo.
    echo Icones encontrados:
    dir /b public\icon-*.png 2>nul || echo   Nenhum icone encontrado
    echo.
    pause
    exit /b 1
)

REM Limpa arquivos temporários
echo [INFO] Limpando arquivos temporarios...
rmdir /s /q pwa-icons-temp

REM Move ZIP para backup
if not exist "backups" mkdir backups
for /f "tokens=2-4 delims=/ " %%a in ('date /t') do (set mydate=%%c%%a%%b)
for /f "tokens=1-2 delims=/:" %%a in ('time /t') do (set mytime=%%a%%b)
move /y porsche-cup-pwa-icons.zip backups\porsche-cup-pwa-icons-%mydate%-%mytime%.zip >nul

echo [INFO] ZIP movido para \backups
echo.
echo ================================================
echo   Processo finalizado!
echo ================================================
echo.

pause
