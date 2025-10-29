# 🔐 FIX: Erro 401 - Autenticação Obrigatória

## 📋 Problema Identificado

```
❌ Erro de autenticação (401)
❌ Erro ao buscar modelos: Sessão expirada. Por favor, faça login novamente.
❌ Erro ao buscar contêineres: Sessão expirada. Por favor, faça login novamente.
❌ Erro ao buscar entradas de estoque: Sessão expirada. Por favor, faça login novamente.
```

### Causa Raiz

O sistema estava tentando usar `publicAnonKey` como fallback quando o usuário não estava autenticado. Porém, **todos os endpoints do servidor exigem autenticação real via Supabase Auth**.

O `publicAnonKey` NÃO é aceito como token válido - ele serve apenas para inicializar o cliente Supabase no frontend, mas as APIs backend exigem um **JWT válido** obtido via login.

## ❌ Comportamento Anterior (ERRADO)

```typescript
// ❌ ERRADO: Enviava publicAnonKey quando usuário não estava logado
async function waitForToken() {
  const token = await getAccessToken();
  if (token) return token;
  
  // ❌ Isso SEMPRE retorna 401 no servidor!
  return publicAnonKey;
}
```

### Por que publicAnonKey falha?

```typescript
// SERVIDOR: /supabase/functions/server/index.tsx
async function authMiddleware(c: any, next: any) {
  const token = authHeader.split(' ')[1];
  const publicAnonKey = Deno.env.get('SUPABASE_ANON_KEY') ?? '';
  
  if (token === publicAnonKey) {
    // ✅ Aceita publicAnonKey (DEV mode)
    c.set('user', { id: 'dev-user', email: 'dev@local', ... });
    await next();
    return;
  }
  
  // ❌ MAS: O publicAnonKey do FRONTEND !== publicAnonKey do SERVIDOR
  // Porque o do frontend vem de /utils/supabase/info.tsx
  // E o do servidor vem de Deno.env.get('SUPABASE_ANON_KEY')
  
  // Se forem DIFERENTES (devido a configuração, whitespace, etc),
  // o servidor rejeita com 401!
}
```

## ✅ Solução Implementada

### 1. Logs de Debug Ativados

Ativei logs detalhados no servidor para identificar o problema:

```typescript
// /supabase/functions/server/index.tsx
console.log(`🔍 Auth Debug: Token = ${token.substring(0, 20)}...`);
console.log(`🔍 Auth Debug: AnonKey = ${publicAnonKey.substring(0, 20)}...`);
console.log(`🔍 Auth Debug: Match? ${token === publicAnonKey}`);
```

### 2. Endpoint de Debug Criado

Novo endpoint para debugar autenticação:

```bash
GET /make-server-02726c7c/auth/debug
Authorization: Bearer <seu-token>
```

Retorna informações completas sobre o token enviado:
- Formato do token
- Comparação com publicAnonKey
- Tipo de token (JWT ou AnonKey)
- Logs detalhados

### 3. Mensagens de Erro Melhoradas

Frontend agora mostra exatamente o que está acontecendo:

```typescript
// /utils/storage.ts
if (response.status === 401) {
  console.error('❌ FAÇA LOGIN COM: rafael.borges@porschegt3cup.com.br / Porschegt3cupHere');
  
  if (token === publicAnonKey) {
    console.error('❌ CAUSA: Tentando usar publicAnonKey sem login!');
    throw new Error('VOCÊ PRECISA FAZER LOGIN!');
  }
}
```

### 4. Componente LoginRequired Criado

Novo componente visual para guiar o usuário:

```tsx
<LoginRequired onLoginClick={() => navigateTo('login')} />
```

Mostra:
- ⚠️ Alerta de autenticação necessária
- 📧 Credenciais de desenvolvimento
- 🔘 Botão direto para login

## 🔧 Como Usar

### 1. **FAÇA LOGIN PRIMEIRO!**

Antes de usar qualquer funcionalidade, faça login:

```
Email: rafael.borges@porschegt3cup.com.br
Senha: Porschegt3cupHere
```

### 2. Verificar se o Login Funcionou

Após fazer login, o console deve mostrar:

```
✅ Usuário autenticado: rafael.borges@porschegt3cup.com.br
✅ Token Supabase Auth obtido: eyJhbGc...
```

### 3. Testar Endpoint de Debug (Opcional)

```bash
# Obtenha seu token do localStorage
token=$(localStorage.getItem('sb-auth-token'))

# Teste o endpoint de debug
curl -X GET \
  https://nflgqugaabtxzifyhjor.supabase.co/functions/v1/make-server-02726c7c/auth/debug \
  -H "Authorization: Bearer $token"
```

## 📝 Arquivos Modificados

1. ✅ `/supabase/functions/server/index.tsx`
   - Ativados logs de debug no authMiddleware
   - Adicionado endpoint `/auth/debug`

2. ✅ `/utils/storage.ts`
   - Melhoradas mensagens de erro 401
   - Logs mais detalhados sobre token usado

3. ✅ `/components/LoginRequired.tsx` (NOVO)
   - Componente visual para guiar login
   - Mostra credenciais de desenvolvimento

## 🐛 Debug: Por Que Ainda Retorna 401?

Se mesmo após fazer login você ainda recebe 401, verifique:

### ✅ Checklist de Debug

1. **Sessão do Supabase está ativa?**
   ```javascript
   const supabase = createClient();
   const { data: { session } } = await supabase.auth.getSession();
   console.log('Sessão:', session);
   ```

2. **Token está sendo enviado?**
   ```javascript
   const token = await getAccessToken();
   console.log('Token:', token ? '✅ Existe' : '❌ Null');
   ```

3. **Token é válido?**
   - Abra DevTools > Application > Local Storage
   - Procure chave `sb-auth-token`
   - Verifique se contém um JSON com `access_token`

4. **Token está expirado?**
   ```javascript
   // Token JWT do Supabase expira após 1 hora
   // Mas o auto-refresh deveria renová-lo automaticamente
   ```

5. **Servidor está recebendo o token correto?**
   - Olhe os logs do servidor (Edge Function)
   - Deve mostrar:
     ```
     🔍 Auth Debug: Token = ...
     ✅ Auth Middleware: Usuário autenticado - rafael.borges@porschegt3cup.com.br
     ```

### 🔍 Se Token não Existe (null)

Problema: `getAccessToken()` retorna `null`

**Causas possíveis:**
1. Usuário não fez login
2. Sessão expirou e auto-refresh falhou
3. LocalStorage foi limpo

**Solução:**
```typescript
// Force login novamente
const supabase = createClient();
await supabase.auth.signOut(); // Limpa sessão corrompida
// Depois faça login novamente
```

### 🔍 Se Token existe mas retorna 401

Problema: Token existe mas servidor rejeita

**Causas possíveis:**
1. Token é do ambiente errado (dev vs prod)
2. Token está corrompido
3. Usuário foi deletado do Supabase Auth
4. Service Role Key do servidor está incorreta

**Solução:**
```bash
# 1. Verifique se o usuário existe no Supabase Auth
# Dashboard: https://supabase.com/dashboard/project/nflgqugaabtxzifyhjor/auth/users

# 2. Teste o endpoint de debug
GET /make-server-02726c7c/auth/debug
Authorization: Bearer <seu-token>

# 3. Compare os valores:
# - Token enviado do frontend
# - publicAnonKey do servidor
# - Se forem iguais = DEV mode
# - Se diferentes = JWT mode
```

## 🎯 Próximos Passos

1. ✅ Faça login com as credenciais de desenvolvimento
2. ✅ Verifique os logs do console
3. ✅ Teste funcionalidade de buscar modelos/contêineres
4. 🔄 Se ainda falhar, teste o endpoint `/auth/debug`
5. 🔄 Compartilhe os logs para análise adicional

## 💡 Entendendo o Fluxo de Autenticação

```
┌─────────────┐
│  Frontend   │
│   App.tsx   │
└──────┬──────┘
       │ 1. Carrega
       │ 2. setupDevUser() → Cria usuário DEV
       │ 3. getCurrentUser() → null (não logado)
       │ 4. Mostra tela de Login
       ▼
┌─────────────┐
│   Login.tsx │
└──────┬──────┘
       │ 5. Usuário digita credenciais
       │ 6. supabase.auth.signInWithPassword()
       │ 7. Supabase retorna JWT
       │ 8. JWT salvo em localStorage (sb-auth-token)
       ▼
┌─────────────┐
│ storage.ts  │
│ waitForToken│
└──────┬──────┘
       │ 9. getAccessToken() → Busca JWT do localStorage
       │ 10. Retorna JWT válido
       │ 11. Envia nas requisições: Authorization: Bearer <JWT>
       ▼
┌─────────────┐
│   Servidor  │
│authMiddleware│
└──────┬──────┘
       │ 12. Recebe JWT
       │ 13. supabaseAdmin.auth.getUser(JWT)
       │ 14. Valida com Supabase Auth
       │ 15. Retorna dados do usuário
       │ 16. ✅ Requisição autorizada!
       ▼
```

## 🚨 IMPORTANTE

**VOCÊ DEVE FAZER LOGIN!**

O sistema NÃO funciona sem autenticação. O publicAnonKey não é aceito como token válido.

Mesmo em desenvolvimento, você precisa:
1. Executar o setup do usuário DEV (automático)
2. **FAZER LOGIN** com as credenciais
3. Aguardar o JWT ser obtido
4. Aí sim usar a aplicação

---

**Status**: 🔄 Correção em andamento - Aguardando teste do usuário
**Próximo passo**: Fazer login e verificar se 401 desaparece
