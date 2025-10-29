# 🔧 TROUBLESHOOTING: Erro containers_check

## ❌ Erro Reportado

```
Erro ao inserir na tabela stock_entries: 
new row for relation "containers" violates check constraint "containers_check"
```

---

## 🎯 Causa Raiz

A constraint `containers_check` está **configurada incorretamente** ou **na tabela errada**, impedindo a inserção de pneus com `container_id` vazio (pneus sem contêiner físico).

---

## ✅ Solução Rápida (5 minutos)

### **PASSO 1: Execute o SQL de Correção**

1. **Abra o SQL Editor do Supabase:**
   ```
   https://supabase.com/dashboard/project/nflgqugaabtxzifyhjor/sql
   ```

2. **Copie TODO o conteúdo do arquivo:**
   ```
   /FIX_CONTAINERS_CHECK_FINAL.sql
   ```

3. **Cole no SQL Editor e clique em RUN**

4. **Aguarde as mensagens de sucesso:**
   ```
   ✅ SUCESSO: Constraint containers_check adicionada corretamente!
   ✅ TESTE 1 PASSOU: Inserção com container_id vazio funcionou!
   🎉 TODOS OS TESTES PASSARAM!
   ```

### **PASSO 2: Teste Imediatamente**

1. Vá em **"Importação de Dados"** ou **"Atualizar Base ARCS"**
2. Tente cadastrar um pneu novo
3. **Deve funcionar sem erro!** ✅

---

## 📊 O Que o SQL Faz?

1. **🔍 DIAGNÓSTICO:** Identifica onde a constraint está configurada
2. **🗑️ LIMPEZA:** Remove a constraint de TODAS as tabelas
3. **✅ CORREÇÃO:** Adiciona constraint CORRETA em `stock_entries`:
   - ✓ Permite `container_id = ''` (pneus sem contêiner)
   - ✓ Valida `container_id` contra tabela `containers` quando não vazio
4. **🧪 TESTE:** Verifica automaticamente se funciona
5. **📋 RELATÓRIO:** Mostra status final

---

## 🔍 Verificação Manual (Opcional)

Se quiser verificar manualmente a constraint:

```sql
-- Ver definição da constraint
SELECT 
  conrelid::regclass AS table_name,
  conname AS constraint_name,
  pg_get_constraintdef(oid) AS definition
FROM pg_constraint
WHERE conname = 'containers_check';
```

**Resultado esperado:**
```
table_name    | constraint_name     | definition
--------------+---------------------+---------------------------------------------
stock_entries | containers_check    | CHECK ((container_id = ''::text) OR ...)
```

---

## 🐛 Se o Erro Persistir

### Opção 1: Remove Completamente a Constraint (Temporário)

```sql
-- REMOVE constraint (permite qualquer container_id)
ALTER TABLE stock_entries DROP CONSTRAINT IF EXISTS containers_check;
```

⚠️ **Cuidado:** Isso remove a validação. Use apenas para teste imediato.

### Opção 2: Verifica Triggers

Pode haver um trigger causando o problema:

```sql
-- Lista todos os triggers em stock_entries
SELECT 
  trigger_name, 
  event_manipulation, 
  event_object_table,
  action_statement
FROM information_schema.triggers
WHERE event_object_table = 'stock_entries';
```

### Opção 3: Verifica Foreign Keys

```sql
-- Lista foreign keys em stock_entries
SELECT
  tc.constraint_name,
  tc.table_name,
  kcu.column_name,
  ccu.table_name AS foreign_table_name,
  ccu.column_name AS foreign_column_name
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
  ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage AS ccu
  ON ccu.constraint_name = tc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY'
  AND tc.table_name = 'stock_entries';
```

---

## 📝 Mensagens de Erro Comuns

### Erro: "constraint already exists"
```
✅ SOLUÇÃO: Ignore - a constraint já está configurada corretamente
```

### Erro: "relation does not exist"
```
❌ PROBLEMA: Tabela stock_entries ou containers não existe
✅ SOLUÇÃO: Execute SETUP_DATABASE.sql primeiro
```

### Erro: "permission denied"
```
❌ PROBLEMA: Usuário sem permissão para alterar constraints
✅ SOLUÇÃO: Use SERVICE_ROLE_KEY no Supabase SQL Editor
```

---

## 🎯 Validação Final

Depois de executar o SQL, teste com esta query:

```sql
-- Tenta inserir pneu com container_id vazio
INSERT INTO stock_entries (
  id, barcode, model_id, model_name, model_type,
  container_id, container_name, status, created_at
)
SELECT
  gen_random_uuid()::TEXT,
  'TEST_' || gen_random_uuid()::TEXT,
  id,
  name,
  type,
  '', -- CONTAINER_ID VAZIO
  'Sem Contêiner',
  'Novo',
  NOW()
FROM tire_models LIMIT 1;

-- Se funcionou, remove o teste
DELETE FROM stock_entries WHERE barcode LIKE 'TEST_%';
```

**Resultado esperado:** ✅ Inserção bem-sucedida

---

## 📞 Suporte

Se o erro persistir após executar o SQL:

1. **Copie a mensagem de erro completa**
2. **Tire um print do SQL Editor mostrando o erro**
3. **Execute e copie o resultado de:**
   ```sql
   SELECT version(); -- Versão do PostgreSQL
   
   SELECT * FROM pg_constraint 
   WHERE conname = 'containers_check';
   
   \d stock_entries; -- Estrutura da tabela
   ```
4. **Envie todas as informações para análise**

---

## ✅ Status Esperado Após Fix

```
✅ Constraint containers_check configurada corretamente
✅ Pneus podem ser cadastrados com "Sem Contêiner"
✅ Validação de contêineres funciona para IDs válidos
✅ Importação ARCS funcionando 100%
✅ Sistema operacional sem erros
```

---

**Última atualização:** 2025-01-22  
**Versão do Fix:** 2.0 - Diagnóstico Completo + Auto-Teste
