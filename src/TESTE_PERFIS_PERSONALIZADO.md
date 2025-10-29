# 🧪 TESTE - Perfil Personalizado "teste"

## 🔍 DIAGNÓSTICO DO PROBLEMA

O usuário **rafael.borges@porschegt3cup.com.br** tem o perfil **"teste"** atribuído, mas o sistema não reconhece as permissões.

## 🛠️ CORREÇÕES IMPLEMENTADAS

### 1. **Hook usePermissions Atualizado**
   - ✅ Agora carrega perfis do **Supabase** (não apenas localStorage)
   - ✅ Usa `getCurrentUserProfileAsync()` para buscar do banco
   - ✅ Tem loading state enquanto carrega
   - ✅ Fallback para cache local se Supabase falhar

### 2. **ProtectedRoute Atualizado**
   - ✅ Mostra "Verificando permissões..." enquanto carrega
   - ✅ Aguarda perfil carregar antes de bloquear acesso

### 3. **Sidebar Atualizado**
   - ✅ Logs de debug para verificar perfil carregado

## 📋 PASSO A PASSO PARA TESTAR

### Passo 1: Verificar Dados no Supabase

1. **Abra o Table Editor:**
   ```
   https://supabase.com/dashboard/project/nflgqugaabtxzifyhjor/editor
   ```

2. **Verificar tabela `access_profiles`:**
   - Deve ter o perfil **"teste"** com:
     - `id = "teste"`
     - `pages` com as 14 páginas selecionadas
     - `features` com as 27 funcionalidades selecionadas

3. **Verificar tabela `auth.users`:**
   - Procure usuário: `rafael.borges@porschegt3cup.com.br`
   - Verifique campo `raw_user_meta_data`:
     ```json
     {
       "profileId": "teste",
       "name": "Rafael Borges",
       "email": "rafael.borges@porschegt3cup.com.br"
     }
     ```
   - ⚠️ **Se `profileId` não estiver lá, esse é o problema!**

### Passo 2: Corrigir profileId no Supabase Auth (SE NECESSÁRIO)

Se o `profileId` não estiver no `user_metadata`:

1. **Vá em Gerenciar Usuários** (como admin)
2. **Edite o usuário rafael.borges@porschegt3cup.com.br**
3. **Selecione o perfil "teste"** novamente
4. **Clique em "Salvar"**
5. **Verifique no Table Editor se salvou**

### Passo 3: Limpar Cache e Testar

1. **Faça logout**
2. **Limpe o cache** (Execute no console F12):
   ```javascript
   localStorage.clear();
   sessionStorage.clear();
   location.reload();
   ```
3. **Faça login novamente** com:
   - Email: rafael.borges@porschegt3cup.com.br
   - Senha: teste

### Passo 4: Verificar Logs no Console

1. **Abra Console do navegador** (F12)
2. **Procure por logs:**
   ```
   ✅ usePermissions - Perfil carregado: teste
   📋 Páginas permitidas: [array com 14 páginas]
   🔐 Sidebar - Perfil carregado: teste
   ```

3. **Se aparecer:**
   ```
   ⚠️ Perfil não encontrado para profileId/role: teste
   ```
   → Significa que o perfil "teste" não está sendo encontrado!

### Passo 5: Debug Completo

Execute no console do navegador (F12) enquanto logado:

```javascript
// 1. Ver usuário atual
const user = JSON.parse(localStorage.getItem('porsche-cup-user'));
console.log('👤 Usuário:', user);
console.log('🆔 ProfileId:', user.profileId);

// 2. Ver perfis no cache
const profiles = JSON.parse(localStorage.getItem('porsche-cup-profiles'));
console.log('📋 Perfis no cache:', profiles);

// 3. Verificar se perfil "teste" existe
const testProfile = profiles?.find(p => p.id === 'teste');
console.log('🧪 Perfil "teste":', testProfile);

// 4. Se não existe, forçar reload do Supabase
if (!testProfile) {
  console.log('❌ Perfil "teste" não encontrado no cache!');
  console.log('🔄 Vá em "Perfis de Acesso" e clique em "Atualizar"');
}
```

## 🔧 SOLUÇÕES PARA PROBLEMAS COMUNS

### Problema 1: Perfil "teste" não está no Supabase

**Solução:**
1. Vá em "Perfis de Acesso" (como admin)
2. Clique em "Atualizar" (botão refresh)
3. Se o perfil "teste" não aparecer:
   - Recrie o perfil manualmente
   - Use mesmo ID: "teste"

### Problema 2: ProfileId não está no user_metadata

**Solução:**
```javascript
// Execute no console como admin:
async function fixUserProfile() {
  const token = await (await fetch('https://nflgqugaabtxzifyhjor.supabase.co/auth/v1/user', {
    headers: { 'Authorization': `Bearer ${localStorage.getItem('supabase.auth.token')}` }
  })).json();
  
  console.log('Token:', token);
  
  // Agora edite o usuário via interface de Gerenciar Usuários
}
```

**OU simplesmente:**
1. Vá em Gerenciar Usuários
2. Edite rafael.borges@porschegt3cup.com.br
3. Selecione perfil "teste"
4. Salve novamente

### Problema 3: Cache desatualizado

**Solução:**
```javascript
// Limpa tudo e força reload
localStorage.clear();
sessionStorage.clear();
location.href = '/';
```

### Problema 4: Perfil existe mas não carrega

**Solução:**
1. Vá em "Perfis de Acesso"
2. Clique no botão "Atualizar"
3. Aguarde carregar do Supabase
4. Faça logout e login novamente

## ✅ CHECKLIST DE VERIFICAÇÃO

Execute na ordem:

- [ ] 1. Perfil "teste" existe na tabela `access_profiles`?
- [ ] 2. Perfil tem 14 páginas e 27 funcionalidades?
- [ ] 3. Usuário tem `profileId: "teste"` no `user_metadata`?
- [ ] 4. Cache local tem o perfil "teste"? (localStorage)
- [ ] 5. Console mostra "Perfil carregado: teste"?
- [ ] 6. Sidebar mostra "Perfil carregado: teste"?
- [ ] 7. Menus correspondentes aparecem?

## 🎯 TESTE FINAL

1. **Faça login** com rafael.borges@porschegt3cup.com.br
2. **Deve aparecer** "Verificando permissões..." (breve)
3. **Deve carregar** apenas as páginas permitidas no perfil "teste"
4. **Console deve mostrar:**
   ```
   ✅ usePermissions - Perfil carregado: teste
   📋 Páginas permitidas: [suas 14 páginas]
   🔐 Sidebar - Perfil carregado: teste
   ```

## 🆘 SE NADA FUNCIONAR

Execute este SQL no Supabase para verificar tudo:

```sql
-- 1. Verificar perfil "teste"
SELECT id, name, pages, features 
FROM access_profiles 
WHERE id = 'teste';

-- 2. Verificar usuário rafael.borges
SELECT id, email, raw_user_meta_data 
FROM auth.users 
WHERE email = 'rafael.borges@porschegt3cup.com.br';

-- 3. Se user_metadata não tem profileId, atualizar:
UPDATE auth.users
SET raw_user_meta_data = raw_user_meta_data || '{"profileId": "teste"}'::jsonb
WHERE email = 'rafael.borges@porschegt3cup.com.br';
```

## 📞 DEBUG AVANÇADO

Se ainda não funcionar, adicione logs extras:

```javascript
// Adicione no console:
window.addEventListener('storage', (e) => {
  console.log('💾 Storage changed:', e.key, e.newValue);
});

// Monitora chamadas à API
const originalFetch = window.fetch;
window.fetch = async (...args) => {
  console.log('🌐 Fetch:', args[0]);
  const response = await originalFetch(...args);
  return response;
};
```

## 🎯 RESULTADO ESPERADO

Após correções:
- ✅ Login com rafael.borges mostra menus personalizados
- ✅ Console mostra perfil "teste" carregado
- ✅ Recarregar página mantém permissões
- ✅ Outros dispositivos também funcionam
