# 🗺️ Diagrama Visual - Sistema de Perfis de Acesso

## 📍 ONDE ESTÁ O PERFIL DO RAFAEL?

```
┌──────────────────────────────────────────────────────────────┐
│                    SUPABASE DATABASE                         │
└──────────────────────────────────────────────────────────────┘
                            │
                ┌───────────┴──────────┐
                │                      │
                ▼                      ▼
    ┌─────────────────────┐  ┌─────────────────────┐
    │  Schema: public     │  │  Schema: auth       │
    │  (Você vê normal)   │  │  (Auth do Supabase) │
    └─────────────────────┘  └─────────────────────┘
                │                      │
                ▼                      ▼
    ┌─────────────────────┐  ┌─────────────────────┐
    │ access_profiles     │  │    auth.users       │
    │ (Perfis Disponíveis)│  │ (ONDE ESTÁ O PERFIL)│
    └─────────────────────┘  └─────────────────────┘
                │                      │
                ▼                      ▼
    ┌─────────────────────┐  ┌─────────────────────┐
    │  id   │   name      │  │ email │  metadata  │
    ├───────┼─────────────┤  ├───────┼────────────┤
    │ admin │Administrador│  │rafael@│{"role":    │
    │operator│ Operador   │  │email  │"operator"} │◄── AQUI!
    │supervisor│Supervisor│  │admin@ │{"role":    │
    │ viewer│Visualizador │  │email  │"admin"}    │
    └───────┴─────────────┘  └───────┴────────────┘
           ↑                          ↑
           │                          │
      CADASTRO DE                RELAÇÃO
       PERFIS                  USUÁRIO ↔ PERFIL
     (Referência)               (Vínculo Real)
```

---

## 🔄 FLUXO DE FUNCIONAMENTO

### 1. Login do Rafael

```
┌─────────────────┐
│ Rafael faz login│
│ rafael@email.com│
└────────┬────────┘
         │
         ▼
┌────────────────────────────────────────────┐
│ Supabase Auth verifica credenciais        │
│ SELECT * FROM auth.users                   │
│ WHERE email = 'rafael@email.com'          │
└────────┬───────────────────────────────────┘
         │
         ▼
┌────────────────────────────────────────────┐
│ Retorna dados do usuário:                  │
│ {                                          │
│   email: "rafael@email.com",              │
│   raw_user_meta_data: {                   │
│     name: "Rafael",                       │
│     role: "operator"  ◄── PERFIL AQUI!   │
│   }                                        │
│ }                                          │
└────────┬───────────────────────────────────┘
         │
         ▼
┌────────────────────────────────────────────┐
│ App.tsx recebe e armazena:                 │
│ - userRole = "operator"                    │
│ - profileId = "operator"                   │
└────────┬───────────────────────────────────┘
         │
         ▼
┌────────────────────────────────────────────┐
│ Sistema aplica RBAC                        │
│ - Mostra/esconde menus                     │
│ - Habilita/desabilita ações                │
│ - Valida permissões                        │
└────────────────────────────────────────────┘
```

---

## 📊 ESTRUTURA DETALHADA

### Tabela: `auth.users`

```sql
CREATE TABLE auth.users (
  id UUID PRIMARY KEY,
  email VARCHAR,
  encrypted_password VARCHAR,
  
  -- ⭐ AQUI FICA O PERFIL DO USUÁRIO
  raw_user_meta_data JSONB,
  
  created_at TIMESTAMP,
  updated_at TIMESTAMP,
  last_sign_in_at TIMESTAMP,
  ...
);
```

### Exemplo de `raw_user_meta_data`:

```json
{
  "name": "Rafael",
  "role": "operator",      ← PERFIL DE ACESSO
  "profileId": "operator", ← ID do perfil (mesmo que role)
  "full_name": "Rafael Silva"
}
```

---

## 🎯 DIFERENÇA ENTRE AS TABELAS

| Característica | `access_profiles` | `auth.users` |
|----------------|-------------------|--------------|
| **Schema** | `public` | `auth` |
| **Função** | Cadastro de perfis disponíveis | Armazena usuários reais |
| **Dados** | Nome dos perfis (Admin, Operator, etc) | Email, senha, metadata |
| **Perfil do Rafael** | ❌ Não está aqui | ✅ Está aqui (`raw_user_meta_data.role`) |
| **Editar via UI** | ✅ Table Editor | ✅ Authentication → Users |
| **Editar via SQL** | ✅ Sim | ✅ Sim |

---

## 💡 EXEMPLO PRÁTICO

### ANTES (Você pensou que era aqui):

```
┌───────────────────────────────────┐
│  access_profiles                  │
├──────────┬────────────────────────┤
│ id       │ name                   │
├──────────┼────────────────────────┤
│ operator │ Operador               │ ◄── ❌ Rafael NÃO está aqui!
└──────────┴────────────────────────┘
```

### AGORA (Onde realmente está):

```
┌─────────────────────────────────────────────────┐
│  auth.users                                     │
├──────────────┬──────────────────────────────────┤
│ email        │ raw_user_meta_data               │
├──────────────┼──────────────────────────────────┤
│rafael@email  │ {"name":"Rafael","role":"operator"}│
│              │                      ↑            │
│              │              PERFIL AQUI! ✅     │
└──────────────┴──────────────────────────────────┘
```

---

## 🔧 COMO ALTERAR O PERFIL DO RAFAEL

### Via SQL (Método Recomendado):

```sql
-- Alterar Rafael para ADMIN
UPDATE auth.users
SET raw_user_meta_data = jsonb_set(
  raw_user_meta_data,
  '{role}',
  '"admin"'
)
WHERE email = 'rafael@email.com';
```

### Via Supabase UI:

1. **Dashboard** → **Authentication** → **Users**
2. Clicar em **Rafael**
3. **User Metadata** → Editar JSON:
   ```json
   {
     "name": "Rafael",
     "role": "admin"  ← Mudar aqui
   }
   ```
4. Salvar

---

## 🔍 RELAÇÃO ENTRE AS TABELAS

```
access_profiles               auth.users
(Referência)                 (Vínculo Real)
─────────────                ─────────────

id: "admin"     ─┐           raw_user_meta_data: {"role": "admin"}
                 │                    ▲
                 │                    │
                 └──── REFERÊNCIA ────┘
                       (Não é FK, apenas validação no código)
```

**Importante:** Não há Foreign Key real entre as tabelas!  
O código valida se o `role` existe em `access_profiles`.

---

## 📋 PERMISSÕES POR PERFIL

```
┌──────────────────────────────────────────────────────────┐
│                    PERFIL: admin                         │
├──────────────────────────────────────────────────────────┤
│ ✅ Criar/Editar/Deletar usuários                        │
│ ✅ Gerenciar perfis de acesso                           │
│ ✅ Ver/Editar/Deletar todos os dados                    │
│ ✅ Acessar configurações                                │
└──────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────┐
│                   PERFIL: operator                       │
├──────────────────────────────────────────────────────────┤
│ ✅ Criar/Editar pneus                                   │
│ ✅ Criar/Editar contêineres                            │
│ ✅ Ver relatórios                                       │
│ ❌ Deletar dados                                        │
│ ❌ Gerenciar usuários                                   │
└──────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────┐
│                  PERFIL: supervisor                      │
├──────────────────────────────────────────────────────────┤
│ ✅ Ver todos os relatórios                              │
│ ✅ Aprovar/Rejeitar ações                               │
│ ❌ Criar/Editar dados                                   │
│ ❌ Deletar dados                                        │
└──────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────┐
│                    PERFIL: viewer                        │
├──────────────────────────────────────────────────────────┤
│ 👁️ Ver dados (somente leitura)                         │
│ ❌ Criar/Editar/Deletar                                 │
└──────────────────────────────────────────────────────────┘
```

---

## ✅ CHECKLIST DE VERIFICAÇÃO

- [x] Entendi que o perfil está em `auth.users`
- [x] Sei que fica na coluna `raw_user_meta_data`
- [x] Sei que o campo JSON é `role`
- [x] Sei como ver via SQL
- [x] Sei como ver via Supabase UI
- [x] Sei como alterar o perfil
- [ ] Executei o SQL `/VER_PERFIL_RAFAEL_AGORA.sql` ← FAZER AGORA!

---

## 🚀 PRÓXIMOS PASSOS

1. **Executar SQL:**
   - Abrir arquivo `/VER_PERFIL_RAFAEL_AGORA.sql`
   - Copiar e colar no Supabase SQL Editor
   - Ver onde está o perfil do Rafael

2. **Alterar perfil (se necessário):**
   - Usar SQL do arquivo
   - Ou editar via Supabase UI

3. **Testar no sistema:**
   - Fazer logout
   - Fazer login novamente como Rafael
   - Verificar permissões aplicadas

---

## 📚 ARQUIVOS RELACIONADOS

| Arquivo | Descrição |
|---------|-----------|
| `/ONDE_ESTA_PERFIL_USUARIO.md` | Guia completo e detalhado |
| `/VER_PERFIL_RAFAEL_AGORA.sql` | SQL para executar AGORA |
| `/DIAGRAMA_PERFIS_ACESSO.md` | Este arquivo (visual) |
| `/utils/permissions.ts` | Código das permissões RBAC |
| `/App.tsx` | Onde o perfil é carregado no login |

---

## 🎯 RESUMO ULTRA-RÁPIDO

**Pergunta:** Onde está o perfil do Rafael?

**Resposta:** 
```
Tabela: auth.users
Coluna: raw_user_meta_data
Campo: role
Valor: "operator"
```

**Ver agora:**
```sql
SELECT 
  email,
  raw_user_meta_data->>'role' as perfil
FROM auth.users
WHERE email = 'rafael@email.com';
```

✅ **PRONTO!**
