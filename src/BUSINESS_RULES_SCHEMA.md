# Regras de Negócio - Estrutura de Armazenamento

## 📋 Visão Geral

As **Regras de Negócio** do sistema Porsche Cup Brasil são armazenadas na tabela **`business_rules`** do Supabase, permitindo configuração dinâmica dos limites de coringas e pneus por categoria e campeonato.

Esta tabela foi projetada especificamente para armazenar regras de negócio com **colunas estruturadas**, substituindo a antiga abordagem de armazenar JSON em campo de texto.

---

## 🗄️ Estrutura da Tabela `business_rules`

Tabela dedicada com validações nativas do PostgreSQL:

```sql
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

### ✅ **Vantagens da Nova Estrutura**

1. **Colunas Tipadas**: `quantidade` é INTEGER, não texto
2. **Validação Nativa**: CHECKs garantem valores válidos
3. **Queries Simples**: WHERE direto, sem parse de JSON
4. **Performance**: Índices otimizados para categoria/campeonato
5. **Manutenção**: SQL puro, sem serialização

---

## 🎯 Tipos de Regras

### 1. **Regras de Coringas** (`rule_type = 'curinga'`)

Quantidade de coringas que podem ser comprados por piloto durante uma temporada.

**Exemplo de registro:**
```sql
rule_type = 'curinga'
categoria = 'Carrera'
campeonato = 'Sprint'
quantidade = 4
```

**Valores Padrão:**
| Categoria  | Campeonato | Quantidade |
|-----------|------------|-----------|
| Carrera   | Sprint     | 4         |
| Carrera   | Endurance  | 4         |
| Challenge | Sprint     | 4         |
| Challenge | Endurance  | 4         |
| Trophy    | Sprint     | 8         |

---

### 2. **Regras de Pneus SLICK** (`rule_type = 'slick'`)

Quantidade de pneus slick que podem ser comprados por piloto e etapa.

**Exemplo de registro:**
```sql
rule_type = 'slick'
categoria = 'Carrera'
campeonato = 'Sprint'
quantidade = 3
```

**Valores Padrão:**
| Categoria  | Campeonato | Quantidade |
|-----------|------------|-----------|
| Carrera   | Sprint     | 3 pneus   |
| Carrera   | Endurance  | 3 pneus   |
| Challenge | Sprint     | 3 pneus   |
| Challenge | Endurance  | 3 pneus   |
| Trophy    | Sprint     | 1 pneu    |

---

### 3. **Regras de Pneus WET** (`rule_type = 'wet'`)

Quantidade de pneus wet que podem ser comprados por piloto e etapa.

**Exemplo de registro:**
```sql
rule_type = 'wet'
categoria = 'Carrera'
campeonato = 'Sprint'
quantidade = 4
```

**Valores Padrão:**
| Categoria  | Campeonato | Quantidade |
|-----------|------------|-----------|
| Carrera   | Sprint     | 4 pneus   |
| Carrera   | Endurance  | 4 pneus   |
| Challenge | Sprint     | 4 pneus   |
| Challenge | Endurance  | 4 pneus   |
| Trophy    | Sprint     | 4 pneus   |

---

## 🔧 Como as Regras São Gerenciadas

### Backend (Supabase Edge Function)

**Endpoint GET:** `/make-server-02726c7c/business-rules`
- Busca todas as regras na tabela `business_rules` usando `SERVICE_ROLE_KEY` (bypass RLS)
- Filtra por tipos: `curinga`, `slick`, `wet` (campo `rule_type`)
- Lê diretamente das colunas estruturadas (`categoria`, `campeonato`, `quantidade`)
- Organiza em 3 arrays (wildcardRules, tirePurchaseRules, wetTirePurchaseRules)
- Retorna regras padrão se nenhuma for encontrada

**Endpoint POST:** `/make-server-02726c7c/business-rules` (apenas admin)
- Verifica autenticação do usuário (apenas admins podem salvar)
- Remove todas as regras existentes usando `SERVICE_ROLE_KEY` (bypass RLS)
- Insere novas regras com colunas estruturadas usando `SERVICE_ROLE_KEY`
- IDs gerados automaticamente pelo DEFAULT gen_random_uuid()
- Cada regra é salva como um registro separado com constraint de unicidade

### Frontend

**Interface de Edição:**
- Página Master Data → Aba "Regras"
- 3 tabelas editáveis com campos de input numérico
- Botão "Editar" para modo de edição
- Botão "Salvar" para persistir alterações
- Validação inline dos valores

**Utility Functions:**
```typescript
// Buscar todas as regras
const rules = await getBusinessRules();

// Buscar limite específico de coringas
const wildcardLimit = await getWildcardLimit('Carrera', 'Sprint'); // retorna 4

// Buscar limite específico de pneus SLICK
const slickLimit = await getTirePurchaseLimit('Carrera', 'Sprint'); // retorna 3

// Buscar limite específico de pneus WET
const wetLimit = await getWetTirePurchaseLimit('Carrera', 'Sprint'); // retorna 4
```

---

## 📊 Exemplo de Registros na Tabela

```sql
-- Exemplo de registros para regras de coringas (IDs gerados automaticamente)
INSERT INTO master_data (id, type, name) VALUES
(gen_random_uuid(),
('wildcard_rule', '{"categoria":"Carrera","campeonato":"Sprint","quantidade":4}'),
('wildcard_rule', '{"categoria":"Carrera","campeonato":"Endurance","quantidade":4}'),
('wildcard_rule', '{"categoria":"Challenge","campeonato":"Sprint","quantidade":4}'),
('wildcard_rule', '{"categoria":"Challenge","campeonato":"Endurance","quantidade":4}'),
('wildcard_rule', '{"categoria":"Trophy","campeonato":"Sprint","quantidade":8}');

-- Exemplo de registros para regras de pneus SLICK
INSERT INTO master_data (type, name) VALUES
('tire_purchase_rule', '{"categoria":"Carrera","campeonato":"Sprint","quantidade":3}'),
('tire_purchase_rule', '{"categoria":"Carrera","campeonato":"Endurance","quantidade":3}'),
('tire_purchase_rule', '{"categoria":"Challenge","campeonato":"Sprint","quantidade":3}'),
('tire_purchase_rule', '{"categoria":"Challenge","campeonato":"Endurance","quantidade":3}'),
('tire_purchase_rule', '{"categoria":"Trophy","campeonato":"Sprint","quantidade":1}');

-- Exemplo de registros para regras de pneus WET
INSERT INTO master_data (type, name) VALUES
('wet_tire_purchase_rule', '{"categoria":"Carrera","campeonato":"Sprint","quantidade":4}'),
('wet_tire_purchase_rule', '{"categoria":"Carrera","campeonato":"Endurance","quantidade":4}'),
('wet_tire_purchase_rule', '{"categoria":"Challenge","campeonato":"Sprint","quantidade":4}'),
('wet_tire_purchase_rule', '{"categoria":"Challenge","campeonato":"Endurance","quantidade":4}'),
('wet_tire_purchase_rule', '{"categoria":"Trophy","campeonato":"Sprint","quantidade":4}');
```

---

## 🔍 Consultas Úteis

### Ver todas as regras
```sql
SELECT rule_type, categoria, campeonato, quantidade, created_at 
FROM business_rules 
ORDER BY rule_type, categoria, campeonato;
```

### Ver regras de coringas
```sql
SELECT categoria, campeonato, quantidade 
FROM business_rules 
WHERE rule_type = 'curinga';
```

### Ver regras de pneus SLICK
```sql
SELECT categoria, campeonato, quantidade 
FROM business_rules 
WHERE rule_type = 'slick';
```

### Ver regras de pneus WET
```sql
SELECT categoria, campeonato, quantidade 
FROM business_rules 
WHERE rule_type = 'wet';
```

### Buscar regra específica
```sql
SELECT quantidade 
FROM business_rules 
WHERE rule_type = 'curinga' 
  AND categoria = 'Carrera' 
  AND campeonato = 'Sprint';
```

### Atualizar regra específica
```sql
UPDATE business_rules 
SET quantidade = 5 
WHERE rule_type = 'curinga' 
  AND categoria = 'Carrera' 
  AND campeonato = 'Sprint';
```

### Limpar todas as regras (cuidado!)
```sql
DELETE FROM business_rules;
-- ou
TRUNCATE business_rules;
```

---

## ⚠️ Importante

1. **Inicialização Automática**: Se nenhuma regra for encontrada no banco, o sistema usa valores padrão automaticamente
2. **Validação**: O sistema valida que todas as 3 categorias de regras estejam presentes antes de salvar
3. **Validação Nativa SQL**: CHECKs no PostgreSQL garantem integridade (categoria, campeonato, quantidade ≥ 0)
4. **Constraint de Unicidade**: Não pode haver regra duplicada (rule_type + categoria + campeonato)
5. **Permissões**: Apenas administradores podem modificar as regras através da interface
6. **Row-Level Security**: O backend usa `SERVICE_ROLE_KEY` para bypass das políticas RLS, permitindo inserção/deleção
7. **Backup**: Cada salvamento remove e recria todos os registros - considere fazer backup antes de alterações manuais
8. **Auto-Update**: Trigger automático atualiza `updated_at` em cada modificação

---

## 🚀 Fluxo de Atualização

```
Usuário Admin → Master Data → Aba "Regras" → Clica "Editar"
    ↓
Modifica os valores nas tabelas
    ↓
Clica "Salvar"
    ↓
Frontend envia POST para /business-rules
    ↓
Backend deleta regras antigas da business_rules
    ↓
Backend insere novas regras na business_rules (colunas estruturadas)
    ↓
Frontend recarrega regras atualizadas
    ↓
Regras aplicadas em todo o sistema
```

---

## 📝 Arquivos Relacionados

- **Backend**: `/supabase/functions/server/index.tsx` (linhas 2119-2193)
- **Utils**: `/utils/businessRules.ts`
- **Frontend**: `/components/MasterData.tsx` (aba "Regras")
- **Tipos**: Interfaces em `/utils/businessRules.ts`

---

## 🎨 Interface Visual

A interface permite:
- ✅ Visualização das 3 tabelas de regras
- ✅ Modo de edição inline com inputs numéricos
- ✅ Badges coloridos para categorias e campeonatos
- ✅ Botões "Editar", "Salvar" e "Cancelar"
- ✅ Feedback visual de sucesso/erro
- ✅ Validação de valores mínimos

---

**Desenvolvido para Porsche Cup Brasil - Sistema de Gestão de Pneus** 🏁
