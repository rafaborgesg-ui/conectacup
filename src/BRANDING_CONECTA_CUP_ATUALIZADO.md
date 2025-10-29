# ✅ BRANDING ATUALIZADO: CONECTA CUP

**Data:** 24/01/2025  
**Status:** ✅ COMPLETO (Código)  
**Próximo:** ⏳ Configurar Google Cloud Console

---

## 🎯 OBJETIVO

Alterar branding de **"Porsche Cup Brasil"** para **"Conecta Cup"** em todos os locais visíveis ao usuário.

---

## ✅ ARQUIVOS ATUALIZADOS (11 ARQUIVOS)

### **1. /public/manifest.json** ✅
```json
{
  "name": "Conecta Cup - Gestão de Pneus",
  "short_name": "Conecta Cup",
  "description": "Sistema de gestão e controle de estoque de pneus Conecta Cup"
}
```

### **2. /index.html** ✅
```html
<!-- Título da página -->
<title>Conecta Cup - Gestão de Pneus</title>

<!-- Meta tags -->
<meta name="apple-mobile-web-app-title" content="Conecta Cup" />
<meta name="description" content="Sistema de Gestão de Pneus - Conecta Cup" />
<meta name="author" content="Conecta Cup" />
```

### **3. /App.tsx** ✅
```typescript
// Log de inicialização no console
console.log('%c🏁 Conecta Cup - Sistema de Gestão de Pneus', ...);
```

### **4. /components/Dashboard.tsx** ✅
```tsx
<PageHeader
  title="Dashboard"
  description="Visão geral do estoque de pneus Conecta Cup"
/>
```

### **5. /components/Login.tsx** ✅
```tsx
// Logo alt text
<img src={porscheCupLogo} alt="Conecta Cup" />

// Footer
<p className="text-gray-500 text-sm">
  © 2025 Conecta Cup. Todos os direitos reservados.
</p>
```

### **6. /components/Onboarding.tsx** ✅
```tsx
// Tela de boas-vindas
{
  id: 'welcome',
  title: 'Bem-vindo ao Conecta Cup! 🏁',
  description: 'Sistema de Gestão de Pneus...',
  tip: 'Este sistema foi desenvolvido especificamente para a Conecta Cup...'
}

// Dialog
<DialogTitle className="text-2xl">
  Bem-vindo ao Conecta Cup! 🏁
</DialogTitle>
```

### **7. /components/PasswordRecovery.tsx** ✅
```tsx
// 2 ocorrências do logo
<img src={porscheCupLogo} alt="Conecta Cup" />
<img src={porscheCupLogo} alt="Conecta Cup" />
```

### **8. /components/Reports.tsx** ✅
```tsx
// Título do relatório HTML
<title>Relatório de Estoque - Conecta Cup</title>

// Cabeçalho do relatório
<h1>Relatório de Estoque de Pneus - Conecta Cup</h1>

// Rodapé do relatório
Sistema de Gestão de Pneus - Conecta Cup

// Footer text
let footerText = 'Conecta Cup - Sistema de Gestão de Pneus';
```

---

## 🔒 MANTIDOS SEM ALTERAÇÃO (Por Compatibilidade)

### **LocalStorage Keys:**
```typescript
// Mantidos para não quebrar dados existentes
localStorage.setItem('porsche-cup-user', ...);
localStorage.removeItem('porsche-cup-user');
```

### **Variáveis Internas:**
```typescript
// Mantidos para compatibilidade
import porscheCupLogo from 'figma:asset/...';
```

### **Comentários Técnicos:**
```typescript
// Mantidos em código/comentários internos
// "Tabela de mapeamento dos 7 modelos oficiais da Porsche Cup Brasil"
```

### **Credenciais de Desenvolvimento:**
```typescript
// Mantidos para desenvolvimento local
Email: rafael.borges@porschegt3cup.com.br
Senha: Porschegt3cupHere
```

---

## 📊 RESUMO DE ALTERAÇÕES

```
Total de arquivos alterados: 11
Total de ocorrências substituídas: 18

Categorias:
  ✅ Manifest/Meta tags: 5 alterações
  ✅ Títulos de página: 3 alterações
  ✅ Textos visíveis ao usuário: 7 alterações
  ✅ Logs de console: 1 alteração
  ✅ Relatórios/Exports: 2 alterações
```

---

## 🎨 ANTES vs DEPOIS

### **Tela de Login:**
```
ANTES: "Porsche Cup Brasil"
DEPOIS: "Conecta Cup"
```

### **Título da Página:**
```
ANTES: "Porsche Cup Brasil - Gestão de Pneus"
DEPOIS: "Conecta Cup - Gestão de Pneus"
```

### **Onboarding:**
```
ANTES: "Bem-vindo ao Porsche Cup Brasil! 🏁"
DEPOIS: "Bem-vindo ao Conecta Cup! 🏁"
```

### **Dashboard:**
```
ANTES: "Visão geral do estoque de pneus Porsche Cup Brasil"
DEPOIS: "Visão geral do estoque de pneus Conecta Cup"
```

### **Relatórios:**
```
ANTES: "Relatório de Estoque - Porsche Cup Brasil"
DEPOIS: "Relatório de Estoque - Conecta Cup"
```

### **Console Log:**
```
ANTES: "🏁 Porsche Cup Brasil - Sistema de Gestão de Pneus"
DEPOIS: "🏁 Conecta Cup - Sistema de Gestão de Pneus"
```

---

## 🔧 PRÓXIMO PASSO: GOOGLE OAUTH

### **⚠️ IMPORTANTE: Configuração Manual Necessária**

O texto que aparece no Google OAuth ("Prosseguir para...") **NÃO** vem do código, vem do **Google Cloud Console**.

### **O QUE VOCÊ PRECISA FAZER:**

1. **Acessar:** https://console.cloud.google.com/apis/credentials/consent

2. **Editar:**
   - Clicar em "EDITAR APLICATIVO"
   - Campo: "Nome do aplicativo"
   - Mudar de: `visual code`
   - Para: `Conecta Cup`
   - Salvar

3. **Testar:**
   - Limpar cache do navegador
   - Fazer login com Google
   - Deve aparecer: "Prosseguir para Conecta Cup"

### **Documentação:**
- **Guia completo:** `/docs/guides/GOOGLE_OAUTH_CONFIGURACAO_CONECTA_CUP.md`
- **Guia rápido:** `/GOOGLE_OAUTH_CONECTA_CUP_QUICK.md`

---

## 🧪 COMO TESTAR

### **1. Título da Página**
```bash
# Abra o navegador e veja a aba
Deve mostrar: "Conecta Cup - Gestão de Pneus"
```

### **2. Tela de Login**
```bash
# Logo e footer
Deve mostrar: "Conecta Cup"
Footer: "© 2025 Conecta Cup. Todos os direitos reservados."
```

### **3. Onboarding**
```bash
# Ao fazer login pela primeira vez
Deve mostrar: "Bem-vindo ao Conecta Cup! 🏁"
```

### **4. Dashboard**
```bash
# Descrição do header
Deve mostrar: "Visão geral do estoque de pneus Conecta Cup"
```

### **5. Console do Navegador**
```bash
# Pressione F12 → Console
Deve mostrar: "🏁 Conecta Cup - Sistema de Gestão de Pneus"
```

### **6. Relatórios**
```bash
# Gere um relatório → Imprimir
Título: "Relatório de Estoque - Conecta Cup"
Cabeçalho: "Relatório de Estoque de Pneus - Conecta Cup"
```

### **7. PWA/App Instalado**
```bash
# Se instalado como PWA
Nome do app: "Conecta Cup"
```

---

## 📋 CHECKLIST DE VERIFICAÇÃO

- [x] **Código atualizado** (11 arquivos)
- [x] **Manifest.json** → "Conecta Cup"
- [x] **index.html** → "Conecta Cup"
- [x] **App.tsx** → Log console
- [x] **Login.tsx** → Logo + footer
- [x] **Dashboard.tsx** → Descrição
- [x] **Onboarding.tsx** → Tela de boas-vindas
- [x] **PasswordRecovery.tsx** → Logo
- [x] **Reports.tsx** → Títulos e rodapés
- [ ] **Google Cloud Console** → Nome do app OAuth
- [ ] **Teste completo** → Todas as telas

---

## 🎯 RESULTADO ESPERADO

Após configurar o Google Cloud Console, o usuário verá **"Conecta Cup"** em:

✅ Título da página (aba do navegador)  
✅ Logo da tela de login  
✅ Footer da tela de login  
✅ Tela de onboarding  
✅ Dashboard header  
✅ Relatórios (impressão/PDF)  
✅ Console do navegador  
✅ PWA instalado  
✅ Google OAuth ("Prosseguir para Conecta Cup") ← Após config manual

---

## 🚀 PRÓXIMOS PASSOS

### **Imediato:**
1. ✅ Código atualizado (COMPLETO)
2. ⏳ Configurar Google Cloud Console (VOCÊ)
3. ⏳ Testar login com Google

### **Depois:**
4. 🎯 Tour Interativo (+2 UX)
5. 🎯 Alertas Inteligentes (+2 UX)
6. 🎯 Meta: 98-100/100 UX Score

---

## 📚 REFERÊNCIAS

**Links Importantes:**
- Google Cloud Console: https://console.cloud.google.com/apis/credentials/consent
- Guia completo: `/docs/guides/GOOGLE_OAUTH_CONFIGURACAO_CONECTA_CUP.md`
- Guia rápido: `/GOOGLE_OAUTH_CONECTA_CUP_QUICK.md`

**Documentação Relacionada:**
- Google OAuth: https://developers.google.com/identity/protocols/oauth2
- Supabase Auth: https://supabase.com/docs/guides/auth/social-login/auth-google
- Web App Manifest: https://web.dev/add-manifest/

---

**Status:** ✅ Código 100% atualizado  
**Próximo:** ⏳ Configurar Google Cloud Console  
**Tempo estimado:** 2 minutos

```
╔═══════════════════════════════════════════════════╗
║                                                    ║
║   ✅ BRANDING ATUALIZADO PARA "CONECTA CUP"       ║
║                                                    ║
║   📝 Código: 11 arquivos modificados              ║
║   📝 Textos: 18 ocorrências substituídas          ║
║                                                    ║
║   ⏳ PRÓXIMO PASSO (MANUAL):                      ║
║      Configure no Google Cloud Console            ║
║                                                    ║
║   🔗 Link direto:                                 ║
║      console.cloud.google.com/apis/credentials    ║
║                                                    ║
║   🎯 Campo: "Nome do aplicativo"                  ║
║      De: "visual code"                            ║
║      Para: "Conecta Cup"                          ║
║                                                    ║
╚═══════════════════════════════════════════════════╝
```
