# 🔐 CORREÇÃO: Persistência de ProfileId no Supabase

## ✅ Problema Resolvido

O `profileId` não estava sendo salvo no Supabase Auth ao criar/atualizar usuários.

### Causa
- Os perfis de acesso eram salvos apenas no **localStorage** (frontend)
- O `profileId` do usuário não estava sendo persistido no **user_metadata** do Supabase Auth
- Após recarregar a página, o usuário perdia a associação com o perfil personalizado

## 🛠️ Correções Implementadas

### 1. **Backend - Rotas de Gerenciamento de Usuários** ✅

Criadas/atualizadas as seguintes rotas no `/supabase/functions/server/index.tsx`:

#### GET /users
```typescript
// Lista todos os usuários com profileId
const formattedUsers = users.map(user => ({
  id: user.id,
  email: user.email || '',
  username: user.user_metadata?.username || user.email?.split('@')[0] || '',
  name: user.user_metadata?.name || user.email?.split('@')[0] || '',
  role: user.user_metadata?.role || 'operator',
  profileId: user.user_metadata?.profileId || user.user_metadata?.role || 'operator', // ✅
  active: true,
  createdAt: user.created_at,
}));
```

#### POST /users
```typescript
// Cria usuário com profileId no user_metadata
const { data, error } = await supabaseAdmin.auth.admin.createUser({
  email: email.trim().toLowerCase(),
  password,
  email_confirm: true,
  user_metadata: {
    name: name.trim(),
    username: username || email.split('@')[0],
    role: role || 'operator',
    profileId: profileId || role || 'operator', // ✅ SALVA NO SUPABASE
  },
});
```

#### PUT /users/:id
```typescript
// Atualiza usuário com novo profileId
const { data, error } = await supabaseAdmin.auth.admin.updateUserById(
  userId,
  {
    user_metadata: {
      name: name?.trim(),
      username: username || email?.split('@')[0],
      role: role || 'operator',
      profileId: profileId || role || 'operator', // ✅ PERSISTE NO SUPABASE
    },
    email: email?.trim().toLowerCase(),
    password: password?.trim() ? password : undefined,
  }
);
```

#### DELETE /users/:id
```typescript
// Remove usuário
await supabaseAdmin.auth.admin.deleteUser(userId);
```

#### GET /users/me
```typescript
// Retorna dados do usuário autenticado incluindo profileId
return c.json({ 
  success: true, 
  data: {
    id: user.id,
    email: user.email,
    name: user.user_metadata?.name,
    role: user.user_metadata?.role,
    profileId: user.user_metadata?.profileId || user.user_metadata?.role,
    isAdmin: user.user_metadata?.role === 'admin',
  }
});
```

### 2. **Frontend - Login e Autenticação** ✅

Atualizado em `/components/Login.tsx` e `/App.tsx`:

```typescript
// Login: Salva profileId no localStorage
localStorage.setItem('porsche-cup-user', JSON.stringify({
  id: user.id,
  email: user.email,
  name,
  role,
  profileId: user.user_metadata?.profileId || role, // ✅
}));
```

### 3. **Sistema de Permissões** ✅

Atualizado em `/utils/permissions.ts`:

```typescript
/**
 * Inicializa perfis padrão no localStorage se não existirem
 */
function initializeDefaultProfiles(): void {
  try {
    const profilesStr = localStorage.getItem('porsche-cup-profiles');
    if (!profilesStr) {
      const defaultProfiles: AccessProfile[] = DEFAULT_PROFILES.map(p => ({
        ...p,
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString(),
      }));
      localStorage.setItem('porsche-cup-profiles', JSON.stringify(defaultProfiles));
      console.log('✅ Perfis padrão inicializados no localStorage');
    }
  } catch (error) {
    console.error('Erro ao inicializar perfis padrão:', error);
  }
}

/**
 * Obtém perfil do usuário atual
 * Agora busca profileId do usuário e encontra o perfil correspondente
 */
export function getCurrentUserProfile(): AccessProfile | null {
  try {
    // Garante que perfis padrão estejam inicializados
    initializeDefaultProfiles();
    
    const userStr = localStorage.getItem('porsche-cup-user');
    if (!userStr) return null;
    
    const user = JSON.parse(userStr);
    const profileId = user.profileId || user.role; // Compatibilidade com role antiga
    
    // Busca perfil no localStorage
    const profilesStr = localStorage.getItem('porsche-cup-profiles');
    if (profilesStr) {
      const profiles: AccessProfile[] = JSON.parse(profilesStr);
      const profile = profiles.find(p => p.id === profileId);
      if (profile) {
        console.log(`✅ Perfil encontrado: ${profile.name} (${profile.id})`);
        return profile;
      }
    }
    
    // Fallback para perfis padrão
    const defaultProfile = DEFAULT_PROFILES.find(p => p.id === profileId);
    if (defaultProfile) {
      console.log(`ℹ️ Usando perfil padrão: ${defaultProfile.name}`);
      return { ...defaultProfile, createdAt: new Date().toISOString(), updatedAt: new Date().toISOString() };
    }
    
    return null;
  } catch (error) {
    console.error('Erro ao obter perfil do usuário:', error);
    return null;
  }
}
```

### 4. **UserManagement - Logs de Debug** ✅

Adicionados logs para debugging:

```typescript
console.log('🔐 Atualizando usuário com profileId:', formData.profileId);
console.log('📤 Dados enviados:', updates);
```

## 🧪 Como Testar

### Teste 1: Criar Novo Usuário com Perfil Personalizado
1. Vá em **"Perfis de Acesso"**
2. Crie um novo perfil (ex: "Gerente de Estoque")
3. Configure páginas e permissões
4. Salve o perfil
5. Vá em **"Gerenciar Usuários"**
6. Crie um novo usuário
7. Selecione o perfil "Gerente de Estoque" no dropdown
8. Salve
9. **Recarregue a página** (F5)
10. ✅ O usuário deve aparecer com o perfil "Gerente de Estoque"

### Teste 2: Atualizar Perfil de Usuário Existente
1. Em **"Gerenciar Usuários"**, edite um usuário existente
2. Mude o perfil para um diferente (ex: de "Operador" para "Supervisor")
3. Salve
4. **Recarregue a página** (F5)
5. ✅ O usuário deve aparecer com o novo perfil "Supervisor"

### Teste 3: Verificar no Console
1. Abra o DevTools (F12)
2. Edite um usuário e mude o perfil
3. No console, você deve ver:
```
🔐 Atualizando usuário com profileId: supervisor
📤 Dados enviados: { email: "...", name: "...", role: "operator", profileId: "supervisor", ... }
✏️ Atualizando usuário abc-123: profileId=supervisor
📥 Dados recebidos: { ... }
🔐 ProfileId recebido: supervisor
✅ Usuário atualizado: user@example.com com profileId=supervisor
```

### Teste 4: Verificar Persistência no Supabase
1. Acesse: https://supabase.com/dashboard/project/nflgqugaabtxzifyhjor/auth/users
2. Clique em um usuário
3. Vá em "User Metadata"
4. ✅ Você deve ver:
```json
{
  "name": "Nome do Usuário",
  "role": "operator",
  "profileId": "supervisor"  // ✅ SALVO NO SUPABASE
}
```

## 📊 Fluxo de Dados Completo

```
1. CRIAÇÃO/EDIÇÃO NO FRONTEND (UserManagement.tsx)
   ↓
2. ENVIO VIA API (POST/PUT /users)
   ↓
3. SALVAMENTO NO SUPABASE AUTH (user_metadata.profileId)
   ↓
4. RETORNO AO FRONTEND
   ↓
5. SALVAMENTO NO LOCALSTORAGE (porsche-cup-user)
   ↓
6. BUSCA DO PERFIL (getCurrentUserProfile())
   ↓
7. VERIFICAÇÃO DE PERMISSÕES (usePermissions)
   ↓
8. PROTEÇÃO DE ROTAS (ProtectedRoute)
```

## 🔍 Debugging

Se algo não funcionar, verifique:

### 1. Console do Browser
```javascript
// Verificar usuário atual
JSON.parse(localStorage.getItem('porsche-cup-user'))

// Verificar perfis disponíveis
JSON.parse(localStorage.getItem('porsche-cup-profiles'))
```

### 2. Logs do Backend (Edge Function)
- Acesse: https://supabase.com/dashboard/project/nflgqugaabtxzifyhjor/functions/make-server-02726c7c/logs
- Procure por mensagens como:
  - `✏️ Atualizando usuário ...`
  - `🔐 ProfileId recebido: ...`
  - `✅ Usuário atualizado: ... com profileId=...`

### 3. Supabase Auth Dashboard
- Acesse: https://supabase.com/dashboard/project/nflgqugaabtxzifyhjor/auth/users
- Verifique se `user_metadata.profileId` está presente

## 🎯 Status

- ✅ Backend: Rotas de usuários criadas com suporte a profileId
- ✅ Frontend: Login atualizado para salvar profileId
- ✅ Permissões: Sistema reconhece profileId do usuário
- ✅ Persistência: ProfileId salvo no Supabase Auth (user_metadata)
- ✅ Compatibilidade: Fallback para role antiga mantido
- ✅ Logs: Debug completo adicionado

## 📝 Próximos Passos Sugeridos

1. ✅ **Sistema RBAC funcionando** (ATUAL)
2. 🔄 Adicionar migração automática de `role` → `profileId` para usuários existentes
3. 🔄 Criar endpoint para sincronização em massa
4. 🎯 Tour interativo (+2 pontos para atingir 96/100)
5. 🔔 Alertas inteligentes (+2 pontos para atingir 98/100)

## 🚀 Deploy

Todas as alterações estão prontas para produção:
- ✅ Backend atualizado
- ✅ Frontend atualizado
- ✅ Sem migrações de banco necessárias (usa user_metadata do Supabase Auth)
- ✅ Retrocompatível com sistema antigo
