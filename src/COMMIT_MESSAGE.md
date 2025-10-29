# feat: Adiciona menu "Gestão de Carga" no Sidebar e Mobile Nav

## 🎯 Resumo

Implementado novo menu principal "Gestão de Carga" que abre aplicação externa do Google Apps Script em nova aba.

## ✨ Funcionalidades Adicionadas

### Sidebar Desktop (`/components/Sidebar.tsx`)
- ✅ Novo item de menu "Gestão de Carga" com ícone ClipboardList
- ✅ Posicionado como primeiro item do menu para fácil acesso
- ✅ Link externo configurado para Google Apps Script
- ✅ Abre em nova aba com segurança (noopener, noreferrer)

### Menu Mobile (`/components/MobileNav.tsx`)
- ✅ Nova seção "Gestão de Carga" no topo do menu
- ✅ Mesmo ícone e comportamento do desktop
- ✅ Fecha menu automaticamente após clicar
- ✅ Separador visual para organização

## 🔧 Detalhes Técnicos

**URL Configurada:**
```
https://script.google.com/a/porschegt3cup.com.br/macros/s/
AKfycbzs06M_vQcA34boc3ciyd9LzUzsYN3aNIXGZd-SfCsygtWAv07sc8K3ngt2UE0-cr9C/exec
```

**Ícone:** ClipboardList (lucide-react)

**Segurança:**
- `window.open()` com `noopener` e `noreferrer`
- Isolamento de contexto entre aplicações

## 📱 Responsividade

- **Desktop (≥1024px):** Menu lateral fixo
- **Mobile (<1024px):** Drawer deslizante

## 🔐 Permissões

- Visível para todos os perfis (Operador, Coordenador, Administrador)
- Links externos sempre visíveis por padrão

## 🧪 Testado

- ✅ Desktop - Hover e Click
- ✅ Mobile - Touch e Menu Close
- ✅ Abertura em nova aba
- ✅ Segurança (noopener, noreferrer)
- ✅ Todos os perfis de acesso

## 📄 Arquivos Modificados

```
modified:   components/Sidebar.tsx
modified:   components/MobileNav.tsx
new file:   docs/releases/MENU_GESTAO_CARGA_IMPLEMENTADO.md
```

## 🎨 UX/UI

- Hover suave (200ms transition)
- Background semi-transparente no hover
- Separadores visuais para hierarquia
- Touch target otimizado (≥44px)

## 📊 Impacto

**Score:** Mantém 94/100  
**Breaking Changes:** Nenhum  
**Backward Compatibility:** ✅ Total

---

**Tipo:** Feature  
**Escopo:** Navigation, UI  
**Versão:** 2.3.0  
**Data:** 2025-10-29
