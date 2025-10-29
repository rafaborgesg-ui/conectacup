# 🔍 Debug - Entrada Planilha

## Problema Reportado
A aba "Entrada Planilha" não está cadastrando pneus na tabela `stock_entries` do Supabase.

## ✅ Solução Implementada
Adicionei **logs detalhados** em toda a função `handleSpreadsheetEntry` para identificar exatamente onde o processo está falhando.

## 📋 Como Usar os Logs para Debug

### 1. Abra o Console do Navegador
- Pressione `F12` ou `Ctrl + Shift + I`
- Vá para a aba **Console**

### 2. Cole os Dados da Planilha
No formato:
```
CÓDIGO	MODELO	CONTÊINER
5290731	30/65-18 Porsche Cup N3	GSILVA - WSCU 7032937
5290742	30/65-18 Porsche Cup N3	GSILVA - WSCU 7032937
```

### 3. Clique em "Processar Planilha"

### 4. Analise os Logs

Os logs vão mostrar **cada etapa** do processo:

#### 📊 Parsing Inicial
```
🔄 [PLANILHA] Iniciando processamento...
📋 [PLANILHA] Texto recebido: CÓDIGO	MODELO	CONTÊINER...
📊 [PLANILHA] Total de linhas: 3
📝 [PLANILHA] Linhas de dados (sem cabeçalho): 2
📝 [PLANILHA] Primeira linha de dados: 5290731	30/65-18 Porsche Cup N3	GSILVA - WSCU 7032937
```

#### 📝 Análise de Cada Linha
```
   Linha 2: 3 colunas -> ["5290731", "30/65-18 Porsche Cup N3", "GSILVA - WSCU 7032937"]
   ✅ Linha 2: Código 05290731, Modelo: "30/65-18 Porsche Cup N3", Contêiner: "GSILVA - WSCU 7032937"
```

#### 📊 Resumo do Parsing
```
📊 [PLANILHA] Resumo parsing:
   - Total linhas válidas: 2
   - Total linhas inválidas: 0
```

#### 🚀 Início do Cadastro
```
🚀 [PLANILHA] Iniciando cadastro de 2 pneus...
📦 [PLANILHA] Modelos disponíveis (7): ["30/65-18 Porsche Cup N3 991 Dianteiro", ...]
📦 [PLANILHA] Contêineres disponíveis (5): ["GSILVA - WSCU 7032937", ...]
```

#### 🔍 Processamento Individual
Para cada pneu:
```
🔍 [PLANILHA] Linha 2: Processando código 05290731
   Comparando modelo "30/65-18 Porsche Cup N3 991 Dianteiro" com "30/65-18 Porsche Cup N3": ✅ MATCH
   ✅ [PLANILHA] Modelo encontrado: "30/65-18 Porsche Cup N3 991 Dianteiro" (ID: abc-123)
   Comparando contêiner "GSILVA - WSCU 7032937" com "GSILVA - WSCU 7032937": ✅ MATCH
   ✅ [PLANILHA] Contêiner encontrado: "GSILVA - WSCU 7032937" (ID: xyz-789)
   💾 [PLANILHA] Salvando entrada: {id: "...", barcode: "05290731", model_id: "abc-123", container_id: "xyz-789"}
   ✅ [PLANILHA] Resultado saveStockEntry: SUCESSO
   📝 [PLANILHA] Entrada adicionada à lista local
```

#### ✅ Resultado Final
```
✅ [PLANILHA] Processamento concluído:
   - Sucessos: 2
   - Erros: 0
   - Total processado: 2
```

## 🔍 Possíveis Problemas e Diagnósticos

### ❌ Problema 1: Modelo não encontrado
**Log:**
```
❌ [PLANILHA] Linha 2: Modelo "30/65-18 Porsche Cup N3" não encontrado
   Comparando modelo "..." com "30/65-18 Porsche Cup N3": ❌
```

**Causa:** O nome do modelo na planilha não corresponde a nenhum modelo cadastrado.

**Solução:**
1. Veja a lista de modelos disponíveis no log: `📦 [PLANILHA] Modelos disponíveis`
2. Ajuste o nome na planilha para corresponder (busca parcial case-insensitive)
3. Ou cadastre o modelo exato em "Cadastro de Modelos"

### ❌ Problema 2: Contêiner não encontrado
**Log:**
```
❌ [PLANILHA] Linha 2: Contêiner "GSILVA - WSCU 7032937" não encontrado
   Comparando contêiner "..." com "GSILVA - WSCU 7032937": ❌
```

**Causa:** O nome do contêiner na planilha não corresponde a nenhum contêiner cadastrado.

**Solução:**
1. Veja a lista de contêineres disponíveis no log: `📦 [PLANILHA] Contêineres disponíveis`
2. Ajuste o nome na planilha para corresponder
3. Ou cadastre o contêiner em "Cadastro de Contêineres"

### ❌ Problema 3: saveStockEntry retorna false
**Log:**
```
💾 [PLANILHA] Salvando entrada: {...}
❌ [PLANILHA] Resultado saveStockEntry: FALHA
```

**Causa:** O código de barras já existe no banco ou houve erro na gravação.

**Possíveis soluções:**
1. **Código duplicado:** Verifique se o código já foi cadastrado antes
2. **Erro de conexão:** Verifique a conexão com Supabase no console
3. **Erro de permissão:** Verifique as Row-Level Security policies no Supabase

### ❌ Problema 4: Formato inválido
**Log:**
```
⚠️ Linha 2 tem apenas 2 colunas (mínimo 3)
```

**Causa:** A linha não tem as 3 colunas separadas por TAB.

**Solução:**
1. Certifique-se de copiar diretamente do Excel/Google Sheets (não digite manualmente)
2. As colunas devem ser separadas por TAB (não espaço)
3. Formato correto: `CÓDIGO[TAB]MODELO[TAB]CONTÊINER`

### ❌ Problema 5: Código inválido
**Log:**
```
⚠️ Linha 2: Código "ABC123" inválido (após limpar: "123")
```

**Causa:** O código não tem 7 ou 8 dígitos numéricos.

**Solução:**
1. Códigos devem ter exatamente 7 ou 8 dígitos
2. O sistema normaliza 7→8 dígitos automaticamente (adiciona zero à esquerda)
3. Remova letras ou caracteres especiais

## 🎯 Checklist de Validação

Execute estes passos para garantir que tudo está correto:

### Antes de colar a planilha:
- [ ] Modelos necessários estão cadastrados em "Cadastro de Modelos"
- [ ] Contêineres necessários estão cadastrados em "Cadastro de Contêineres"
- [ ] Console do navegador está aberto (F12)

### Ao colar a planilha:
- [ ] Planilha tem o cabeçalho na primeira linha
- [ ] Dados foram copiados diretamente do Excel/Google Sheets (preserva TAB)
- [ ] Códigos têm 7 ou 8 dígitos

### Após clicar em "Processar":
- [ ] Veja os logs no console
- [ ] Identifique onde está falhando (parsing, modelo, contêiner, ou save)
- [ ] Corrija conforme os logs indicam

## 📝 Exemplo de Planilha Válida

```
CÓDIGO	MODELO	CONTÊINER
5290731	30/65-18 Porsche Cup N3	GSILVA - WSCU 7032937
5290742	30/65-18 Porsche Cup N3	GSILVA - WSCU 7032937
290743	Porsche Cup	Container ABC
```

**Nota:** Os nomes de modelo e contêiner usam **busca parcial case-insensitive**:
- ✅ "30/65-18 Porsche Cup N3" encontra "30/65-18 Porsche Cup N3 991 Dianteiro"
- ✅ "porsche cup" encontra "30/65-18 Porsche Cup N3 991 Dianteiro"
- ✅ "GSILVA" encontra "GSILVA - WSCU 7032937"

## 🚨 Logs de Erro Adicionais

Se houver erros, eles aparecerão no console:

```
❌ [PLANILHA] Erros detalhados: [
  "Linha 2: Modelo 'XYZ' não encontrado",
  "Linha 3: Código 12345678 já cadastrado ou erro ao salvar"
]
```

E também em um toast (notificação) na tela.

## 🔧 Próximos Passos

1. **Execute o teste** com os logs ativados
2. **Copie os logs** do console
3. **Identifique o problema** baseado nos logs acima
4. **Corrija** e teste novamente

Se os logs mostrarem que `saveStockEntry` está retornando `true` mas os dados não aparecem no Supabase, o problema pode estar:
- Na função `saveStockEntry` em `/utils/storage.ts`
- Nas permissões RLS (Row-Level Security) do Supabase
- Na conexão com o banco de dados

Nesse caso, me avise com os logs específicos e podemos investigar mais a fundo!
