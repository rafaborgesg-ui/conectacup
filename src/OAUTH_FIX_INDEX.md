# 🔗 ÍNDICE RÁPIDO - CORREÇÃO OAUTH CONECTA CUP

**Use este índice para acessar rapidamente os guias necessários**

---

## 🚀 INÍCIO RÁPIDO (ESCOLHA UM)

### **Opção 1: Guia Ultra-Rápido** ⚡ (5 minutos)
📄 **[FIX_REDIRECT_QUICK.md](./FIX_REDIRECT_QUICK.md)**
- Apenas o essencial
- 3 passos simples
- Links diretos

### **Opção 2: Guia Completo** 📚 (10 minutos)
📄 **[FIX_GOOGLE_OAUTH_REDIRECT_CONECTACUP.md](./FIX_GOOGLE_OAUTH_REDIRECT_CONECTACUP.md)**
- Passo a passo detalhado
- Troubleshooting completo
- Fluxo explicado

---

## 📋 POR PROBLEMA

### **Problema 1: Nome Errado no OAuth**
```
❌ "Prosseguir para visual code"
✅ "Prosseguir para Conecta Cup"
```

**Guias:**
- 📄 [GOOGLE_OAUTH_CONECTA_CUP_QUICK.md](./GOOGLE_OAUTH_CONECTA_CUP_QUICK.md) - 2 minutos
- 📄 [docs/guides/GOOGLE_OAUTH_CONFIGURACAO_CONECTA_CUP.md](./docs/guides/GOOGLE_OAUTH_CONFIGURACAO_CONECTA_CUP.md) - Completo

**Solução:**
1. Google Cloud Console → OAuth consent screen
2. Alterar "Nome do aplicativo" para "Conecta Cup"

---

### **Problema 2: Redirect para Vercel**
```
❌ Redireciona para: porschecup.vercel.app
✅ Deve redirecionar para: conectacup.com
```

**Guias:**
- 📄 [FIX_REDIRECT_QUICK.md](./FIX_REDIRECT_QUICK.md) - 5 minutos
- 📄 [FIX_GOOGLE_OAUTH_REDIRECT_CONECTACUP.md](./FIX_GOOGLE_OAUTH_REDIRECT_CONECTACUP.md) - Completo

**Solução:**
1. Supabase Dashboard → URL Configuration
2. Google Cloud Console → Redirect URIs
3. Remover URLs do Vercel

---

## 🔗 LINKS DIRETOS

### **Supabase Dashboard:**
```
Projeto: https://supabase.com/dashboard/project/nflgqugaabtxzifyhjor

URL Configuration:
https://supabase.com/dashboard/project/nflgqugaabtxzifyhjor/auth/url-configuration

Providers:
https://supabase.com/dashboard/project/nflgqugaabtxzifyhjor/auth/providers
```

### **Google Cloud Console:**
```
Dashboard: https://console.cloud.google.com/

Credentials:
https://console.cloud.google.com/apis/credentials

OAuth Consent Screen:
https://console.cloud.google.com/apis/credentials/consent
```

---

## 📚 DOCUMENTAÇÃO DISPONÍVEL

### **Guias de Correção:**
1. **FIX_REDIRECT_QUICK.md** - Guia rápido redirect (5min)
2. **FIX_GOOGLE_OAUTH_REDIRECT_CONECTACUP.md** - Guia completo redirect
3. **GOOGLE_OAUTH_CONECTA_CUP_QUICK.md** - Guia rápido nome app (2min)
4. **docs/guides/GOOGLE_OAUTH_CONFIGURACAO_CONECTA_CUP.md** - Guia completo nome app

### **Resumos:**
5. **BRANDING_CONECTA_CUP_ATUALIZADO.md** - Todas as alterações de branding
6. **SESSAO_BRANDING_OAUTH_RESUMO.md** - Resumo completo da sessão

---

## ✅ CHECKLIST RÁPIDO

### **1. Configurar Google Cloud Console:**
- [ ] Acessar: https://console.cloud.google.com/apis/credentials/consent
- [ ] Editar "Nome do aplicativo" → "Conecta Cup"
- [ ] Salvar

### **2. Configurar Supabase Dashboard:**
- [ ] Acessar: https://supabase.com/dashboard/project/nflgqugaabtxzifyhjor/auth/url-configuration
- [ ] Site URL → `https://www.conectacup.com`
- [ ] Redirect URLs → Adicionar conectacup.com
- [ ] Remover URLs do Vercel
- [ ] Salvar

### **3. Configurar Google Redirect URIs:**
- [ ] Acessar: https://console.cloud.google.com/apis/credentials
- [ ] Clicar no OAuth Client ID
- [ ] Adicionar redirect URIs do conectacup.com
- [ ] Remover URLs do Vercel
- [ ] Salvar

### **4. Testar:**
- [ ] Limpar cache do navegador
- [ ] Acessar: https://www.conectacup.com/
- [ ] Login com Google
- [ ] Verificar redirect correto

---

## 🆘 PROBLEMAS COMUNS

### **1. Ainda mostra "visual code"**
→ Aguarde 5-10 minutos após salvar no Google Cloud Console  
→ Limpe cache do navegador

### **2. Ainda redireciona para Vercel**
→ Verifique se salvou no Supabase Dashboard  
→ Aguarde 5 minutos para propagação  
→ Use janela anônima para testar

### **3. Erro "redirect_uri_mismatch"**
→ URI deve ser exatamente: `https://nflgqugaabtxzifyhjor.supabase.co/auth/v1/callback`  
→ Copie do Supabase Dashboard

---

## 🎯 RESUMO

| Tarefa | Tempo | Guia Recomendado |
|--------|-------|------------------|
| **Corrigir nome OAuth** | 2min | GOOGLE_OAUTH_CONECTA_CUP_QUICK.md |
| **Corrigir redirect** | 5min | FIX_REDIRECT_QUICK.md |
| **Entender tudo** | 15min | Guias completos |

**Tempo total:** 7 minutos (guias rápidos)

---

## 📞 PRECISA DE AJUDA?

1. **Veja os guias acima** (99% dos casos são resolvidos)
2. **Verifique troubleshooting** nos guias completos
3. **Aguarde 5-10 minutos** após configurações

---

**Última Atualização:** 24/01/2025  
**Status do Código:** ✅ 100% Pronto  
**Próximo Passo:** ⏳ Configurações manuais (você)

```
╔════════════════════════════════════════╗
║  🎯 COMECE AQUI:                       ║
║                                         ║
║  1️⃣ FIX_REDIRECT_QUICK.md (5min)      ║
║     Resolve o redirect para Vercel     ║
║                                         ║
║  2️⃣ GOOGLE_OAUTH_CONECTA_CUP_QUICK.md ║
║     (2min) Corrige nome do app         ║
║                                         ║
║  Total: 7 minutos ⚡                   ║
╚════════════════════════════════════════╝
```
