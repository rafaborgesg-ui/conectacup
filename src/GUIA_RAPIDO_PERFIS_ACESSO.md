# 🚀 GUIA RÁPIDO: Sistema de Perfis de Acesso

## ⚡ 3 MINUTOS PARA COMEÇAR

### **1️⃣ CRIAR UM PERFIL PERSONALIZADO**

**Cenário:** Você quer criar um perfil "Mecânico" que só pode registrar entrada de pneus e consultar.

```
1. Vá em "Gerenciar Usuários"
2. No formulário, clique "⚙️ Gerenciar Perfis"
3. Preencha:
   Nome: "Mecânico"
   Descrição: "Registro de entrada e consultas"
   
4. Selecione PÁGINAS:
   ☑ Dashboard
   ☑ Entrada de Estoque
   ☑ Relatórios
   
5. Selecione FUNCIONALIDADES:
   ☑ Criar Entrada
   ☑ Visualizar Relatórios
   
6. Clique "Adicionar"
```

✅ **Pronto!** Perfil "Mecânico" criado com 3 páginas e 2 funcionalidades.

---

### **2️⃣ USAR UM PERFIL PADRÃO**

**Cenário:** Novo funcionário precisa apenas visualizar dados.

```
1. Vá em "Gerenciar Usuários"
2. Clique "Novo Usuário"
3. Preencha:
   Nome: João Silva
   Email: joao@porsche.com
   Senha: ********
   Perfil: 👁️ Visualizador  ← SELECIONE AQUI
   
4. Clique "Adicionar"
```

✅ **Pronto!** João terá acesso somente leitura a Dashboard e Relatórios.

---

### **3️⃣ CLONAR E PERSONALIZAR**

**Cenário:** Você quer um perfil "Operador Sênior" baseado no "Operador".

```
1. Na tela de perfis, localize "👤 Operador"
2. Clique no botão [📋 Clonar]
3. O formulário será preenchido automaticamente
4. Altere:
   Nome: "Operador (Cópia)" → "Operador Sênior"
   
5. Adicione mais permissões:
   ☑ Descarte de Pneus
   ☑ Editar Entrada
   ☑ Aprovar Movimentação
   
6. Clique "Adicionar"
```

✅ **Pronto!** Perfil customizado criado em segundos!

---

## 📋 PERFIS PADRÃO DISPONÍVEIS

### **🛡️ Administrador**
- **Tudo:** Acesso total (16 páginas, 27 funções)
- **Use para:** Gerentes, TI, Proprietários

### **👤 Operador**
- **Operacional:** Entrada, modelos, relatórios (7 páginas)
- **Use para:** Funcionários operacionais

### **🟢 Supervisor**
- **Operacional + Aprovações:** Tudo do operador + descartes e ajustes (11 páginas)
- **Use para:** Supervisores, coordenadores

### **👁️ Visualizador**
- **Somente Leitura:** Dashboard e relatórios (3 páginas)
- **Use para:** Clientes, auditoria, consultas

---

## 🎯 CASOS DE USO COMUNS

### **Caso 1: Mecânico de Pista**
```yaml
Perfil: Personalizado "Mecânico"
Páginas:
  - Dashboard (ver dados)
  - Entrada de Estoque (registrar pneus)
Funcionalidades:
  - Criar Entrada
  - Visualizar Relatórios
```

### **Caso 2: Almoxarife**
```yaml
Perfil: Personalizado "Almoxarife"
Páginas:
  - Dashboard
  - Entrada de Estoque
  - Modelos de Pneu
  - Contêineres
  - Relatórios
Funcionalidades:
  - CRUD Entrada
  - CRUD Modelos
  - CRUD Contêineres
  - Visualizar/Exportar Relatórios
```

### **Caso 3: Coordenador**
```yaml
Perfil: Supervisor (padrão)
Páginas: 11 páginas operacionais
Funcionalidades:
  - Tudo do operador
  - + Aprovar movimentações
  - + Criar descartes
  - + Ajustar estoque
```

### **Caso 4: Cliente/Auditor**
```yaml
Perfil: Visualizador (padrão)
Páginas:
  - Dashboard
  - Relatórios
Funcionalidades:
  - Visualizar
  - Exportar
```

---

## ⚙️ DICAS PRO

### **✅ Sempre:**
- Clone perfis padrão em vez de criar do zero
- Use nomes descritivos: "Mecânico Pista A" é melhor que "Perfil 1"
- Teste o perfil antes de atribuir a muitos usuários

### **❌ Evite:**
- Excluir perfis do sistema (você não consegue, são protegidos)
- Dar acesso desnecessário (princípio do menor privilégio)
- Criar muitos perfis similares (use os padrão sempre que possível)

### **💡 Truques:**
1. **Auditoria rápida:** Veja quantos usuários têm cada perfil
2. **Template:** Clone "Operador" e remova o que não precisa
3. **Hierarquia:** Use Visualizador → Operador → Supervisor → Admin

---

## 🔧 SOLUÇÃO RÁPIDA DE PROBLEMAS

### **Perfis não aparecem?**
```javascript
// Abra console (F12) e rode:
localStorage.getItem('porsche-cup-profiles')
// Deve mostrar JSON com perfis
```

### **Usuário não vê perfil personalizado?**
1. Verifique se salvou o perfil (botão "Adicionar")
2. Recarregue a página de usuários
3. O perfil deve aparecer na lista suspensa

### **Perfil sumiu?**
- Perfis do sistema NUNCA somem (são recriados automaticamente)
- Perfis personalizados estão no localStorage
- Backup: Exporte antes de modificar

---

## 📊 RESUMO VISUAL

```
ESTRUTURA DE PERMISSÕES:

┌─────────────────┐
│ 1. PERFIL       │ ← Define QUEM
├─────────────────┤
│ 2. PÁGINAS      │ ← Define ONDE (Dashboard, Relatórios...)
├─────────────────┤
│ 3. FUNÇÕES      │ ← Define O QUE (Criar, Editar, Excluir...)
└─────────────────┘

EXEMPLO:
┌──────────────────────────────┐
│ Perfil: "Mecânico"           │
├──────────────────────────────┤
│ Páginas:                     │
│   ☑ Dashboard                │
│   ☑ Entrada de Estoque       │
├──────────────────────────────┤
│ Funcionalidades:             │
│   ☑ Criar Entrada            │
│   ☑ Visualizar Relatórios    │
└──────────────────────────────┘
        ↓
João (Mecânico) pode:
✅ Ver Dashboard
✅ Registrar entrada de pneus
✅ Ver relatórios

João NÃO pode:
❌ Editar/excluir entradas
❌ Gerenciar usuários
❌ Acessar configurações
```

---

## 🎓 FLUXO COMPLETO

```
1. CRIAR PERFIL
   ↓
2. ATRIBUIR A USUÁRIO
   ↓
3. USUÁRIO FAZ LOGIN
   ↓
4. SISTEMA VERIFICA PERMISSÕES
   ↓
5. MOSTRA APENAS PÁGINAS/BOTÕES PERMITIDOS
```

---

## 📱 ATALHOS

| Ação | Atalho |
|------|--------|
| Criar perfil | Gerenciar Usuários → ⚙️ Gerenciar Perfis → Formulário |
| Clonar perfil | Lista de perfis → Botão [📋] |
| Editar perfil | Lista de perfis → Botão [✏️] (só personalizados) |
| Ver permissões | Hover sobre badges "X páginas, Y funcs" |
| Atribuir a usuário | Criar/Editar Usuário → Dropdown "Perfil" |

---

## ✅ CHECKLIST DE IMPLEMENTAÇÃO

**Para usar o sistema:**
- [x] ✅ Sistema implementado e funcionando
- [ ] ⏳ Adicionar ao menu lateral (próximo passo)
- [ ] ⏳ Aplicar verificações nos componentes
- [ ] ⏳ Testar com usuários reais

**Para cada novo perfil:**
- [ ] Definir nome e descrição clara
- [ ] Selecionar páginas necessárias (mínimo 1)
- [ ] Selecionar funcionalidades
- [ ] Testar com usuário de teste
- [ ] Atribuir aos usuários corretos

---

## 🚀 PRÓXIMO PASSO

Agora que você entende o sistema, siga para:
1. **Criar seus perfis personalizados**
2. **Atribuir aos usuários**
3. **Aguardar próxima atualização** que adicionará a verificação automática

📚 **Documentação completa:** `/SISTEMA_PERFIS_ACESSO_IMPLEMENTADO.md`

---

**Dúvidas?** Consulte a documentação completa ou entre em contato! 🎉
