# 🚨 CORREÇÃO CRÍTICA: Limite de 5000 Registros

## Problema Identificado

O Dashboard e outros componentes estavam carregando apenas **5000 de 7676 pneus** cadastrados no Supabase devido a um limite excessivamente baixo aplicado nas queries.

### Sintomas
- Dashboard mostrando "Total de Pneus: 5000" quando existem 7676 no banco
- Contagens de status incorretas
- Dados incompletos em relatórios

### Causa Raiz
Durante otimização anterior para evitar timeouts, aplicamos `.limit(5000)` em todas as queries principais, mas isso estava **cortando dados** ao invés de apenas otimizar performance.

## Solução Aplicada

Aumentamos o limite de **5000 para 10000** em todos os componentes e utilitários:

### Arquivos Corrigidos

1. ✅ **`/components/Dashboard.tsx`** (linha 79)
2. ✅ **`/components/Reports.tsx`**
3. ✅ **`/components/DiscardReports.tsx`**
4. ✅ **`/components/TireDiscard.tsx`**
5. ✅ **`/components/TireStatusChange.tsx`**
6. ✅ **`/components/ContainerGridMap.tsx`**
7. ✅ **`/utils/storage.ts`** (linha 387)
8. ✅ **`/utils/optimizedQueries.ts`** (linha 486)

### Query Antes (INCORRETA)
```typescript
const { data: allEntries, error: allError } = await supabase
  .from('stock_entries')
  .select('*', { count: 'exact' })
  .order('created_at', { ascending: false })
  .limit(5000); // ❌ Cortava dados em 5000
```

### Query Depois (CORRIGIDA)
```typescript
const { data: allEntries, error: allError } = await supabase
  .from('stock_entries')
  .select('*', { count: 'exact' })
  .order('created_at', { ascending: false })
  .limit(10000); // ✅ Comporta todos os 7676 registros
```

## Validação

Após a correção, você deve ver:

1. **Dashboard**: Total de Pneus = 7676 (ou o total real no banco)
2. **Contagens de Status**: Valores corretos para cada status
3. **Relatórios**: Dados completos

## Performance

O limite de 10000 é seguro porque:
- É maior que o total atual de registros (7676)
- Mantém margem para crescimento
- Evita timeouts (limite testado anteriormente era 49999 e causava timeout)
- É muito menor que o limite problemático anterior

## Próximos Passos

Se o estoque crescer além de 10000 registros, considerar:
1. Implementar paginação server-side
2. Usar virtualização de tabelas (já implementada em alguns componentes)
3. Implementar cache inteligente com invalidação
4. Considerar agregações do lado do servidor para estatísticas

## Data da Correção
**25 de outubro de 2025**

## Status
✅ **RESOLVIDO** - Todos os componentes atualizados
