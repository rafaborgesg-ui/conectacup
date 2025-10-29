# Localização do Botão de Seleção de Colunas

## 📍 Onde está o botão?

O botão **"Colunas (6)"** está localizado no módulo **Ajuste de Estoque**, na barra superior da tabela.

### Localização exata:

```
Menu Lateral > Ajuste de Estoque
    ↓
[Filtros e Busca]
    ↓
[Tabela]
    ↓
┌─────────────────────────────────────────────────────────────┐
│ 6 registros encontrados     [⚙️ Colunas (6)] [Registros: ▼] │ ← AQUI!
├─────────────────────────────────────────────────────────────┤
│ ☐  Código  Modelo  Tipo  Contêiner  Status  Data  Ações    │
│ ☐  ...                                                       │
└─────────────────────────────────────────────────────────────┘
```

## 🔍 Como identificar:

1. Navegue até **Ajuste de Estoque** no menu lateral (ícone de engrenagem)
2. Role a página até encontrar a tabela de pneus
3. Na parte superior da tabela, logo acima dos cabeçalhos das colunas
4. À **direita** do texto "X registros encontrados"
5. À **esquerda** do seletor "Registros por página"

## ✨ Aparência do botão:

- **Ícone**: ⚙️ (Settings/Configurações)
- **Texto**: "Colunas (6)" - o número indica quantas colunas estão visíveis
- **Estilo**: Botão outline (borda cinza)
- **Tamanho**: Pequeno (size="sm")

## 🎯 Ao clicar:

Abrirá um popover (menu suspenso) com:
- ✅ Lista de todas as colunas disponíveis (13 no total)
- Checkboxes para marcar/desmarcar colunas
- Botões "Todas" e "Padrão" no topo
- Contador de colunas selecionadas no rodapé

## 📋 Colunas disponíveis:

### Colunas PADRÃO (visíveis por padrão):
1. ✅ Código de Barras
2. ✅ Modelo
3. ✅ Tipo
4. ✅ Contêiner
5. ✅ Status
6. ✅ Data de Entrada

### Colunas OPCIONAIS (ocultas por padrão):
7. ⬜ Piloto
8. ⬜ Equipe
9. ⬜ Ano/Temporada
10. ⬜ Etapa
11. ⬜ Categoria
12. ⬜ Campeonato
13. ⬜ ID da Sessão

## 🐛 Troubleshooting:

### Não consigo ver o botão?

1. **Verifique se está no módulo correto**: Deve ser **Ajuste de Estoque** (não Entrada de Estoque ou Relatórios)

2. **Recarregue a página**: Pressione `Ctrl + F5` (Windows) ou `Cmd + Shift + R` (Mac) para forçar atualização

3. **Verifique o console do navegador**: 
   - Pressione `F12` para abrir DevTools
   - Vá na aba "Console"
   - Procure por mensagens de erro ou os logs de debug:
     - "ColumnSelector renderizado com X colunas selecionadas"
     - "Colunas visíveis no StockAdjustment: [...]"

4. **Verifique a responsividade**: 
   - Em telas menores, o botão pode quebrar para uma nova linha
   - Role horizontalmente se necessário

5. **Limpe o cache do navegador**:
   - Chrome: `Ctrl + Shift + Delete` > Limpar dados de navegação
   - Ou use navegação anônima para testar

## 💡 Dica:

Se ainda assim não conseguir ver, tire um print da tela mostrando a área da tabela e compartilhe para que eu possa ajudar a diagnosticar o problema!
