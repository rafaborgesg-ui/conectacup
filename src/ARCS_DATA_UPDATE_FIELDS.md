# ARCS Data Update - Mapeamento de Campos

## Visão Geral

O módulo **Atualizar Base de Dados ARCS** processa planilhas Excel do sistema ARCS e atualiza automaticamente todos os campos relacionados na tabela `stock_entries` do Supabase.

## Estrutura da Planilha Excel ARCS

A planilha deve seguir o formato padrão do ARCS com as seguintes colunas:

| Coluna Excel | Nome do Campo | Coluna DB (stock_entries) | Descrição |
|--------------|---------------|---------------------------|-----------|
| **A** | Piloto | `pilot` | Nome do piloto |
| **B** | Nº | `numero` | Número do carro/piloto |
| **C** | Categoria | `categoria` | Categoria da competição |
| **D** | Ano | `ano` | Ano da temporada |
| **E** | Etapa | `etapa` | Número/nome da etapa |
| **F** | Pista | `pista` | Nome do autódromo |
| **G** | Camp. | `campeonato` | Nome do campeonato |
| **H** | Tipo | _(não salvo)_ | Tipo do pneu (informativo) |
| **I** | Set | `set_pneu` | Conjunto/set do pneu |
| **J** | Lado | `lado` | Lado do pneu (esquerdo/direito) |
| **K** | Serial | `barcode` | **Código de barras (CHAVE)** |
| **L** | Condição | `status` | **guardado → "Piloto" / descartado → "Descarte Piloto"** |
| **M** | Local | `local` | Localização física |
| **N** | T.V | `tempo_vida` | Tempo de vida do pneu |
| **O** | Data e hora | `data_hora` | Data/hora do registro |

## Fluxo de Processamento

### 1. Upload da Planilha
- Usuário faz upload de arquivo Excel (.xlsx)
- Componente valida formato do arquivo

### 2. Carregamento de Dados
```typescript
// Carrega todos os dados necessários
const stockEntries = await getStockEntries(true); // Inclui descartados
const tireModels = await getTireModels();
const containers = await getContainers();
```

### 3. Leitura dos Dados
```typescript
// Lê cada linha da planilha (ignora header linha 1)
const record = {
  piloto: row[0],      // Coluna A
  numero: row[1],      // Coluna B
  categoria: row[2],   // Coluna C
  ano: row[3],         // Coluna D
  etapa: row[4],       // Coluna E
  pista: row[5],       // Coluna F
  campeonato: row[6],  // Coluna G
  // Tipo row[7] não é salvo
  set: row[8],         // Coluna I
  lado: row[9],        // Coluna J
  serial: row[10],     // Coluna K - CÓDIGO DE BARRAS
  condicao: row[11],   // Coluna L - CONDIÇÃO
  local: row[12],      // Coluna M
  tv: row[13],         // Coluna N
  dataHora: row[14],   // Coluna O
};
```

### 4. Normalização do Barcode
```typescript
// Normaliza código de barras para 8 dígitos
const normalizedSerial = normalizeBarcode(record.serial);
// Exemplo: "1234" → "00001234"
// Exemplo: "12345678" → "12345678"
```

### 5. Busca no Banco de Dados
```typescript
// Busca pneu na tabela stock_entries pelo barcode
let entry = stockEntries.find(e => e.barcode === normalizedSerial);
```

### 6. Cadastro Automático (se não encontrado)
```typescript
if (!entry) {
  // 6.1. Determina o modelo baseado em categoria e lado
  const model = determineModel(record.categoria, record.lado, record.tipo, tireModels);
  
  if (!model) {
    result.errors.push(`Não foi possível determinar o modelo`);
    continue;
  }
  
  // 6.2. Seleciona contêiner disponível
  const defaultContainer = containers.find(c => c.current_stock < c.capacity) || containers[0];
  
  // 6.3. Cadastra novo pneu
  await saveStockEntry({
    barcode: normalizedSerial,
    model_id: model.id,
    model_name: model.name,
    model_type: model.type,
    container_id: defaultContainer.id,
    container_name: defaultContainer.name,
    pilot: record.piloto,
    status: 'Novo'
  });
  
  result.created++;
  console.log(`✅ Pneu ${normalizedSerial} cadastrado automaticamente`);
}
```

### 7. Determinação do Status
```typescript
// Mapeia condição da planilha para status do sistema
const condicaoLower = record.condicao.toLowerCase().trim();

if (condicaoLower === 'guardado') {
  newStatus = 'Piloto';
} else if (condicaoLower === 'descartado') {
  newStatus = 'Descarte Piloto';
} else {
  // Ignora outras condições
  continue;
}
```

### 8. Preparação dos Dados para Atualização
```typescript
const updates = {
  status: newStatus,              // Status baseado na condição
  pilot: record.piloto,           // Coluna A
  numero: record.numero,          // Coluna B
  categoria: record.categoria,    // Coluna C
  ano: record.ano,                // Coluna D
  etapa: record.etapa,            // Coluna E
  pista: record.pista,            // Coluna F
  campeonato: record.campeonato,  // Coluna G
  set_pneu: record.set,           // Coluna I
  lado: record.lado,              // Coluna J
  local: record.local,            // Coluna M
  tempo_vida: record.tv,          // Coluna N
  data_hora: record.dataHora,     // Coluna O
};

// Remove campos vazios
Object.keys(updates).forEach(key => {
  if (updates[key] === '' || updates[key] === null) {
    delete updates[key];
  }
});
```

### 9. Atualização no Supabase
```typescript
// Chama API para atualizar pelo barcode
await updateStockEntryByBarcode(normalizedSerial, updates);

// API Request
PUT /make-server-02726c7c/stock-entries/{barcode}
Body: { status, pilot, numero, categoria, ... }

// Servidor atualiza diretamente no Postgres
supabaseAdmin
  .from('stock_entries')
  .update(updates)
  .eq('barcode', barcode)
```

## Lógica de Determinação de Modelo

### Mapeamento Automático: Categoria + Lado → Modelo

O sistema identifica automaticamente o modelo correto do pneu baseado nas colunas **Categoria** e **Lado** da planilha ARCS.

#### Tabela de Mapeamento

| Tipo | Categoria | Lado | Modelo Determinado |
|------|-----------|------|-------------------|
| Slick | 991 | Dianteiro/E/D/F | **991 Dianteiro** |
| Slick | 991 | Traseiro/R | **991 Traseiro** |
| Slick | 992 | Dianteiro/E/D/F | **992 Dianteiro** |
| Slick | 992 | Traseiro/R | **992 Traseiro** |
| Wet | 991 | Dianteiro/E/D/F | **991 Dianteiro** |
| Wet | 992 | Dianteiro/E/D/F | **992 Dianteiro** |
| Wet | * | Traseiro/R | **991 e 992 Traseiro** |

#### Lógica de Detecção

```typescript
// 1. Identifica o tipo (Slick ou Wet)
const isWet = tipo.includes('wet') || tipo.includes('chuva');
const tireType = isWet ? 'Wet' : 'Slick';

// 2. Identifica a categoria (991 ou 992)
const is991 = categoria.includes('991');
const is992 = categoria.includes('992');

// 3. Identifica a posição (Dianteiro ou Traseiro)
const isDianteiro = lado.includes('diant') || lado.includes('e') || lado.includes('d');
const isTraseiro = lado.includes('tras') || lado === 'r';

// 4. Aplica regras de mapeamento
if (tireType === 'Slick') {
  if (is991 && isDianteiro) return '991 Dianteiro';
  if (is991 && isTraseiro) return '991 Traseiro';
  if (is992 && isDianteiro) return '992 Dianteiro';
  if (is992 && isTraseiro) return '992 Traseiro';
}

if (tireType === 'Wet') {
  if (is991 && isDianteiro) return '991 Dianteiro';
  if (is992 && isDianteiro) return '992 Dianteiro';
  if (isTraseiro) return '991 e 992 Traseiro'; // Compartilhado
}
```

#### Exemplos de Mapeamento

| Categoria | Lado | Tipo | → Modelo |
|-----------|------|------|----------|
| GT3 Cup 991 | Diant | Slick | 991 Dianteiro (Slick) |
| 991 | Traseiro | Slick | 991 Traseiro (Slick) |
| Sport 992 | E | Slick | 992 Dianteiro (Slick) |
| 992 | R | Wet | 991 e 992 Traseiro (Wet) |
| 991 Challenge | Dianteiro | Wet | 991 Dianteiro (Wet) |

#### Seleção de Contêiner

Quando um pneu novo é cadastrado automaticamente:
1. **Prioridade**: Primeiro contêiner com espaço disponível (`current_stock < capacity`)
2. **Fallback**: Se todos cheios, usa o primeiro contêiner da lista
3. **Erro**: Se nenhum contêiner existe, registra erro

```typescript
const defaultContainer = containers.find(c => c.current_stock < c.capacity) || containers[0];
```

## Regras de Negócio

### Campos Obrigatórios
- **Coluna K (Serial)**: Código de barras - OBRIGATÓRIO
- **Coluna L (Condição)**: guardado ou descartado - OBRIGATÓRIO
- **Coluna C (Categoria)**: Necessária para cadastro automático (991/992)
- **Coluna J (Lado)**: Necessária para cadastro automático (dianteiro/traseiro)

### Campos Opcionais
- Todos os outros campos são opcionais
- Campos vazios/null não sobrescrevem dados existentes

### Normalização de Barcode
- Todos os códigos são normalizados para 8 dígitos
- Zeros à esquerda são adicionados se necessário
- Se maior que 8 dígitos, pega os últimos 8

### Validações
1. Arquivo deve ser .xlsx
2. Serial e Condição devem estar preenchidos
3. Barcode deve existir na tabela stock_entries
4. Condição deve ser "guardado" ou "descartado" (case-insensitive)

## Resultado do Processamento

Após o processamento, o sistema retorna:
- **Total**: Número de registros processados
- **Atualizados**: Pneus existentes que tiveram dados atualizados
- **Cadastrados**: Pneus novos cadastrados automaticamente
- **Erros**: Registros que não puderam ser processados (modelo não identificado, etc.)
- **Lista de Erros**: Detalhamento de cada erro ocorrido

## Logs de Debug

O sistema gera logs detalhados:
```
📊 Processando 150 registros da planilha ARCS
✅ Dados carregados: 1200 pneus, 7 modelos, 5 contêineres
🔍 Processando: 1234 → 00001234 (Condição: guardado)

// Pneu existente - atualização
📝 Atualizando 00001234: Novo → Piloto
✅ Atualizado: 00001234 → Piloto + pilot, numero, categoria, etapa

// Pneu novo - cadastro automático
🆕 Pneu 00005678 não encontrado. Tentando cadastro automático...
✅ Pneu 00005678 cadastrado automaticamente: 992 Dianteiro no Container A
📝 Atualizando 00005678: Novo → Piloto
✅ Atualizado: 00005678 → Piloto + pilot, numero, categoria, etapa

// Erro - modelo não identificado
🆕 Pneu 00009999 não encontrado. Tentando cadastro automático...
❌ Não foi possível determinar modelo para 00009999
```

## Banco de Dados

### Schema: public
### Tabela: stock_entries

Campos atualizados pelo ARCS Data Update:
```sql
-- Campos principais (já existentes)
barcode VARCHAR(8) PRIMARY KEY
status VARCHAR(50)

-- Campos ARCS (novos/opcionais)
pilot VARCHAR(100)
numero VARCHAR(20)
categoria VARCHAR(50)
ano VARCHAR(10)
etapa VARCHAR(50)
pista VARCHAR(100)
campeonato VARCHAR(100)
set_pneu VARCHAR(20)
lado VARCHAR(20)
local VARCHAR(100)
tempo_vida VARCHAR(50)
data_hora VARCHAR(50)
```

## Sincronização de Telas

Após atualização bem-sucedida:
```typescript
// Dispara evento global para atualizar outras telas
window.dispatchEvent(new Event('stock-entries-updated'));

// Componentes que escutam este evento:
// - Dashboard
// - Reports
// - TireStockEntry
// - TireMovement
// - Etc.
```

## Exemplo de Planilha

```
| A        | B  | C       | D    | E     | F          | G           | H    | I   | J   | K        | L          | M       | N  | O                |
|----------|----|---------|----- |-------|------------|-------------|------|-----|-----|----------|------------|---------|----|--------------------|
| Piloto   | Nº | Categ.  | Ano  | Etapa | Pista      | Camp.       | Tipo | Set | Lado| Serial   | Condição   | Local   | TV | Data e hora        |
| Fulano   | 77 | GT3 Cup | 2024 | 1     | Interlagos | Porsche Cup | Slick| A   | E   | 00001234 | guardado   | Box 1   | 50 | 2024-01-15 10:30   |
| Ciclano  | 88 | Sport   | 2024 | 1     | Interlagos | Porsche Cup | Wet  | B   | D   | 00005678 | descartado | Descarte| 120| 2024-01-15 11:45   |
```

## Tratamento de Erros

### Erro: "Entrada com ID X não encontrada"
- ✅ **CORRIGIDO**: Função agora usa barcode ao invés de ID
- Sistema busca diretamente pela coluna `barcode`

### Info: "Pneu não encontrado: 00001234"
- ✅ **RESOLVIDO AUTOMATICAMENTE**: Sistema cadastra pneu automaticamente
- Determina modelo baseado em categoria e lado da planilha
- Aloca no primeiro contêiner disponível

### Erro: "Não foi possível determinar o modelo"
- Categoria ou lado não foram identificados corretamente na planilha
- Verifique se as colunas C (Categoria) e J (Lado) estão preenchidas
- Certifique-se que categoria contém "991" ou "992"
- Certifique-se que lado contém termos reconhecidos (dianteiro/traseiro/e/d/r)

### Erro: "Erro ao atualizar X"
- Erro de conexão com banco de dados
- Verifique logs do servidor para detalhes

## Permissões

- **Acesso**: Apenas administradores (`role = 'admin'`)
- **Autenticação**: Supabase Auth com RLS
- **Endpoint**: Protegido com `authMiddleware`

## Performance

- Processamento sequencial (loop for)
- Atualização individual por pneu
- Eventos de sincronização no final
- Logs detalhados para auditoria

## Status de Implementação

1. ✅ Atualização de múltiplos campos
2. ✅ Interface completa com StockEntry
3. ✅ Logs detalhados de processamento
4. ✅ Instruções atualizadas na UI
5. ✅ **Cadastro automático de pneus não encontrados**
6. ✅ **Determinação automática de modelo por categoria/lado**
7. ✅ **Alocação inteligente em contêineres**
8. 🔄 Testar com planilha ARCS real
9. 🔄 Validar dados após importação

## Benefícios do Cadastro Automático

### ✅ Antes (Manual)
- Pneu não encontrado → Erro
- Usuário precisava cadastrar manualmente
- Interrompia o fluxo de importação
- Risco de dados inconsistentes

### ✅ Agora (Automático)
- Pneu não encontrado → Cadastro automático
- Modelo determinado por lógica de negócio
- Processo contínuo sem interrupção
- Dados sempre consistentes com a planilha

### Casos de Uso

1. **Primeira importação**: Todos os pneus são cadastrados automaticamente
2. **Importação incremental**: Apenas pneus novos são cadastrados
3. **Sincronização ARCS**: Sistema sempre atualizado com base ARCS
4. **Recuperação de dados**: Pode recriar base a partir da planilha
