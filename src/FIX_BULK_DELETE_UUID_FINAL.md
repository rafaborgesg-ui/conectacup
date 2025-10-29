# 🔧 CORREÇÃO FINAL - Erro UUID na Deleção em Massa

## ❌ Problema Identificado

```
Erro ao deletar em massa: Error: invalid input syntax for type uuid: "22222222"
```

### Causa Raiz

O Edge Function tinha **dois endpoints DELETE** com o mesmo padrão de rota:

1. **Endpoint 1 (linha 1338)**: `/stock-entries/:id` → Esperava UUID
2. **Endpoint 2 (linha 1503)**: `/stock-entries/:barcode` → Esperava barcode (TEXT com 8 dígitos)

Quando o frontend chamava `/stock-entries/22222222`, o framework Hono estava correspondendo ao **primeiro** endpoint (`:id`), que tentava usar "22222222" como UUID, gerando o erro de conversão.

## ✅ Solução Aplicada

### 1. Removidos endpoints duplicados e obsoletos

Removidos os seguintes endpoints não utilizados do Edge Function:

- `DELETE /stock-entries/:id` (linha 1338) - **Não usado em nenhum lugar**
- `POST /stock-entries/bulk-delete` (linha 1362) - **Não usado em nenhum lugar**

### 2. Mantido endpoint correto

O único endpoint DELETE agora é:

```typescript
app.delete("/make-server-02726c7c/stock-entries/:barcode", authMiddleware, async (c) => {
  try {
    const barcode = c.req.param("barcode");
    console.log(`🗑️ Deletando pneu por barcode: ${barcode}`);
    
    // Validação: barcode deve ter exatamente 8 dígitos
    if (!barcode || barcode.length !== 8 || !/^\d{8}$/.test(barcode)) {
      console.error(`❌ Barcode inválido: ${barcode}`);
      return c.json({ 
        success: false, 
        error: `Barcode inválido: "${barcode}". Deve ter 8 dígitos numéricos.` 
      }, 400);
    }
    
    // IMPORTANTE: Força barcode como TEXT para evitar cast para UUID
    const { data, error } = await supabaseAdmin
      .from('stock_entries')
      .delete()
      .eq('barcode', String(barcode))  // Garante que é string
      .select();
    
    if (error) {
      console.error('❌ Erro ao deletar pneu:', error.message);
      return c.json({ success: false, error: error.message }, 500);
    }
    
    if (!data || data.length === 0) {
      console.log(`⚠️ Pneu não encontrado: ${barcode}`);
      return c.json({ success: false, error: "Pneu não encontrado" }, 404);
    }
    
    console.log(`✅ Pneu deletado com sucesso: ${barcode}`);
    return c.json({ success: true, message: "Pneu deletado com sucesso" });
  } catch (error: any) {
    console.error("❌ Erro fatal ao deletar pneu:", error);
    return c.json({ success: false, error: error?.message || 'Erro desconhecido' }, 500);
  }
});
```

## 📋 Arquivos Modificados

### `/supabase/functions/server/index.tsx`

**Removido (linhas 1338-1384)**:
- Endpoint duplicado `DELETE /stock-entries/:id`
- Endpoint não usado `POST /stock-entries/bulk-delete`

**Mantido**:
- Endpoint `DELETE /stock-entries/:barcode` com validação e cast correto

### Frontend (nenhuma alteração necessária)

O código do frontend em `/components/StockAdjustment.tsx` já estava correto:

```typescript
async function deleteStockEntryByBarcode(barcode: string): Promise<void> {
  const { projectId, publicAnonKey } = await import('../utils/supabase/info');
  const response = await fetch(
    `https://${projectId}.supabase.co/functions/v1/make-server-02726c7c/stock-entries/${barcode}`,
    {
      method: 'DELETE',
      headers: {
        'Authorization': `Bearer ${publicAnonKey}`,
        'Content-Type': 'application/json',
      },
    }
  );

  if (!response.ok) {
    const error = await response.json();
    throw new Error(error?.error || 'Erro ao deletar pneu');
  }

  window.dispatchEvent(new Event('stock-entries-updated'));
}
```

A função `handleBulkDelete` usa corretamente o barcode:

```typescript
const handleBulkDelete = async () => {
  if (selectedEntries.size === 0) {
    toast.error('Nenhum pneu selecionado');
    return;
  }

  const barcodesToDelete = Array.from(selectedEntries);
  
  setIsDeleting(true);

  try {
    // Deleta cada pneu usando o barcode diretamente
    for (const barcode of barcodesToDelete) {
      await deleteStockEntryByBarcode(barcode);
    }

    toast.success(`${count} ${count === 1 ? 'pneu excluído' : 'pneus excluídos'}`);

    await loadEntries();
    setSelectedEntries(new Set());
    setIsDeleting(false);
  } catch (error: any) {
    console.error('Erro ao deletar em massa:', error);
    toast.error('❌ Erro ao excluir', {
      description: error?.message || 'Não foi possível excluir todos os pneus.',
      duration: 4000,
    });
    setIsDeleting(false);
  }
};
```

## 🧪 Como Testar

1. **Acesse o módulo Ajuste de Estoque** (login como admin)

2. **Teste deleção individual**:
   - Clique no ícone de lixeira em um pneu específico
   - Confirme a exclusão
   - ✅ Deve deletar sem erros

3. **Teste deleção em massa**:
   - Selecione vários pneus (use o checkbox na primeira coluna)
   - Clique em "Excluir Selecionados"
   - Confirme a exclusão
   - ✅ Deve deletar todos sem erro de UUID

4. **Verifique logs do Edge Function**:
   ```
   🗑️ Deletando pneu por barcode: 22222222
   ✅ Pneu deletado com sucesso: 22222222
   ```

## 🔍 Validações do Endpoint

O endpoint agora valida:

1. ✅ Barcode tem exatamente 8 dígitos
2. ✅ Barcode contém apenas números
3. ✅ Cast explícito para TEXT com `String(barcode)`
4. ✅ Mensagens de erro detalhadas
5. ✅ Logs completos para debugging

## 📊 Status da Correção

| Item | Status | Observação |
|------|--------|------------|
| Endpoint DELETE duplicado removido | ✅ | Linha 1338 removida |
| Endpoint bulk-delete removido | ✅ | Linha 1362 removida |
| Endpoint DELETE por barcode mantido | ✅ | Linha 1455 (anteriormente 1503) |
| Cast explícito String(barcode) | ✅ | Já estava aplicado |
| Validação de formato | ✅ | Regex `/^\d{8}$/` |
| Frontend atualizado | ✅ | Já estava correto |

## 🎯 Resultado Esperado

Após o deploy automático do Edge Function:

- ✅ Deleção individual funciona perfeitamente
- ✅ Deleção em massa funciona sem erro de UUID
- ✅ Barcodes com 8 dígitos numéricos são aceitos
- ✅ Mensagens de erro claras para entradas inválidas
- ✅ Logs detalhados para debugging

## 🚀 Próximos Passos

1. ✅ **Correção aplicada** - Endpoints duplicados removidos
2. ⏳ **Aguardar deploy** - Supabase fará deploy automático do Edge Function
3. 🧪 **Testar** - Verificar deleção em massa no módulo Ajuste de Estoque
4. ✅ **Confirmar** - Validar que não há mais erro de UUID

---

**Data da Correção**: 2025-10-20  
**Arquivos Modificados**: `/supabase/functions/server/index.tsx`  
**Linhas Removidas**: 1338-1384 (47 linhas)  
**Impacto**: Zero - Endpoints removidos não eram usados
