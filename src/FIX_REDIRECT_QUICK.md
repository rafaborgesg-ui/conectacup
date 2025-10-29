# ⚡ CORREÇÃO RÁPIDA - REDIRECT GOOGLE OAUTH

**Problema:** Redireciona para `porschecup.vercel.app` ao invés de `conectacup.com`

---

## 🎯 SOLUÇÃO (5 MINUTOS)

### **1. SUPABASE DASHBOARD (2min)** ⚠️ **CRÍTICO**

**Link:** https://supabase.com/dashboard/project/nflgqugaabtxzifyhjor/auth/url-configuration

**Altere:**

```yaml
Site URL:
  ❌ REMOVA: https://porschecup.vercel.app
  ✅ ADICIONE: https://www.conectacup.com

Redirect URLs (uma por linha):
  ✅ https://www.conectacup.com/
  ✅ https://www.conectacup.com/**
  ✅ https://conectacup.com/
  ✅ https://conectacup.com/**
  ✅ http://localhost:5173/
  ✅ http://localhost:5173/**
  
  ❌ REMOVA: Qualquer URL com "vercel.app"
```

**Clique em SAVE** ✅

---

### **2. GOOGLE CLOUD CONSOLE (2min)**

**Link:** https://console.cloud.google.com/apis/credentials

1. Clique no seu **OAuth 2.0 Client ID**

2. **Authorized redirect URIs:**
   ```
   ✅ https://nflgqugaabtxzifyhjor.supabase.co/auth/v1/callback
   ✅ https://www.conectacup.com/
   ✅ https://conectacup.com/
   
   ❌ REMOVA: https://porschecup.vercel.app/
   ```

3. **Clique em SAVE** ✅

---

### **3. TESTE (1min)**

1. **Limpe cache:** `Ctrl + Shift + Delete` → "Todo o período"

2. **Ou use janela anônima:** `Ctrl + Shift + N`

3. **Teste:**
   - Acesse: https://www.conectacup.com/
   - Clique em "Fazer Login com Google"
   - Deve retornar para: `https://www.conectacup.com/` ✅

---

## 📋 CHECKLIST

- [ ] Supabase: Site URL = `https://www.conectacup.com`
- [ ] Supabase: Redirect URLs adicionadas (6 URLs)
- [ ] Supabase: URLs do Vercel removidas
- [ ] Google: Redirect URIs atualizados
- [ ] Google: URLs do Vercel removidas
- [ ] Cache limpo
- [ ] Testado em janela anônima
- [ ] Redireciona corretamente para conectacup.com ✅

---

## 🆘 ERRO?

**Ainda redireciona para Vercel:**
- Aguarde 5-10 minutos (propagação)
- Limpe cache completamente
- Use janela anônima

**Erro "redirect_uri_mismatch":**
- URI deve ser: `https://nflgqugaabtxzifyhjor.supabase.co/auth/v1/callback`
- Copie do Supabase Dashboard → Authentication → Providers → Google

---

## 📚 GUIA COMPLETO

Ver: `/FIX_GOOGLE_OAUTH_REDIRECT_CONECTACUP.md`

---

**Status:** ⏳ Aguardando configuração  
**Tempo:** 5 minutos  
**Próximo:** 🚀 Tour Interativo
