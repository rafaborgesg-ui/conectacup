# 🔧 CORREÇÃO: GOOGLE OAUTH REDIRECT PARA CONECTACUP.COM

**Data:** 24/01/2025  
**Problema:** Após login Google, redireciona para `https://porschecup.vercel.app/#` ao invés de `conectacup.com`  
**Causa:** Configurações antigas no Supabase Dashboard e Google Cloud Console  

---

## 🎯 PROBLEMA IDENTIFICADO

### **Sintoma:**
```
❌ Após "Fazer Login com o Google"
   Redireciona para: https://porschecup.vercel.app/#
   
✅ Deveria redirecionar para: https://www.conectacup.com/
```

### **Causa:**
O código está correto (`redirectTo: 'https://www.conectacup.com/'`), mas a configuração no **Supabase Dashboard** ainda tem URLs antigas.

---

## ✅ SOLUÇÃO (3 PASSOS)

### **PASSO 1: SUPABASE DASHBOARD** ⚠️ **CRÍTICO**

1. **Acesse Supabase Dashboard:**
   ```
   https://supabase.com/dashboard/project/nflgqugaabtxzifyhjor
   ```

2. **Vá em: Authentication → URL Configuration**
   
   Ou acesse direto:
   ```
   https://supabase.com/dashboard/project/nflgqugaabtxzifyhjor/auth/url-configuration
   ```

3. **Atualize os seguintes campos:**

   **Site URL:**
   ```
   ❌ REMOVA: https://porschecup.vercel.app
   ✅ ADICIONE: https://www.conectacup.com
   ```

   **Redirect URLs (Allowed):**
   ```
   ✅ ADICIONE (cada URL em uma linha):
   
   https://www.conectacup.com/
   https://www.conectacup.com/**
   https://conectacup.com/
   https://conectacup.com/**
   http://localhost:5173/
   http://localhost:5173/**
   ```

   **⚠️ IMPORTANTE:** 
   - **REMOVA** qualquer URL que contenha `porschecup.vercel.app`
   - **REMOVA** qualquer URL que contenha `.vercel.app`

4. **Salve as alterações**

---

### **PASSO 2: GOOGLE CLOUD CONSOLE**

1. **Acesse Google Cloud Console:**
   ```
   https://console.cloud.google.com/apis/credentials
   ```

2. **Encontre seu OAuth 2.0 Client ID**
   - Clique no nome do cliente

3. **Atualize "Authorized redirect URIs":**

   **Adicione:**
   ```
   https://nflgqugaabtxzifyhjor.supabase.co/auth/v1/callback
   https://www.conectacup.com/
   https://conectacup.com/
   ```

   **Remova:**
   ```
   ❌ https://porschecup.vercel.app/
   ❌ Qualquer URL com .vercel.app
   ```

4. **Salve**

---

### **PASSO 3: LIMPAR SESSÕES E TESTAR**

1. **Limpe o cache do navegador:**
   - Chrome: `Ctrl + Shift + Delete`
   - Escolha: "Cookies e outros dados do site" + "Imagens e arquivos em cache"
   - Período: "Todo o período"
   - Clique em "Limpar dados"

2. **Ou use Janela Anônita:**
   - Chrome: `Ctrl + Shift + N`
   - Edge: `Ctrl + Shift + P`

3. **Teste o login:**
   ```
   1. Acesse: https://www.conectacup.com/
   2. Clique em "Fazer Login com Google"
   3. Escolha sua conta
   4. Você deve ser redirecionado para: https://www.conectacup.com/
   5. E estar logado no sistema ✅
   ```

---

## 🔍 VERIFICAÇÃO DETALHADA

### **A. Supabase Dashboard**

1. **Authentication → URL Configuration:**
   ```yaml
   Site URL: https://www.conectacup.com
   
   Redirect URLs:
     - https://www.conectacup.com/
     - https://www.conectacup.com/**
     - https://conectacup.com/
     - https://conectacup.com/**
     - http://localhost:5173/
     - http://localhost:5173/**
   ```

2. **Authentication → Providers → Google:**
   ```yaml
   Google Enabled: ON (toggle verde)
   Client ID: (seu client ID do Google)
   Client Secret: (seu client secret do Google)
   Redirect URL: https://nflgqugaabtxzifyhjor.supabase.co/auth/v1/callback
   ```

### **B. Google Cloud Console**

1. **APIs & Services → Credentials → OAuth 2.0 Client IDs:**
   ```yaml
   Authorized JavaScript origins:
     - https://www.conectacup.com
     - https://conectacup.com
     - http://localhost:5173
   
   Authorized redirect URIs:
     - https://nflgqugaabtxzifyhjor.supabase.co/auth/v1/callback
     - https://www.conectacup.com/
     - https://conectacup.com/
   ```

2. **APIs & Services → OAuth consent screen:**
   ```yaml
   Application name: Conecta Cup
   Authorized domains:
     - conectacup.com
     - supabase.co
   ```

---

## 🧪 TESTE COMPLETO

### **1. Teste Local (Desenvolvimento)**

```bash
# Terminal 1: Inicie o servidor local
npm run dev

# Navegador
1. Abra: http://localhost:5173
2. Clique em "Fazer Login com Google"
3. Faça login
4. Deve retornar para: http://localhost:5173/ ✅
```

### **2. Teste Produção**

```bash
# Navegador (janela anônima)
1. Abra: https://www.conectacup.com/
2. Clique em "Fazer Login com Google"
3. Escolha conta Google
4. Deve retornar para: https://www.conectacup.com/ ✅
5. Deve estar logado no sistema ✅
```

---

## 🚨 TROUBLESHOOTING

### **Problema 1: Ainda redireciona para Vercel**

**Solução:**
1. Verifique se salvou no Supabase Dashboard
2. Aguarde 5-10 minutos para propagação
3. Limpe cache do navegador COMPLETAMENTE
4. Use janela anônima
5. Verifique se está testando em `https://www.conectacup.com/` (não localhost)

### **Problema 2: Erro "redirect_uri_mismatch"**

**Solução:**
1. A URI no Google Cloud Console deve ser EXATAMENTE:
   ```
   https://nflgqugaabtxzifyhjor.supabase.co/auth/v1/callback
   ```
2. Sem barra no final
3. HTTPS obrigatório
4. Copie e cole do Supabase Dashboard → Authentication → Providers → Google

### **Problema 3: Erro 401 após login**

**Solução:**
1. Verifique se o Client ID e Client Secret no Supabase estão corretos
2. Copie novamente do Google Cloud Console
3. Cole no Supabase (sem espaços extras)
4. Salve e aguarde 2 minutos

### **Problema 4: "App not verified"**

**Solução:**
1. Isso é NORMAL em desenvolvimento
2. Clique em "Avançado" → "Ir para Conecta Cup (não seguro)"
3. Para produção, você precisa submeter o app para verificação do Google

### **Problema 5: Loop infinito de redirecionamento**

**Solução:**
1. Limpe cookies do site
2. Saia de todas as sessões no Supabase Dashboard
3. Aguarde 5 minutos
4. Tente novamente em janela anônima

---

## 📋 CHECKLIST COMPLETO

### **Supabase Dashboard:**
- [ ] Site URL atualizada para `https://www.conectacup.com`
- [ ] Redirect URLs adicionadas (6 URLs)
- [ ] URLs antigas do Vercel removidas
- [ ] Google provider ativado
- [ ] Client ID e Client Secret verificados
- [ ] Configurações salvas

### **Google Cloud Console:**
- [ ] OAuth Client ID configurado
- [ ] Redirect URIs atualizados (sem Vercel)
- [ ] JavaScript origins atualizados
- [ ] OAuth consent screen com "Conecta Cup"
- [ ] Domínios autorizados atualizados

### **Código (já feito):**
- [x] `redirectTo` no Login.tsx = `https://www.conectacup.com/`
- [x] Nenhuma referência a Vercel no código
- [x] Logo alt text = "Conecta Cup"

### **Teste:**
- [ ] Cache do navegador limpo
- [ ] Login local testado (localhost)
- [ ] Login produção testado (conectacup.com)
- [ ] Redirecionamento correto confirmado
- [ ] Sem erros no console

---

## 🔗 LINKS IMPORTANTES

### **Supabase:**
- Dashboard: https://supabase.com/dashboard/project/nflgqugaabtxzifyhjor
- URL Config: https://supabase.com/dashboard/project/nflgqugaabtxzifyhjor/auth/url-configuration
- Providers: https://supabase.com/dashboard/project/nflgqugaabtxzifyhjor/auth/providers

### **Google Cloud:**
- Console: https://console.cloud.google.com/
- Credentials: https://console.cloud.google.com/apis/credentials
- OAuth Consent: https://console.cloud.google.com/apis/credentials/consent

### **Documentação:**
- Supabase Auth: https://supabase.com/docs/guides/auth/social-login/auth-google
- Google OAuth: https://developers.google.com/identity/protocols/oauth2

---

## 📊 FLUXO CORRETO

```
┌─────────────────────────────────────────────────┐
│ 1. Usuário clica "Login com Google"            │
│    em https://www.conectacup.com/               │
└─────────────────────────┬───────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────┐
│ 2. Supabase redireciona para Google             │
│    accounts.google.com/o/oauth2/auth            │
└─────────────────────────┬───────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────┐
│ 3. Usuário faz login no Google                  │
│    e autoriza o app "Conecta Cup"               │
└─────────────────────────┬───────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────┐
│ 4. Google redireciona para Supabase callback    │
│    nflgqugaabtxzifyhjor.supabase.co/auth/v1/... │
└─────────────────────────┬───────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────┐
│ 5. Supabase processa autenticação               │
│    e cria sessão do usuário                     │
└─────────────────────────┬───────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────┐
│ 6. Supabase redireciona para redirectTo         │
│    ✅ https://www.conectacup.com/               │
│    ❌ NÃO https://porschecup.vercel.app/        │
└─────────────────────────┬───────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────┐
│ 7. Usuário está logado em conectacup.com ✅     │
└─────────────────────────────────────────────────┘
```

---

## 🎯 PRÓXIMOS PASSOS

Após corrigir o redirect:

1. ✅ Código atualizado (COMPLETO)
2. ⏳ Configurar Supabase Dashboard (VOCÊ - 2min)
3. ⏳ Configurar Google Cloud Console (VOCÊ - 2min)
4. ⏳ Testar login com Google (VOCÊ - 1min)
5. 🚀 Continuar com Tour Interativo (+2 UX)

---

## 💡 DICA IMPORTANTE

O `redirectTo` no código é **apenas uma sugestão**. O Supabase decide para onde redirecionar baseado em:

1. **Prioritário:** URLs configuradas em "Redirect URLs (Allowed)" no Dashboard
2. **Fallback:** Site URL no Dashboard
3. **Código:** `redirectTo` no código (deve estar na lista de URLs permitidas)

Por isso é CRÍTICO configurar corretamente no Supabase Dashboard!

---

## ✅ CÓDIGO JÁ ATUALIZADO

O código já está correto:

```typescript
// /components/Login.tsx - Linha 179
const { data, error } = await supabase.auth.signInWithOAuth({
  provider: 'google',
  options: {
    redirectTo: 'https://www.conectacup.com/', // ✅ CORRETO
    queryParams: {
      access_type: 'offline',
      prompt: 'consent',
    },
  },
});
```

**Nenhuma referência a Vercel no código!** ✅

---

## 📝 RESUMO EXECUTIVO

| Item | Status | Ação Necessária |
|------|--------|-----------------|
| **Código** | ✅ OK | Nenhuma (já atualizado) |
| **Supabase Dashboard** | ⚠️ PENDENTE | Atualizar URLs (2min) |
| **Google Cloud Console** | ⚠️ PENDENTE | Atualizar redirect URIs (2min) |
| **Teste** | ⏳ AGUARDANDO | Testar após configuração |

**Tempo total estimado:** 5 minutos

---

**Status:** ✅ Código limpo (sem Vercel)  
**Próximo:** ⏳ Configurar Dashboards (Supabase + Google)  
**Depois:** 🚀 Tour Interativo (+2 UX)

```
╔══════════════════════════════════════════════════╗
║                                                   ║
║  ✅ CÓDIGO LIMPO - SEM REFERÊNCIAS VERCEL        ║
║                                                   ║
║  ⚠️ CONFIGURE MANUALMENTE:                       ║
║                                                   ║
║  1️⃣ Supabase Dashboard (2min)                   ║
║     Site URL + Redirect URLs                     ║
║                                                   ║
║  2️⃣ Google Cloud Console (2min)                 ║
║     Redirect URIs                                ║
║                                                   ║
║  3️⃣ Teste (1min)                                ║
║     Janela anônima                               ║
║                                                   ║
║  🔗 Links diretos fornecidos acima              ║
║                                                   ║
╚══════════════════════════════════════════════════╝
```
