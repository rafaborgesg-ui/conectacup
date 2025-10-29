# fix: rename useKeyboardAdjustment.ts to .tsx (contains JSX)

## 🐛 Problema

Build falhando no Vercel com erro de sintaxe JSX:
```
ERROR: Unexpected ">"
/vercel/path0/src/utils/useKeyboardAdjustment.ts:221:10
```

## ✅ Solução

Renomeado arquivo de `.ts` para `.tsx` pois contém JSX (componente `KeyboardAware`).

## 📝 Mudanças

### Arquivos
- 🗑️ Deletado: `utils/useKeyboardAdjustment.ts`
- ✨ Criado: `utils/useKeyboardAdjustment.tsx`

### Conteúdo
- Código idêntico
- Apenas mudança de extensão
- JSX agora suportado corretamente

## 🧪 Testado

- ✅ Build local passa
- ✅ Importações funcionando
- ✅ Sem breaking changes
- ✅ Runtime sem impacto

## 🎯 Regra

Arquivos que contêm JSX devem ter extensão `.tsx` (não `.ts`).

## 📊 Impacto

**Breaking Changes:** Nenhum  
**Runtime Impact:** Nenhum  
**Build:** ✅ Corrigido

---

**Tipo:** Bug Fix  
**Escopo:** Build, TypeScript  
**Versão:** 2.3.1  
**Data:** 2025-10-29
