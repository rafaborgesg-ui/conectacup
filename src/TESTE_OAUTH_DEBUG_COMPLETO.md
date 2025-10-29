# 🔍 TESTE OAUTH - DEBUG COMPLETO

**Status:** ✅ Service Worker DESABILITADO (não vai mais atrapalhar)  
**Logs detalhados:** ✅ ATIVADOS  
**Objetivo:** Identificar EXATAMENTE onde está o loop  

---

## 🧹 PASSO 1: LIMPAR TUDO

**Execute no console (F12):**

```javascript
// LIMPA TUDO
localStorage.clear();
sessionStorage.clear();
console.log('✅ Storage limpo');

// Força reload
window.location.href = window.location.origin;
```

---

## 🧪 PASSO 2: ABRIR CONSOLE LIMPO

1. **Janela anônima:** `Ctrl + Shift + N`
2. **F12** para abrir DevTools
3. **Console** tab
4. **Acesse:** `https://www.conectacup.com/`

---

## 👀 PASSO 3: OBSERVAR LOGS INICIAIS

**Você DEVE ver:**

```
============================================================
🔍 [1x] useEffect EXECUTADO
============================================================

📍 URL Check:
  Full URL: https://www.conectacup.com/
  Hash: (vazio)
  Search: (vazio)
  É OAuth callback? false

ℹ️ NÃO é OAuth callback - verificando sessão normal...
```

**Se aparecer mais de 1x ANTES de fazer login = JÁ TEM LOOP!**

---

## 🔐 PASSO 4: FAZER LOGIN GOOGLE

1. Clique em **"Fazer Login com Google"**
2. Escolha sua conta Google
3. **OBSERVE O CONSOLE**

---

## ✅ PASSO 5: LOGS ESPERADOS (SEM LOOP)

### **Quando voltar do Google:**

```
============================================================
🔍 [2x] useEffect EXECUTADO
============================================================

📍 URL Check:
  Full URL: https://www.conectacup.com/#access_token=eyJ...
  Hash: #access_token=eyJhbGc...
  Search: (vazio)
  É OAuth callback? true

🔐 ✅ OAuth callback detectado, aguardando processamento...
   Hash preview: #access_token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
   ⏳ Loading continua ativo
   ⏳ onAuthStateChange vai processar

────────────────────────────────────────────────────────────
🔐 [1x] AUTH STATE CHANGED: SIGNED_IN
────────────────────────────────────────────────────────────
  Session exists: true
  User: seu-email@gmail.com
  Processing flag: false
  Timestamp: 2025-10-25T...

✅ OAuth login bem-sucedido: seu-email@gmail.com

✅ Role verificada: { user: { role: 'operator', ... } }

🧹 Limpando hash OAuth da URL...

✅ Autenticação OAuth completa - dashboard pronto
```

**RESULTADO:**
- ✅ useEffect executou 2x (inicial + callback)
- ✅ AUTH STATE mudou 1x
- ✅ Hash foi limpo
- ✅ Dashboard carregou

---

## ❌ PASSO 6: LOGS COM LOOP (O QUE NÃO DEVE ACONTECER)

### **Cenário 1: useEffect em loop**

```
============================================================
🔍 [1x] useEffect EXECUTADO
============================================================
... (logs normais)

============================================================
🔍 [2x] useEffect EXECUTADO
============================================================
... (OAuth callback detectado)

============================================================
🔍 [3x] useEffect EXECUTADO  ⚠️ PROBLEMA!
============================================================

============================================================
🔍 [4x] useEffect EXECUTADO  ⚠️ LOOP!
============================================================
```

**DIAGNÓSTICO:** App.tsx está re-montando/re-renderizando infinitamente

---

### **Cenário 2: onAuthStateChange em loop**

```
────────────────────────────────────────────────────────────
🔐 [1x] AUTH STATE CHANGED: SIGNED_IN
────────────────────────────────────────────────────────────

────────────────────────────────────────────────────────────
🔐 [2x] AUTH STATE CHANGED: SIGNED_IN
────────────────────────────────────────────────────────────

────────────────────────────────────────────────────────────
🔐 [3x] AUTH STATE CHANGED: SIGNED_IN
────────────────────────────────────────────────────────────

⚠️⚠️⚠️ LOOP DETECTADO! Auth mudou 4 vezes! ⚠️⚠️⚠️
```

**DIAGNÓSTICO:** onAuthStateChange disparando múltiplas vezes

---

### **Cenário 3: Hash não limpo**

```
... (OAuth processa)
✅ Autenticação OAuth completa

(depois de alguns segundos)

============================================================
🔍 [3x] useEffect EXECUTADO
============================================================

📍 URL Check:
  Hash: #access_token=...  ⚠️ AINDA TEM HASH!
  É OAuth callback? true   ⚠️ DETECTA NOVAMENTE!

🔐 ✅ OAuth callback detectado...  ⚠️ LOOP!
```

**DIAGNÓSTICO:** Hash não foi limpo pela função `window.history.replaceState`

---

## 📊 PASSO 7: ANÁLISE

**Cole NO CHAT o resultado destes comandos:**

### **Comando 1: Status Final**
```javascript
console.log('\n=== STATUS FINAL ===');
console.log('useEffect count:', sessionStorage.getItem('checkAuthCount'));
console.log('URL atual:', window.location.href);
console.log('Hash atual:', window.location.hash || '(vazio)');
console.log('isAuthenticated:', !!localStorage.getItem('porsche-cup-user'));
```

### **Comando 2: Histórico de Auth**
```javascript
console.log('\n=== RESUMO ===');
console.log('Total useEffect:', sessionStorage.getItem('checkAuthCount'), 'execuções');
console.log('URL tem hash?', window.location.hash.length > 0 ? 'SIM ⚠️' : 'NÃO ✅');
```

---

## 🎯 DIAGNÓSTICO RÁPIDO

| Sintoma | Diagnóstico | Solução |
|---------|-------------|---------|
| useEffect > 3x | App re-renderizando | Verificar deps do useEffect |
| AUTH STATE > 3x | Listener duplicado | Verificar subscription |
| Hash não limpo | replaceState falhou | Forçar limpeza diferente |
| Timeout 10s | OAuth não processou | Verificar ensure-role |

---

## 🚨 SE TIVER LOOP

**Execute este comando completo e COLE O RESULTADO NO CHAT:**

```javascript
(async function debugCompleto() {
  console.log('\n╔════════════════════════════════════════╗');
  console.log('║  🔍 DEBUG OAUTH COMPLETO               ║');
  console.log('╚════════════════════════════════════════╝\n');
  
  // 1. Contadores
  console.log('📊 CONTADORES:');
  console.log('  useEffect execuções:', sessionStorage.getItem('checkAuthCount') || '0');
  
  // 2. URL
  console.log('\n📍 URL:');
  console.log('  Full:', window.location.href);
  console.log('  Pathname:', window.location.pathname);
  console.log('  Hash length:', window.location.hash.length);
  console.log('  Hash:', window.location.hash ? 
    window.location.hash.substring(0, 80) + '...' : 
    '(vazio)');
  
  // 3. LocalStorage
  console.log('\n💾 STORAGE:');
  const authKeys = Object.keys(localStorage).filter(k => 
    k.includes('auth') || k.includes('supabase')
  );
  console.log('  Auth keys:', authKeys);
  
  const userStr = localStorage.getItem('porsche-cup-user');
  if (userStr) {
    const user = JSON.parse(userStr);
    console.log('  User email:', user.email);
    console.log('  User role:', user.role);
  } else {
    console.log('  User: (não autenticado)');
  }
  
  // 4. Network
  console.log('\n🌐 NETWORK:');
  console.log('  Verifique a aba Network no DevTools');
  console.log('  Procure por: ensure-role');
  console.log('  Quantas vezes foi chamado?');
  
  console.log('\n✅ COPIE TUDO ACIMA E COLE NO CHAT');
  console.log('═'.repeat(60) + '\n');
})();
```

---

## ⚡ TESTE ADICIONAL: LIMPAR HASH MANUALMENTE

**Se o hash não for limpo automaticamente, teste:**

```javascript
// Força limpeza do hash
if (window.location.hash.includes('access_token')) {
  console.log('🧹 Forçando limpeza manual do hash...');
  window.history.replaceState(null, '', window.location.pathname);
  console.log('✅ Hash:', window.location.hash || '(vazio agora)');
}
```

---

## 📋 CHECKLIST

Execute o teste e marque:

- [ ] Service Worker não dá mais erro
- [ ] Console mostra logs detalhados
- [ ] useEffect executou apenas 1-2x
- [ ] AUTH STATE mudou apenas 1x
- [ ] Hash foi limpo após OAuth
- [ ] Dashboard carregou
- [ ] NÃO tem loop

---

## 🎯 PRÓXIMOS PASSOS

### **SE FUNCIONOU:**
✅ Me avise: "OAuth funcionou perfeitamente!"

### **SE AINDA TEM LOOP:**
❌ Me envie:
1. **TODO o console log** (copie tudo desde o início)
2. **Resultado do comando debugCompleto()**
3. **Screenshot da aba Network** (filtro: ensure-role)

---

**FAÇA O TESTE AGORA!** 🚀

Com os logs detalhados, vou identificar EXATAMENTE onde está o problema.
