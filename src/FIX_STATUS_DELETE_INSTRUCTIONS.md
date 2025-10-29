# 🔧 CORREÇÃO - Exclusão de Status não Funciona

## ❌ Problema Relatado

Na página **"Cadastro de Status"** (StatusRegistration), o botão de **excluir status** não está funcionando.

## 🔍 Diagnóstico

O componente `StatusRegistration.tsx` usa o Supabase client diretamente para deletar:

```typescript
const { error } = await supabase
  .from('tire_status')
  .delete()
  .eq('id', deleteId);
```

### Possíveis Causas

1. **Política RLS (Row Level Security) bloqueando DELETE**
   - A tabela `tire_status` pode não ter uma política que permita DELETE para usuários autenticados

2. **Foreign Key Constraints**
   - Se a tabela `stock_entries` referencia `tire_status` com `ON DELETE RESTRICT`, você não pode deletar um status que está sendo usado

3. **Falta de autenticação**
   - O usuário pode não estar autenticado corretamente com Supabase Auth

4. **Permissões do role "authenticated"**
   - O role pode não ter permissão de DELETE na tabela

## ✅ Soluções Implementadas

### 1. Melhorias no Componente (StatusRegistration.tsx)

**Adicionado logging detalhado** para identificar o problema:

```typescript
// Agora loga:
- Status a ser deletado
- Código do erro
- Detalhes do erro
- Hint do PostgreSQL
```

**Mensagens de erro específicas**:

| Código de Erro | Mensagem |
|----------------|----------|
| `23503` (FK violation) | "Este status está sendo usado por pneus e não pode ser excluído. Mude o status dos pneus primeiro." |
| `42501` (Permission denied) | "Sem permissão para excluir. Verifique se você está autenticado como administrador." |
| Outros | Mensagem original do erro |

**Verificação de resultado**:
- Agora usa `.select()` para confirmar que o registro foi deletado
- Alerta se nenhum registro foi afetado

### 2. Script SQL de Correção (FIX_TIRE_STATUS_DELETE.sql)

Execute este arquivo no **SQL Editor do Supabase**:

```
https://supabase.com/dashboard/project/nflgqugaabtxzifyhjor/sql
```

O script faz:

1. ✅ **Verifica políticas RLS existentes**
2. ✅ **Verifica foreign keys** que referenciam `tire_status`
3. ✅ **Habilita RLS** na tabela
4. ✅ **Adiciona política DELETE** para usuários autenticados
5. ✅ **Adiciona políticas SELECT, INSERT, UPDATE** (se não existirem)
6. ✅ **Exibe relatório** de políticas criadas

## 🧪 Como Testar Após Correção

### Passo 1: Execute o Script SQL

1. Acesse o **SQL Editor** do Supabase
2. Cole todo o conteúdo de `FIX_TIRE_STATUS_DELETE.sql`
3. Clique em **Run** (ou pressione Ctrl/Cmd + Enter)
4. Verifique se não há erros
5. Veja o relatório final de políticas

### Passo 2: Teste no Frontend

1. **Faça logout e login novamente** (para atualizar token)
2. Acesse **Cadastro de Status**
3. Crie um **novo status de teste**:
   - Nome: "Teste Delete"
   - Cor: Qualquer cor
   - Ordem: 99
4. Clique em **Excluir** (ícone de lixeira)
5. Confirme a exclusão no dialog
6. **Verifique o console** (F12 → Console):
   - Deve mostrar: `✅ Status deletado com sucesso`
   - **NÃO** deve mostrar erros

### Passo 3: Teste com Status em Uso

1. Crie outro status de teste
2. **Registre um pneu** usando esse status (via TireStockEntry)
3. Tente excluir o status
4. Deve aparecer: **"Este status está sendo usado por pneus e não pode ser excluído"**

## 🔍 Debugging - Se Ainda Não Funcionar

### 1. Verifique Políticas RLS

Execute no SQL Editor:

```sql
SELECT 
  policyname,
  cmd,
  roles
FROM pg_policies
WHERE tablename = 'tire_status';
```

**Esperado:**
```
policyname                                    | cmd    | roles
--------------------------------------------- | ------ | --------------
Todos podem ler status                        | SELECT | {public}
Usuários autenticados podem criar status      | INSERT | {authenticated}
Usuários autenticados podem atualizar status  | UPDATE | {authenticated}
Usuários autenticados podem deletar status    | DELETE | {authenticated}
```

### 2. Verifique Foreign Keys

Execute no SQL Editor:

```sql
SELECT
  tc.table_name, 
  kcu.column_name,
  rc.delete_rule
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
  ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage AS ccu
  ON ccu.constraint_name = tc.constraint_name
JOIN information_schema.referential_constraints AS rc
  ON tc.constraint_name = rc.constraint_name
WHERE ccu.table_name = 'tire_status' 
  AND tc.constraint_type = 'FOREIGN KEY';
```

**Se retornar alguma FK com `delete_rule = 'RESTRICT'`:**
- Você **não pode** deletar status que estão sendo usados
- Solução: Mude o status dos pneus antes de deletar

### 3. Verifique Autenticação

Abra o console e execute:

```javascript
const { data: { user } } = await (await import('./utils/supabase/client')).createClient().auth.getUser();
console.log('Usuário autenticado:', user);
```

**Esperado:**
```javascript
Usuário autenticado: { id: "...", email: "...", ... }
```

**Se retornar `null`:**
- Você não está autenticado
- Faça logout e login novamente

### 4. Logs Detalhados

Quando tentar excluir, veja o console:

**Sucesso:**
```
🗑️ Deletando status: [ID]
📝 Status a deletar: { id: "...", name: "...", color: "..." }
✅ Status deletado com sucesso: [...]
```

**Erro de FK:**
```
❌ Erro ao deletar status: {...}
❌ Código do erro: 23503
❌ Detalhes do erro: Key (id)=(...) is still referenced from table "stock_entries"
```

**Erro de Permissão:**
```
❌ Erro ao deletar status: {...}
❌ Código do erro: 42501
❌ Detalhes do erro: permission denied for table tire_status
```

## 🆘 Solução de Emergência (Última Opção)

Se **nada funcionar**, você pode desabilitar RLS temporariamente:

```sql
-- ⚠️ ATENÇÃO: Isto remove a segurança da tabela!
-- Use APENAS para testes
ALTER TABLE tire_status DISABLE ROW LEVEL SECURITY;
```

**Depois de testar**, reative:

```sql
ALTER TABLE tire_status ENABLE ROW LEVEL SECURITY;
```

## 📋 Checklist de Verificação

Antes de reportar que não funciona, verifique:

- [ ] Script SQL executado sem erros
- [ ] Políticas RLS criadas (verificar com SELECT pg_policies)
- [ ] Usuário autenticado (verificar com auth.getUser())
- [ ] Status a deletar **não está sendo usado** por pneus
- [ ] Console mostra logs detalhados sem erro
- [ ] Logout e login realizados após executar SQL

## 🎯 Resultado Esperado

Após aplicar as correções:

1. ✅ **Exclusão funciona** para status personalizados
2. ✅ **Mensagem clara** quando status está em uso
3. ✅ **Mensagem clara** quando há erro de permissão
4. ✅ **Logs detalhados** no console para debugging
5. ✅ **Toast de sucesso** com nome do status excluído

## 📊 Status Padrão vs Personalizados

O sistema separa os status em dois grupos:

| Tipo | Descrição | Pode Deletar? |
|------|-----------|---------------|
| **Padrão** | Primeiros 5 status do sistema | ❌ Não (sem botão delete) |
| **Personalizados** | Status criados pelo usuário | ✅ Sim (se não estiver em uso) |

Os **status padrão** não têm botão de exclusão (linhas 522-531 do componente).

---

**Data da Correção**: 2025-10-20  
**Arquivos Modificados**: 
- `/components/StatusRegistration.tsx`
- `/FIX_TIRE_STATUS_DELETE.sql` (novo)

**Impacto**: Melhoria de UX e debugging para exclusão de status
