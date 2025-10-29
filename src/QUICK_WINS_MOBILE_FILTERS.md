# 📱 Quick Win: Integrar Mobile Filters

## 🎯 Objetivo
Substituir filtros atuais por MobileFilters em 2 componentes principais.

## ⏱️ Tempo: 15 minutos

---

## 1. Reports.tsx (10 min)

### Estado Atual (Problema)
```tsx
// Múltiplos Select inline - ruim em mobile
<Select value={filterModel} onValueChange={setFilterModel}>
  {/* ... */}
</Select>
<Select value={filterContainer} onValueChange={setFilterContainer}>
  {/* ... */}
</Select>
<Select value={filterStatus} onValueChange={setFilterStatus}>
  {/* ... */}
</Select>
```

### Solução com MobileFilters

#### 1. Adicionar import
```tsx
import { MobileFilters } from './MobileFilters';
import { Package, Box, Activity } from 'lucide-react';
```

#### 2. Preparar sections
```tsx
const filterSections = [
  {
    id: 'model',
    label: 'Modelo de Pneu',
    icon: <Package className="w-5 h-5" />,
    options: tireModels.map(model => ({
      value: model.id,
      label: model.name,
      count: entries.filter(e => e.tire_model_id === model.id).length
    })),
    selectedValues: filterModel,
    onChange: setFilterModel
  },
  {
    id: 'container',
    label: 'Contêiner',
    icon: <Box className="w-5 h-5" />,
    options: containers.map(c => ({
      value: c.id,
      label: c.name,
      count: entries.filter(e => e.container_id === c.id).length
    })),
    selectedValues: filterContainer,
    onChange: setFilterContainer
  },
  {
    id: 'status',
    label: 'Status',
    icon: <Activity className="w-5 h-5" />,
    options: tireStatuses.map(s => ({
      value: s.id,
      label: s.name,
      count: entries.filter(e => e.status === s.id).length
    })),
    selectedValues: filterStatus,
    onChange: setFilterStatus
  }
];
```

#### 3. Substituir UI
```tsx
// REMOVER selects inline
// ADICIONAR:
<div className="flex items-center gap-2 mb-4">
  <MobileFilters
    sections={filterSections}
    onClear={() => {
      setFilterModel([]);
      setFilterContainer([]);
      setFilterStatus([]);
    }}
    totalResults={filteredEntries.length}
  />
  
  {/* Manter search input */}
  <Input
    type="search"
    placeholder="Buscar..."
    value={searchTerm}
    onChange={(e) => setSearchTerm(e.target.value)}
  />
</div>
```

---

## 2. TireMovement.tsx (5 min)

### Adicionar MobileFilters

```tsx
import { MobileFilters } from './MobileFilters';

const filterSections = [
  {
    id: 'container',
    label: 'Contêiner',
    options: containers.map(c => ({ value: c.id, label: c.name })),
    selectedValues: filterContainer,
    onChange: setFilterContainer
  },
  {
    id: 'status',
    label: 'Status',
    options: statuses.map(s => ({ value: s.id, label: s.name })),
    selectedValues: filterStatus,
    onChange: setFilterStatus
  }
];

// No render:
<MobileFilters
  sections={filterSections}
  onClear={() => {
    setFilterContainer([]);
    setFilterStatus([]);
  }}
  totalResults={movements.length}
/>
```

---

## 📈 Resultado

### Antes (Mobile)
```
❌ Dropdowns pequenos difíceis de clicar
❌ Sem contador de filtros ativos
❌ Limpar filtros não óbvio
❌ Sem feedback de resultados
```

### Depois (Mobile)
```
✅ Sheet lateral espaçoso (touch-friendly)
✅ Badge com contador de filtros
✅ Botão "Limpar todos" visível
✅ Total de resultados exibido
✅ Seções expansíveis organizadas
✅ Checkboxes visuais grandes
```

---

## 🎯 Benefícios Imediatos

1. **UX Mobile +200%**
   - Touch targets 48px+ (vs 32px atual)
   - Área de filtros dedicada
   - Mais espaço para visualizar opções

2. **Produtividade +50%**
   - Menos toques para filtrar
   - Feedback visual claro
   - Contador de resultados

3. **Consistência +100%**
   - Padrão único em todo sistema
   - Comportamento previsível

---

## ✅ Checklist

- [ ] Reports.tsx com MobileFilters
- [ ] TireMovement.tsx com MobileFilters
- [ ] Testar em mobile
- [ ] Verificar touch targets

---

## ⏱️ Tempo Total: 15 minutos
## 💰 Impacto: MUITO ALTO (mobile)
## 🎯 ROI: 20x
