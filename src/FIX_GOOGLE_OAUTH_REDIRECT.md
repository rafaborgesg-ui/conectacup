# ✅ FIX: Redirecionamento Google OAuth

## 🎯 PROBLEMA RESOLVIDO

**Problema:** Login com Google redirecionava para domínio Vercel  
**Solução:** Código atualizado para redirecionar para **https://www.conectacup.com/**

---

## 📝 ALTERAÇÕES REALIZADAS

### 1. **Login.tsx** - Login com Google
```typescript
// ANTES:
redirectTo: `${window.location.origin}/`

// DEPOIS:
redirectTo: 'https://www.conectacup.com/'
```
**Arquivo:** `/components/Login.tsx` (linha 179)

---

### 2. **index.tsx** - Recuperação de Senha
```typescript
// ANTES:
redirectTo: `${c.req.header('origin') || 'http://localhost:3000'}/reset-password`

// DEPOIS:
redirectTo: 'https://www.conectacup.com/reset-password'
```
**Arquivo:** `/supabase/functions/server/index.tsx` (linha 605)

---

## ⚠️ AÇÃO NECESSÁRIA: Configurar Supabase

### 🔧 **Passo 1: Redirect URLs no Supabase**

1. Acesse: https://supabase.com/dashboard/project/nflgqugaabtxzifyhjor/auth/url-configuration
2. Em **"Redirect URLs"**, adicione:
   ```
   https://www.conectacup.com/
   https://www.conectacup.com/reset-password
   https://www.conectacup.com/**
   ```
3. Clique em **Save**

---

### 🌐 **Passo 2: Site URL no Supabase**

1. Na mesma página, em **"Site URL"**, configure:
   ```
   https://www.conectacup.com
   ```
2. Clique em **Save**

---

### 🔐 **Passo 3: Google Cloud Console**

1. Acesse: https://console.cloud.google.com/apis/credentials
2. Selecione o **OAuth 2.0 Client ID** do projeto
3. Em **"Authorized redirect URIs"**, adicione:
   ```
   https://nflgqugaabtxzifyhjor.supabase.co/auth/v1/callback
   ```
4. Em **"Authorized JavaScript origins"**, adicione:
   ```
   https://www.conectacup.com
   ```
5. Clique em **Save**

---

## 🧪 COMO TESTAR

1. ✅ **Deploy** do código atualizado
2. ✅ **Configurar** Supabase Dashboard (Passos 1-2)
3. ✅ **Configurar** Google Cloud Console (Passo 3)
4. ✅ **Aguardar** 2-3 minutos (propagação)
5. ✅ **Limpar** cache do navegador (Ctrl+Shift+Delete)
6. ✅ **Acessar** https://www.conectacup.com
7. ✅ **Clicar** em "Entrar com Google"
8. ✅ **Verificar** redirecionamento correto

---

## ✅ RESULTADO ESPERADO

### **Fluxo Correto:**
```
1. Usuário clica em "Entrar com Google"
2. É redirecionado para autenticação Google
3. Após autenticar, retorna para: https://www.conectacup.com/
4. Sistema faz login automático
5. Dashboard é exibido
```

### **Antes (Errado):**
```
❌ https://porsche-cup-*.vercel.app/
```

### **Depois (Correto):**
```
✅ https://www.conectacup.com/
```

---

## 📋 CHECKLIST

- [x] ✅ **Código atualizado** - Login.tsx
- [x] ✅ **Código atualizado** - index.tsx (servidor)
- [x] ✅ **Documentação criada** - GOOGLE_OAUTH_CONFIGURACAO.md
- [ ] ⏳ **Configurar Redirect URLs** no Supabase Dashboard
- [ ] ⏳ **Configurar Site URL** no Supabase Dashboard
- [ ] ⏳ **Configurar Google Cloud Console**
- [ ] ⏳ **Testar** login com Google
- [ ] ⏳ **Validar** redirecionamento correto

---

## 🆘 TROUBLESHOOTING

### **Erro: "redirect_uri_mismatch"**
**Causa:** URI não está cadastrada no Google Cloud Console  
**Solução:** Adicione `https://nflgqugaabtxzifyhjor.supabase.co/auth/v1/callback`

### **Ainda redireciona para Vercel**
**Causa:** Cache do navegador ou configuração não propagada  
**Solução:** 
1. Limpe cache completamente
2. Aguarde 5 minutos
3. Tente em aba anônima

### **Erro 401 após login**
**Causa:** Google OAuth não habilitado no Supabase  
**Solução:** Verifique em Auth → Providers → Google

---

## 📚 DOCUMENTAÇÃO COMPLETA

Consulte o guia completo em:
`/docs/guides/GOOGLE_OAUTH_CONFIGURACAO.md`

---

## 🎉 STATUS

**Código:** ✅ PRONTO  
**Deploy:** ⏳ PENDENTE  
**Configuração Supabase:** ⏳ PENDENTE  
**Configuração Google:** ⏳ PENDENTE  
**Testes:** ⏳ PENDENTE

---

**Data:** 24/01/2025  
**Prioridade:** 🔴 ALTA  
**Impacto:** Login com Google indisponível até configuração
