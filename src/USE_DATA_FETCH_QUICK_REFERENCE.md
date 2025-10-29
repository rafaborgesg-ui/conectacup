# 🔄 useDataFetch - Quick Reference

**1-pager para consulta rápida**

---

## 📖 Import

```tsx
import { useDataFetch } from '../utils/useDataFetch';
```

---

## ⚡ Uso Rápido

```tsx
const { data, loading, error, refetch } = useDataFetch(
  () => fetchMyData(),
  []
);
```

---

## 🎯 Exemplos por Caso de Uso

### Fetch Simples
```tsx
const { data, loading } = useDataFetch(
  async () => {
    const res = await fetch('/api/data');
    return res.json();
  },
  []
);
```

### Supabase
```tsx
const { data } = useDataFetch(
  async () => {
    const supabase = createClient();
    const { data, error } = await supabase.from('table').select('*');
    if (error) throw error;
    return data;
  },
  []
);
```

### Com Refetch
```tsx
const { data, refetch } = useDataFetch(() => fetchData(), []);

<button onClick={refetch}>Atualizar</button>
```

### Com Dependências
```tsx
const { data } = useDataFetch(
  () => fetchTiresByStatus(status),
  [status] // Refetch quando status muda
);
```

### Cache (5min)
```tsx
const { data } = useDataFetch(
  () => fetchData(),
  [],
  { cacheTime: 5 * 60 * 1000 }
);
```

### Retry (3x)
```tsx
const { data } = useDataFetch(
  () => fetchData(),
  [],
  { retryCount: 3, retryDelay: 2000 }
);
```

### Debounce Search
```tsx
const [query, setQuery] = useState('');

const { data, loading } = useDataFetch(
  () => search(query),
  [query],
  { debounceMs: 300 }
);
```

### Callbacks + Toast
```tsx
const { data } = useDataFetch(
  () => importData(),
  [],
  {
    onSuccess: (d) => console.log('OK:', d),
    onError: (e) => console.error('Erro:', e),
    successMessage: 'Sucesso!',
    errorMessage: 'Erro!',
    showSuccessToast: true,
  }
);
```

---

## 📊 API

### Retorno
```tsx
{
  data: T | null              // Dados
  loading: boolean            // Carregando?
  error: Error | null         // Erro
  refetch: () => Promise<void> // Refetch
  reset: () => void           // Limpar
  setData: (d: T) => void     // Set manual
  isRefetching: boolean       // Refazendo?
}
```

### Opções
```tsx
{
  onSuccess?: (data: T) => void
  onError?: (error: Error) => void
  successMessage?: string
  errorMessage?: string
  showSuccessToast?: boolean    // default: false
  showErrorToast?: boolean      // default: true
  autoFetch?: boolean           // default: true
  initialDelay?: number         // default: 0
  cacheTime?: number            // default: 0
  debounceMs?: number           // default: 0
  retryCount?: number           // default: 0
  retryDelay?: number           // default: 1000
}
```

---

## 🎨 Padrões de Renderização

### Loading
```tsx
if (loading) return <LoadingSpinner />;
```

### Error
```tsx
if (error) return <ErrorState error={error} onRetry={refetch} />;
```

### Empty
```tsx
if (!data?.length) return <EmptyState />;
```

### Success
```tsx
return <Table data={data} />;
```

---

## 🔧 Helpers

### Supabase
```tsx
import { useSupabaseFetch } from '../utils/useDataFetch';

const { data } = useSupabaseFetch(
  (supabase) => supabase.from('table').select('*'),
  []
);
```

### Clear Cache
```tsx
import { clearDataFetchCache } from '../utils/useDataFetch';

clearDataFetchCache();
```

---

## 💡 Tips

### ✅ DO
```tsx
// Extrair fetch para função
const fetchTires = async () => { ... };
const { data } = useDataFetch(fetchTires, []);

// Usar optional chaining
{data?.map(...)}

// Usar TypeScript
const { data } = useDataFetch<Tire[]>(...);
```

### ❌ DON'T
```tsx
// Não usar função inline com deps complexas
const { data } = useDataFetch(
  () => fetch(...),
  [obj] // obj muda sempre
);

// Não esquecer optional chaining
{data.map(...)} // erro se data = null
```

---

## 🚀 Migração

### Antes
```tsx
const [data, setData] = useState([]);
const [loading, setLoading] = useState(true);
const [error, setError] = useState(null);

useEffect(() => {
  const load = async () => {
    try {
      setLoading(true);
      const res = await fetch(...);
      setData(res);
    } catch (e) {
      setError(e);
    } finally {
      setLoading(false);
    }
  };
  load();
}, []);
```

### Depois
```tsx
const { data, loading, error } = useDataFetch(
  () => fetch(...),
  []
);
```

**-80% de código!**

---

## 📚 Docs Completas

- `/docs/USE_DATA_FETCH_GUIDE.md` - Guia completo
- `/docs/USE_DATA_FETCH_MIGRATION_EXAMPLE.md` - Migração
- `/USE_DATA_FETCH_IMPLEMENTADO.md` - Resumo

---

**Quick Reference v1.0** | useDataFetch Hook
