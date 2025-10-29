# 🚀 Roadmap de Melhorias - Porsche Cup Brasil 2025

## 📅 Planejamento Estratégico

**Última atualização:** 24 de Outubro de 2025  
**Versão atual:** 2.1 (Dashboard + Loading States)  
**Próxima versão:** 2.2 (Mobile Enhancements)

---

## ✅ CONCLUÍDO (Últimas 4 Sprints)

### Sprint 1: Dashboard Visual ✅
- [x] DashboardCharts.tsx completo
- [x] 4 tipos de gráficos (Linha, Pizza, Barras, Área)
- [x] 4 KPIs interativos
- [x] Integração Recharts
- [x] Responsivo mobile/desktop
- **Status:** ✅ 100% implementado

### Sprint 2: Loading States ✅
- [x] LoadingSpinner.tsx (4 variações)
- [x] LoadingSkeleton.tsx (10 skeletons)
- [x] ErrorState.tsx (5 tipos)
- [x] LoadingOverlay.tsx (fullscreen + inline)
- [x] Dashboard.tsx loading
- [x] Reports.tsx loading
- [x] TireModelRegistration.tsx loading
- [x] ContainerRegistration.tsx loading
- **Status:** ✅ 80% implementado (faltam 6 componentes simples)

### Sprint 3: Modo Rápido 🚀 ✅
- [x] Quick mode toggle
- [x] Auto-fill last used
- [x] Atalhos de teclado (A-G, 1-7)
- [x] Auto-submit 8 dígitos
- [x] Feedback visual imediato
- **Status:** ✅ 100% implementado

### Sprint 4: PWA & Mobile ✅
- [x] Service Worker
- [x] Manifest.json
- [x] Ícones (192x192, 512x512)
- [x] Install prompt
- [x] Offline support
- [x] Mobile navigation
- **Status:** ✅ 100% implementado

---

## 🔥 PRÓXIMAS MELHORIAS (Prioridade)

---

## 🎯 SPRINT 5: Melhorias Mobile-Specific (2-3 dias)

**Objetivo:** Transformar a experiência mobile em nível de app nativo

**Prioridade:** 🔴 ALTA  
**Impacto:** ⭐⭐⭐⭐⭐ (5/5)  
**Complexidade:** 🟡 MÉDIA (6-8 horas)  
**Prazo:** 2-3 dias

### Features:

#### 1. Bottom Sheet para Formulários Mobile 📱
**Tempo estimado:** 2 horas

**Descrição:**
- Substituir formulários fullscreen por bottom sheets em mobile
- Swipe down to dismiss
- Backdrop blur
- Smooth animations

**Componentes afetados:**
- TireStockEntry.tsx
- TireDiscard.tsx
- TireConsumption.tsx
- StatusRegistration.tsx

**Implementação:**
```tsx
// Novo componente: /components/BottomSheet.tsx
import { motion, AnimatePresence } from 'motion/react';

export function BottomSheet({ isOpen, onClose, children }) {
  return (
    <AnimatePresence>
      {isOpen && (
        <>
          {/* Backdrop */}
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            onClick={onClose}
            className="fixed inset-0 bg-black/40 z-40"
          />
          
          {/* Sheet */}
          <motion.div
            initial={{ y: '100%' }}
            animate={{ y: 0 }}
            exit={{ y: '100%' }}
            transition={{ type: 'spring', damping: 30 }}
            className="fixed bottom-0 left-0 right-0 z-50 bg-white rounded-t-3xl shadow-2xl max-h-[90vh] overflow-auto"
          >
            {/* Handle */}
            <div className="flex justify-center pt-3 pb-2">
              <div className="w-12 h-1.5 bg-gray-300 rounded-full" />
            </div>
            
            {/* Content */}
            <div className="p-6">
              {children}
            </div>
          </motion.div>
        </>
      )}
    </AnimatePresence>
  );
}
```

**Benefícios:**
- ✅ Mais nativo (iOS/Android style)
- ✅ Melhor UX em mobile
- ✅ Menos scroll necessário
- ✅ Gesture-based (swipe to close)

---

#### 2. Swipe Gestures 👆
**Tempo estimado:** 1.5 horas

**Descrição:**
- Swipe left/right em cards para ações rápidas
- Swipe to delete
- Swipe to edit
- Haptic feedback (vibration API)

**Implementação:**
```tsx
// Hook: /utils/useSwipeGesture.ts
import { useState } from 'react';

export function useSwipeGesture(onSwipeLeft, onSwipeRight) {
  const [touchStart, setTouchStart] = useState(null);
  const [touchEnd, setTouchEnd] = useState(null);

  const minSwipeDistance = 50;

  const onTouchStart = (e) => {
    setTouchEnd(null);
    setTouchStart(e.targetTouches[0].clientX);
  };

  const onTouchMove = (e) => {
    setTouchEnd(e.targetTouches[0].clientX);
  };

  const onTouchEnd = () => {
    if (!touchStart || !touchEnd) return;
    
    const distance = touchStart - touchEnd;
    const isLeftSwipe = distance > minSwipeDistance;
    const isRightSwipe = distance < -minSwipeDistance;
    
    if (isLeftSwipe) {
      onSwipeLeft();
      if (navigator.vibrate) navigator.vibrate(10);
    }
    if (isRightSwipe) {
      onSwipeRight();
      if (navigator.vibrate) navigator.vibrate(10);
    }
  };

  return {
    onTouchStart,
    onTouchMove,
    onTouchEnd,
  };
}
```

**Uso:**
```tsx
// Em qualquer card/item de lista
const { onTouchStart, onTouchMove, onTouchEnd } = useSwipeGesture(
  () => handleDelete(), // swipe left
  () => handleEdit()    // swipe right
);

<div
  onTouchStart={onTouchStart}
  onTouchMove={onTouchMove}
  onTouchEnd={onTouchEnd}
  className="card"
>
  {content}
</div>
```

---

#### 3. Pull to Refresh 🔄
**Tempo estimado:** 1 hora

**Descrição:**
- Pull down para atualizar listas
- Spinner animado no topo
- Apenas em mobile

**Implementação:**
```tsx
// Hook: /utils/usePullToRefresh.ts
export function usePullToRefresh(onRefresh) {
  const [isPulling, setIsPulling] = useState(false);
  const [pullDistance, setPullDistance] = useState(0);
  
  const threshold = 80; // 80px para trigger

  const handleTouchStart = (e) => {
    if (window.scrollY === 0) {
      startY = e.touches[0].clientY;
    }
  };

  const handleTouchMove = (e) => {
    if (window.scrollY === 0) {
      const currentY = e.touches[0].clientY;
      const distance = currentY - startY;
      
      if (distance > 0) {
        setPullDistance(Math.min(distance, threshold * 1.5));
        setIsPulling(distance > threshold);
      }
    }
  };

  const handleTouchEnd = async () => {
    if (isPulling) {
      await onRefresh();
      if (navigator.vibrate) navigator.vibrate(20);
    }
    setPullDistance(0);
    setIsPulling(false);
  };

  return { isPulling, pullDistance, handleTouchStart, handleTouchMove, handleTouchEnd };
}
```

---

#### 4. Touch Feedback Melhorado 💫
**Tempo estimado:** 1 hora

**Descrição:**
- Active states em todos botões/cards
- Ripple effect
- Vibration API feedback
- Scale animation on tap

**CSS:**
```css
/* globals.css */
.touch-active:active {
  transform: scale(0.97);
  opacity: 0.85;
  transition: all 0.1s ease;
}

.ripple {
  position: relative;
  overflow: hidden;
}

.ripple::after {
  content: '';
  position: absolute;
  top: 50%;
  left: 50%;
  width: 100px;
  height: 100px;
  background: rgba(255, 255, 255, 0.5);
  border-radius: 50%;
  transform: translate(-50%, -50%) scale(0);
  animation: ripple 0.6s ease-out;
}

@keyframes ripple {
  to {
    transform: translate(-50%, -50%) scale(4);
    opacity: 0;
  }
}
```

---

#### 5. Virtual Keyboard Handling 📱⌨️
**Tempo estimado:** 1.5 horas

**Descrição:**
- Auto-scroll quando keyboard abre
- Resize viewport
- Scroll to focused input
- Prevent zoom em inputs

**Implementação:**
```tsx
// Hook: /utils/useKeyboardAdjustment.ts
export function useKeyboardAdjustment() {
  useEffect(() => {
    const inputs = document.querySelectorAll('input, textarea, select');
    
    inputs.forEach(input => {
      input.addEventListener('focus', (e) => {
        setTimeout(() => {
          e.target.scrollIntoView({ 
            behavior: 'smooth', 
            block: 'center' 
          });
        }, 300); // Espera keyboard abrir
      });
    });

    // Detecta resize de keyboard
    window.visualViewport?.addEventListener('resize', () => {
      const activeElement = document.activeElement;
      if (activeElement && (activeElement.tagName === 'INPUT' || activeElement.tagName === 'TEXTAREA')) {
        activeElement.scrollIntoView({ block: 'center' });
      }
    });
  }, []);
}
```

---

### Resumo Sprint 5:

| Feature | Tempo | Impacto | Prioridade |
|---------|-------|---------|------------|
| Bottom Sheet | 2h | ⭐⭐⭐⭐⭐ | 🔴 Alta |
| Swipe Gestures | 1.5h | ⭐⭐⭐⭐ | 🔴 Alta |
| Pull to Refresh | 1h | ⭐⭐⭐ | 🟡 Média |
| Touch Feedback | 1h | ⭐⭐⭐⭐ | 🟡 Média |
| Keyboard Handling | 1.5h | ⭐⭐⭐⭐⭐ | 🔴 Alta |
| **TOTAL** | **7h** | | |

**ROI:** 🚀 ALTO - Transforma app em experiência nativa

---

## 🎯 SPRINT 6: Atalhos de Teclado Avançados (1-2 dias)

**Objetivo:** Navegação ultra-rápida para power users

**Prioridade:** 🔴 ALTA  
**Impacto:** ⭐⭐⭐⭐ (4/5)  
**Complexidade:** 🟢 BAIXA (4-6 horas)  
**Prazo:** 1-2 dias

### Features:

#### 1. Command Palette (Ctrl+K) ⌨️
**Tempo estimado:** 2 horas

**Descrição:**
- Cmd+K / Ctrl+K abre command palette
- Busca fuzzy em todas ações
- Navegação entre páginas
- Ações rápidas

**Implementação:**
```tsx
// /components/CommandPalette.tsx
import { useState, useEffect } from 'react';
import { Command } from './ui/command';

export function CommandPalette() {
  const [open, setOpen] = useState(false);

  useEffect(() => {
    const down = (e: KeyboardEvent) => {
      if (e.key === 'k' && (e.metaKey || e.ctrlKey)) {
        e.preventDefault();
        setOpen((open) => !open);
      }
    };

    document.addEventListener('keydown', down);
    return () => document.removeEventListener('keydown', down);
  }, []);

  return (
    <Command.Dialog open={open} onOpenChange={setOpen}>
      <Command.Input placeholder="Digite um comando ou busque..." />
      <Command.List>
        <Command.Group heading="Navegação">
          <Command.Item onSelect={() => navigate('/dashboard')}>
            Dashboard
          </Command.Item>
          <Command.Item onSelect={() => navigate('/stock-entry')}>
            Entrada de Estoque
          </Command.Item>
          {/* ... */}
        </Command.Group>
        
        <Command.Group heading="Ações">
          <Command.Item onSelect={() => handleNewEntry()}>
            Novo Pneu (Ctrl+N)
          </Command.Item>
          <Command.Item onSelect={() => handleExport()}>
            Exportar Relatório (Ctrl+E)
          </Command.Item>
        </Command.Group>
      </Command.List>
    </Command.Dialog>
  );
}
```

**Atalhos sugeridos:**
- `Ctrl+K` - Command palette
- `Ctrl+N` - Novo pneu
- `Ctrl+E` - Exportar
- `Ctrl+F` - Busca
- `Ctrl+/` - Help
- `Esc` - Fechar modals
- `G+D` - Ir para Dashboard (Vim-style)
- `G+S` - Ir para Stock Entry
- `G+R` - Ir para Reports

---

#### 2. Navegação por Teclado 🎮
**Tempo estimado:** 1.5 horas

**Descrição:**
- Tab navigation melhorada
- Arrow keys em listas/grids
- Enter to select
- Space to toggle

**Implementação:**
```tsx
// Hook: /utils/useKeyboardNavigation.ts
export function useKeyboardNavigation(items, onSelect) {
  const [selectedIndex, setSelectedIndex] = useState(0);

  useEffect(() => {
    const handleKey = (e: KeyboardEvent) => {
      switch(e.key) {
        case 'ArrowDown':
          e.preventDefault();
          setSelectedIndex(i => Math.min(i + 1, items.length - 1));
          break;
        case 'ArrowUp':
          e.preventDefault();
          setSelectedIndex(i => Math.max(i - 1, 0));
          break;
        case 'Enter':
          e.preventDefault();
          onSelect(items[selectedIndex]);
          break;
      }
    };

    document.addEventListener('keydown', handleKey);
    return () => document.removeEventListener('keydown', handleKey);
  }, [selectedIndex, items]);

  return selectedIndex;
}
```

---

#### 3. Help Overlay (?) 📖
**Tempo estimado:** 1 hour

**Descrição:**
- Pressione `?` para ver todos atalhos
- Overlay modal com lista
- Busca de atalhos
- Customização

**UI:**
```
┌─────────────────────────────────┐
│  Atalhos de Teclado             │
├─────────────────────────────────┤
│  Navegação                      │
│  ├─ Ctrl+K    Command Palette   │
│  ├─ G+D       Dashboard          │
│  └─ G+S       Stock Entry        │
│                                  │
│  Ações                          │
│  ├─ Ctrl+N    Novo Pneu         │
│  ├─ Ctrl+E    Exportar          │
│  └─ Ctrl+S    Salvar            │
│                                  │
│  [Fechar com Esc ou ?]          │
└─────────────────────────────────┘
```

---

#### 4. Atalhos Customizáveis ⚙️
**Tempo estimado:** 1.5 horas

**Descrição:**
- Settings page para customizar atalhos
- Salvar em localStorage
- Reset to defaults
- Import/Export config

---

### Resumo Sprint 6:

| Feature | Tempo | Impacto | Prioridade |
|---------|-------|---------|------------|
| Command Palette | 2h | ⭐⭐⭐⭐⭐ | 🔴 Alta |
| Keyboard Nav | 1.5h | ⭐⭐⭐⭐ | 🟡 Média |
| Help Overlay | 1h | ⭐⭐⭐ | 🟡 Média |
| Custom Shortcuts | 1.5h | ⭐⭐ | 🟢 Baixa |
| **TOTAL** | **6h** | | |

---

## 🎯 SPRINT 7-10: Features Adicionais

### Sprint 7: Busca Global 🔍
- Search bar global no header
- Busca fuzzy multi-module
- Resultados agrupados por tipo
- Histórico de buscas
- **Tempo:** 4-6 horas

### Sprint 8: Exportação Avançada 📊
- Excel export (xlsx)
- CSV com encoding correto
- PDF templates customizáveis
- Print view otimizada
- Scheduled exports
- **Tempo:** 6-8 horas

### Sprint 9: Temas e Personalização 🎨
- Dark mode completo
- Custom color schemes
- Layout preferences (compact/comfortable)
- Densidade de informação
- Salvar preferências
- **Tempo:** 8-10 horas

### Sprint 10: Notificações 🔔
- Toast notifications melhoradas
- Push notifications (PWA)
- Email notifications (Supabase)
- In-app notification center
- Preferences por tipo
- **Tempo:** 10-12 horas

---

## 📊 Visão Geral do Roadmap

### Cronograma Estimado

| Sprint | Feature | Tempo | Prazo | Status |
|--------|---------|-------|-------|--------|
| 1 | Dashboard Visual | 6h | ✅ Concluído | ✅ 100% |
| 2 | Loading States | 8h | ✅ 80% | 🔄 Em andamento |
| 3 | Modo Rápido | 4h | ✅ Concluído | ✅ 100% |
| 4 | PWA & Mobile | 6h | ✅ Concluído | ✅ 100% |
| **5** | **Mobile Enhancements** | **7h** | **2-3 dias** | ⏳ Próximo |
| **6** | **Keyboard Shortcuts** | **6h** | **1-2 dias** | ⏳ Próximo |
| 7 | Busca Global | 5h | 1-2 dias | 📅 Planejado |
| 8 | Exportação | 7h | 2-3 dias | 📅 Planejado |
| 9 | Temas | 9h | 3-4 dias | 📅 Planejado |
| 10 | Notificações | 11h | 4-5 dias | 📅 Planejado |

**Total estimado para Sprints 5-10:** ~45 horas (~6 dias de trabalho)

---

## 🎯 Recomendação Imediata

### Opção A: Completar Loading States (30 min)
**Prós:**
- ✅ Finaliza Sprint 2 (100%)
- ✅ Consistência visual
- ✅ Rápido (30 min)

**Contras:**
- ⚠️ Baixo impacto individual
- ⚠️ Não adiciona novas features

### Opção B: Iniciar Mobile Enhancements (Sprint 5)
**Prós:**
- ✅ Alto impacto (⭐⭐⭐⭐⭐)
- ✅ Features visíveis/wow factor
- ✅ Melhora UX drasticamente

**Contras:**
- ⚠️ Deixa Loading States 80%
- ⚠️ Mais tempo necessário

### Opção C: Keyboard Shortcuts (Sprint 6)
**Prós:**
- ✅ Power users adoram
- ✅ Produtividade++
- ✅ Relativamente rápido

**Contras:**
- ⚠️ Menor impacto visual
- ⚠️ Menos usuários usarão

---

## 💡 Sugestão Final

### 🏆 RECOMENDAÇÃO: Opção A + B Híbrida

1. **Primeiro (30 min):** Completar 6 componentes de Loading States
   - UserManagement.tsx
   - DataImport.tsx  
   - TireDiscard.tsx
   - TireConsumption.tsx
   - StockAdjustment.tsx
   - StatusRegistration.tsx

2. **Depois (7h):** Sprint 5 - Mobile Enhancements
   - Bottom Sheet
   - Swipe Gestures
   - Pull to Refresh
   - Touch Feedback
   - Keyboard Handling

**Justificativa:**
- ✅ Completa Sprint 2 (satisfação)
- ✅ Adiciona features de alto impacto
- ✅ Mobile-first strategy
- ✅ Experiência nativa

---

## 📝 Decisão?

**O que fazemos agora?**

1. ✅ **Completar Loading States** (30 min) + **Sprint 5 Mobile** (7h)
2. 🚀 **Ir direto para Sprint 5** (Mobile Enhancements)
3. ⌨️ **Sprint 6** (Keyboard Shortcuts)
4. 🔍 **Sprint 7** (Busca Global)
5. 💬 **Outra prioridade?**

---

**Desenvolvido por:** Sistema de IA  
**Data:** 24 de Outubro de 2025  
**Versão:** 2.1 → 2.2  
**Status:** ⏳ Aguardando decisão
