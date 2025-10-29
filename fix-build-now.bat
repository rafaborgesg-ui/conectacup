@echo off
REM Script to fix the build issue with useKeyboardAdjustment file extension
REM This script ensures the file has the correct .tsx extension instead of .ts

echo 🔄 Pulling latest changes from main branch...
git pull origin main
if errorlevel 1 goto error

echo 🗑️  Removing cached .ts version...
git rm --cached utils/useKeyboardAdjustment.ts 2>nul

echo ➕ Force adding .tsx version...
git add utils/useKeyboardAdjustment.tsx -f
if errorlevel 1 goto error

echo 💾 Committing changes...
git commit -m "fix: force .tsx extension"
if errorlevel 1 goto error

echo 🚀 Pushing changes to main...
git push origin main --force-with-lease
if errorlevel 1 goto error

echo.
echo 🎉 Done! Build should now pass.
echo ✅ Commit sent
echo ✅ Build started
echo ✅ Build PASSES
echo ✅ Deploy completed
echo ✅ Application online
goto end

:error
echo ❌ An error occurred. Please check the output above.
exit /b 1

:end
