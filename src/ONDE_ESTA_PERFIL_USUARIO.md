# 📍 Onde está o Perfil de Acesso do Usuário?

## 🎯 RESPOSTA RÁPIDA

O perfil de acesso (role) do usuário **Rafael** está armazenado em:

**Tabela:** `auth.users` (tabela do Supabase Auth)  
**Coluna:** `raw_user_meta_data` → campo `role`

---

## 📊 ESTRUTURA DE PERFIS

### Tabela 1: `access_profiles` (Perfis Disponíveis)

**Localização:** `public.access_profiles`  
**Função:** Define quais perfis existem no sistema

| id | name |
|----|------|
| admin | Administrador |
| operator | Operador |
| supervisor | Supervisor |
| viewer | Visualizador |

✅ Você já está vendo esta tabela na screenshot!

---

### Tabela 2: `auth.users` (Usuários e seus Perfis)

**Localização:** `auth.users` (schema `auth`, não `public`)  
**Função:** Armazena os usuários e seus perfis de acesso

**Estrutura (simplificada):**

| id (UUID) | email | raw_user_meta_data | user_metadata |
|-----------|-------|-------------------|---------------|
| 123abc... | rafael@email.com | `{"name": "Rafael", "role": "operator"}` | (JSON) |
| 456def... | admin@email.com | `{"name": "Admin", "role": "admin"}` | (JSON) |

---

## 🔍 COMO VER O PERFIL DO RAFAEL NO SUPABASE

### OPÇÃO 1: SQL Query (Recomendado)

**No Supabase SQL Editor:**

```sql
-- Ver todos os usuários e seus perfis
SELECT 
  id,
  email,
  raw_user_meta_data->>'name' as nome,
  raw_user_meta_data->>'role' as perfil,
  created_at
FROM auth.users
ORDER BY created_at DESC;
```

**Resultado esperado:**
```
email: rafael@email.com
nome: Rafael
perfil: operator  ← AQUI ESTÁ O PERFIL!
```

---

### OPÇÃO 2: Supabase UI (Authentication)

1. Abrir **Supabase Dashboard**
2. Ir em **Authentication** → **Users**
3. Clicar no usuário **Rafael**
4. Ver seção **"User Metadata"**

Você verá:
```json
{
  "name": "Rafael",
  "role": "operator"
}
```

---

## 🔧 COMO ALTERAR O PERFIL DO RAFAEL

### OPÇÃO 1: SQL (Mais Rápido)

```sql
-- Mudar Rafael de "operator" para "admin"
UPDATE auth.users
SET raw_user_meta_data = jsonb_set(
  raw_user_meta_data,
  '{role}',
  '"admin"'
)
WHERE email = 'rafael@email.com';

-- Verificar alteração
SELECT 
  email,
  raw_user_meta_data->>'role' as perfil_novo
FROM auth.users
WHERE email = 'rafael@email.com';
```

---

### OPÇÃO 2: Via Servidor (API)

**Endpoint:** `POST /make-server-02726c7c/users`  
**Body:**
```json
{
  "email": "rafael@email.com",
  "name": "Rafael",
  "password": "senha123",
  "role": "admin"  ← Novo perfil
}
```

---

## 📋 PERFIS DISPONÍVEIS E SUAS PERMISSÕES

| Perfil | ID | Permissões |
|--------|-----|-----------|
| **Administrador** | `admin` | ✅ Tudo (CRUD completo) |
| **Operador** | `operator` | ✅ Criar/Editar/Ver pneus e containers |
| **Supervisor** | `supervisor` | ✅ Ver relatórios e aprovar |
| **Visualizador** | `viewer` | 👁️ Apenas visualizar |

---

## 🔄 FLUXO COMPLETO

```
1. Usuário faz login
   ↓
2. Supabase Auth retorna session
   ↓
3. session.user.user_metadata.role ← AQUI ESTÁ O PERFIL
   ↓
4. App.tsx armazena em localStorage
   ↓
5. Sistema aplica permissões RBAC
```

---

## 🛠️ VERIFICAR PERFIL DO RAFAEL AGORA

### SQL Completo (Copiar e Colar)

```sql
-- ═══════════════════════════════════════════════
-- VERIFICAR PERFIL DO USUÁRIO RAFAEL
-- ═══════════════════════════════════════════════

-- 1️⃣ Ver perfil atual
SELECT 
  '👤 USUÁRIO' as tipo,
  email,
  raw_user_meta_data->>'name' as nome,
  raw_user_meta_data->>'role' as perfil_atual,
  CASE 
    WHEN raw_user_meta_data->>'role' = 'admin' THEN '🔴 Administrador'
    WHEN raw_user_meta_data->>'role' = 'operator' THEN '🟢 Operador'
    WHEN raw_user_meta_data->>'role' = 'supervisor' THEN '🟡 Supervisor'
    WHEN raw_user_meta_data->>'role' = 'viewer' THEN '🔵 Visualizador'
    ELSE '⚪ Sem perfil definido'
  END as perfil_visual,
  created_at as cadastrado_em
FROM auth.users
WHERE email ILIKE '%rafael%'
ORDER BY created_at DESC;

-- ═══════════════════════════════════════════════

-- 2️⃣ Ver TODOS os usuários e perfis
SELECT 
  email,
  raw_user_meta_data->>'name' as nome,
  raw_user_meta_data->>'role' as perfil,
  created_at
FROM auth.users
ORDER BY created_at DESC
LIMIT 20;

-- ═══════════════════════════════════════════════

-- 3️⃣ Contar usuários por perfil
SELECT 
  raw_user_meta_data->>'role' as perfil,
  COUNT(*) as total_usuarios,
  CASE 
    WHEN raw_user_meta_data->>'role' = 'admin' THEN '🔴 Administrador'
    WHEN raw_user_meta_data->>'role' = 'operator' THEN '🟢 Operador'
    WHEN raw_user_meta_data->>'role' = 'supervisor' THEN '🟡 Supervisor'
    WHEN raw_user_meta_data->>'role' = 'viewer' THEN '🔵 Visualizador'
    ELSE '⚪ Outros'
  END as tipo
FROM auth.users
GROUP BY raw_user_meta_data->>'role'
ORDER BY COUNT(*) DESC;

-- ═══════════════════════════════════════════════
```

---

## ❓ PERGUNTAS FREQUENTES

### 1. Por que não está na tabela `access_profiles`?

**R:** A tabela `access_profiles` é apenas um **cadastro de perfis disponíveis** (admin, operator, etc).  
O **vínculo usuário ↔ perfil** fica em `auth.users.raw_user_meta_data.role`.

### 2. Posso criar uma tabela separada para usuários?

**R:** ❌ Não recomendado! O Supabase Auth já gerencia autenticação.  
Apenas use `user_metadata` para armazenar dados extras como `role`.

### 3. Como adicionar novos perfis?

1. Adicionar na tabela `access_profiles`:
   ```sql
   INSERT INTO access_profiles (id, name)
   VALUES ('gerente', 'Gerente');
   ```

2. Atualizar usuário:
   ```sql
   UPDATE auth.users
   SET raw_user_meta_data = jsonb_set(
     raw_user_meta_data,
     '{role}',
     '"gerente"'
   )
   WHERE email = 'joao@email.com';
   ```

3. Adicionar permissões em `utils/permissions.ts`

---

## 🎯 RESUMO VISUAL

```
┌─────────────────────────────────────────────────────┐
│  TABELA: auth.users                                 │
├─────────────────────────────────────────────────────┤
│  Coluna: raw_user_meta_data (JSONB)                │
├─────────────────────────────────────────────────────┤
│  {                                                  │
│    "name": "Rafael",      ← Nome do usuário        │
│    "role": "operator"     ← PERFIL DE ACESSO! ✅   │
│  }                                                  │
└─────────────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────────────┐
│  TABELA: access_profiles (referência)              │
├─────────────────────────────────────────────────────┤
│  id: "operator"                                     │
│  name: "Operador"                                   │
└─────────────────────────────────────────────────────┘
```

---

## ✅ PRÓXIMOS PASSOS

1. **Executar SQL** acima para ver perfil do Rafael
2. **Modificar perfil** se necessário (operator → admin)
3. **Recarregar aplicação** para aplicar mudanças

**Link direto para SQL Editor:**  
https://supabase.com/dashboard/project/nflgqugaabtxzifyhjor/sql

---

## 🔐 SEGURANÇA

⚠️ **IMPORTANTE:** Apenas administradores devem ter acesso à tabela `auth.users`!

O sistema **NÃO** expõe essa tabela para usuários normais.  
Apenas o servidor (com `SUPABASE_SERVICE_ROLE_KEY`) pode modificar perfis.
