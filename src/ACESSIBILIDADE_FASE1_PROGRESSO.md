# ✅ FASE 1 - ACESSIBILIDADE WCAG 2.1 AA
## Progresso de Implementação

**Data:** 24 de Outubro de 2025  
**Status:** 🟢 3/5 Completo | 🟡 2/5 Em Andamento

---

## ✅ IMPLEMENTAÇÕES CONCLUÍDAS

### 1. ✅ useFocusTrap Hook
**Arquivo:** `/utils/useFocusTrap.ts`  
**Status:** ✅ COMPLETO

**O que faz:**
- Mantém o foco dentro de modais/dialogs
- Permite navegação Tab/Shift+Tab circular
- Foca automaticamente no primeiro elemento ao abrir
- WCAG 2.1 - Guideline 2.4.3: Focus Order

**Aplicado em:**
- ✅ Dialog (`/components/ui/dialog.tsx`)
- ✅ AlertDialog (`/components/ui/alert-dialog.tsx`)
- ✅ Sheet (`/components/ui/sheet.tsx`)
- ✅ BottomSheet (`/components/BottomSheet.tsx`)

---

### 2. ✅ LiveRegion Component
**Arquivo:** `/components/ui/live-region.tsx`  
**Status:** ✅ COMPLETO

**O que faz:**
- Anuncia mudanças dinâmicas para leitores de tela
- Suporta politeness: 'polite' | 'assertive' | 'off'
- Auto-limpeza de mensagens após delay
- WCAG 2.1 - Guideline 4.1.3: Status Messages

**Uso:**
```tsx
import { LiveRegion, useLiveRegion } from './components/ui/live-region';

// Opção 1: Component direto
<LiveRegion message={statusMessage} politeness="polite" />

// Opção 2: Hook
const { announce, LiveRegion } = useLiveRegion();
announce('Pneu registrado com sucesso');
<LiveRegion />
```

**Próximos passos:** Aplicar em componentes-chave (ver seção "Tarefas Pendentes")

---

### 3. ✅ Skip Links
**Arquivo:** `/App.tsx`  
**Status:** ✅ COMPLETO

**O que faz:**
- Permite usuários de teclado pular navegação
- Visível apenas quando focado com Tab
- Link direto para conteúdo principal (#main-content)
- WCAG 2.1 - Guideline 2.4.1: Bypass Blocks

**Implementação:**
```tsx
// Skip link (invisível até focar)
<a href="#main-content" className="sr-only focus:not-sr-only ...">
  Pular para conteúdo principal
</a>

// Main content com id
<main id="main-content" tabIndex={-1}>
  {/* conteúdo */}
</main>
```

---

## 🟡 TAREFAS PENDENTES

### 4. 🟡 Ajustar Contraste de Cores
**Status:** 🟡 AGUARDANDO IMPLEMENTAÇÃO  
**Prioridade:** ALTA  
**Tempo Estimado:** 2-3 horas

**Problema:**
`text-gray-500` (#6B7280) em fundo branco = **4.6:1** ❌  
WCAG AA requer: **4.5:1 mínimo**

**Solução:**
Substituir `text-gray-500` por `text-gray-600` (#4B5563) = **7.1:1** ✅

**Arquivos para modificar:**

#### A. Dashboard.tsx
```tsx
// ANTES ❌
<p className="text-gray-500 text-sm mb-1">Total de Pneus</p>

// DEPOIS ✅
<p className="text-gray-600 text-sm mb-1">Total de Pneus</p>
```

**Locais:**
- [ ] Lines ~30-50: Descrições de cards estatísticos
- [ ] Lines ~200-250: Labels de gráficos
- [ ] Lines ~300-350: Hints de filtros

#### B. Reports.tsx
```tsx
// ANTES ❌
<Label className="text-sm text-gray-500">Período</Label>

// DEPOIS ✅
<Label className="text-sm text-gray-600">Período</Label>
```

**Locais:**
- [ ] Lines ~50-100: Labels de filtros
- [ ] Lines ~150-200: Hints de inputs
- [ ] Lines ~250-300: Rodapés de tabelas

#### C. TireStockEntry.tsx
```tsx
// ANTES ❌
<p className="text-xs text-gray-500">Digite ou escaneie 8 dígitos</p>

// DEPOIS ✅
<p className="text-xs text-gray-600">Digite ou escaneie 8 dígitos</p>
```

**Locais:**
- [ ] Lines ~100-150: Hints de campos de entrada
- [ ] Lines ~200-250: Instruções de uso
- [ ] Lines ~300-350: Mensagens de ajuda

#### D. Outros Componentes
- [ ] `/components/TireDiscard.tsx` - Hints e labels
- [ ] `/components/TireMovement.tsx` - Instruções
- [ ] `/components/StockAdjustment.tsx` - Descrições
- [ ] `/components/ContainerRegistration.tsx` - Labels
- [ ] `/components/TireModelRegistration.tsx` - Hints

#### E. Atualizar globals.css
```css
/* styles/globals.css - ADICIONAR */

/* ✅ WCAG 2.1 AA - Contraste Adequado */
.text-muted {
  color: #4B5563; /* gray-600 - Contraste 7.1:1 */
}

/* Use text-gray-500 APENAS para textos grandes (18px+) */
.text-subtle {
  color: #6B7280; 
  font-size: 1.125rem; /* 18px mínimo */
}
```

**Comando de busca (para ajudar):**
```bash
# Encontrar todas as ocorrências de text-gray-500
grep -r "text-gray-500" components/ --include="*.tsx"
```

---

### 5. 🟡 Adicionar ARIA Labels em Botões Icon-Only
**Status:** 🟡 AGUARDANDO IMPLEMENTAÇÃO  
**Prioridade:** ALTA  
**Tempo Estimado:** 2-3 horas

**Problema:**
Botões com apenas ícones não têm rótulos para leitores de tela

**Solução:**
Adicionar `aria-label` e `title` em todos os botões icon-only

**Template de correção:**
```tsx
// ANTES ❌
<button onClick={handleDelete}>
  <Trash2 size={18} />
</button>

// DEPOIS ✅
<button 
  onClick={handleDelete}
  aria-label="Excluir pneu"
  title="Excluir pneu"
  className="p-2 hover:bg-red-50 rounded-lg transition-colors"
>
  <Trash2 size={18} aria-hidden="true" />
</button>
```

**Arquivos para modificar:**

#### A. StockAdjustment.tsx
**Botões de ação em linhas da tabela**

```tsx
// Linha ~250
<button 
  onClick={() => handleEdit(entry.id)}
  aria-label="Editar entrada"
  title="Editar entrada"
>
  <Edit size={18} aria-hidden="true" />
</button>

<button 
  onClick={() => handleDelete(entry.id)}
  aria-label="Excluir entrada"
  title="Excluir entrada"
>
  <Trash2 size={18} aria-hidden="true" />
</button>
```

**Locais:**
- [ ] Linha ~250: Botões Edit/Delete em cada linha
- [ ] Linha ~300: Botões de filtro
- [ ] Linha ~350: Botões de exportação

#### B. Reports.tsx
**Botões de filtro e exportação**

```tsx
// Linha ~150
<button 
  onClick={handleExport}
  aria-label="Exportar relatório"
  title="Exportar relatório"
>
  <Download size={18} aria-hidden="true" />
</button>

<button 
  onClick={handleFilter}
  aria-label="Abrir filtros"
  title="Abrir filtros"
>
  <Filter size={18} aria-hidden="true" />
</button>

<button 
  onClick={handleRefresh}
  aria-label="Atualizar dados"
  title="Atualizar dados"
>
  <RefreshCw size={18} aria-hidden="true" />
</button>
```

**Locais:**
- [ ] Linha ~150: Botões de ação do cabeçalho
- [ ] Linha ~200: Botões de ordenação de colunas
- [ ] Linha ~250: Botões de ação em linhas

#### C. Dashboard.tsx
**Ícones de ações rápidas**

```tsx
// Linha ~100
<button 
  onClick={() => handleCardClick('total')}
  aria-label="Ver detalhes do total de pneus"
  title="Ver detalhes do total de pneus"
>
  <Package size={24} aria-hidden="true" className="text-[#D50000]" />
</button>

<button 
  onClick={handleRefreshDashboard}
  aria-label="Atualizar dashboard"
  title="Atualizar dashboard"
>
  <RefreshCw size={18} aria-hidden="true" />
</button>
```

**Locais:**
- [ ] Linha ~100: Ícones de cards estatísticos
- [ ] Linha ~200: Botões de ação rápida
- [ ] Linha ~300: Controles de gráficos

#### D. TireStockEntry.tsx
**Botões de atalho (A-G, 1-7)**

```tsx
// Linha ~200
{tireModels.map((model, index) => (
  <button
    key={model.id}
    onClick={() => handleQuickSelect(model.id)}
    aria-label={`Selecionar modelo ${model.name} (Atalho ${shortcutMode === 'letters' ? String.fromCharCode(65 + index) : index + 1})`}
    title={`${model.name} - Atalho ${shortcutMode === 'letters' ? String.fromCharCode(65 + index) : index + 1}`}
    className={cn(
      "h-12 px-4 rounded-lg font-medium transition-all",
      selectedModel === model.id
        ? "bg-[#D50000] text-white"
        : "bg-white hover:bg-gray-50 border border-gray-200"
    )}
  >
    <span aria-hidden="true">
      {shortcutMode === 'letters' 
        ? String.fromCharCode(65 + index) 
        : index + 1}
    </span>
  </button>
))}

<button
  onClick={() => setShowScanner(true)}
  aria-label="Abrir scanner de código de barras"
  title="Abrir scanner de código de barras"
>
  <Camera size={20} aria-hidden="true" />
</button>

<button
  onClick={() => setShowBulkEntry(true)}
  aria-label="Entrada em massa"
  title="Entrada em massa"
>
  <Upload size={20} aria-hidden="true" />
</button>
```

**Locais:**
- [ ] Linha ~200: Botões de seleção rápida de modelos
- [ ] Linha ~250: Botão de scanner
- [ ] Linha ~300: Botão de entrada em massa
- [ ] Linha ~350: Toggle de modo rápido

#### E. Outros Componentes
- [ ] `/components/TireDiscard.tsx` - Botões de ação
- [ ] `/components/TireMovement.tsx` - Botões de navegação
- [ ] `/components/ContainerRegistration.tsx` - Botões de gerenciamento
- [ ] `/components/MobileNav.tsx` - Ícones de navegação mobile
- [ ] `/components/Sidebar.tsx` - Ícones de menu desktop
- [ ] `/components/ExportMenu.tsx` - Botões de exportação

**Comando de busca (para ajudar):**
```bash
# Encontrar botões que provavelmente precisam de aria-label
grep -r "onClick.*<[A-Z][a-z]*.*size=" components/ --include="*.tsx"
```

---

## 📊 RESUMO DE PROGRESSO

| Tarefa | Status | Tempo | Prioridade |
|--------|--------|-------|------------|
| 1. useFocusTrap Hook | ✅ Completo | - | - |
| 2. LiveRegion Component | ✅ Completo | - | - |
| 3. Skip Links | ✅ Completo | - | - |
| 4. Ajustar Contraste | 🟡 Pendente | 2-3h | ALTA |
| 5. ARIA Labels | 🟡 Pendente | 2-3h | ALTA |

**Total Estimado:** 4-6 horas restantes

---

## 🎯 PRÓXIMOS PASSOS

### Passo 1: Ajustar Contraste (Recomendado começar aqui)
1. Abrir `/styles/globals.css`
2. Adicionar classes `.text-muted` e `.text-subtle`
3. Fazer busca global por `text-gray-500`
4. Substituir por `text-gray-600` em textos pequenos (<18px)
5. Testar visualmente em todos os módulos

### Passo 2: Adicionar ARIA Labels
1. Começar por `StockAdjustment.tsx` (mais botões)
2. Depois `Reports.tsx`
3. Depois `Dashboard.tsx`
4. Depois `TireStockEntry.tsx`
5. Finalizar com componentes menores

### Passo 3: Aplicar LiveRegion
1. Adicionar em `TireStockEntry.tsx` para anunciar registros
2. Adicionar em `TireDiscard.tsx` para anunciar descartes
3. Adicionar em `TireMovement.tsx` para anunciar movimentações
4. Adicionar em `StockAdjustment.tsx` para anunciar ajustes

### Passo 4: Testar Acessibilidade
1. Usar navegador apenas com teclado (Tab, Shift+Tab, Enter, Esc)
2. Testar com leitor de tela (NVDA no Windows / VoiceOver no Mac)
3. Executar Lighthouse Accessibility Audit
4. Verificar contraste com WebAIM Contrast Checker

---

## 🛠️ FERRAMENTAS DE TESTE

### Navegação por Teclado
**Teclas principais:**
- `Tab` - Próximo elemento focável
- `Shift + Tab` - Elemento anterior
- `Enter / Space` - Ativar botão/link
- `Esc` - Fechar modal/dialog
- Setas - Navegar em listas/menus

### Leitores de Tela
**Windows:** NVDA (gratuito)
- Download: https://www.nvaccess.org/
- Atalho: `NVDA + N` para abrir menu

**Mac:** VoiceOver (nativo)
- Atalho: `Cmd + F5` para ativar

**Chrome Extension:** Screen Reader (para testes rápidos)

### Lighthouse Audit
1. Abrir DevTools (F12)
2. Aba "Lighthouse"
3. Selecionar "Accessibility"
4. Clicar "Generate report"
5. Meta: **95+ score**

### Contrast Checker
- WebAIM: https://webaim.org/resources/contrastchecker/
- Inserir:
  - Foreground: #6B7280 (gray-500) ou #4B5563 (gray-600)
  - Background: #FFFFFF (branco)
- Verificar: WCAG AA Normal Text (4.5:1 mínimo)

---

## ✅ CHECKLIST FINAL

### Contraste de Cores
- [ ] Atualizar `globals.css` com classes `.text-muted` e `.text-subtle`
- [ ] Dashboard.tsx - substituir text-gray-500
- [ ] Reports.tsx - substituir text-gray-500
- [ ] TireStockEntry.tsx - substituir text-gray-500
- [ ] TireDiscard.tsx - substituir text-gray-500
- [ ] TireMovement.tsx - substituir text-gray-500
- [ ] StockAdjustment.tsx - substituir text-gray-500
- [ ] Outros componentes - substituir text-gray-500
- [ ] Testar contraste com WebAIM

### ARIA Labels
- [ ] StockAdjustment.tsx - botões Edit/Delete
- [ ] Reports.tsx - botões Export/Filter/Refresh
- [ ] Dashboard.tsx - ícones de cards e ações
- [ ] TireStockEntry.tsx - botões A-G, Scanner, Bulk
- [ ] TireDiscard.tsx - botões de ação
- [ ] TireMovement.tsx - botões de navegação
- [ ] MobileNav.tsx - ícones de navegação
- [ ] Sidebar.tsx - ícones de menu
- [ ] ExportMenu.tsx - botões de exportação
- [ ] Testar com leitor de tela

### LiveRegion (Opcional para Fase 1)
- [ ] TireStockEntry.tsx - anunciar registros
- [ ] TireDiscard.tsx - anunciar descartes
- [ ] TireMovement.tsx - anunciar movimentações
- [ ] StockAdjustment.tsx - anunciar ajustes

### Testes Finais
- [ ] Navegação completa por teclado
- [ ] Skip link funciona (Tab na primeira tecla)
- [ ] Focus trap em todos os modais
- [ ] Lighthouse Accessibility Score 95+
- [ ] Teste com NVDA/VoiceOver

---

**Status Geral:** 🟢 60% Completo  
**Próxima Ação:** Ajustar contraste de cores  
**Tempo Restante:** 4-6 horas

