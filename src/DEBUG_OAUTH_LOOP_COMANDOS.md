# 🔍 DEBUG OAUTH LOOP - COMANDOS

**Execute estes comandos no console do navegador (F12) para identificar o problema**

---

## 🧪 TESTE 1: Verificar Estado Inicial

**Antes de fazer login**, execute no console:

```javascript
// 1. Limpar TUDO
localStorage.clear();
sessionStorage.clear();
console.log('✅ Storage limpo');

// 2. Verificar URL
console.log('URL atual:', window.location.href);
console.log('Hash:', window.location.hash);
console.log('Pathname:', window.location.pathname);

// 3. Recarregar
window.location.reload();
```

---

## 🧪 TESTE 2: Monitorar OAuth Callback

**Execute ANTES de clicar em "Login com Google"**:

```javascript
// Monitor de Auth State Changes
let authChangeCount = 0;
const originalConsoleLog = console.log;

console.log = function(...args) {
  if (args[0]?.includes?.('Auth state changed')) {
    authChangeCount++;
    originalConsoleLog.call(console, `[${authChangeCount}x]`, ...args);
    
    if (authChangeCount > 3) {
      console.error('⚠️⚠️⚠️ LOOP DETECTADO! Auth state mudou', authChangeCount, 'vezes!');
      console.trace('Stack trace:');
    }
  } else {
    originalConsoleLog.apply(console, args);
  }
};

console.log('✅ Monitor de OAuth ativado - agora faça login');
```

**Agora clique em "Login com Google" e observe o console**

---

## 🧪 TESTE 3: Verificar Após Callback

**Quando voltar do Google**, execute imediatamente:

```javascript
// 1. Informações da URL
console.log('=== CALLBACK DEBUG ===');
console.log('URL completa:', window.location.href);
console.log('Hash:', window.location.hash);
console.log('Hash length:', window.location.hash.length);
console.log('Tem access_token?', window.location.hash.includes('access_token'));
console.log('Tem refresh_token?', window.location.hash.includes('refresh_token'));
console.log('Tem error?', window.location.hash.includes('error'));

// 2. LocalStorage
console.log('\n=== LOCAL STORAGE ===');
const authKey = Object.keys(localStorage).find(k => k.includes('auth'));
console.log('Auth key:', authKey);
if (authKey) {
  try {
    const authData = JSON.parse(localStorage.getItem(authKey));
    console.log('Auth data exists:', !!authData);
    console.log('Has session:', !!authData?.currentSession);
    console.log('User email:', authData?.currentSession?.user?.email);
    console.log('Has role:', !!authData?.currentSession?.user?.user_metadata?.role);
    console.log('Role value:', authData?.currentSession?.user?.user_metadata?.role);
  } catch (e) {
    console.error('Erro ao parsear auth data:', e);
  }
}

// 3. Estado da aplicação
console.log('\n=== APP STATE ===');
console.log('isAuthenticated:', localStorage.getItem('porsche-cup-user'));

// 4. Timing check
console.log('\n=== TIMING ===');
console.log('Timestamp:', new Date().toISOString());
```

---

## 🧪 TESTE 4: Verificar Loop Infinito

**Se suspeitar de loop**, execute:

```javascript
// Detector de reloads infinitos
let reloadCount = parseInt(sessionStorage.getItem('reload-count') || '0');
reloadCount++;
sessionStorage.setItem('reload-count', reloadCount.toString());

console.log('╔══════════════════════════════════════╗');
console.log('║  RELOAD COUNTER                      ║');
console.log('╠══════════════════════════════════════╣');
console.log('║  Reloads:', reloadCount.toString().padEnd(28), '║');
if (reloadCount > 3) {
  console.error('║  ⚠️ LOOP INFINITO DETECTADO!        ║');
  console.error('║  A página recarregou', reloadCount, 'vezes!      ║');
}
console.log('╚══════════════════════════════════════╝');

// Se detectou loop, pare tudo
if (reloadCount > 5) {
  console.error('🛑 PARANDO LOOP FORÇADAMENTE');
  sessionStorage.clear();
  localStorage.clear();
  alert('Loop infinito detectado! Storage limpo. Recarregando...');
  window.location.href = window.location.origin;
}
```

---

## 🧪 TESTE 5: Verificar Configuração Supabase

```javascript
// Executar após voltar do Google
async function debugSupabase() {
  console.log('=== SUPABASE DEBUG ===');
  
  // Importa createClient
  const { createClient } = await import('./utils/supabase/client.ts');
  const supabase = createClient();
  
  // 1. getSession
  console.log('\n1. getSession():');
  const { data: sessionData, error: sessionError } = await supabase.auth.getSession();
  console.log('  Session exists:', !!sessionData?.session);
  console.log('  Session error:', sessionError);
  if (sessionData?.session) {
    console.log('  User email:', sessionData.session.user.email);
    console.log('  User role:', sessionData.session.user.user_metadata?.role);
    console.log('  Access token (10 chars):', sessionData.session.access_token.substring(0, 10));
  }
  
  // 2. getUser
  console.log('\n2. getUser():');
  const { data: userData, error: userError } = await supabase.auth.getUser();
  console.log('  User exists:', !!userData?.user);
  console.log('  User error:', userError);
  if (userData?.user) {
    console.log('  User email:', userData.user.email);
    console.log('  User role:', userData.user.user_metadata?.role);
  }
  
  // 3. Configuração do cliente
  console.log('\n3. Client config:');
  console.log('  detectSessionInUrl:', true); // hardcoded no cliente
  console.log('  persistSession:', true);
  console.log('  autoRefreshToken:', true);
}

debugSupabase().catch(err => console.error('Erro no debug:', err));
```

---

## 🧪 TESTE 6: Verificar Network Requests

**No DevTools (F12)**:

1. Vá para aba **Network**
2. Filtre por `ensure-role`
3. Faça login com Google
4. Verifique:
   - Quantas vezes `ensure-role` é chamado?
   - Qual o status code? (deve ser 200)
   - Qual a resposta? (deve ter `user.role`)

**Se ensure-role for chamado múltiplas vezes = LOOP!**

---

## 🧪 TESTE 7: Simular OAuth Callback Manualmente

**Para testar sem fazer login real**:

```javascript
// Simula URL de callback OAuth
const fakeHash = '#access_token=fake-token-12345&expires_in=3600&refresh_token=fake-refresh&token_type=bearer';
window.location.hash = fakeHash;

console.log('✅ Hash fake criado:', window.location.hash);
console.log('Recarregando...');
setTimeout(() => window.location.reload(), 1000);
```

**Observe se:**
- Detecta como OAuth callback ✅
- Fica em loading ✅
- Não mostra tela de login ✅

---

## 🧪 TESTE 8: Verificar Múltiplos Listeners

```javascript
// Verifica se há múltiplos listeners de auth
let listenerCount = 0;

const originalOnAuthStateChange = window.supabase?.auth?.onAuthStateChange;

if (originalOnAuthStateChange) {
  window.supabase.auth.onAuthStateChange = function(...args) {
    listenerCount++;
    console.log('⚠️ onAuthStateChange chamado', listenerCount, 'vezes');
    if (listenerCount > 1) {
      console.error('❌ MÚLTIPLOS LISTENERS! Isso pode causar loop!');
      console.trace();
    }
    return originalOnAuthStateChange.apply(this, args);
  };
}
```

---

## 📊 RESULTADO ESPERADO

### **✅ Comportamento CORRETO:**

```
🏁 Conecta Cup - Sistema de Gestão de Pneus
🔐 OAuth callback detectado, aguardando processamento...
🔐 Auth state changed: SIGNED_IN Processing: false
✅ OAuth login bem-sucedido: seu-email@gmail.com
✅ Role verificada: { user: { role: 'operator' } }
🧹 Limpando hash OAuth da URL...
✅ Autenticação OAuth completa - dashboard pronto
```

### **❌ Comportamento COM LOOP:**

```
🔐 Auth state changed: SIGNED_IN Processing: false
[2x] 🔐 Auth state changed: SIGNED_IN Processing: false
[3x] 🔐 Auth state changed: SIGNED_IN Processing: false
⚠️⚠️⚠️ LOOP DETECTADO! Auth state mudou 3 vezes!
```

---

## 🎯 PRÓXIMOS PASSOS

**Depois de executar os testes acima, me envie**:

1. **Todos os logs do console** (copie tudo!)
2. **Resultado do TESTE 2** (contador de auth changes)
3. **Resultado do TESTE 3** (estado após callback)
4. **Screenshot da aba Network** mostrando requests `ensure-role`

**Com essas informações, conseguirei identificar EXATAMENTE onde está o problema!**

---

## ⚡ ATALHO RÁPIDO

**Execute tudo de uma vez**:

```javascript
// COMANDO COMPLETO DE DEBUG
(async function() {
  console.clear();
  console.log('╔════════════════════════════════════════╗');
  console.log('║  🔍 OAUTH DEBUG - CONECTA CUP          ║');
  console.log('╚════════════════════════════════════════╝\n');
  
  // 1. URL
  console.log('📍 URL INFO:');
  console.log('  Full:', window.location.href);
  console.log('  Hash:', window.location.hash || '(vazio)');
  console.log('  Has access_token:', window.location.hash.includes('access_token'));
  
  // 2. LocalStorage
  console.log('\n💾 LOCAL STORAGE:');
  const authKey = Object.keys(localStorage).find(k => k.includes('auth'));
  console.log('  Auth key:', authKey || '(não encontrado)');
  if (authKey) {
    try {
      const authData = JSON.parse(localStorage.getItem(authKey));
      console.log('  Has session:', !!authData?.currentSession);
      console.log('  User:', authData?.currentSession?.user?.email || '(sem user)');
      console.log('  Role:', authData?.currentSession?.user?.user_metadata?.role || '(sem role)');
    } catch (e) {
      console.log('  Error parsing:', e.message);
    }
  }
  
  // 3. App state
  console.log('\n🎯 APP STATE:');
  const userStr = localStorage.getItem('porsche-cup-user');
  if (userStr) {
    const user = JSON.parse(userStr);
    console.log('  Authenticated:', true);
    console.log('  Email:', user.email);
    console.log('  Role:', user.role);
  } else {
    console.log('  Authenticated:', false);
  }
  
  // 4. Reload counter
  console.log('\n🔄 RELOAD COUNTER:');
  let count = parseInt(sessionStorage.getItem('debug-reload') || '0');
  count++;
  sessionStorage.setItem('debug-reload', count.toString());
  console.log('  Page loads:', count);
  if (count > 3) {
    console.error('  ⚠️ POSSÍVEL LOOP DETECTADO!');
  }
  
  console.log('\n✅ Debug completo - copie e cole para análise');
})();
```

---

**COLE RESULTADO NO CHAT PARA EU ANALISAR** 🔍
