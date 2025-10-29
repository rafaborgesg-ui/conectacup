# 🔧 Instruções para Corrigir Status de Descarte

## 🎯 Problema Identificado

Você está vendo este aviso na página **Relatórios & Histórico de Descarte**:

```
⚠️ ATENÇÃO: Existem pneus no estoque mas nenhum com status "Descartado DSI"
💡 Verifique se os pneus foram descartados com o status correto
```

Isso acontece porque **os dados existentes no banco de dados** estão usando status antigos como:
- `"Descarte"` (muito antigo)
- `"Descarte DSI"` (intermediário)

O sistema agora usa o status **`"Descartado DSI"`** (nome correto e definitivo).

---

## ✅ Solução Rápida (3 minutos)

### Passo 1: Acessar o Supabase SQL Editor

Clique neste link (abre em nova aba):
👉 **[Supabase SQL Editor](https://supabase.com/dashboard/project/nflgqugaabtxzifyhjor/sql)**

### Passo 2: Copiar e Executar o Script

1. **Abra o arquivo** `MIGRATION_STATUS_COMPLETA.sql` (está na raiz do projeto)
2. **Copie TODO o conteúdo** do arquivo
3. **Cole no SQL Editor** do Supabase
4. **Clique em "Run"** (ou pressione Ctrl+Enter)

### Passo 3: Verificar o Resultado

O script vai exibir várias mensagens. Você deve ver:

```sql
✅ RESULTADO FINAL
status              | quantidade
--------------------|----------
Novo                | XXX
Pneu CUP            | XXX
Descartado DSI      | XXX  ← Deve aparecer aqui!
...
```

✅ **Se aparecer "Descartado DSI" com quantidade > 0**: Sucesso! Vá para o Passo 4.

❌ **Se NÃO aparecer**: Algo deu errado. Veja a seção "Problemas Comuns" abaixo.

### Passo 4: Recarregar a Aplicação

1. Volte para a aplicação Porsche Cup
2. **Recarregue a página** com **Ctrl+F5** (Windows) ou **Cmd+Shift+R** (Mac)
3. Acesse **"Relatórios & Histórico de Descarte"**

✅ **Agora os pneus descartados devem aparecer!**

---

## 🔍 O Que o Script Faz?

O script `MIGRATION_STATUS_COMPLETA.sql` executa 6 passos:

1. **📊 Diagnóstico Inicial**: Mostra todos os status atuais no banco
2. **🔍 Backup Visual**: Lista os registros que serão atualizados
3. **📈 Atualização**: Converte todos os status antigos para "Descartado DSI"
4. **✅ Verificação**: Confirma que a migração funcionou
5. **📋 Atualiza Tabela de Status**: Garante que "Descartado DSI" está cadastrado
6. **🎯 Verificação Final**: Mostra o resultado completo

---

## 🚨 Problemas Comuns

### ❌ "Nenhum registro foi atualizado"

**Causa**: Não existem pneus descartados no banco (você ainda não descartou nenhum).

**Solução**: 
1. Use o módulo **"Descarte de Pneus"**
2. Descarte alguns pneus de teste
3. Volte para **"Relatórios & Histórico"** para ver os resultados

---

### ❌ "permission denied" ou erro de acesso

**Causa**: Você não tem permissão de admin no Supabase.

**Solução**:
1. Faça login no Supabase com a conta de administrador
2. Ou peça para alguém com acesso executar o script

---

### ❌ "relation 'tire_status' does not exist"

**Causa**: A tabela `tire_status` não foi criada ainda.

**Solução**:
1. Execute primeiro: `SETUP_DATABASE.sql` (setup completo do banco)
2. Depois execute: `MIGRATION_STATUS_COMPLETA.sql`

---

## 🔄 Compatibilidade Retroativa

**IMPORTANTE:** Enquanto você não executar o script SQL, **o sistema continua funcionando!**

O código foi atualizado para aceitar **qualquer variação** do status de descarte:
- ✅ `"Descartado DSI"` (novo e correto)
- ✅ `"Descarte DSI"` (antigo, mas aceito)
- ✅ `"Descarte"` (muito antigo, mas aceito)

Isso significa que:
- ✅ Você pode descartar pneus normalmente
- ✅ Novos descartes usarão "Descartado DSI"
- ✅ Descartes antigos continuam visíveis
- ⚠️ Mas é **recomendado executar o script** para padronizar tudo

---

## 📊 Status Oficiais do Sistema

Após a migração, estes são os status oficiais:

| Status | Cor | Descrição |
|--------|-----|-----------|
| **Novo** | 🔵 Azul | Pneu novo, ainda não utilizado |
| **Pneu CUP** | 🟢 Verde | Pneu em uso na Porsche Cup |
| **Descartado DSI** | 🔴 Vermelho | **Pneu descartado do estoque (DSI)** ← Correto! |
| **Descarte Piloto** | 🟠 Laranja | Pneu descartado por piloto |
| **Piloto** | 🟣 Roxo | Pneu alocado para piloto específico |

---

## ✅ Checklist Pós-Migração

Após executar o script SQL:

- [ ] ✅ Recarreguei a aplicação (Ctrl+F5)
- [ ] ✅ Acessei "Relatórios & Histórico de Descarte"
- [ ] ✅ Os pneus descartados aparecem corretamente
- [ ] ✅ O alerta amarelo não aparece mais
- [ ] ✅ Console mostra logs com "Descartado DSI"
- [ ] ✅ Novos descartes usam "Descartado DSI"

---

## 🆘 Precisa de Ajuda?

Se nada disso funcionou:

1. **Copie os logs do console** do navegador (F12 → Console)
2. **Copie o resultado do script SQL** do Supabase
3. **Entre em contato** com a equipe de desenvolvimento
4. **Ou abra um ticket** com essas informações

---

## 📝 Notas Técnicas

- **Nome Correto**: `"Descartado DSI"` (com "Descartado" e não "Descarte")
- **Tabela**: `stock_entries`
- **Coluna**: `status`
- **Schema**: `public`
- **Script**: `MIGRATION_STATUS_COMPLETA.sql`

---

**Última Atualização:** 2025-10-19  
**Versão do Sistema:** 2.0 (Supabase)
