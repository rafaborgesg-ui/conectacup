# 🚀 GOOGLE OAUTH - GUIA RÁPIDO (2 MINUTOS)

## ❌ PROBLEMA
Login Google mostra: **"Prosseguir para visual code"**

## ✅ SOLUÇÃO
Mostrar: **"Prosseguir para Conecta Cup"**

---

## 🔧 O QUE FAZER (3 PASSOS)

### **PASSO 1: Acessar Google Cloud Console**

1. Vá para: https://console.cloud.google.com/apis/credentials/consent

2. Faça login com sua conta Google

---

### **PASSO 2: Editar Nome da Aplicação**

1. Clique em **EDITAR APLICATIVO**

2. Encontre o campo: **Nome do aplicativo**

3. **Mude de:** `visual code`  
   **Para:** `Conecta Cup`

4. Clique em **SALVAR E CONTINUAR** (3x até o final)

---

### **PASSO 3: Testar**

1. Limpe o cache do navegador (Ctrl + Shift + Delete)

2. Acesse: https://www.conectacup.com/

3. Clique em **Entrar com Google**

4. Deve aparecer: **"Prosseguir para Conecta Cup"** ✅

---

## 📋 CHECKLIST

- [ ] Acessei https://console.cloud.google.com/apis/credentials/consent
- [ ] Cliquei em "EDITAR APLICATIVO"
- [ ] Alterei "Nome do aplicativo" para "Conecta Cup"
- [ ] Salvei as alterações
- [ ] Limpei cache do navegador
- [ ] Testei o login com Google
- [ ] Confirmo que aparece "Conecta Cup"

---

## 🆘 TROUBLESHOOTING

**Ainda aparece "visual code"?**
- Aguarde 5-10 minutos (Google demora para propagar)
- Teste em janela anônima
- Verifique se editou o projeto correto

**Erro "Redirect URI mismatch"?**
- Adicione em **URIs de redirecionamento autorizados:**
  ```
  https://nflgqugaabtxzifyhjor.supabase.co/auth/v1/callback
  https://www.conectacup.com/
  ```

---

## 📚 DOCUMENTAÇÃO COMPLETA

Ver: `/docs/guides/GOOGLE_OAUTH_CONFIGURACAO_CONECTA_CUP.md`

---

**Status:** ⏳ Aguardando configuração no Google Cloud  
**Próximo:** 🚀 Tour Interativo (+2 UX)

---

## 🔗 LINK DIRETO

👉 **https://console.cloud.google.com/apis/credentials/consent**

(Salve este link nos favoritos!)
