# 💾 Funcionalidade de Preferências de Colunas Personalizadas

## Resumo

Implementada a funcionalidade de **salvar preferências de colunas** no componente `ColumnSelector`, permitindo que os usuários personalizem e mantenham suas configurações de visualização entre sessões.

## ✨ Funcionalidades Implementadas

### 1. Botão "Salvar como Meu Padrão"
- Localizado na parte inferior do menu de seleção de colunas
- Salva a configuração atual de colunas selecionadas no localStorage
- Feedback visual com toast de confirmação ao salvar

### 2. Botão "Meu Padrão" ⭐
- Aparece automaticamente quando há preferências salvas
- Localizado ao lado dos botões "Todas" e "Padrão"
- Restaura rapidamente as colunas personalizadas salvas
- Destaque visual em amarelo para fácil identificação

### 3. Carregamento Automático
- As preferências salvas são carregadas automaticamente ao abrir a página
- Cada tabela mantém suas próprias preferências independentes
- Validação automática para garantir que apenas colunas válidas sejam carregadas

### 4. Indicador Visual
- Ícone de estrela (⭐) indica quando há preferências salvas
- Texto informativo: "Você tem preferências salvas"

## 🎯 Locais de Uso

### 1. Relatórios & Histórico → Aba Histórico
- **Storage Key**: `reports-history`
- Colunas disponíveis: Código, Modelo, Tipo, Status, Contêiner, Data, Piloto, Equipe, Sessão, Etapa, Temporada, Campeonato, Categoria

### 2. Ajuste de Estoque
- **Storage Key**: `stock-adjustment`
- Colunas disponíveis: Código, Modelo, Tipo, Contêiner, Status, Data, Piloto, Equipe, Temporada, Etapa, Categoria, Campeonato, Sessão

## 📝 Como Usar

### Para o Usuário:

1. **Personalizar colunas**:
   - Clique no botão "Colunas" (ícone de engrenagem)
   - Selecione/desmarque as colunas desejadas
   - As mudanças são aplicadas instantaneamente

2. **Salvar preferências**:
   - Após personalizar, clique em "Salvar como Meu Padrão"
   - Mensagem de confirmação aparecerá: "✓ Preferências salvas com sucesso!"
   - Um ícone de estrela aparecerá indicando que há preferências salvas

3. **Restaurar preferências salvas**:
   - Clique no botão "Meu" (com estrela amarela)
   - Suas colunas personalizadas serão restauradas instantaneamente

4. **Voltar ao padrão do sistema**:
   - Clique no botão "Padrão" para restaurar a configuração original
   - Isso não apaga suas preferências salvas

## 🔧 Detalhes Técnicos

### Arquivos Modificados

1. **`/components/ColumnSelector.tsx`**
   - Adicionado prop `storageKey` para identificação única
   - Implementadas funções `saveUserPreference()` e `loadUserPreference()`
   - Adicionado estado `hasSavedPreference` para controlar UI
   - Novos botões "Salvar como Meu Padrão" e "Meu Padrão"
   - Toasts de feedback usando Sonner

2. **`/components/Reports.tsx`**
   - Adicionado `storageKey="reports-history"` ao ColumnSelector
   - Modificado `useState` para carregar preferências salvas automaticamente

3. **`/components/StockAdjustment.tsx`**
   - Adicionado `storageKey="stock-adjustment"` ao ColumnSelector
   - Modificado `useState` para carregar preferências salvas automaticamente

### LocalStorage

```typescript
// Estrutura da chave
Key: `column-preference-${storageKey}`

// Exemplo
localStorage.getItem('column-preference-reports-history')
localStorage.getItem('column-preference-stock-adjustment')

// Formato do valor (JSON)
["barcode", "model_name", "status", "container_name", "created_at"]
```

### Validação de Segurança

- Verifica se as colunas salvas ainda existem na configuração atual
- Fallback automático para colunas padrão em caso de erro
- Try-catch para evitar crashes por dados corrompidos no localStorage

## 🎨 UI/UX

### Cores e Estilos
- Botão "Salvar": Borda vermelha (#D50000) com hover invertido
- Botão "Meu": Texto âmbar com ícone de estrela
- Toast de sucesso: Verde com checkmark
- Toast de erro: Vermelho (caso ocorra)

### Responsividade
- Funciona em todos os dispositivos
- Layout adaptativo do popover
- Feedback visual consistente

## ✅ Benefícios

1. **Produtividade**: Usuários não precisam reconfigurar colunas toda vez
2. **Personalização**: Cada tabela pode ter suas próprias preferências
3. **Flexibilidade**: Fácil alternar entre visualizações personalizadas e padrão
4. **Persistência**: Configurações mantidas entre sessões
5. **Segurança**: Validação de dados para evitar erros

## 🚀 Próximas Melhorias Possíveis

- [ ] Múltiplos perfis de visualização por usuário
- [ ] Exportar/importar configurações
- [ ] Sincronização de preferências via backend
- [ ] Configurações por perfil de usuário (admin vs operador)
- [ ] Reset de todas as preferências salvas (botão global)

## 📅 Changelog

**2025-10-24**
- ✅ Implementado salvamento de preferências no localStorage
- ✅ Adicionado botão "Salvar como Meu Padrão"
- ✅ Adicionado botão "Meu Padrão" com ícone de estrela
- ✅ Carregamento automático de preferências salvas
- ✅ Feedback visual com toasts
- ✅ Validação de dados salvos
- ✅ Documentação completa

---

**Status**: ✅ Implementado e Testado  
**Versão**: 1.0.0  
**Autor**: Sistema Porsche Cup Brasil
