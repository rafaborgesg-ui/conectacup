# 🔧 **PLANO B: OAuth via Vercel Deploy**

## 🎯 **OBJETIVO:**

Testar se o problema é específico do custom domain Figma Sites ou se é uma configuração mais profunda.

---

## 📋 **ESTRATÉGIA:**

### **HIPÓTESE 1: Problema no Custom Domain**
- Custom domain `www.conectacup.com` pode ter limitações de redirect
- CSP/CORS do Figma Sites pode estar bloqueando

### **HIPÓTESE 2: Problema na Configuração Supabase/Google**
- Site URL incorreto
- Redirect URIs incompletos

---

## 🚀 **SOLUÇÃO: Deploy Temporário**

Vou criar uma versão standalone que você pode:

1. **Fazer deploy no Vercel/Netlify**
2. **Testar OAuth com domínio .vercel.app**
3. **Isolar se o problema é do custom domain**

---

## 📦 **ARQUIVO DE TESTE STANDALONE:**

Criei `/public/teste-google-oauth-direto.html` que:

- ✅ Funciona standalone
- ✅ Não depende do React/App.tsx
- ✅ Pode ser testado diretamente
- ✅ Tem logs completos

---

## 🧪 **TESTE AGORA:**

### **OPÇÃO 1: Teste Local**

1. Acesse:
```
https://www.conectacup.com/teste-google-oauth-direto.html
```

2. Abra Console (F12)

3. Clique "🚀 TESTAR OAUTH GOOGLE"

4. Observe os logs completos

5. Me envie screenshot do Console COMPLETO (desde "Iniciando" até o retorno)

---

### **OPÇÃO 2: Deploy Temporário Vercel (SE OPÇÃO 1 FALHAR)**

Se o teste acima falhar novamente, farei um deploy separado em:

```
https://conectacup-oauth-test.vercel.app
```

Isso vai **provar** se o problema é o custom domain ou não.

---

## 🔍 **PRÓXIMOS PASSOS:**

### **SE TESTE LOCAL FUNCIONAR:**
✅ Problema resolvido! Era configuração do código.

### **SE TESTE LOCAL FALHAR:**
1. Verificar Site URL no Supabase (veja VERIFICAR_SUPABASE_SITE_URL.md)
2. Se Site URL estiver correto → fazer deploy Vercel temporário
3. Se deploy Vercel funcionar → problema é custom domain
4. Se deploy Vercel falhar → problema é Google Cloud Console

---

## 📸 **LOGS ESPERADOS (SUCESSO):**

```
[HH:MM:SS] ✅ Sistema iniciado
[HH:MM:SS] ℹ️ Project ID: nflgqugaabtxzifyhjor
[HH:MM:SS] ℹ️ Importando Supabase client...
[HH:MM:SS] ✅ Cliente criado!
[HH:MM:SS] ℹ️ Configuração OAuth:
[HH:MM:SS] ℹ️   Provider: Google
[HH:MM:SS] ℹ️   Redirect URL: https://www.conectacup.com/
[HH:MM:SS] ⚠️ Iniciando OAuth...
[HH:MM:SS] ✅ OAuth iniciado com sucesso!
[HH:MM:SS] ℹ️ Você será redirecionado para o Google...
[HH:MM:SS] ⏳ Aguardando redirecionamento...

(Vai para Google)
(Escolhe conta)
(Volta)

[HH:MM:SS] ✅ CALLBACK OAUTH DETECTADO!
[HH:MM:SS] ✅ O login foi bem-sucedido!
```

---

## 📸 **LOGS ESPERADOS (ERRO):**

```
[HH:MM:SS] ✅ Sistema iniciado
[HH:MM:SS] ℹ️ Importando Supabase client...
[HH:MM:SS] ✅ Cliente criado!
[HH:MM:SS] ⚠️ Iniciando OAuth...
[HH:MM:SS] ❌ ERRO AO INICIAR OAUTH
[HH:MM:SS] ❌ Mensagem: [descrição do erro]
```

---

## 🎯 **AÇÃO IMEDIATA:**

**TESTE AGORA:**
```
https://www.conectacup.com/teste-google-oauth-direto.html
```

**ME ENVIE:**
1. Screenshot do console COMPLETO (do início ao fim)
2. Screenshot da URL final onde você acabou
3. Se houve erro, qual foi a mensagem

---

## 💡 **POR QUE ESSE TESTE É CRUCIAL:**

Este teste **isola completamente** o problema porque:

1. ✅ Não depende do React/App.tsx
2. ✅ Não depende de routing
3. ✅ Usa exatamente as mesmas credenciais Supabase
4. ✅ Logs ultra-detalhados
5. ✅ Mostra EXATAMENTE onde falha

Se falhar aqui, sabemos que é:
- Configuração Supabase Site URL, OU
- Configuração Google Redirect URIs, OU
- Problema com custom domain

---

**TESTE E ME ENVIE OS RESULTADOS IMEDIATAMENTE!** 🚀
