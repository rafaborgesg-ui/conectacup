# 🔐 **CONFIGURAÇÃO GOOGLE OAuth - CONECTA CUP**

## ✅ **STATUS DO CÓDIGO**
O código está **CORRETO** e pronto. O problema é **CONFIGURAÇÃO EXTERNA**.

---

## 🎯 **PASSO 1: SUPABASE - URL Configuration**

### **1.1 Acesse o Supabase Dashboard**
```
https://supabase.com/dashboard
```

### **1.2 Selecione seu projeto e vá em:**
```
Authentication → URL Configuration
```

### **1.3 Configure as seguintes URLs:**

```
Site URL:
https://www.conectacup.com

Additional Redirect URLs:
https://www.conectacup.com/**
https://www.conectacup.com
```

**⚠️ IMPORTANTE:** Clique em **SAVE** depois de configurar!

---

## 🎯 **PASSO 2: GOOGLE CLOUD CONSOLE - Authorized Redirect URIs**

### **2.1 Acesse o Google Cloud Console**
```
https://console.cloud.google.com/apis/credentials
```

### **2.2 Encontre suas credenciais OAuth 2.0**
- Clique no projeto que você está usando
- Vá em "APIs & Services" → "Credentials"
- Clique no **Client ID** que você criou

### **2.3 Adicione as Authorized Redirect URIs**

**VOCÊ PRECISA ADICIONAR AMBAS AS URLs:**

```
https://kpgusqbafkbs.supabase.co/auth/v1/callback
https://www.conectacup.com
```

**⚠️ SUBSTITUA:** `kpgusqbafkbs` pelo seu **PROJECT_ID** real do Supabase.

**💡 Como encontrar o PROJECT_ID:**
1. Vá no Supabase Dashboard
2. Clique em "Settings" → "General"
3. Copie o "Reference ID" ou olhe a URL: `https://supabase.com/dashboard/project/[PROJECT_ID]`

### **2.4 Clique em SAVE**

---

## 🎯 **PASSO 3: VERIFICAR CONFIGURAÇÃO NO SUPABASE**

### **3.1 Vá em Authentication → Providers → Google**

**Verifique se está configurado:**
- ✅ **Google Enabled** (toggle verde)
- ✅ **Client ID** preenchido
- ✅ **Client Secret** preenchido

---

## 🎯 **PASSO 4: TESTE**

### **4.1 Abra o DevTools (F12)**

### **4.2 Vá na aba "Console"**

### **4.3 Limpe o cache:**
```javascript
localStorage.clear()
sessionStorage.clear()
```

### **4.4 Recarregue a página (Ctrl+Shift+R)**

### **4.5 Clique em "Entrar com Google"**

### **4.6 Observe os logs:**

**ESPERADO:**
```
🔐 Iniciando login com Google...
(Redirecionamento para Google)
(Escolhe conta)
(Volta para https://www.conectacup.com/?code=...)
✅ Auth mudou: SIGNED_IN
```

**SE DER ERRO:**
```
❌ Error: Invalid redirect URI
```

**SOLUÇÃO:** Verifique se adicionou AMBAS as URLs no Google Cloud Console.

---

## 🔍 **DIAGNÓSTICO DE PROBLEMAS**

### **Problema: "Invalid redirect URI"**

**Causa:** Google Cloud Console não tem as URLs corretas.

**Solução:**
1. Vá em Google Cloud Console
2. Adicione AMBAS as URLs:
   - `https://[PROJECT_ID].supabase.co/auth/v1/callback`
   - `https://www.conectacup.com`

---

### **Problema: "Google provider is not enabled"**

**Causa:** Google OAuth não configurado no Supabase.

**Solução:**
1. Vá em Supabase → Authentication → Providers → Google
2. Habilite o toggle
3. Adicione Client ID e Client Secret

**📖 Siga:** https://supabase.com/docs/guides/auth/social-login/auth-google

---

### **Problema: Redireciona mas não volta**

**Causa:** Site URL incorreta no Supabase.

**Solução:**
1. Vá em Supabase → Authentication → URL Configuration
2. Site URL: `https://www.conectacup.com`
3. Additional Redirect URLs: `https://www.conectacup.com/**`

---

## 📸 **SCREENSHOTS PARA CONFERÊNCIA**

### **Screenshot 1 - Supabase URL Configuration**
```
Site URL: https://www.conectacup.com
Additional Redirect URLs: https://www.conectacup.com/**
```

### **Screenshot 2 - Google Cloud Console**
```
Authorized redirect URIs:
  https://kpgusqbafkbs.supabase.co/auth/v1/callback
  https://www.conectacup.com
```

### **Screenshot 3 - Supabase Google Provider**
```
Google: Enabled ✅
Client ID: [SEU_CLIENT_ID]
Client Secret: [SEU_CLIENT_SECRET]
```

---

## ✅ **CHECKLIST FINAL**

Antes de testar, confirme que:

- [ ] Supabase URL Configuration tem `https://www.conectacup.com`
- [ ] Google Cloud Console tem AMBAS as URLs redirect
- [ ] Google Provider está Enabled no Supabase
- [ ] Client ID e Secret estão preenchidos
- [ ] Limpou o cache (localStorage + sessionStorage)

---

## 🚀 **PRÓXIMOS PASSOS APÓS CONFIGURAR**

1. ✅ Limpe o cache
2. ✅ Recarregue a página
3. ✅ Clique em "Entrar com Google"
4. ✅ Escolha a conta
5. ✅ Deve voltar autenticado

---

## 📞 **SUPORTE**

Se ainda tiver problemas, envie:
1. Screenshot do Supabase URL Configuration
2. Screenshot do Google Cloud Console Authorized redirect URIs
3. Screenshot do console (F12) quando clica no botão
4. Mensagem de erro completa

---

**🎯 O CÓDIGO ESTÁ 100% CORRETO. O PROBLEMA É SÓ CONFIGURAÇÃO!**
