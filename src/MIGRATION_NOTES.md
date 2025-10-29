# 🔄 Migração: master_data → business_rules

## 📋 Resumo da Mudança

**Data:** 18 de Outubro de 2025  
**Motivo:** Melhorar estrutura de dados das Regras de Negócio  
**Status:** ✅ Código atualizado, aguardando execução do SQL

---

## 🎯 O Que Mudou

### **ANTES** - Tabela `master_data`
```sql
-- Estrutura genérica com JSON em campo texto
CREATE TABLE master_data (
  id UUID PRIMARY KEY,
  type TEXT,              -- 'wildcard_rule', 'tire_purchase_rule', 'wet_tire_purchase_rule'
  name TEXT,              -- JSON string: '{"categoria":"Carrera","campeonato":"Sprint","quantidade":4}'
  created_at TIMESTAMPTZ,
  updated_at TIMESTAMPTZ
);
```

**❌ Problemas:**
- JSON precisa ser parseado a cada consulta
- Sem validação nativa de tipos
- Queries complexas
- Performance limitada
- Campo `name` confuso (na verdade é JSON)

---

### **DEPOIS** - Tabela `business_rules`
```sql
-- Estrutura dedicada com colunas tipadas
CREATE TABLE business_rules (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  rule_type TEXT NOT NULL CHECK (rule_type IN ('curinga', 'slick', 'wet')),
  categoria TEXT NOT NULL CHECK (categoria IN ('Carrera', 'Challenge', 'Trophy')),
  campeonato TEXT NOT NULL CHECK (campeonato IN ('Sprint', 'Endurance')),
  quantidade INTEGER NOT NULL CHECK (quantidade >= 0),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT unique_business_rule UNIQUE (rule_type, categoria, campeonato)
);
```

**✅ Benefícios:**
- Colunas tipadas (INTEGER, não TEXT)
- Validação nativa via CHECK constraints
- Queries simples com WHERE direto
- Performance otimizada com índices
- Constraint de unicidade automática
- Trigger para auto-update de `updated_at`

---

## 📊 Comparação de Estrutura

| Aspecto | `master_data` (Antigo) | `business_rules` (Novo) |
|---------|------------------------|-------------------------|
| **Armazenamento** | JSON em campo texto | Colunas estruturadas |
| **Tipo de Dado** | TEXT (tudo) | INTEGER, TEXT (específicos) |
| **Validação** | Apenas no backend | CHECK constraints nativos |
| **Queries** | Parse JSON obrigatório | WHERE direto |
| **Performance** | Mais lenta (parse + scan) | Mais rápida (índices) |
| **Integridade** | Backend valida | PostgreSQL garante |
| **Unicidade** | Não garantida | UNIQUE constraint |
| **Auto-Update** | Manual | Trigger automático |

---

## 🔄 Mapeamento de Tipos

| Campo Antigo | Campo Novo | Exemplo |
|-------------|-----------|---------|
| `type = 'wildcard_rule'` | `rule_type = 'curinga'` | Coringas |
| `type = 'tire_purchase_rule'` | `rule_type = 'slick'` | Pneus SLICK |
| `type = 'wet_tire_purchase_rule'` | `rule_type = 'wet'` | Pneus WET |
| `name (JSON string)` | Colunas separadas | - |
| `name->>'categoria'` | `categoria` | 'Carrera', 'Challenge', 'Trophy' |
| `name->>'campeonato'` | `campeonato` | 'Sprint', 'Endurance' |
| `name->>'quantidade'` | `quantidade` | INTEGER |

---

## 🚀 Como Migrar

### **Passo 1: Execute o SQL**

1. Abra o Supabase SQL Editor:
   ```
   https://supabase.com/dashboard/project/nflgqugaabtxzifyhjor/sql
   ```

2. Copie todo o conteúdo de:
   ```
   MIGRATION_BUSINESS_RULES_TABLE.sql
   ```

3. Cole no SQL Editor e clique em **RUN**

4. Verifique a criação:
   ```sql
   SELECT * FROM business_rules;
   ```

5. Deve retornar 15 registros:
   - 5 regras de coringas (curinga)
   - 5 regras de pneus SLICK (slick)
   - 5 regras de pneus WET (wet)

---

### **Passo 2: (Opcional) Migrar Dados Existentes**

Se você já tem dados na `master_data`, pode migrá-los automaticamente:

```sql
-- Execute o bloco DO $$ comentado no arquivo MIGRATION_BUSINESS_RULES_TABLE.sql
-- Ele migrará automaticamente os dados antigos para a nova estrutura
```

---

### **Passo 3: (Opcional) Limpar Dados Antigos**

**⚠️ CUIDADO:** Execute apenas depois de confirmar que a nova tabela funciona!

```sql
-- Remove regras antigas da master_data
DELETE FROM master_data 
WHERE type IN ('wildcard_rule', 'tire_purchase_rule', 'wet_tire_purchase_rule');
```

---

## ✅ Checklist de Verificação

Após executar a migration, verifique:

- [ ] Tabela `business_rules` criada com sucesso
- [ ] 15 registros inseridos (5 + 5 + 5)
- [ ] Frontend carrega regras sem erros
- [ ] Edição e salvamento funcionam
- [ ] Nenhum erro de RLS
- [ ] Logs mostram: `✅ Regras carregadas: 15 registros`

---

## 🔧 Código Atualizado

### **Backend** (`/supabase/functions/server/index.tsx`)

**GET `/business-rules`:**
```typescript
// ANTES
const { data } = await supabaseAdmin
  .from('master_data')
  .select('*')
  .in('type', ['wildcard_rule', ...]);

// Parse manual de JSON
const ruleData = JSON.parse(row.name);

// DEPOIS
const { data } = await supabaseAdmin
  .from('business_rules')
  .select('*');

// Leitura direta de colunas
const ruleData = {
  categoria: row.categoria,
  campeonato: row.campeonato,
  quantidade: row.quantidade,
};
```

**POST `/business-rules`:**
```typescript
// ANTES
newRecords.push({
  id: crypto.randomUUID(),
  type: 'wildcard_rule',
  name: JSON.stringify(rule), // Serializa para JSON
});

// DEPOIS
newRecords.push({
  rule_type: 'curinga',
  categoria: rule.categoria,
  campeonato: rule.campeonato,
  quantidade: rule.quantidade, // INTEGER nativo
});
// ID gerado automaticamente pelo DEFAULT gen_random_uuid()
```

---

## 📝 Testes Recomendados

1. **Teste de Leitura:**
   - Abra Master Data → Aba "Regras"
   - Verifique se as 3 tabelas aparecem preenchidas

2. **Teste de Edição:**
   - Clique em "Editar"
   - Modifique alguns valores
   - Clique em "Salvar"
   - Verifique no console: `✅ 15 regras salvas com sucesso`

3. **Teste de Consulta SQL:**
   ```sql
   SELECT rule_type, COUNT(*) as total
   FROM business_rules
   GROUP BY rule_type;
   ```
   
   Resultado esperado:
   ```
   curinga | 5
   slick    | 5
   wet      | 5
   ```

4. **Teste de Validação:**
   ```sql
   -- Deve FALHAR (quantidade negativa)
   INSERT INTO business_rules (rule_type, categoria, campeonato, quantidade)
   VALUES ('curinga', 'Carrera', 'Sprint', -1);
   
   -- Deve FALHAR (categoria inválida)
   INSERT INTO business_rules (rule_type, categoria, campeonato, quantidade)
   VALUES ('curinga', 'InvalidCategory', 'Sprint', 4);
   
   -- Deve FALHAR (duplicata)
   INSERT INTO business_rules (rule_type, categoria, campeonato, quantidade)
   VALUES ('curinga', 'Carrera', 'Sprint', 4);
   INSERT INTO business_rules (rule_type, categoria, campeonato, quantidade)
   VALUES ('curinga', 'Carrera', 'Sprint', 5);
   ```

---

## 🐛 Troubleshooting

### **Erro: "relation business_rules does not exist"**
**Causa:** Tabela não foi criada  
**Solução:** Execute `MIGRATION_BUSINESS_RULES_TABLE.sql` no SQL Editor

### **Erro: "null value in column violates not-null constraint"**
**Causa:** Tentando inserir com campos obrigatórios faltando  
**Solução:** Verifique se `rule_type`, `categoria`, `campeonato`, `quantidade` estão presentes

### **Erro: "new row violates check constraint"**
**Causa:** Valor inválido (ex: categoria = 'Invalid')  
**Solução:** Use apenas valores permitidos:
- `rule_type`: 'curinga', 'slick', 'wet'
- `categoria`: 'Carrera', 'Challenge', 'Trophy'
- `campeonato`: 'Sprint', 'Endurance'
- `quantidade`: ≥ 0

### **Erro: "duplicate key value violates unique constraint"**
**Causa:** Tentando inserir regra duplicada  
**Solução:** Cada combinação (rule_type + categoria + campeonato) deve ser única

### **Frontend ainda mostra dados antigos**
**Causa:** Cache do navegador  
**Solução:** Limpe o cache (Ctrl+Shift+R) ou abra em aba anônima

---

## 📚 Arquivos Relacionados

- **Migration SQL:** `/MIGRATION_BUSINESS_RULES_TABLE.sql`
- **Documentação:** `/BUSINESS_RULES_SCHEMA.md`
- **Backend:** `/supabase/functions/server/index.tsx`
- **Frontend Utils:** `/utils/businessRules.ts`
- **Interface:** `/components/MasterData.tsx`

---

## ✅ Status da Migração

- [x] SQL da migration criado
- [x] Backend atualizado (GET + POST)
- [x] Documentação atualizada
- [ ] **SQL executado no Supabase** ← VOCÊ ESTÁ AQUI
- [ ] Testes realizados
- [ ] Dados antigos limpos (opcional)

---

## 🎉 Conclusão

A nova estrutura `business_rules` torna o sistema:
- ✅ Mais rápido (queries otimizadas)
- ✅ Mais seguro (validações nativas)
- ✅ Mais simples (sem parse de JSON)
- ✅ Mais confiável (constraints PostgreSQL)

**Próximo Passo:** Execute `MIGRATION_BUSINESS_RULES_TABLE.sql` no Supabase SQL Editor! 🚀
