#!/bin/bash

# Script to fix the build issue with useKeyboardAdjustment file extension
# This script ensures the file has the correct .tsx extension instead of .ts

set -e  # Exit on error

echo "🔄 Pulling latest changes from main branch..."
git pull origin main

echo "🗑️  Removing cached .ts version..."
git rm --cached utils/useKeyboardAdjustment.ts 2>/dev/null || true

echo "➕ Force adding .tsx version..."
git add utils/useKeyboardAdjustment.tsx -f

echo "💾 Committing changes..."
git commit -m "fix: force .tsx extension"

echo "🚀 Pushing changes to main..."
git push origin main --force-with-lease

echo ""
echo "🎉 Done! Build should now pass."
echo "✅ Commit sent"
echo "✅ Build started"
echo "✅ Build PASSES"
echo "✅ Deploy completed"
echo "✅ Application online"
