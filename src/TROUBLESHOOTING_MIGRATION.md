# 🔧 Troubleshooting - Migração business_rules

## 🚨 Erro: "policy already exists"

**Erro Completo:**
```
ERROR: 42710: policy "business_rules_select_all" for table "business_rules" already exists
```

**Causa:** A tabela `business_rules` foi criada parcialmente em uma execução anterior.

**Solução:** Execute uma das 3 opções abaixo:

---

### ✅ **OPÇÃO 1: Reset Completo + Recriação (RECOMENDADO)**

**Passo 1:** Execute `RESET_BUSINESS_RULES_TABLE.sql`:
```sql
-- Remove TUDO relacionado à tabela business_rules
-- Copie e execute no Supabase SQL Editor
```

**Passo 2:** Execute `MIGRATION_BUSINESS_RULES_TABLE.sql`:
```sql
-- Recria a tabela do zero com todos os dados
```

**Passo 3:** Verifique:
```sql
SELECT COUNT(*) FROM business_rules;
-- Deve retornar: 15
```

---

### ✅ **OPÇÃO 2: Apenas Inserir Dados (SE A TABELA JÁ EXISTE)**

Se a tabela já existe mas está vazia, execute apenas:

```sql
-- Execute: INSERT_BUSINESS_RULES_DATA.sql
```

Verifique:
```sql
SELECT * FROM business_rules ORDER BY rule_type, categoria;
```

---

### ✅ **OPÇÃO 3: Correção Manual no Console**

**Passo 1:** Abra o SQL Editor do Supabase:
```
https://supabase.com/dashboard/project/nflgqugaabtxzifyhjor/sql
```

**Passo 2:** Execute este comando para ver o estado atual:
```sql
-- Verifica se a tabela existe
SELECT table_name 
FROM information_schema.tables 
WHERE table_name = 'business_rules';

-- Verifica policies existentes
SELECT policyname 
FROM pg_policies 
WHERE tablename = 'business_rules';

-- Verifica dados existentes
SELECT COUNT(*) FROM business_rules;
```

**Passo 3:** Baseado no resultado:

**Se a tabela existe mas está vazia:**
```sql
-- Execute INSERT_BUSINESS_RULES_DATA.sql
```

**Se a tabela tem dados antigos:**
```sql
-- Limpa e insere dados novos
DELETE FROM business_rules;
-- Depois execute INSERT_BUSINESS_RULES_DATA.sql
```

**Se a tabela está corrompida:**
```sql
-- Execute RESET_BUSINESS_RULES_TABLE.sql
-- Depois execute MIGRATION_BUSINESS_RULES_TABLE.sql
```

---

## 🔍 **Verificação Final**

Após executar qualquer opção acima, verifique se está tudo correto:

```sql
-- 1. Contagem de registros
SELECT COUNT(*) FROM business_rules;
-- Esperado: 15

-- 2. Contagem por tipo
SELECT rule_type, COUNT(*) as total
FROM business_rules
GROUP BY rule_type
ORDER BY rule_type;
-- Esperado:
-- slick    | 5
-- wet      | 5
-- curinga | 5

-- 3. Ver todas as regras
SELECT 
  rule_type,
  categoria,
  campeonato,
  quantidade
FROM business_rules
ORDER BY rule_type, categoria, campeonato;

-- 4. Testar consulta específica
SELECT quantidade 
FROM business_rules 
WHERE rule_type = 'curinga' 
  AND categoria = 'Carrera' 
  AND campeonato = 'Sprint';
-- Esperado: 4
```

---

## 🧪 **Teste no Frontend**

Após a migração SQL, teste no frontend:

1. **Acesse Master Data:**
   - Login como admin
   - Clique em "Master Data" no menu

2. **Vá para aba "Regras":**
   - Clique na aba "Regras de Negócio"
   - Deve mostrar 3 tabelas preenchidas

3. **Teste Edição:**
   - Clique em "Editar"
   - Modifique um valor
   - Clique em "Salvar"
   - Verifique no console do navegador (F12):
     ```
     ✅ 15 regras salvas com sucesso
     ```

4. **Verifique no SQL:**
   ```sql
   SELECT * FROM business_rules 
   WHERE updated_at > NOW() - INTERVAL '1 minute';
   -- Deve mostrar as regras recém-atualizadas
   ```

---

## 📋 **Checklist de Sucesso**

- [ ] SQL executado sem erros
- [ ] Tabela `business_rules` existe
- [ ] 15 registros inseridos (5 + 5 + 5)
- [ ] Policies RLS criadas
- [ ] Trigger `updated_at` funcionando
- [ ] Frontend carrega regras corretamente
- [ ] Edição e salvamento funcionam
- [ ] Console mostra: `✅ Regras carregadas: 15 registros`

---

## ❓ **Outros Erros Comuns**

### **Erro: "relation does not exist"**
**Solução:** A tabela não foi criada. Execute `MIGRATION_BUSINESS_RULES_TABLE.sql`

### **Erro: "null value in column violates not-null constraint"**
**Solução:** Algum campo obrigatório está faltando. Verifique o INSERT

### **Erro: "duplicate key value violates unique constraint"**
**Solução:** Tentando inserir regra duplicada. Use `ON CONFLICT DO UPDATE`

### **Frontend mostra erro "business_rules does not exist"**
**Solução:** 
1. Execute a migration SQL
2. Limpe cache do navegador (Ctrl+Shift+R)
3. Recarregue a página

### **Backend retorna regras padrão ao invés de dados do banco**
**Solução:**
1. Verifique se há dados: `SELECT COUNT(*) FROM business_rules;`
2. Se vazio, execute `INSERT_BUSINESS_RULES_DATA.sql`
3. Verifique RLS: usuário precisa estar autenticado

---

## 🆘 **Precisa de Ajuda?**

Se nenhuma das soluções acima funcionar:

1. **Capture informações:**
   ```sql
   -- Estado da tabela
   \d business_rules
   
   -- Policies
   SELECT * FROM pg_policies WHERE tablename = 'business_rules';
   
   -- Dados
   SELECT * FROM business_rules;
   
   -- Erros recentes
   SELECT * FROM pg_stat_activity WHERE state = 'idle in transaction';
   ```

2. **Console do navegador:**
   - Abra DevTools (F12)
   - Aba "Console"
   - Copie mensagens de erro

3. **Logs do backend:**
   - Verifique logs do Supabase Edge Functions
   - Procure por erros relacionados a `business_rules`

---

## 🎯 **Resumo Rápido**

**Problema:** Policy já existe  
**Solução Rápida:** Execute `RESET_BUSINESS_RULES_TABLE.sql` + `MIGRATION_BUSINESS_RULES_TABLE.sql`

**Problema:** Tabela vazia  
**Solução Rápida:** Execute `INSERT_BUSINESS_RULES_DATA.sql`

**Problema:** Frontend não carrega regras  
**Solução Rápida:** Verifique se há 15 registros no banco + limpe cache

---

## ✅ **Próximos Passos Após Sucesso**

1. ✅ Teste todas as funcionalidades de edição de regras
2. ✅ (Opcional) Limpe dados antigos da `master_data`:
   ```sql
   DELETE FROM master_data 
   WHERE type IN ('wildcard_rule', 'tire_purchase_rule', 'wet_tire_purchase_rule');
   ```
3. ✅ Documente a data da migração
4. ✅ Faça backup da nova estrutura

---

**Boa sorte! 🚀**
