# ⚡ FIX LOOP - 2 MINUTOS

## ❌ PROBLEMA
Loop infinito após login Google

## ✅ CAUSA
Redirect URLs vazias no Supabase

## 🎯 SOLUÇÃO

### **1. No Supabase Dashboard**
Você está na página certa!

### **2. Seção "Redirect URLs"**
Clique em **"Add URL"** (botão verde)

### **3. Adicione estas 6 URLs:**

```
https://www.conectacup.com/
https://www.conectacup.com/**
https://conectacup.com/
https://conectacup.com/**
http://localhost:5173/
http://localhost:5173/**
```

(Clique "Add URL" antes de cada uma)

### **4. Clique em SAVE**

### **5. Teste**
- Limpe cache: `Ctrl + Shift + Delete`
- Janela anônima: `Ctrl + Shift + N`
- Login Google → Deve funcionar ✅

---

## 📋 DEVE FICAR ASSIM

```
Site URL:
https://www.conectacup.com/

Redirect URLs:
✅ https://www.conectacup.com/
✅ https://www.conectacup.com/**
✅ https://conectacup.com/
✅ https://conectacup.com/**
✅ http://localhost:5173/
✅ http://localhost:5173/**
```

---

## 🎯 POR QUE?

Supabase PRECISA que a URL de redirect esteja na lista permitida.

Você configurou apenas o "Site URL", mas faltou adicionar nas "Redirect URLs".

**Ambos são necessários!**

---

**Guia completo:** `/FIX_OAUTH_LOOP_URGENTE.md`

```
╔════════════════════════════════╗
║  AÇÃO AGORA:                   ║
║  1. Add URL (6x)               ║
║  2. SAVE                       ║
║  3. Limpe cache                ║
║  4. Teste                      ║
║  ✅ RESOLVIDO                  ║
╚════════════════════════════════╝
```
