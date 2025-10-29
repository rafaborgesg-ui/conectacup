# 🚨 CORREÇÃO URGENTE - LOOP INFINITO OAUTH

**Problema:** Loop infinito após login com Google  
**Causa:** Redirect URLs vazias no Supabase Dashboard  
**Solução:** 2 minutos  

---

## ❌ PROBLEMA IDENTIFICADO

### **O que está acontecendo:**
```
1. Login com Google → ✅ Funciona
2. Google autentica → ✅ Funciona  
3. Supabase recebe callback → ✅ Funciona
4. Supabase tenta redirecionar → ❌ FALHA (URL não permitida)
5. Volta para /login → ❌ LOOP INFINITO
```

### **Causa Raiz:**
Na imagem que você enviou, vejo:
```
✅ Site URL: https://www.conectacup.com/
❌ Redirect URLs: "No Redirect URLs" (VAZIO!)
```

**O Site URL sozinha NÃO É SUFICIENTE!**  
Você PRECISA adicionar as URLs na lista de **"Redirect URLs"**.

---

## ✅ SOLUÇÃO (2 MINUTOS)

### **PASSO 1: Adicionar Redirect URLs**

1. **Na mesma página onde você está** (URL Configuration)

2. **Role até a seção "Redirect URLs"**

3. **Clique no botão "Add URL"** (botão verde)

4. **Adicione CADA uma dessas URLs (uma por vez):**

```
https://www.conectacup.com/
```

Clique em **"Add URL"** novamente e adicione:

```
https://www.conectacup.com/**
```

Clique em **"Add URL"** novamente e adicione:

```
https://conectacup.com/
```

Clique em **"Add URL"** novamente e adicione:

```
https://conectacup.com/**
```

Clique em **"Add URL"** novamente e adicione (para desenvolvimento local):

```
http://localhost:5173/
```

Clique em **"Add URL"** novamente e adicione:

```
http://localhost:5173/**
```

5. **Clique em SAVE** (botão verde no topo)

---

## 🔍 COMO DEVE FICAR

### **Site URL:**
```
https://www.conectacup.com/
```

### **Redirect URLs:** (6 URLs na lista)
```
✅ https://www.conectacup.com/
✅ https://www.conectacup.com/**
✅ https://conectacup.com/
✅ https://conectacup.com/**
✅ http://localhost:5173/
✅ http://localhost:5173/**
```

---

## 🧪 TESTE IMEDIATO

1. **Limpe TUDO do navegador:**
   - `Ctrl + Shift + Delete`
   - Selecione: "Cookies e outros dados do site" + "Imagens e arquivos em cache"
   - Período: "Todo o período"
   - Clique em "Limpar dados"

2. **OU use Janela Anônima:**
   - `Ctrl + Shift + N` (Chrome)
   - `Ctrl + Shift + P` (Edge)

3. **Teste o login:**
   ```
   1. Acesse: https://www.conectacup.com/
   2. Clique em "Fazer Login com Google"
   3. Escolha sua conta Google
   4. Deve logar e ficar na página principal ✅
   5. NÃO deve voltar para login ✅
   ```

---

## 🎯 POR QUE ISSO ACONTECE?

### **Como o Supabase decide onde redirecionar:**

```
┌─────────────────────────────────────┐
│ 1. Google autentica usuário         │
└─────────────┬───────────────────────┘
              │
              ▼
┌─────────────────────────────────────┐
│ 2. Google redireciona para Supabase │
│    callback URL                      │
└─────────────┬───────────────────────┘
              │
              ▼
┌─────────────────────────────────────┐
│ 3. Supabase processa autenticação   │
└─────────────┬───────────────────────┘
              │
              ▼
┌─────────────────────────────────────┐
│ 4. Supabase verifica se o redirectTo│
│    está na lista de "Redirect URLs" │
└─────────────┬───────────────────────┘
              │
      ┌───────┴────────┐
      │                │
      ▼                ▼
┌─────────┐      ┌──────────┐
│ ESTÁ NA │      │ NÃO ESTÁ │
│  LISTA  │      │ NA LISTA │
└────┬────┘      └─────┬────┘
     │                 │
     ▼                 ▼
┌─────────┐      ┌──────────┐
│ Permite │      │ REJEITA  │
│ redirect│      │ redirect │
│ ✅      │      │ ❌       │
└────┬────┘      └─────┬────┘
     │                 │
     │                 ▼
     │           ┌──────────┐
     │           │ Usuário  │
     │           │ volta p/ │
     │           │ /login   │
     │           │ LOOP ∞   │
     │           └──────────┘
     │
     ▼
┌─────────┐
│ Usuário │
│ logado  │
│ ✅      │
└─────────┘
```

### **O problema:**

Seu código diz: `redirectTo: 'https://www.conectacup.com/'`

Mas o Supabase verifica:
```
"https://www.conectacup.com/" está em "Redirect URLs"?
❌ NÃO → REJEITA → Volta para /login → LOOP
```

Após adicionar as URLs:
```
"https://www.conectacup.com/" está em "Redirect URLs"?
✅ SIM → PERMITE → Usuário logado ✅
```

---

## 📋 CHECKLIST

- [ ] Acessei Supabase → Authentication → URL Configuration
- [ ] Configurei Site URL = `https://www.conectacup.com/`
- [ ] Cliquei em "Add URL" na seção "Redirect URLs"
- [ ] Adicionei: `https://www.conectacup.com/`
- [ ] Adicionei: `https://www.conectacup.com/**`
- [ ] Adicionei: `https://conectacup.com/`
- [ ] Adicionei: `https://conectacup.com/**`
- [ ] Adicionei: `http://localhost:5173/`
- [ ] Adicionei: `http://localhost:5173/**`
- [ ] Cliquei em SAVE
- [ ] Aguardei 1-2 minutos
- [ ] Limpei cache do navegador
- [ ] Testei login com Google em janela anônima
- [ ] Login funcionou sem loop ✅

---

## 🔧 SCREENSHOT DE COMO DEVE FICAR

```
┌─────────────────────────────────────────────┐
│ URL Configuration                            │
├─────────────────────────────────────────────┤
│                                              │
│ Site URL                                     │
│ ┌─────────────────────────────────────────┐ │
│ │ https://www.conectacup.com/             │ │
│ └─────────────────────────────────────────┘ │
│                                              │
│ Redirect URLs                                │
│ ┌─────────────────────────────────────────┐ │
│ │ 1. https://www.conectacup.com/          │ │
│ │ 2. https://www.conectacup.com/**        │ │
│ │ 3. https://conectacup.com/              │ │
│ │ 4. https://conectacup.com/**            │ │
│ │ 5. http://localhost:5173/               │ │
│ │ 6. http://localhost:5173/**             │ │
│ └─────────────────────────────────────────┘ │
│                                              │
│           [Save changes] 💾                  │
└─────────────────────────────────────────────┘
```

---

## ⚠️ IMPORTANTE: WILDCARDS

### **O que é `/**`?**

```
https://www.conectacup.com/     → Permite apenas a raiz
https://www.conectacup.com/**   → Permite QUALQUER rota
                                   (/dashboard, /reports, etc)
```

**AMBOS são necessários!**

---

## 🆘 SE AINDA NÃO FUNCIONAR

### **1. Aguarde 5 minutos**
Supabase pode levar alguns minutos para propagar as configurações.

### **2. Verifique o Console do Navegador**
1. Abra DevTools: `F12`
2. Vá em "Console"
3. Faça login com Google
4. Veja se há erros relacionados a redirect

### **3. Verifique se salvou**
Volte no Supabase Dashboard e confirme que as 6 URLs estão lá.

### **4. Limpe sessões antigas**
```
1. Supabase Dashboard → Authentication → Users
2. Encontre seu usuário
3. Clique nos 3 pontinhos → "Delete user"
4. Tente fazer login novamente
```

---

## 💡 DICA EXTRA

Se você está testando em **localhost** durante desenvolvimento:

1. Use `http://localhost:5173/` (com as barras e wildcards)
2. NÃO use `http://127.0.0.1:5173/`
3. São considerados domínios diferentes!

---

**Status:** 🚨 URGENTE  
**Tempo:** 2 minutos  
**Dificuldade:** Fácil  

```
╔═══════════════════════════════════════════╗
║  🎯 AÇÃO NECESSÁRIA AGORA:                ║
║                                            ║
║  1. Clique em "Add URL" 6 vezes           ║
║  2. Adicione cada URL da lista            ║
║  3. Clique em SAVE                        ║
║  4. Aguarde 2 minutos                     ║
║  5. Limpe cache                           ║
║  6. Teste em janela anônima               ║
║                                            ║
║  ✅ Loop será resolvido!                  ║
╚═══════════════════════════════════════════╝
```
