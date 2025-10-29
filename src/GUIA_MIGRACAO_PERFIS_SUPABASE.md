# 🔐 Guia de Migração: Perfis de Acesso para Supabase

## ✅ O QUE FOI IMPLEMENTADO

### Antes (Problema)
- ❌ Perfis salvos apenas no **localStorage** (navegador)
- ❌ Perfis diferentes em cada dispositivo
- ❌ Perde dados ao limpar cache
- ❌ Não sincroniza entre usuários
- ❌ Não funciona em produção

### Depois (Solução)
- ✅ Perfis salvos no **Supabase** (banco de dados)
- ✅ Sincroniza em todos os dispositivos
- ✅ Dados persistentes e seguros
- ✅ Funciona perfeitamente em produção
- ✅ Cache local para performance

## 📋 PASSO A PASSO PARA ATIVAÇÃO

### Passo 1: Executar Migration SQL no Supabase

1. **Acesse o SQL Editor do Supabase:**
   ```
   https://supabase.com/dashboard/project/nflgqugaabtxzifyhjor/sql/new
   ```

2. **Copie TODO o conteúdo do arquivo:**
   ```
   MIGRATION_ACCESS_PROFILES_TABLE.sql
   ```

3. **Cole no SQL Editor e clique em RUN**

4. **Verifique o resultado:**
   - ✅ Deve mostrar 4 perfis criados
   - ✅ admin, operator, supervisor, viewer

### Passo 2: Verificar a Tabela Criada

1. **Vá em Table Editor:**
   ```
   https://supabase.com/dashboard/project/nflgqugaabtxzifyhjor/editor
   ```

2. **Procure pela tabela:** `access_profiles`

3. **Deve ter 4 linhas (perfis padrão):**

| id | name | description | pages | features | is_system | is_default |
|----|------|-------------|-------|----------|-----------|------------|
| admin | Administrador | Acesso total... | [16 páginas] | [23 funcionalidades] | true | true |
| operator | Operador | Acesso básico... | [7 páginas] | [7 funcionalidades] | true | true |
| supervisor | Supervisor | Acesso completo... | [11 páginas] | [12 funcionalidades] | true | false |
| viewer | Visualizador | Somente leitura... | [3 páginas] | [3 funcionalidades] | true | false |

### Passo 3: Testar no Sistema

1. **Acesse a aplicação** e faça login como admin

2. **Vá em "Perfis de Acesso"**

3. **Clique no botão "Atualizar"** (ícone de refresh)

4. **Deve carregar os 4 perfis do Supabase**

5. **Teste criar um novo perfil:**
   - Nome: "Gerente de Estoque"
   - Descrição: "Acesso ao gerenciamento de estoque"
   - Selecione algumas páginas e funcionalidades
   - Clique em "Adicionar"

6. **Recarregue a página** (F5)
   - ✅ O novo perfil deve continuar lá (salvo no Supabase!)

7. **Abra em outro navegador/dispositivo**
   - ✅ O perfil deve aparecer lá também!

## 🔄 MIGRAÇÃO AUTOMÁTICA DE DADOS

Se você já tinha perfis personalizados no localStorage, eles ainda estão lá como cache. Para migrar para o Supabase:

### Opção 1: Manual (Recomendado)
1. Antes de executar a migration, anote seus perfis personalizados
2. Execute a migration SQL
3. Recrie os perfis manualmente na interface
4. Eles serão salvos no Supabase automaticamente

### Opção 2: Via Console (Avançado)
Execute no console do navegador (F12):
```javascript
// 1. Pegar perfis do localStorage
const localProfiles = JSON.parse(localStorage.getItem('porsche-cup-profiles') || '[]');
const customProfiles = localProfiles.filter(p => !p.isSystem);

console.log('Perfis personalizados:', customProfiles);

// 2. Copie manualmente para o Supabase via interface
// Não há script automático para evitar conflitos
```

## 🏗️ ARQUITETURA DA SOLUÇÃO

### Backend (Supabase)
```
Tabela: access_profiles
├── Campos:
│   ├── id (TEXT, PK) - Ex: "admin", "operator", "profile-123456"
│   ├── name (TEXT) - Ex: "Administrador"
│   ├── description (TEXT) - Descrição do perfil
│   ├── pages (JSONB) - Array de páginas: ["dashboard", "stock_entry", ...]
│   ├── features (JSONB) - Array de features: ["stock_create", "stock_edit", ...]
│   ├── is_default (BOOLEAN) - Perfil padrão para novos usuários
│   ├── is_system (BOOLEAN) - Protege perfis do sistema de exclusão
│   ├── created_at (TIMESTAMPTZ) - Data de criação
│   └── updated_at (TIMESTAMPTZ) - Data de atualização
│
├── Índices:
│   ├── idx_access_profiles_name
│   ├── idx_access_profiles_is_system
│   └── idx_access_profiles_is_default
│
├── RLS (Row Level Security):
│   ├── SELECT: Todos podem ler (autenticados)
│   ├── INSERT: Apenas admins
│   ├── UPDATE: Apenas admins
│   └── DELETE: Apenas admins + não-sistema
│
└── Trigger:
    └── update_access_profiles_updated_at() - Atualiza updated_at automaticamente
```

### API Routes (Edge Function)

```
GET /access-profiles
├── Auth: Requerida
├── Retorna: Lista de todos os perfis
└── Formato: { success: true, data: AccessProfile[] }

POST /access-profiles
├── Auth: Admin
├── Body: { id, name, description, pages, features, isDefault }
├── Retorna: Perfil criado
└── Formato: { success: true, data: AccessProfile }

PUT /access-profiles/:id
├── Auth: Admin
├── Body: { name, description, pages, features, isDefault }
├── Proteção: Não permite editar perfis is_system=true
├── Retorna: Perfil atualizado
└── Formato: { success: true, data: AccessProfile }

DELETE /access-profiles/:id
├── Auth: Admin
├── Proteção: Não permite deletar perfis is_system=true
├── TODO: Verificar se há usuários usando o perfil
├── Retorna: Confirmação
└── Formato: { success: true, message: "..." }
```

### Frontend (React)

```typescript
AccessProfileManagement Component
├── Carrega perfis do Supabase via API
├── Cache local no localStorage (performance)
├── Botão "Atualizar" para sincronizar
├── Loading states durante requisições
├── Fallback para localStorage se Supabase falhar
└── Mensagens de erro amigáveis

Fluxo de Dados:
1. Usuário abre "Perfis de Acesso"
2. Component chama loadProfiles()
3. Faz GET /access-profiles
4. Recebe perfis do Supabase
5. Salva no localStorage (cache)
6. Exibe na interface

Ao criar/editar:
1. Usuário preenche formulário
2. Valida dados
3. Faz POST/PUT /access-profiles
4. Supabase salva no banco
5. Recarrega lista (GET /access-profiles)
6. Atualiza cache localStorage
7. Exibe toast de sucesso
```

## 🧪 TESTES COMPLETOS

### Teste 1: Criar Perfil
```
1. Acesse "Perfis de Acesso"
2. Preencha formulário
3. Clique "Adicionar"
4. Aguarde toast de sucesso
5. Verifique que perfil apareceu na lista
6. Recarregue página (F5)
7. ✅ Perfil deve continuar lá
```

### Teste 2: Editar Perfil
```
1. Clique em "Editar" em um perfil não-sistema
2. Modifique dados
3. Clique "Atualizar"
4. Aguarde toast de sucesso
5. Recarregue página (F5)
6. ✅ Modificações devem estar salvas
```

### Teste 3: Deletar Perfil
```
1. Clique em "Excluir" em um perfil não-sistema
2. Confirme exclusão
3. Aguarde toast de sucesso
4. ✅ Perfil deve sumir da lista
5. Recarregue página (F5)
6. ✅ Perfil não deve retornar
```

### Teste 4: Proteção de Perfis Sistema
```
1. Tente editar perfil "Administrador"
2. ✅ Deve mostrar: "Perfis do sistema não podem ser editados"
3. Tente deletar perfil "Operador"
4. ✅ Deve mostrar: "Perfis do sistema não podem ser deletados"
```

### Teste 5: Sincronização Multi-Dispositivo
```
1. Crie um perfil no computador
2. Abra em outro dispositivo/navegador
3. Faça login com mesmo usuário
4. Acesse "Perfis de Acesso"
5. ✅ Perfil deve aparecer lá também
```

### Teste 6: Atribuir Perfil a Usuário
```
1. Vá em "Gerenciar Usuários"
2. Crie ou edite um usuário
3. No campo "Perfil de Acesso", selecione um perfil personalizado
4. Salve
5. Recarregue página
6. ✅ Usuário deve ter o perfil selecionado
7. Faça login com esse usuário
8. ✅ Permissões devem refletir o perfil
```

## 🔍 TROUBLESHOOTING

### Erro: "Tabela não configurada"
**Causa:** Migration SQL não foi executada
**Solução:**
1. Execute `MIGRATION_ACCESS_PROFILES_TABLE.sql` no Supabase SQL Editor
2. Clique no botão "Atualizar" em Perfis de Acesso

### Erro: "Sessão expirada"
**Causa:** Token JWT expirou
**Solução:**
1. Faça logout
2. Faça login novamente
3. Tente novamente

### Perfis não aparecem
**Causa:** Possível problema de conexão ou RLS
**Solução:**
1. Verifique se está logado
2. Verifique no Supabase Table Editor se os perfis existem
3. Verifique RLS policies (devem estar habilitadas)
4. Veja console do navegador para erros

### Não consigo editar perfil
**Causa:** Tentando editar perfil do sistema
**Solução:**
1. Clone o perfil (botão de cópia)
2. Edite a cópia
3. Perfis com `is_system=true` não podem ser editados

### Cache desatualizado
**Causa:** localStorage com dados antigos
**Solução:**
```javascript
// Execute no console (F12):
localStorage.removeItem('porsche-cup-profiles');
location.reload();
```

## 📊 ESTRUTURA DE DADOS

### AccessProfile Interface
```typescript
interface AccessProfile {
  id: string;                    // Ex: "admin", "profile-123"
  name: string;                  // Ex: "Administrador"
  description: string;           // Ex: "Acesso total ao sistema"
  pages: PageKey[];              // Ex: ["dashboard", "stock_entry"]
  features: FeatureKey[];        // Ex: ["stock_create", "stock_edit"]
  isDefault: boolean;            // true = perfil padrão para novos usuários
  isSystem: boolean;             // true = não pode ser editado/deletado
  createdAt: string;             // ISO 8601 timestamp
  updatedAt: string;             // ISO 8601 timestamp
}
```

### Exemplo de Perfil no Banco
```json
{
  "id": "supervisor",
  "name": "Supervisor",
  "description": "Acesso operacional completo + aprovações e descartes",
  "pages": [
    "dashboard",
    "stock_entry",
    "tire_model",
    "container",
    "reports",
    "discard_reports",
    "stock_adjustment",
    "tire_movement",
    "tire_status_change",
    "tire_discard",
    "tire_consumption"
  ],
  "features": [
    "stock_create",
    "stock_edit",
    "stock_export",
    "model_create",
    "model_edit",
    "container_create",
    "container_edit",
    "reports_view",
    "reports_export",
    "movement_create",
    "movement_approve",
    "discard_create",
    "discard_view"
  ],
  "is_default": false,
  "is_system": true,
  "created_at": "2025-01-26T10:00:00.000Z",
  "updated_at": "2025-01-26T10:00:00.000Z"
}
```

## ✅ CHECKLIST DE IMPLANTAÇÃO

- [ ] 1. Executar `MIGRATION_ACCESS_PROFILES_TABLE.sql` no Supabase
- [ ] 2. Verificar tabela `access_profiles` criada
- [ ] 3. Verificar 4 perfis padrão inseridos
- [ ] 4. Testar carregar perfis na interface
- [ ] 5. Testar criar novo perfil
- [ ] 6. Testar editar perfil (não-sistema)
- [ ] 7. Testar deletar perfil (não-sistema)
- [ ] 8. Testar proteção de perfis sistema
- [ ] 9. Testar atribuir perfil a usuário
- [ ] 10. Testar persistência após reload
- [ ] 11. Testar sincronização multi-dispositivo
- [ ] 12. Documentar para equipe

## 🎯 BENEFÍCIOS

✅ **Centralização:** Um único local de verdade (Supabase)
✅ **Sincronização:** Perfis iguais em todos dispositivos
✅ **Segurança:** RLS protege dados, apenas admins editam
✅ **Performance:** Cache local reduz requisições
✅ **Auditoria:** Timestamps de criação/atualização
✅ **Escalabilidade:** Pronto para produção
✅ **Backup:** Dados no banco, não dependem de localStorage

## 📝 PRÓXIMOS PASSOS SUGERIDOS

1. ✅ **Sistema RBAC funcionando** (ATUAL)
2. 🔄 Adicionar verificação de usuários antes de deletar perfil
3. 🔄 Criar dashboard de uso de perfis
4. 🔄 Exportar/importar perfis (JSON)
5. 🎯 Tour interativo (+2 pontos)
6. 🔔 Alertas inteligentes (+2 pontos)
