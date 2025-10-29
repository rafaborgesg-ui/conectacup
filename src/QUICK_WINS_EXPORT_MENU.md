# 📊 Quick Win: Adicionar Export Menu

## 🎯 Objetivo
Substituir botão de exportação simples por ExportMenu rico em 2 componentes.

## ⏱️ Tempo: 10 minutos

---

## 1. Reports.tsx (5 min)

### Estado Atual
```tsx
// Botão simples de Excel
<Button onClick={handleExportExcel}>
  <FileSpreadsheet className="w-4 h-4 mr-2" />
  Exportar Excel
</Button>
```

### Substituir por ExportMenu

#### 1. Adicionar import
```tsx
import { ExportMenu } from './ExportMenu';
import type { ExportFormat, ExportOptions } from './ExportMenu';
```

#### 2. Preparar colunas
```tsx
const exportColumns = [
  { id: 'barcode', label: 'Código de Barras', required: true },
  { id: 'model', label: 'Modelo', required: true },
  { id: 'container', label: 'Contêiner' },
  { id: 'status', label: 'Status' },
  { id: 'season', label: 'Temporada' },
  { id: 'stage', label: 'Etapa' },
  { id: 'pilot', label: 'Piloto' },
  { id: 'championship', label: 'Campeonato' },
  { id: 'category', label: 'Categoria' },
  { id: 'date', label: 'Data de Entrada' }
];
```

#### 3. Implementar handler
```tsx
const handleExport = async (format: ExportFormat, options: ExportOptions) => {
  const dataToExport = filteredEntries.map(entry => {
    const row: any = {};
    
    // Adiciona apenas colunas selecionadas
    if (options.selectedColumns.includes('barcode')) {
      row.barcode = entry.barcode;
    }
    if (options.selectedColumns.includes('model')) {
      row.model = tireModels.find(m => m.id === entry.tire_model_id)?.name;
    }
    if (options.selectedColumns.includes('container')) {
      row.container = containers.find(c => c.id === entry.container_id)?.name;
    }
    if (options.selectedColumns.includes('status')) {
      row.status = tireStatuses.find(s => s.id === entry.status)?.name;
    }
    // ... outras colunas
    
    return row;
  });

  if (format === 'excel') {
    await exportStockToExcel(
      dataToExport, 
      'Relatório de Estoque',
      options.includeHeaders,
      options.includeTimestamp
    );
  } else if (format === 'pdf') {
    await exportToPDF(dataToExport, options);
  } else if (format === 'csv') {
    await exportToCSV(dataToExport, options);
  } else if (format === 'print') {
    window.print();
  }
};
```

#### 4. Substituir botão
```tsx
// REMOVER botão simples
// ADICIONAR:
<ExportMenu
  onExport={handleExport}
  totalRecords={filteredEntries.length}
  columns={exportColumns}
  variant="default"
  size="default"
/>
```

---

## 2. DiscardReports.tsx (5 min)

### Implementação rápida

```tsx
import { ExportMenu } from './ExportMenu';

const exportColumns = [
  { id: 'barcode', label: 'Código', required: true },
  { id: 'model', label: 'Modelo', required: true },
  { id: 'reason', label: 'Motivo' },
  { id: 'date', label: 'Data' },
  { id: 'responsible', label: 'Responsável' }
];

const handleExport = async (format, options) => {
  // Similar ao Reports.tsx
  const data = discardedTires.map(tire => /* ... */);
  
  if (format === 'excel') {
    await exportToExcel(data, 'Relatório de Descartes', options);
  }
  // ... outros formatos
};

// No render:
<ExportMenu
  onExport={handleExport}
  totalRecords={discardedTires.length}
  columns={exportColumns}
/>
```

---

## 📈 Resultado

### Antes
```
❌ Apenas Excel
❌ Sem opções de customização
❌ Sem feedback de progresso
❌ Exporta sempre tudo
```

### Depois
```
✅ 4 formatos (Excel, PDF, CSV, Print)
✅ Quick export (1 clique)
✅ Seleção de colunas
✅ Opções de cabeçalho/rodapé/timestamp
✅ Feedback de progresso animado
✅ Mobile-friendly dialog
```

---

## 🎯 Features Desbloqueadas

1. **Quick Export (1 clique)**
   - Excel, PDF, CSV, Print
   - Sem configuração

2. **Exportação Personalizada**
   - Escolhe colunas
   - Configura headers/footer
   - Adiciona timestamp

3. **Feedback Visual**
   - Barra de progresso
   - Animação de sucesso
   - Erros claros

4. **Mobile UX**
   - Dialog responsivo
   - Touch-friendly
   - Scroll otimizado

---

## ✅ Checklist

- [ ] Reports.tsx com ExportMenu
- [ ] DiscardReports.tsx com ExportMenu
- [ ] Testar 4 formatos
- [ ] Verificar seleção de colunas
- [ ] Testar em mobile

---

## ⏱️ Tempo Total: 10 minutos
## 💰 Impacto: ALTO
## 🎯 ROI: 12x (funcionalidade rica rapidamente)
