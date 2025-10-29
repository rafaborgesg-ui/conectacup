# ✅ CORREÇÃO: Contagem de Status com Muitos Registros

## 🔍 Problema Identificado

Quando a base de dados `stock_entries` alcançou muitos registros, os **status não estavam sendo contados corretamente** nas páginas Dashboard e Relatórios.

### Causa Raiz

O Dashboard estava contando **TODOS os registros** (`allEntries`) incluindo pneus **descartados** ao invés de contar apenas os **registros ativos** (`activeEntries`).

O Reports estava contando **TODOS os registros** (`entries`) sem respeitar os **filtros aplicados** (temporada, etapa, piloto, status).

### Código Problemático

#### Dashboard.tsx (linha 172)
```typescript
// ❌ ERRADO - Contava TODOS incluindo descartados
const countWithStatus = (allEntries || []).filter(e => e.status === status.name).length;

const containersWithStatus = new Set(
  (allEntries || [])
    .filter(e => e.status === status.name)
    .map(e => e.container_id)
).size;
```

#### Reports.tsx (linha 321)
```typescript
// ❌ ERRADO - Usava entries ao invés de filteredEntriesByStatus
const statusSummary = entries.reduce((acc: { [key: string]: { count: number; color: string } }, entry) => {
  // ...
}, {});
```

### Impacto

- ✅ Card "Total de Pneus" estava **CORRETO** (usava `activeEntries`)
- ❌ Cards de **status individuais** estavam **INCORRETOS** (incluíam descartados)
- ❌ Gráfico de **status no Reports** estava **INCORRETO** (não respeitava filtros)

**Exemplo:**
- Total real de pneus ativos: **150**
- Total de pneus "Novo": **120** (contando descartados também)
- ❌ **Inconsistência:** 120 > 150 não faz sentido!

## ✅ Solução Implementada

### 1. Dashboard.tsx - Usa `activeEntries`

```typescript
// ✅ CORRETO - Conta apenas pneus ATIVOS (exclui descartados)
const countWithStatus = activeEntries.filter(e => e.status === status.name).length;

// Conta containers únicos com pneus ATIVOS deste status
const containersWithStatus = new Set(
  activeEntries
    .filter(e => e.status === status.name)
    .map(e => e.container_id)
).size;
```

**O que são `activeEntries`?**

São os pneus que **NÃO** estão descartados:

```typescript
// Linha 75-79 do Dashboard.tsx
const activeEntries = (allEntries || []).filter(entry => 
  entry.status !== 'Descartado DSI' && 
  entry.status !== 'Descarte DSI' && 
  entry.status !== 'Descarte'
);
```

### 2. Reports.tsx - Usa `filteredEntriesByStatus`

```typescript
// ✅ CORRETO - Usa filteredEntriesByStatus que respeita todos os filtros
const statusSummary = filteredEntriesByStatus.reduce((acc: { [key: string]: { count: number; color: string } }, entry) => {
  const statusName = entry.status || 'Sem Status';
  if (!acc[statusName]) {
    const statusInfo = tireStatuses.find(s => s.name === statusName);
    acc[statusName] = {
      count: 0,
      color: statusInfo?.color || '#6B7280'
    };
  }
  acc[statusName].count += 1;
  return acc;
}, {});
```

**O que é `filteredEntriesByStatus`?**

São os pneus filtrados por:
- Status
- Temporada (ano)
- Etapa
- Piloto

```typescript
// Linha 238-245 do Reports.tsx
const filteredEntriesByStatus = entries.filter(entry => {
  const matchesStatus = filterStatus === 'all' || entry.status === filterStatus;
  const matchesSeason = filterSeason === 'all' || (entry as any).ano?.toString() === filterSeason.toString();
  const matchesStage = filterStage === 'all' || (entry as any).etapa?.toString() === filterStage.toString();
  const matchesPilot = filterPilot === 'all' || (entry as any).pilot === filterPilot;
  
  return matchesStatus && matchesSeason && matchesStage && matchesPilot;
});
```

## 📊 Resultado Esperado

### Dashboard

**Antes:**
```
Total de Pneus: 150 ✅ (correto)
Status "Novo": 180 ❌ (incluía descartados)
Status "Em Uso": 90 ❌ (incluía descartados)
Status "Descartado DSI": 40 ❌ (não deveria aparecer)
```

**Depois:**
```
Total de Pneus: 150 ✅
Status "Novo": 80 ✅ (apenas ativos)
Status "Em Uso": 50 ✅ (apenas ativos)
Status "Descartado DSI": 0 ✅ (pois são filtrados)
```

### Reports

**Antes (filtro de status = "Novo"):**
```
Gráfico de Status:
- Novo: 180 ❌ (ignorava filtro)
- Em Uso: 90 ❌ (ignorava filtro)
- Descartado: 40 ❌ (ignorava filtro)
```

**Depois (filtro de status = "Novo"):**
```
Gráfico de Status:
- Novo: 80 ✅ (respeita filtro)
```

## 🎯 Validação

Para validar a correção:

### 1. Dashboard

1. Abra o **Dashboard**
2. Verifique o console:
   ```
   📊 Dashboard - Dados carregados do Supabase:
      - Total de entradas: 190 (incluindo descartados)
      - Entradas ativas: 150 (excluindo descartados)
   ```
3. **Verifique a consistência:**
   - Soma de todos os cards de status ≤ "Total de Pneus"
   - Cards de status descartado devem ter valor **0** ou **não aparecer**

### 2. Reports

1. Abra **Relatórios & Histórico**
2. **Sem filtros:** Verifique se os números fazem sentido
3. **Com filtro de status "Novo":** O gráfico deve mostrar **apenas** pneus "Novo"
4. **Com filtro de temporada "2025":** O gráfico deve mostrar apenas dados de 2025

### 3. Teste de Integridade

Execute este teste:

```typescript
// No console do navegador
const cards = document.querySelectorAll('[data-card-type]');
let totalFromCards = 0;

cards.forEach(card => {
  const type = card.getAttribute('data-card-type');
  if (type !== 'total') { // Ignora o card "Total"
    const value = parseInt(card.querySelector('[data-card-value]')?.textContent || '0');
    totalFromCards += value;
    console.log(`${type}: ${value}`);
  }
});

const totalCard = parseInt(document.querySelector('[data-card-type="total"] [data-card-value]')?.textContent || '0');

console.log('Soma dos cards:', totalFromCards);
console.log('Card Total:', totalCard);
console.log('Consistente?', totalFromCards <= totalCard ? '✅' : '❌');
```

## 📝 Observações Importantes

### Pneus Descartados

Os seguintes status são considerados **descartados** e **NÃO** aparecem no Dashboard:
- `Descartado DSI`
- `Descarte DSI`
- `Descarte`

**Mas "Descarte Piloto" NÃO é descartado!** Ele aparece normalmente.

### Performance

A correção **NÃO afeta a performance** porque:
- `activeEntries` já estava sendo calculado (linha 75)
- `filteredEntriesByStatus` já estava sendo calculado (linha 238)
- Apenas mudamos qual array usar na contagem

### Compatibilidade

A correção é **100% compatível** com:
- Todos os status cadastrados
- Filtros de temporada, etapa e piloto
- Paginação
- Exportação de PDF
- Gráficos

## 🔧 Arquivos Modificados

1. `/components/Dashboard.tsx`
   - Linha 172: `allEntries` → `activeEntries`
   - Linha 176-179: `allEntries` → `activeEntries`

2. `/components/Reports.tsx`
   - Linha 321: `entries` → `filteredEntriesByStatus`

## ✅ Checklist de Validação

- [ ] Dashboard mostra contagens consistentes
- [ ] Soma dos cards de status ≤ Total de Pneus
- [ ] Cards de status descartado têm valor 0
- [ ] Gráfico de status no Reports respeita filtros
- [ ] Filtro de status funciona corretamente
- [ ] Filtro de temporada funciona corretamente
- [ ] Filtro de etapa funciona corretamente
- [ ] Filtro de piloto funciona corretamente
- [ ] Não há erros no console

## 🚀 Próximos Passos (Opcional)

### Melhoria 1: Adicionar Validação Visual

Adicionar um badge de inconsistência se a soma dos status for maior que o total:

```typescript
{totalFromAllCards > totalActive && (
  <Alert variant="destructive">
    ⚠️ Inconsistência detectada: Soma dos status ({totalFromAllCards}) > Total ({totalActive})
  </Alert>
)}
```

### Melhoria 2: Adicionar Tooltip Explicativo

Nos cards de status, adicionar tooltip explicando:
- "Apenas pneus ativos (exclui descartados)"

### Melhoria 3: Log de Debug

Adicionar logs detalhados no Dashboard:

```typescript
console.log(`📊 [Dashboard] Status "${status.name}":`);
console.log(`   - Total no banco: ${allEntries.filter(e => e.status === status.name).length}`);
console.log(`   - Apenas ativos: ${activeEntries.filter(e => e.status === status.name).length}`);
console.log(`   - Descartados: ${(allEntries.filter(e => e.status === status.name).length - activeEntries.filter(e => e.status === status.name).length)}`);
```

## 📅 Histórico

- **Data:** 2025-01-21
- **Problema:** Contagens de status inconsistentes com muitos registros
- **Causa:** Dashboard contava todos os registros incluindo descartados
- **Solução:** Usar `activeEntries` no Dashboard e `filteredEntriesByStatus` no Reports
- **Status:** ✅ Resolvido
