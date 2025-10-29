# ⚡ Loading States - Guia Rápido de Implementação

## 🎯 Como Aplicar Loading States em 5 Minutos

### 📋 Checklist por Componente

Para cada componente da aplicação, siga este checklist:

- [ ] 1. Adicionar imports
- [ ] 2. Identificar loading states
- [ ] 3. Escolher skeleton apropriado
- [ ] 4. Implementar loading UI
- [ ] 5. Adicionar ButtonLoading em submits
- [ ] 6. Testar visualmente

---

## 🚀 Passo 1: Imports

Adicione no topo do arquivo:

```tsx
// Loading components
import { LoadingSpinner, LoadingPorsche, ButtonLoading } from './LoadingSpinner';
import { 
  Skeleton, 
  TableSkeleton, 
  FormSkeleton,
  CardGridSkeleton,
  ListSkeleton 
} from './LoadingSkeleton';
import { ErrorState } from './ErrorState';
```

---

## 🎨 Passo 2: Escolher Skeleton

### Tipo de Componente → Skeleton Recomendado

| Componente | Skeleton | Exemplo |
|------------|----------|---------|
| Dashboard com cards | `DashboardCardSkeleton` | Dashboard.tsx ✅ |
| Tabela de dados | `TableSkeleton` | Reports, UserManagement |
| Formulário | `FormSkeleton` | TireModel, Container, Status |
| Grid de cards | `CardGridSkeleton` | MasterData |
| Lista de itens | `ListSkeleton` | TireStockEntry (últimas entradas) |
| Gráfico | `ChartSkeleton` | Reports |
| Página completa | `PageSkeleton` | Qualquer página |
| Entrada de estoque | `StockEntrySkeleton` | TireStockEntry ✅ |
| Relatórios | `ReportSkeleton` | Reports |

---

## 💻 Passo 3: Implementar Loading

### Template Básico

```tsx
export function MyComponent() {
  const [isLoading, setIsLoading] = useState(true);
  const [data, setData] = useState([]);

  useEffect(() => {
    loadData();
  }, []);

  const loadData = async () => {
    setIsLoading(true);
    try {
      const result = await fetchData();
      setData(result);
    } finally {
      setIsLoading(false);
    }
  };

  // 🎨 LOADING STATE
  if (isLoading) {
    return (
      <div className="px-4 py-6">
        <PageHeader icon={Icon} title="Título" />
        <Card className="p-6 mt-6">
          {/* Escolha o skeleton apropriado */}
          <FormSkeleton fields={4} />
        </Card>
      </div>
    );
  }

  // ✅ CONTEÚDO NORMAL
  return (
    <div className="px-4 py-6">
      {/* Seu conteúdo aqui */}
    </div>
  );
}
```

---

## 🔘 Passo 4: Botões com Loading

### Antes:
```tsx
<Button onClick={handleSave} disabled={isSaving}>
  {isSaving ? 'Salvando...' : 'Salvar'}
</Button>
```

### Depois:
```tsx
<Button onClick={handleSave} disabled={isSaving}>
  {isSaving ? (
    <ButtonLoading text="Salvando..." />
  ) : (
    'Salvar'
  )}
</Button>
```

---

## 📊 Exemplos Práticos

### Exemplo 1: Reports.tsx

```tsx
// Imports
import { ReportSkeleton, ChartSkeleton } from './LoadingSkeleton';
import { LoadingPorsche } from './LoadingSpinner';

export function Reports() {
  const [isLoading, setIsLoading] = useState(true);
  
  // Loading state
  if (isLoading) {
    return (
      <div className="px-4 py-6 space-y-6">
        <PageHeader icon={BarChart3} title="Relatórios" />
        <ReportSkeleton />
      </div>
    );
  }
  
  return (
    // Conteúdo normal
  );
}
```

---

### Exemplo 2: TireModelRegistration.tsx

```tsx
// Imports
import { FormSkeleton } from './LoadingSkeleton';
import { ButtonLoading } from './LoadingSpinner';

export function TireModelRegistration() {
  const [isLoading, setIsLoading] = useState(true);
  const [isSaving, setIsSaving] = useState(false);
  
  // Loading state
  if (isLoading) {
    return (
      <div className="px-4 py-6">
        <PageHeader icon={Layers} title="Cadastro de Modelos" />
        <Card className="p-6 mt-6">
          <FormSkeleton fields={5} />
        </Card>
      </div>
    );
  }
  
  return (
    <div className="px-4 py-6">
      <form onSubmit={handleSubmit}>
        {/* Campos do formulário */}
        
        <Button type="submit" disabled={isSaving}>
          {isSaving ? (
            <ButtonLoading text="Salvando..." />
          ) : (
            'Cadastrar Modelo'
          )}
        </Button>
      </form>
    </div>
  );
}
```

---

### Exemplo 3: UserManagement.tsx

```tsx
// Imports
import { TableSkeleton } from './LoadingSkeleton';

export function UserManagement() {
  const [isLoading, setIsLoading] = useState(true);
  const [users, setUsers] = useState([]);
  
  // Loading state
  if (isLoading) {
    return (
      <div className="px-4 py-6">
        <PageHeader icon={Users} title="Gerenciar Usuários" />
        <Card className="p-6 mt-6">
          <TableSkeleton rows={10} columns={5} />
        </Card>
      </div>
    );
  }
  
  return (
    // Tabela normal
  );
}
```

---

### Exemplo 4: DataImport.tsx (com progresso)

```tsx
// Imports
import { LoadingOverlay } from './LoadingOverlay';
import { FormSkeleton } from './LoadingSkeleton';

export function DataImport() {
  const [isLoading, setIsLoading] = useState(true);
  const [isUploading, setIsUploading] = useState(false);
  const [uploadProgress, setUploadProgress] = useState(0);
  
  // Page loading
  if (isLoading) {
    return (
      <div className="px-4 py-6">
        <PageHeader icon={Upload} title="Importação de Dados" />
        <Card className="p-6 mt-6">
          <FormSkeleton fields={3} />
        </Card>
      </div>
    );
  }
  
  return (
    <div className="px-4 py-6">
      {/* Conteúdo */}
      
      {/* Upload overlay */}
      <LoadingOverlay
        isOpen={isUploading}
        text="Importando dados..."
        progress={uploadProgress}
      />
    </div>
  );
}
```

---

## 🎯 Componentes Pendentes (10 total)

### Prioridade ALTA (usar diariamente)

1. **Reports.tsx** 
   - Skeleton: `ReportSkeleton`
   - Tempo: 5 min

2. **TireModelRegistration.tsx**
   - Skeleton: `FormSkeleton`
   - Tempo: 5 min

3. **ContainerRegistration.tsx**
   - Skeleton: `FormSkeleton`
   - Tempo: 5 min

4. **DataImport.tsx**
   - Skeleton: `FormSkeleton` + `LoadingOverlay`
   - Tempo: 10 min

5. **UserManagement.tsx**
   - Skeleton: `TableSkeleton`
   - Tempo: 5 min

### Prioridade MÉDIA

6. **TireDiscard.tsx**
   - Skeleton: `FormSkeleton`
   - Tempo: 5 min

7. **TireConsumption.tsx**
   - Skeleton: `FormSkeleton`
   - Tempo: 5 min

8. **StockAdjustment.tsx**
   - Skeleton: `TableSkeleton`
   - Tempo: 5 min

### Prioridade BAIXA

9. **MasterData.tsx**
   - Skeleton: `CardGridSkeleton`
   - Tempo: 5 min

10. **StatusRegistration.tsx**
    - Skeleton: `FormSkeleton`
    - Tempo: 5 min

**Total estimado: 55 minutos (~1 hora)**

---

## 🧪 Como Testar

### Teste Manual (5 min por componente)

1. **Abrir componente no navegador**
2. **Throttle de rede: Slow 3G** (DevTools > Network)
3. **Refresh da página**
4. **Verificar:**
   - [ ] Skeleton aparece imediatamente
   - [ ] Layout não "pula" ao carregar
   - [ ] Animação shimmer funciona
   - [ ] Transição é suave
   - [ ] Botões mostram loading ao clicar

### Teste Responsivo (2 min)

1. **Responsive mode** (Ctrl+Shift+M)
2. **Mobile (375px)**
   - [ ] Skeleton ajusta layout
   - [ ] Texto legível
3. **Tablet (768px)**
   - [ ] Grid ajusta colunas
4. **Desktop (1440px)**
   - [ ] Layout completo

---

## 🐛 Problemas Comuns

### ❌ Skeleton não aparece

**Causa:** Falta adicionar conditional rendering

**Fix:**
```tsx
// ❌ Errado
return <div>{data.map(...)}</div>

// ✅ Correto
if (isLoading) return <TableSkeleton />;
return <div>{data.map(...)}</div>
```

---

### ❌ Layout "pula" ao carregar

**Causa:** Skeleton não match o layout real

**Fix:**
- Use skeleton com mesmo número de linhas/colunas
- Ajuste rows/columns props
- Teste visualmente

---

### ❌ Botão não mostra loading

**Causa:** Falta desabilitar botão ou verificar estado

**Fix:**
```tsx
// ✅ Correto
<Button disabled={isSaving}>
  {isSaving ? <ButtonLoading /> : 'Salvar'}
</Button>
```

---

## 📝 Checklist Final

Antes de considerar "pronto":

- [ ] Imports adicionados
- [ ] Loading state implementado
- [ ] Skeleton escolhido corretamente
- [ ] Botões com ButtonLoading
- [ ] Testado em desktop
- [ ] Testado em mobile
- [ ] Sem erros no console
- [ ] Transição suave
- [ ] Animações funcionando

---

## 🚀 Próximo Passo

1. **Escolha um componente** da lista de prioridade ALTA
2. **Abra o arquivo** no editor
3. **Siga o template** deste guia
4. **Teste visualmente**
5. **Repita** para próximo componente

**Meta:** Implementar todos os 10 componentes em ~1 hora

---

## 💡 Dicas Finais

- ✅ **Copy/paste é permitido!** Use os templates
- ✅ **Teste imediatamente** após cada mudança
- ✅ **Ajuste conforme necessário** (rows, cols, fields)
- ✅ **Seja consistente** com o padrão existente
- ✅ **Documente** se criar skeleton customizado

---

**Happy coding! 🎉**

*Guia criado em 24/10/2025*
