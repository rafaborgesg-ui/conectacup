# 🔧 FIX: Erros 401 - Autenticação

## 📋 Problema Identificado

Todos os erros de autenticação (401) e "Sessão expirada" estão ocorrendo porque:

1. ❌ A credencial DEV (`rafael.borges@porschegt3cup.com.br`) não autenticava via Supabase Auth
2. ❌ O sistema salvava usuário no localStorage mas **não criava sessão Supabase**
3. ❌ Todas as requisições à API falhavam porque `getAccessToken()` retornava `null`
4. ❌ O sistema usava `publicAnonKey` como fallback, que é aceito pelo servidor
5. ⚠️ **MAS**: O servidor compara `token === publicAnonKey` e se não bater, retorna 401

## ✅ Solução Implementada

### 1. Removida Credencial DEV Hardcoded
**Antes** (`Login.tsx`):
```typescript
if (email === 'rafael.borges@porschegt3cup.com.br' && password === 'Porschegt3cupHere') {
  localStorage.setItem('porsche-cup-user', JSON.stringify(devUser));
  onLogin('admin'); // SEM autenticar no Supabase!
  return;
}
```

**Depois**:
```typescript
// Credencial DEV agora usa Supabase Auth normal
// Usuário deve estar cadastrado no Supabase
```

### 2. Melhorado `waitForToken()`
**Antes** (`storage.ts`):
```typescript
// Verificava usuário DEV no localStorage primeiro
if (userData.id === 'dev-admin-local') {
  return publicAnonKey;
}
```

**Depois**:
```typescript
// SEMPRE tenta obter token Supabase primeiro
const token = await getAccessToken();
if (token) return token;

// Fallback para publicAnonKey apenas se não houver sessão
return publicAnonKey;
```

### 3. Debug Logs Adicionados

**Frontend** (`storage.ts`):
```typescript
console.log(`✅ Token Supabase Auth obtido: ${token.substring(0, 20)}...`);
// OU
console.log(`⚠️ Usando publicAnonKey (sem sessão): ${publicAnonKey.substring(0, 20)}...`);
```

**Backend** (`index.tsx`):
```typescript
console.log(`🔍 Auth Debug: Token recebido = ${token.substring(0, 20)}...`);
console.log(`🔍 Auth Debug: AnonKey esperado = ${publicAnonKey.substring(0, 20)}...`);
console.log(`🔍 Auth Debug: Token match? ${token === publicAnonKey}`);
```

## 🚀 Como Resolver AGORA

### Opção 1: Criar Usuário de Desenvolvimento (RECOMENDADO)

Execute no Supabase SQL Editor:

```sql
-- Criar usuário DEV admin via SQL
-- ATENÇÃO: Isso só funciona se você tiver acesso ao painel do Supabase

-- Alternativamente, use a tela de CADASTRO da aplicação
```

### Opção 2: Usar Cadastro da Aplicação

1. Na tela de login, clique em **"Criar conta"**
2. Preencha:
   - **Email**: `rafael.borges@porschegt3cup.com.br`
   - **Senha**: `Porschegt3cupHere`
   - **Nome**: `Rafael Borges`
   - **Role**: Será criado como `operator`
3. Após cadastro, faça login normalmente
4. **Para tornar ADMIN**, execute SQL no Supabase:

```sql
-- Atualizar role para admin
UPDATE auth.users
SET raw_user_meta_data = jsonb_set(
  COALESCE(raw_user_meta_data, '{}'::jsonb),
  '{role}',
  '"admin"'
)
WHERE email = 'rafael.borges@porschegt3cup.com.br';
```

### Opção 3: Criar Usuário via API (Edge Function)

```bash
curl -X POST \
  "https://nflgqugaabtxzifyhjor.supabase.co/functions/v1/make-server-02726c7c/auth/signup" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5mbGdxdWdhYWJ0eHppZnloam9yIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjAyNjU4MDQsImV4cCI6MjA3NTg0MTgwNH0.V6Is77Z0AfcY1K3H0b2yr5HDCGKX8OAHdx6bUnZYzOA" \
  -d '{
    "email": "rafael.borges@porschegt3cup.com.br",
    "password": "Porschegt3cupHere",
    "name": "Rafael Borges",
    "role": "admin"
  }'
```

## 🧪 Verificar Correção

Após criar o usuário e fazer login, você deve ver nos logs do console:

### Frontend (Console do Navegador):
```
✅ Token Supabase Auth obtido: eyJhbGciOiJIUzI1NiIs...
```

### Backend (Logs do Edge Function):
```
✅ Auth Middleware: Usuário autenticado - rafael.borges@porschegt3cup.com.br (admin)
```

### SEM Erros:
```
❌ Erro de autenticação (401)  ← NÃO DEVE APARECER
❌ Sessão expirada            ← NÃO DEVE APARECER
```

## 📌 Arquivos Modificados

1. ✅ `/components/Login.tsx` - Removida credencial DEV hardcoded
2. ✅ `/utils/storage.ts` - Melhorado `waitForToken()` com logs
3. ✅ `/supabase/functions/server/index.tsx` - Adicionados logs de debug

## ⚠️ IMPORTANTE

- **NÃO** use credenciais hardcoded em produção
- **SEMPRE** autentique via Supabase Auth para garantir tokens válidos
- O `publicAnonKey` deve ser usado **apenas** quando não há sessão (modo offline)
- Para desenvolvimento, crie um usuário real no Supabase

## 🎯 Próximos Passos

1. ✅ Criar usuário de desenvolvimento
2. ✅ Fazer login com credenciais reais
3. ✅ Verificar que não há mais erros 401
4. ✅ Remover logs de debug após confirmar funcionamento
5. 🚀 Continuar desenvolvimento normal

---

**Status**: ✅ Correção implementada - Aguardando criação de usuário no Supabase
