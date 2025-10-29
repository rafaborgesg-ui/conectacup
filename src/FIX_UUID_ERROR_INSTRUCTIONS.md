# 🔧 Instruções para Corrigir Erro de UUID

## ❌ Erro Reportado

```
⚠️ ERRO DE PROGRAMAÇÃO: Componente frontend está enviando UUID ao invés de barcode de 8 dígitos
❌ UUID detectado no lugar de barcode: 0f0e10f6-aff5-4c19-ae6b-444e1945bf23
```

## 🎯 Causa Raiz

Apesar de você ter informado que limpou todos os 7560 registros, **este UUID específico ainda existe no banco de dados**. Isso pode acontecer por:

1. **Limite de 1000 registros do PostgREST**: Algumas queries padrão do Supabase retornam apenas os primeiros 1000 registros
2. **Cache do Supabase**: O Supabase pode estar cacheando resultados antigos
3. **Registro não foi alcançado pelo script**: O script de limpeza pode não ter processado todos os registros

## ✅ Solução Passo a Passo

### Passo 1: Verificar se o UUID ainda existe

No **Supabase Dashboard → SQL Editor**, execute:

```sql
-- Busca o UUID específico que está causando o erro
SELECT * FROM stock_entries 
WHERE barcode = '0f0e10f6-aff5-4c19-ae6b-444e1945bf23';
```

**Resultado esperado:**
- Se retornar **0 linhas**: O UUID não existe mais (problema é de cache)
- Se retornar **1+ linhas**: O UUID ainda existe e precisa ser deletado

---

### Passo 2A: Se o UUID AINDA EXISTE (resultado com linhas)

Execute este SQL para deletá-lo:

```sql
-- DELETA o registro com UUID corrompido
DELETE FROM stock_entries 
WHERE barcode = '0f0e10f6-aff5-4c19-ae6b-444e1945bf23';

-- Verifica se foi deletado
SELECT COUNT(*) as registros_restantes
FROM stock_entries 
WHERE barcode = '0f0e10f6-aff5-4c19-ae6b-444e1945bf23';
```

**Resultado esperado:** `registros_restantes = 0`

---

### Passo 2B: Se o UUID NÃO EXISTE (resultado 0 linhas)

O problema é **cache do frontend**. Limpe completamente:

1. **Abra o DevTools** (F12)
2. **Application → Storage → Clear site data**
3. **Recarregue a página** (Ctrl + Shift + R)
4. **Faça logout e login** novamente

---

### Passo 3: Verificação Completa do Banco

Execute o script completo de verificação:

```sql
-- No Supabase Dashboard → SQL Editor, execute:
```

Copie e cole o conteúdo de `/VERIFY_NO_UUID_BARCODES.sql`

**Resultados esperados:**
- ✅ Query 1: 0 registros (nenhum UUID)
- ✅ Query 2: `total_uuids = 0`
- ✅ Query 3: 0 registros (nenhum barcode inválido)
- ✅ Query 4: `percentual_validos = 100.00`
- ✅ Query 5: 0 registros (UUID específico não existe)

---

### Passo 4: Usar o Verificador de Integridade

Na aplicação, vá para:

**Ajuste de Estoque → Verificação de Integridade → Verificar Agora**

Isso executará uma verificação completa via interface e mostrará:
- Total de registros
- Barcodes válidos
- Barcodes inválidos
- Lista detalhada de registros corrompidos

**Resultado esperado:**
```
✅ Banco de Dados Saudável
Total de Registros: 7560
Barcodes Válidos: 7560
Barcodes Inválidos: 0
```

---

## 🔍 Se o Problema Persistir

### Cenário 1: UUID não está no banco, mas erro continua

**Causa:** Cache do Supabase ou do browser

**Solução:**
1. Limpe o cache do navegador completamente
2. Faça logout e login novamente
3. Se usar PWA, desinstale e reinstale o app
4. Limpe o Service Worker:
   - DevTools → Application → Service Workers → Unregister

### Cenário 2: Muitos UUIDs ainda aparecem na verificação

**Causa:** O script de limpeza não processou todos os registros

**Solução:** Execute a limpeza em BATCH completa:

```sql
-- ATENÇÃO: Este script deleta TODOS os registros com barcode UUID
-- Faça backup antes!

-- 1. Conta quantos serão deletados
SELECT COUNT(*) as total_para_deletar
FROM stock_entries
WHERE barcode ~ '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$';

-- 2. Se estiver OK, delete
DELETE FROM stock_entries
WHERE barcode ~ '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$';

-- 3. Verifica que foram todos deletados
SELECT COUNT(*) as uuids_restantes
FROM stock_entries
WHERE barcode ~ '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$';
```

**Resultado esperado:** `uuids_restantes = 0`

---

## 📊 Validações do Frontend

O código frontend já possui validações que **filtram automaticamente** registros com UUID:

### Em `storage.ts` (linhas 375-394)
```typescript
// Filtra registros com barcode corrompido
const uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
const validEntries = allEntries.filter((entry: StockEntry) => {
  if (uuidRegex.test(entry.barcode)) {
    console.error('❌ REGISTRO CORROMPIDO - barcode é UUID:', entry.barcode);
    return false; // Filtra fora
  }
  return true;
});
```

### Em `TireDiscard.tsx` (linhas 92-111)
```typescript
// Filtra registros corrompidos antes de exibir
const validEntries = allEntries.filter((entry: any) => {
  if (uuidRegex.test(entry.barcode)) {
    console.error('❌ [TireDiscard] REGISTRO CORROMPIDO:', entry.barcode);
    return false;
  }
  return true;
});
```

**Isso significa:** Mesmo que existam registros com UUID no banco, eles **não devem aparecer** na interface.

---

## 🎯 Próximos Passos

1. ✅ Execute `/VERIFY_NO_UUID_BARCODES.sql` no Supabase
2. ✅ Se encontrar UUIDs, delete-os com o SQL do Passo 2A
3. ✅ Limpe o cache do navegador (Ctrl + Shift + Delete)
4. ✅ Recarregue a aplicação (Ctrl + Shift + R)
5. ✅ Use o Verificador de Integridade na UI
6. ✅ Se tudo estiver OK, o erro não deve mais aparecer

---

## 📞 Suporte

Se após seguir todos os passos o erro persistir:

1. Tire um screenshot da tela de **Verificação de Integridade**
2. Exporte o resultado de `/VERIFY_NO_UUID_BARCODES.sql`
3. Verifique o **Console do navegador** (F12) para logs adicionais
4. Procure por erros no formato: `❌ REGISTRO CORROMPIDO DETECTADO`

---

## ✅ Confirmação de Sucesso

Você saberá que o problema foi resolvido quando:

1. ✅ Query SQL não retorna nenhum UUID
2. ✅ Verificador de Integridade mostra "100% saudável"
3. ✅ Nenhum erro de UUID aparece no console
4. ✅ Todas as operações (entrada, descarte, movimentação) funcionam sem erros
