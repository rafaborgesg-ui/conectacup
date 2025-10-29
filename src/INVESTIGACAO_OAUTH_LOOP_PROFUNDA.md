# 🔍 INVESTIGAÇÃO PROFUNDA - OAUTH LOOP

**Status:** 🎯 **CAUSA RAIZ IDENTIFICADA**  
**Problema:** Race condition entre `checkAuth()` e `detectSessionInUrl`  
**Severidade:** 🔴 CRÍTICA  

---

## 🔬 ANÁLISE FORENSE DO CÓDIGO

### **1. FLUXO ATUAL (COM LOOP)**

```typescript
// App.tsx - useEffect
useEffect(() => {
  const checkAuth = async () => {
    const user = await getCurrentUser(); // ❌ PROBLEMA AQUI!
    
    if (user) {
      setIsAuthenticated(true);
    } else {
      setIsAuthenticated(false); // ❌ MUITO CEDO!
    }
  };
  
  checkAuth(); // ⚠️ Executa IMEDIATAMENTE
  
  // OAuth listener
  supabase.auth.onAuthStateChange(async (event, session) => {
    if (event === 'SIGNED_IN') {
      // Chama ensure-role...
      // Mas JÁ ESTÁ EM LOOP!
    }
  });
}, []);
```

### **2. O QUE ESTÁ ACONTECENDO:**

```
TIMELINE DO OAUTH CALLBACK:

T=0ms:   Usuário volta do Google com URL:
         https://conectacup.com/#access_token=xxx&refresh_token=yyy

T=1ms:   App.tsx monta
         └─> useEffect inicia

T=2ms:   checkAuth() executa
         └─> getCurrentUser() é chamado

T=3ms:   ❌ PROBLEMA: detectSessionInUrl ainda NÃO processou!
         └─> getSession() retorna null (sessão ainda não detectada)
         └─> user = null
         └─> setIsAuthenticated(false) ❌
         └─> isLoading = false

T=10ms:  Componente re-renderiza
         └─> !isAuthenticated = true
         └─> Mostra tela de LOGIN ❌

T=50ms:  detectSessionInUrl finalmente processa os tokens da URL
         └─> Sessão criada no localStorage
         └─> onAuthStateChange dispara: SIGNED_IN

T=60ms:  OAuth listener executa
         └─> Chama ensure-role
         └─> setIsAuthenticated(true)
         └─> MAS... usuário já viu tela de login!

T=70ms:  Re-renderiza mostrando app
         └─> Mas há artifacts/flickers
         └─> Ou pior: volta para login (loop!)

T=100ms: detectSessionInUrl pode rodar novamente (depende do timing)
         └─> LOOP INFINITO se houver race condition
```

---

## 🎯 CAUSA RAIZ

### **PROBLEMA 1: Race Condition**

```typescript
// getCurrentUser() usa getSession()
const { data: { session } } = await supabase.auth.getSession();

// Mas getSession() lê do localStorage
// E detectSessionInUrl AINDA NÃO SALVOU lá!
```

**Explicação:**
1. `detectSessionInUrl: true` processa tokens da URL de forma **assíncrona**
2. `checkAuth()` executa **imediatamente** e lê `localStorage`
3. **localStorage ainda está vazio!**
4. `checkAuth()` decide: "Não está autenticado" ❌
5. Mostra tela de login
6. `detectSessionInUrl` finalmente termina e salva no localStorage
7. Agora tem sessão, mas já mostrou login
8. **LOOP!**

---

### **PROBLEMA 2: Sem Proteção para OAuth Callback**

```typescript
// App.tsx não verifica se é um OAuth callback
if (!isAuthenticated) {
  return <Login />; // ❌ Mostra login mesmo durante callback!
}
```

**Deveria verificar:**
```typescript
// Detecta se URL tem tokens OAuth
const isOAuthCallback = window.location.hash.includes('access_token');

if (isOAuthCallback) {
  return <LoadingSpinner />; // Aguarda processamento
}

if (!isAuthenticated) {
  return <Login />;
}
```

---

### **PROBLEMA 3: detectSessionInUrl é Assíncrono mas Invisível**

```typescript
// client.ts
detectSessionInUrl: true, // ⚠️ Não retorna Promise!

// Não há como fazer:
await detectSessionInUrl();

// Então checkAuth() não pode esperar!
```

---

## 🔧 SOLUÇÕES POSSÍVEIS

### **SOLUÇÃO 1: Detectar OAuth Callback Antes de checkAuth** ⭐ RECOMENDADA

```typescript
useEffect(() => {
  const checkAuth = async () => {
    // 1. Verifica se é OAuth callback
    const isOAuthCallback = 
      window.location.hash.includes('access_token') ||
      window.location.hash.includes('refresh_token');
    
    if (isOAuthCallback) {
      console.log('🔐 OAuth callback detectado, aguardando...');
      // NÃO faz nada, deixa onAuthStateChange processar
      return;
    }
    
    // 2. Só verifica auth se NÃO for callback
    const user = await getCurrentUser();
    // ...
  };
  
  checkAuth();
}, []);
```

**Vantagens:**
- ✅ Simples
- ✅ Evita race condition
- ✅ Deixa onAuthStateChange processar callback

---

### **SOLUÇÃO 2: Adicionar Delay para detectSessionInUrl**

```typescript
useEffect(() => {
  const checkAuth = async () => {
    // Aguarda detectSessionInUrl processar
    await new Promise(resolve => setTimeout(resolve, 100));
    
    const user = await getCurrentUser();
    // ...
  };
  
  checkAuth();
}, []);
```

**Vantagens:**
- ✅ Simples
**Desvantagens:**
- ❌ Hacky
- ❌ Tempo arbitrário (100ms pode não ser suficiente)

---

### **SOLUÇÃO 3: Usar Apenas onAuthStateChange** ⭐⭐ MAIS ROBUSTA

```typescript
useEffect(() => {
  const supabase = createClient();
  let initialCheckDone = false;
  
  const { data: { subscription } } = supabase.auth.onAuthStateChange(
    async (event, session) => {
      console.log('Auth event:', event);
      
      if (event === 'INITIAL_SESSION') {
        // Primeira verificação - pode ser null
        if (session) {
          // Tem sessão salva
          await handleAuthentication(session);
        } else {
          // Sem sessão
          setIsAuthenticated(false);
        }
        setIsLoading(false);
        initialCheckDone = true;
      } else if (event === 'SIGNED_IN') {
        // OAuth callback ou login normal
        await handleAuthentication(session);
      } else if (event === 'SIGNED_OUT') {
        setIsAuthenticated(false);
      }
    }
  );
  
  // Fallback: se INITIAL_SESSION não disparar em 2s
  setTimeout(() => {
    if (!initialCheckDone) {
      setIsLoading(false);
    }
  }, 2000);
  
  return () => subscription.unsubscribe();
}, []);
```

**Vantagens:**
- ✅ Usa API oficial do Supabase
- ✅ INITIAL_SESSION é disparado após detectSessionInUrl
- ✅ Sem race condition
- ✅ Mais robusto

---

## 🎯 SOLUÇÃO FINAL RECOMENDADA

Vou implementar **SOLUÇÃO 1 + melhorias da SOLUÇÃO 3**:

```typescript
useEffect(() => {
  const checkAuth = async () => {
    try {
      // 1. PROTEÇÃO: Verifica se é OAuth callback
      const urlHash = window.location.hash;
      const urlSearch = window.location.search;
      const isOAuthCallback = 
        urlHash.includes('access_token') ||
        urlHash.includes('refresh_token') ||
        urlSearch.includes('code='); // PKCE flow
      
      if (isOAuthCallback) {
        console.log('🔐 OAuth callback detectado, aguardando processamento...');
        // Mostra loading, NÃO tenta verificar auth ainda
        // onAuthStateChange vai processar
        return;
      }
      
      // 2. Verifica autenticação normal
      await setupDevUser();
      const user = await getCurrentUser();
      
      if (user) {
        console.log('✅ Usuário autenticado:', user.email);
        setUserRole(user.role);
        setIsAuthenticated(true);
        // ...
      } else {
        setIsAuthenticated(false);
      }
    } catch (error) {
      console.warn('Erro na verificação de autenticação:', error);
      setIsAuthenticated(false);
    } finally {
      setIsLoading(false);
    }
  };
  
  checkAuth();
  
  // OAuth listener
  const supabase = createClient();
  const { data: { subscription } } = supabase.auth.onAuthStateChange(
    async (event, session) => {
      console.log('🔐 Auth state changed:', event);
      
      if (event === 'SIGNED_IN' && session) {
        console.log('✅ Login detectado:', session.user.email);
        
        // Garante role
        try {
          const response = await fetch(
            `https://${projectId}.supabase.co/functions/v1/make-server-02726c7c/auth/ensure-role`,
            {
              method: 'POST',
              headers: {
                'Authorization': `Bearer ${session.access_token}`,
              },
            }
          );
          
          if (response.ok) {
            const data = await response.json();
            setUserRole(data.user.role);
            setIsAuthenticated(true);
            localStorage.setItem('porsche-cup-user', JSON.stringify(data.user));
            
            // ✅ IMPORTANTE: Remove isLoading aqui também!
            setIsLoading(false);
          }
        } catch (error) {
          console.error('Erro ao garantir role:', error);
          // Fallback
          const user = await getCurrentUser();
          if (user) {
            setUserRole(user.role);
            setIsAuthenticated(true);
            setIsLoading(false);
          }
        }
      } else if (event === 'SIGNED_OUT') {
        setIsAuthenticated(false);
        setUserRole('');
      }
    }
  );
  
  return () => subscription.unsubscribe();
}, []);
```

---

## 📊 COMPARAÇÃO

### **ANTES (com loop):**

```
OAuth Callback → checkAuth() executa imediatamente
                 ↓
                 getCurrentUser() → null (tokens ainda não processados)
                 ↓
                 setIsAuthenticated(false)
                 ↓
                 Mostra LOGIN ❌
                 ↓
                 detectSessionInUrl processa (50ms depois)
                 ↓
                 onAuthStateChange: SIGNED_IN
                 ↓
                 setIsAuthenticated(true)
                 ↓
                 Tenta mostrar app mas há conflito
                 ↓
                 LOOP INFINITO ❌
```

### **DEPOIS (sem loop):**

```
OAuth Callback → checkAuth() detecta tokens na URL
                 ↓
                 "É OAuth callback, não vou verificar ainda"
                 ↓
                 Continua mostrando LOADING ✅
                 ↓
                 detectSessionInUrl processa tokens
                 ↓
                 onAuthStateChange: SIGNED_IN
                 ↓
                 ensure-role garante role
                 ↓
                 setIsAuthenticated(true)
                 ↓
                 setIsLoading(false)
                 ↓
                 Mostra APP ✅
                 ↓
                 SEM LOOP ✅
```

---

## 🧪 COMO TESTAR A CORREÇÃO

1. **Adicione logs:**
```typescript
console.log('🔍 URL hash:', window.location.hash);
console.log('🔍 URL search:', window.location.search);
console.log('🔍 isOAuthCallback:', isOAuthCallback);
```

2. **Faça login OAuth**

3. **Verifique console:**
```
✅ Deve ver: "OAuth callback detectado, aguardando processamento..."
✅ NÃO deve ver: "Usuário autenticado" antes do callback
✅ Deve ver: "Auth state changed: SIGNED_IN"
✅ Deve ver: "Role verificada"
```

4. **Comportamento esperado:**
- Tela de loading contínua durante callback
- SEM flash de tela de login
- Login direto para dashboard
- SEM loop

---

## 💡 LIÇÕES APRENDIDAS

### **1. detectSessionInUrl é Assíncrono**
- Não assume que sessão está disponível imediatamente
- Sempre verifica se é OAuth callback primeiro

### **2. onAuthStateChange é Mais Confiável**
- Use para detectar mudanças de auth
- Não dependa apenas de getCurrentUser() inicial

### **3. Race Conditions em OAuth**
- Sempre proteja contra race conditions em callbacks
- Verifique URL antes de decidir estado de auth

---

**Próximo:** Implementar a correção no código
