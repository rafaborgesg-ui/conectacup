# 🔍 **VERIFICAR CONFIGURAÇÃO SUPABASE - URGENTE**

## 🚨 **PROBLEMA IDENTIFICADO:**

O Google **aceita** a autenticação mas **não consegue** redirecionar de volta.

Isso acontece porque o **Site URL** no Supabase Dashboard pode estar configurado incorretamente.

---

## ✅ **VERIFICAÇÃO OBRIGATÓRIA:**

### **PASSO 1: Acesse o Supabase Dashboard**

```
https://supabase.com/dashboard/project/nflgqugaabtxzifyhjor
```

### **PASSO 2: Vá em Authentication > URL Configuration**

Caminho:
```
Authentication → URL Configuration
```

### **PASSO 3: Verifique o Site URL**

**DEVE ESTAR EXATAMENTE:**
```
https://www.conectacup.com
```

**❌ ERRADO:**
```
https://conectacup.com           (sem www)
http://www.conectacup.com        (http em vez de https)
https://www.conectacup.com/      (com barra no final)
```

**✅ CORRETO:**
```
https://www.conectacup.com
```

---

## 🔧 **CORREÇÃO SE ESTIVER ERRADO:**

### **No campo "Site URL", coloque:**
```
https://www.conectacup.com
```

### **No campo "Redirect URLs", adicione:**
```
https://www.conectacup.com/**
https://www.conectacup.com
```

### **Clique em SAVE**

### **Aguarde 2 minutos** (propagação da configuração)

---

## 📸 **ME ENVIE SCREENSHOT:**

Tire um screenshot da tela **Authentication → URL Configuration** mostrando:

- ✅ Site URL
- ✅ Redirect URLs
- ✅ Depois de salvar

**FORMATO ESPERADO:**

```
Authentication / URL Configuration

Site URL:
  https://www.conectacup.com

Redirect URLs:
  https://www.conectacup.com/**
  https://www.conectacup.com
  
[SAVE] button
```

---

## 🧪 **TESTE APÓS CORRIGIR:**

### **1. Limpe o cache:**
```javascript
localStorage.clear()
sessionStorage.clear()
```

### **2. Aguarde 2 minutos**

### **3. Teste novamente:**
```
https://www.conectacup.com
```

### **4. Clique "Entrar com Google"**

---

## 🎯 **RESULTADO ESPERADO:**

Após escolher conta no Google, deve voltar para:
```
https://www.conectacup.com/?code=XXXXXXXXXXXXXXXXXX
```

Ou:
```
https://www.conectacup.com/#access_token=XXXXXXXXXXXXXXXX
```

**E os logs devem mostrar:**
```
📍 URL Check:
  Full URL: https://www.conectacup.com/?code=...
  É OAuth callback? true
✅ SIGNED_IN
```

---

## ⚠️ **SE O SITE URL ESTIVER CORRETO:**

Se já está configurado como `https://www.conectacup.com` e ainda não funciona, o problema está em outra camada.

Nesse caso, precisamos testar com um **domínio Vercel** temporário para isolar se o problema é específico do custom domain.

---

## 📞 **REPORTE:**

**Me envie:**

1. ✅ Screenshot do Supabase URL Configuration
2. ✅ Confirmação do valor exato do Site URL
3. ✅ Resultado do teste após salvar
4. ✅ Logs do console após o teste

---

## 🔍 **CHECKLIST:**

- [ ] Acessei o Supabase Dashboard
- [ ] Fui em Authentication → URL Configuration
- [ ] Verifiquei o Site URL
- [ ] Tirei screenshot
- [ ] (Se necessário) Corrigi o Site URL
- [ ] Salvei as alterações
- [ ] Aguardei 2 minutos
- [ ] Testei novamente
- [ ] Enviei resultados

---

**VERIFIQUE AGORA E ME ENVIE OS RESULTADOS!** 🚀
