# 🗂️ Arquivos de Migração - Guia de Uso

## ❓ **Qual arquivo eu devo usar?**

Escolha baseado na sua situação:

---

## 🚀 **Situação 1: ERRO "policy already exists"** ← VOCÊ ESTÁ AQUI

**Sintoma:** Tentou executar a migration e recebeu erro de policy já existente.

**Solução:** Use o arquivo **QUICK_FIX** ⬇️

### 📄 **Arquivo: `QUICK_FIX.sql`**

✅ **Use este arquivo se:**
- Recebeu erro: `policy "business_rules_select_all" already exists`
- Quer solução rápida em 1 comando
- Primeira vez executando a migration

🎯 **O que faz:**
- Remove tudo que existe (se existir)
- Cria tabela do zero
- Insere 15 registros
- Configura tudo (RLS, índices, triggers)

⏱️ **Tempo:** 5 segundos

📋 **Como usar:**
1. Abra: https://supabase.com/dashboard/project/nflgqugaabtxzifyhjor/sql
2. Copie **TODO** o conteúdo de `QUICK_FIX.sql`
3. Cole no SQL Editor
4. Clique em **RUN**
5. Veja resultado: 3 linhas com contagem de regras

---

## 📚 **Situação 2: Primeira instalação limpa**

**Sintoma:** Nunca executou migration antes, quer criar tabela pela primeira vez.

**Solução:** Use o arquivo **MIGRATION** ⬇️

### 📄 **Arquivo: `MIGRATION_BUSINESS_RULES_TABLE.sql`**

✅ **Use este arquivo se:**
- Primeira vez criando a tabela
- Quer versão completa com documentação
- Precisa de migration formal

🎯 **O que faz:**
- Cria tabela com todas as configurações
- Insere dados padrão
- Inclui comentários e documentação
- Script de migração opcional (comentado)

⏱️ **Tempo:** 10 segundos

📋 **Como usar:**
1. Abra: https://supabase.com/dashboard/project/nflgqugaabtxzifyhjor/sql
2. Copie **TODO** o conteúdo de `MIGRATION_BUSINESS_RULES_TABLE.sql`
3. Cole no SQL Editor
4. Clique em **RUN**

---

## 🗑️ **Situação 3: Preciso limpar tudo**

**Sintoma:** Tabela está corrompida, precisa deletar tudo e recomeçar.

**Solução:** Use o arquivo **RESET** ⬇️

### 📄 **Arquivo: `RESET_BUSINESS_RULES_TABLE.sql`**

⚠️ **CUIDADO:** Remove TUDO relacionado à tabela!

✅ **Use este arquivo se:**
- Tabela está corrompida
- Quer deletar tudo e recomeçar
- Precisa fazer limpeza total

🎯 **O que faz:**
- Remove triggers
- Remove funções
- Remove policies
- Remove índices
- Remove tabela

⏱️ **Tempo:** 2 segundos

📋 **Como usar:**
1. Execute `RESET_BUSINESS_RULES_TABLE.sql`
2. Depois execute `QUICK_FIX.sql` ou `MIGRATION_BUSINESS_RULES_TABLE.sql`

---

## 📝 **Situação 4: Tabela existe mas está vazia**

**Sintoma:** Tabela já existe, só precisa inserir dados.

**Solução:** Use o arquivo **INSERT** ⬇️

### 📄 **Arquivo: `INSERT_BUSINESS_RULES_DATA.sql`**

✅ **Use este arquivo se:**
- Tabela `business_rules` já existe
- Está vazia ou com dados antigos
- Só precisa inserir/atualizar dados

🎯 **O que faz:**
- Insere 15 registros
- Usa `ON CONFLICT DO UPDATE` (seguro)
- Mostra validação

⏱️ **Tempo:** 1 segundo

📋 **Como usar:**
1. Abra: https://supabase.com/dashboard/project/nflgqugaabtxzifyhjor/sql
2. Copie conteúdo de `INSERT_BUSINESS_RULES_DATA.sql`
3. Cole no SQL Editor
4. Clique em **RUN**

---

## 📖 **Documentação e Guias**

### 📄 **`MIGRATION_STEP_BY_STEP.md`**
Guia visual passo a passo da migração completa.

**Use quando:**
- É sua primeira migração
- Quer entender cada passo
- Precisa de validação em cada etapa

### 📄 **`TROUBLESHOOTING_MIGRATION.md`**
Soluções para erros comuns.

**Use quando:**
- Encontrou um erro
- Migration não funcionou
- Precisa debugar problema

### 📄 **`MIGRATION_NOTES.md`**
Notas técnicas sobre a migração.

**Use quando:**
- Quer entender as mudanças
- Precisa comparar antes/depois
- Documentação para equipe

### 📄 **`BUSINESS_RULES_SCHEMA.md`**
Documentação completa da estrutura.

**Use quando:**
- Quer entender a arquitetura
- Precisa fazer queries customizadas
- Referência técnica

---

## 🎯 **Fluxograma de Decisão**

```
Recebeu erro "policy already exists"?
├─ SIM → Use QUICK_FIX.sql ✅
└─ NÃO
   └─ Tabela business_rules existe?
      ├─ SIM
      │  └─ Está vazia?
      │     ├─ SIM → Use INSERT_BUSINESS_RULES_DATA.sql
      │     └─ NÃO → Use RESET + QUICK_FIX
      └─ NÃO → Use MIGRATION_BUSINESS_RULES_TABLE.sql
```

---

## 📊 **Matriz de Arquivos**

| Arquivo | Tamanho | Uso | Risco | Tempo |
|---------|---------|-----|-------|-------|
| **QUICK_FIX.sql** | 150 linhas | 🔥 Mais usado | Baixo | 5s |
| **MIGRATION_BUSINESS_RULES_TABLE.sql** | 600 linhas | Primeira vez | Baixo | 10s |
| **RESET_BUSINESS_RULES_TABLE.sql** | 50 linhas | Limpeza | Médio | 2s |
| **INSERT_BUSINESS_RULES_DATA.sql** | 80 linhas | Só dados | Muito baixo | 1s |
| **MIGRATION_STEP_BY_STEP.md** | Guia | Referência | - | - |
| **TROUBLESHOOTING_MIGRATION.md** | Guia | Debug | - | - |
| **MIGRATION_NOTES.md** | Guia | Documentação | - | - |
| **BUSINESS_RULES_SCHEMA.md** | Guia | Referência | - | - |

---

## ✅ **Recomendação Final**

### **Para o seu caso específico (erro de policy):**

1. ✅ **Execute:** `QUICK_FIX.sql`
2. ✅ **Aguarde:** 5 segundos
3. ✅ **Verifique:** Deve ver 3 linhas com contagens
4. ✅ **Teste:** Frontend → Master Data → Regras

**Se der qualquer erro:**
→ Consulte `TROUBLESHOOTING_MIGRATION.md`

---

## 🆘 **Ajuda Rápida**

**Link do SQL Editor:**
```
https://supabase.com/dashboard/project/nflgqugaabtxzifyhjor/sql
```

**Verificar se funcionou:**
```sql
SELECT COUNT(*) FROM business_rules;
-- Deve retornar: 15
```

**Comando de emergência (reverte tudo):**
```sql
-- Execute RESET_BUSINESS_RULES_TABLE.sql
```

---

## 🎉 **Próximos Passos Após Migração**

1. ✅ Teste no frontend: Master Data → Regras
2. ✅ Edite e salve uma regra
3. ✅ Verifique console do navegador (F12)
4. ✅ (Opcional) Limpe dados antigos da `master_data`

---

**Boa sorte! Se tiver qualquer dúvida, consulte os guias ou a documentação. 🚀**
