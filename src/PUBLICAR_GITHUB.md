# 🚀 Guia Rápido - Publicar Menu "Gestão de Carga" no GitHub

## ✅ Pré-requisitos

Antes de publicar, certifique-se de que:
- ✅ Você está no diretório raiz do projeto
- ✅ Git está instalado e configurado
- ✅ Você tem acesso ao repositório remoto
- ✅ Você está na branch correta

---

## 📋 Comandos Git - Passo a Passo

### 1️⃣ Verificar Status
```bash
git status
```

**Esperado:**
```
modified:   components/Sidebar.tsx
modified:   components/MobileNav.tsx
new file:   docs/releases/MENU_GESTAO_CARGA_IMPLEMENTADO.md
new file:   COMMIT_MESSAGE.md
new file:   PUBLICAR_GITHUB.md
```

---

### 2️⃣ Adicionar Arquivos Modificados

**Opção A - Adicionar todos os arquivos:**
```bash
git add .
```

**Opção B - Adicionar arquivos específicos:**
```bash
git add components/Sidebar.tsx
git add components/MobileNav.tsx
git add docs/releases/MENU_GESTAO_CARGA_IMPLEMENTADO.md
git add COMMIT_MESSAGE.md
git add PUBLICAR_GITHUB.md
```

---

### 3️⃣ Verificar Arquivos Staged
```bash
git status
```

**Esperado:**
```
Changes to be committed:
  modified:   components/Sidebar.tsx
  modified:   components/MobileNav.tsx
  new file:   docs/releases/MENU_GESTAO_CARGA_IMPLEMENTADO.md
  new file:   COMMIT_MESSAGE.md
  new file:   PUBLICAR_GITHUB.md
```

---

### 4️⃣ Fazer Commit

**Opção A - Commit simples:**
```bash
git commit -m "feat: Adiciona menu Gestão de Carga no Sidebar e Mobile Nav"
```

**Opção B - Commit detalhado (recomendado):**
```bash
git commit -F COMMIT_MESSAGE.md
```

**Opção C - Commit convencional completo:**
```bash
git commit -m "feat(navigation): adiciona menu Gestão de Carga

- Novo item de menu no Sidebar Desktop
- Nova seção no Menu Mobile
- Link externo para Google Apps Script
- Segurança com noopener e noreferrer
- Visível para todos os perfis
- Documentação completa adicionada

Refs: #gestao-carga
"
```

---

### 5️⃣ Verificar Commit
```bash
git log -1
```

ou

```bash
git show HEAD
```

---

### 6️⃣ Publicar no GitHub

**Opção A - Push direto (se você está na main/master):**
```bash
git push origin main
```

ou

```bash
git push origin master
```

**Opção B - Push em nova branch (recomendado):**
```bash
# Criar nova branch
git checkout -b feature/menu-gestao-carga

# Push da branch
git push origin feature/menu-gestao-carga
```

Depois, criar Pull Request no GitHub.

---

## 🔄 Workflow Completo (Copy-Paste)

### Para Branch Main/Master:
```bash
# 1. Verificar status
git status

# 2. Adicionar arquivos
git add components/Sidebar.tsx components/MobileNav.tsx docs/releases/MENU_GESTAO_CARGA_IMPLEMENTADO.md

# 3. Commit
git commit -m "feat(navigation): adiciona menu Gestão de Carga

- Novo menu no Sidebar Desktop e Mobile Nav
- Link para Google Apps Script
- Visível para todos os perfis
- Documentação completa"

# 4. Push
git push origin main
```

### Para Nova Branch (Recomendado):
```bash
# 1. Criar e mudar para nova branch
git checkout -b feature/menu-gestao-carga

# 2. Adicionar arquivos
git add components/Sidebar.tsx components/MobileNav.tsx docs/releases/MENU_GESTAO_CARGA_IMPLEMENTADO.md

# 3. Commit
git commit -m "feat(navigation): adiciona menu Gestão de Carga"

# 4. Push
git push origin feature/menu-gestao-carga

# 5. Criar Pull Request no GitHub UI
echo "Agora abra o GitHub e crie o Pull Request!"
```

---

## 📝 Mensagem de Pull Request (GitHub)

Se você criou uma branch, use esta mensagem no PR:

```markdown
# 🎯 Adiciona Menu "Gestão de Carga"

## Resumo
Implementa novo menu principal "Gestão de Carga" que abre aplicação externa do Google Apps Script.

## Mudanças
- ✅ Sidebar Desktop: Novo item "Gestão de Carga"
- ✅ Menu Mobile: Nova seção "Gestão de Carga"
- ✅ Ícone ClipboardList
- ✅ Link externo com segurança (noopener, noreferrer)
- ✅ Visível para todos os perfis

## Arquivos Modificados
- `components/Sidebar.tsx`
- `components/MobileNav.tsx`
- `docs/releases/MENU_GESTAO_CARGA_IMPLEMENTADO.md` (novo)

## Testes
- ✅ Desktop - Hover e Click
- ✅ Mobile - Touch e Close
- ✅ Abertura em nova aba
- ✅ Todos os perfis

## Screenshots
(Adicione prints do menu aqui)

## Checklist
- [x] Código testado localmente
- [x] Documentação atualizada
- [x] Sem breaking changes
- [x] Backward compatible
- [x] Segue padrões do projeto
```

---

## 🔍 Verificação Pós-Push

Após o push, verifique:

1. **GitHub Web:**
   - Acesse o repositório no GitHub
   - Confirme que o commit aparece
   - Verifique os arquivos modificados

2. **Status Local:**
   ```bash
   git status
   # Deve mostrar: "Your branch is up to date with 'origin/main'"
   ```

3. **Log Remoto:**
   ```bash
   git log origin/main -1
   ```

---

## 🆘 Solução de Problemas

### Erro: "Updates were rejected"
```bash
# Pull primeiro
git pull origin main --rebase

# Depois push
git push origin main
```

### Erro: "No upstream branch"
```bash
# Configurar upstream
git push --set-upstream origin feature/menu-gestao-carga
```

### Erro: "Permission denied"
```bash
# Verificar autenticação
git config --list | grep user

# Reconfigurar se necessário
git config user.name "Seu Nome"
git config user.email "seu@email.com"
```

### Desfazer Último Commit (antes do push)
```bash
# Manter alterações
git reset --soft HEAD~1

# Descartar alterações
git reset --hard HEAD~1
```

---

## 📊 Resumo de Arquivos

| Arquivo | Tipo | Descrição |
|---------|------|-----------|
| `components/Sidebar.tsx` | Modificado | Adiciona menu desktop |
| `components/MobileNav.tsx` | Modificado | Adiciona menu mobile |
| `docs/releases/MENU_GESTAO_CARGA_IMPLEMENTADO.md` | Novo | Documentação completa |
| `COMMIT_MESSAGE.md` | Novo | Mensagem de commit |
| `PUBLICAR_GITHUB.md` | Novo | Este guia |

---

## 🎯 Checklist Final

Antes de publicar:

- [ ] Código testado localmente
- [ ] Sem erros no console
- [ ] Funciona em desktop
- [ ] Funciona em mobile
- [ ] Link abre corretamente
- [ ] Documentação atualizada
- [ ] Commit message clara
- [ ] Branch correta selecionada

---

## 🚀 Comandos Rápidos (TL;DR)

**Push Direto:**
```bash
git add .
git commit -m "feat: adiciona menu Gestão de Carga"
git push origin main
```

**Com Branch:**
```bash
git checkout -b feature/menu-gestao-carga
git add .
git commit -m "feat: adiciona menu Gestão de Carga"
git push origin feature/menu-gestao-carga
```

---

## 📞 Próximos Passos

Após publicar:

1. ✅ Verificar no GitHub que o commit foi publicado
2. ✅ Criar Pull Request (se usou branch)
3. ✅ Solicitar code review (opcional)
4. ✅ Fazer merge (se aprovado)
5. ✅ Deploy em produção

---

**Boa sorte com a publicação! 🚀**

---

**Criado em:** 29 de Outubro de 2025  
**Versão:** 2.3.0  
**Projeto:** Conecta Cup
