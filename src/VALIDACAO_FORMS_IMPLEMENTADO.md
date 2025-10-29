# ✅ VALIDAÇÃO DE FORMS - IMPLEMENTADO

**Data:** 24 de Outubro de 2025  
**Status:** 🟢 Sistema Base Completo | 🟡 Refatoração em Andamento

---

## 📦 O QUE FOI CRIADO

### 1. ✅ Hook `useFormValidation`
**Arquivo:** `/utils/useFormValidation.ts`

**Features:**
- ✅ Validação em tempo real
- ✅ Validação assíncrona (duplicatas, API calls)
- ✅ Mensagens de erro customizáveis
- ✅ Touch state (só mostra erro após interação)
- ✅ Suporte a múltiplos campos
- ✅ Validação síncrona e assíncrona combinadas
- ✅ Reset e controle programático

**Validações Disponíveis:**
- `required` - Campo obrigatório
- `minLength` - Mínimo de caracteres
- `maxLength` - Máximo de caracteres
- `min` - Valor mínimo (numérico)
- `max` - Valor máximo (numérico)
- `pattern` - RegEx personalizado
- `email` - Validação de e-mail
- `custom` - Validação customizada síncrona
- `asyncValidation` - Validação customizada assíncrona

---

### 2. ✅ Componentes Validados
**Arquivo:** `/components/ValidatedInput.tsx`

**Componentes Criados:**
- ✅ `ValidatedInput` - Input com validação
- ✅ `ValidatedTextarea` - Textarea com validação e contador
- ✅ `ValidatedSelect` - Select com validação

**Features:**
- ✅ Ícones de status (✓ válido, ✗ erro, ⟳ validando)
- ✅ Mensagens de erro acessíveis (ARIA)
- ✅ Helper text
- ✅ Loading state para validação assíncrona
- ✅ Contador de caracteres (textarea)
- ✅ Estilização automática de erro/sucesso

---

## 🎯 COMO USAR

### Exemplo 1: Entrada de Código de Barras (TireStockEntry)

```tsx
import { useFormValidation } from '../utils/useFormValidation';
import { ValidatedInput } from './ValidatedInput';
import { checkBarcodeExists } from '../utils/storage';

function TireStockEntry() {
  const {
    values,
    errors,
    touched,
    handleChange,
    handleBlur,
    handleSubmit,
    reset,
  } = useFormValidation({
    initialValues: {
      barcode: '',
      modelId: '',
      containerId: '',
    },
    validationRules: {
      barcode: {
        required: true,
        minLength: 8,
        maxLength: 8,
        pattern: /^\d{8}$/,
        asyncValidation: async (value) => {
          if (value.length === 8) {
            const exists = await checkBarcodeExists(value);
            if (exists) return 'Código de barras já cadastrado';
          }
        },
      },
      modelId: {
        required: true,
        custom: (value) => {
          if (!value) return 'Selecione um modelo de pneu';
        },
      },
      containerId: {
        required: true,
        custom: (value) => {
          if (!value) return 'Selecione um contêiner';
        },
      },
    },
    onSubmit: async (values) => {
      await registerTire(values);
      toast.success('Pneu registrado com sucesso!');
      reset();
    },
  });

  return (
    <form onSubmit={handleSubmit}>
      <ValidatedInput
        label="Código de Barras"
        name="barcode"
        value={values.barcode}
        error={errors.barcode}
        touched={touched.barcode}
        onChange={(e) => handleChange('barcode', e.target.value)}
        onBlur={() => handleBlur('barcode')}
        placeholder="Digite 8 dígitos"
        maxLength={8}
        required
        helperText="Escaneie ou digite o código de 8 dígitos"
      />

      <ValidatedSelect
        label="Modelo do Pneu"
        name="modelId"
        value={values.modelId}
        error={errors.modelId}
        touched={touched.modelId}
        onChange={(e) => handleChange('modelId', e.target.value)}
        onBlur={() => handleBlur('modelId')}
        options={tireModels.map(m => ({ value: m.id, label: m.name }))}
        required
      />

      <Button type="submit" disabled={!isValid || isSubmitting}>
        {isSubmitting ? 'Registrando...' : 'Registrar Pneu'}
      </Button>
    </form>
  );
}
```

---

### Exemplo 2: Descarte de Pneu (TireDiscard)

```tsx
import { useFormValidation } from '../utils/useFormValidation';
import { ValidatedInput, ValidatedTextarea, ValidatedSelect } from './ValidatedInput';

function TireDiscard() {
  const {
    values,
    errors,
    touched,
    handleChange,
    handleBlur,
    handleSubmit,
  } = useFormValidation({
    initialValues: {
      barcode: '',
      reason: '',
      notes: '',
    },
    validationRules: {
      barcode: {
        required: true,
        minLength: 8,
        maxLength: 8,
        pattern: /^\d{8}$/,
        asyncValidation: async (value) => {
          if (value.length === 8) {
            const tire = await getTireByBarcode(value);
            if (!tire) return 'Pneu não encontrado';
            if (tire.status === 'DESCARTADO') return 'Pneu já foi descartado';
          }
        },
      },
      reason: {
        required: true,
      },
      notes: {
        maxLength: 500,
      },
    },
    onSubmit: async (values) => {
      await discardTire(values);
      toast.success('Pneu descartado com sucesso!');
    },
  });

  return (
    <form onSubmit={handleSubmit}>
      <ValidatedInput
        label="Código do Pneu"
        name="barcode"
        value={values.barcode}
        error={errors.barcode}
        touched={touched.barcode}
        onChange={(e) => handleChange('barcode', e.target.value)}
        onBlur={() => handleBlur('barcode')}
        required
      />

      <ValidatedSelect
        label="Motivo do Descarte"
        name="reason"
        value={values.reason}
        error={errors.reason}
        touched={touched.reason}
        onChange={(e) => handleChange('reason', e.target.value)}
        onBlur={() => handleBlur('reason')}
        options={[
          { value: '', label: 'Selecione...' },
          { value: 'desgaste', label: 'Desgaste Natural' },
          { value: 'dano', label: 'Dano Estrutural' },
          { value: 'corte', label: 'Corte/Perfuração' },
        ]}
        required
      />

      <ValidatedTextarea
        label="Observações"
        name="notes"
        value={values.notes}
        error={errors.notes}
        touched={touched.notes}
        onChange={(e) => handleChange('notes', e.target.value)}
        onBlur={() => handleBlur('notes')}
        maxLength={500}
        showCharCount
        rows={4}
        helperText="Adicione detalhes sobre o descarte (opcional)"
      />

      <Button type="submit">Descartar Pneu</Button>
    </form>
  );
}
```

---

### Exemplo 3: Movimentação de Pneu (TireMovement)

```tsx
function TireMovement() {
  const {
    values,
    errors,
    touched,
    handleChange,
    handleBlur,
    handleSubmit,
    setFieldValue,
  } = useFormValidation({
    initialValues: {
      barcode: '',
      newContainerId: '',
      pilot: '',
      team: '',
    },
    validationRules: {
      barcode: {
        required: true,
        minLength: 8,
        maxLength: 8,
        pattern: /^\d{8}$/,
      },
      newContainerId: {
        required: true,
      },
      pilot: {
        minLength: 3,
        maxLength: 100,
      },
    },
    onSubmit: async (values) => {
      await moveTire(values);
      toast.success('Pneu movimentado com sucesso!');
    },
  });

  // Auto-preencher dados ao escanear
  const handleBarcodeComplete = async (barcode: string) => {
    const tire = await getTireByBarcode(barcode);
    if (tire) {
      setFieldValue('pilot', tire.pilot || '');
      setFieldValue('team', tire.team || '');
    }
  };

  return (
    <form onSubmit={handleSubmit}>
      <ValidatedInput
        label="Código do Pneu"
        name="barcode"
        value={values.barcode}
        error={errors.barcode}
        touched={touched.barcode}
        onChange={(e) => {
          handleChange('barcode', e.target.value);
          if (e.target.value.length === 8) {
            handleBarcodeComplete(e.target.value);
          }
        }}
        onBlur={() => handleBlur('barcode')}
        required
      />

      {/* Outros campos... */}
    </form>
  );
}
```

---

## 🔄 REFATORAÇÃO NECESSÁRIA

### Componentes a Refatorar:

#### 1. TireStockEntry.tsx
**Status:** 🟡 PENDENTE  
**Prioridade:** ALTA  
**Campos a validar:**
- ✅ Código de barras (8 dígitos, verificar duplicata)
- ✅ Modelo do pneu (obrigatório)
- ✅ Contêiner (obrigatório)
- 📝 Ano (formato YYYY, opcional)
- 📝 Etapa (opcional)

**Estimativa:** 2 horas

---

#### 2. TireDiscard.tsx
**Status:** 🟡 PENDENTE  
**Prioridade:** ALTA  
**Campos a validar:**
- ✅ Código de barras (8 dígitos, verificar existência)
- ✅ Motivo (obrigatório)
- ✅ Observações (máx 500 caracteres, opcional)

**Estimativa:** 1.5 horas

---

#### 3. TireMovement.tsx
**Status:** 🟡 PENDENTE  
**Prioridade:** MÉDIA  
**Campos a validar:**
- ✅ Código de barras (8 dígitos, verificar existência)
- ✅ Novo contêiner (obrigatório)
- 📝 Piloto (min 3, max 100 caracteres, opcional)
- 📝 Equipe (opcional)

**Estimativa:** 1.5 horas

---

#### 4. ContainerRegistration.tsx
**Status:** 🟡 PENDENTE  
**Prioridade:** BAIXA  
**Campos a validar:**
- ✅ Nome do contêiner (min 3, max 50 caracteres)
- ✅ Código (verificar duplicata, opcional)
- 📝 Localização (max 200 caracteres, opcional)

**Estimativa:** 1 hora

---

#### 5. TireModelRegistration.tsx
**Status:** 🟡 PENDENTE  
**Prioridade:** BAIXA  
**Campos a validar:**
- ✅ Nome do modelo (min 3, max 100 caracteres)
- ✅ Código (verificar duplicata)
- ✅ Tipo (Slick/Wet, obrigatório)

**Estimativa:** 1 hora

---

## 📊 BENEFÍCIOS

### UX/UI
- ✅ Feedback visual imediato
- ✅ Previne erros antes do submit
- ✅ Mensagens de erro claras e contextuais
- ✅ Ícones de status intuitivos

### Desenvolvimento
- ✅ Código reutilizável
- ✅ Menos código duplicado
- ✅ Fácil manutenção
- ✅ Type-safe (TypeScript)

### Acessibilidade
- ✅ ARIA labels automáticos
- ✅ Mensagens de erro anunciadas para leitores de tela
- ✅ Estados visuais claros
- ✅ Navegação por teclado otimizada

---

## 🛠️ VALIDAÇÕES CUSTOMIZADAS COMUNS

### Verificar Código de Barras Duplicado
```typescript
asyncValidation: async (value) => {
  if (value.length === 8) {
    const entries = await getStockEntriesSync();
    const exists = entries.some(e => e.barcode === value);
    if (exists) return 'Código de barras já cadastrado';
  }
}
```

### Verificar Pneu Existe
```typescript
asyncValidation: async (value) => {
  if (value.length === 8) {
    const entries = await getStockEntriesSync();
    const tire = entries.find(e => e.barcode === value);
    if (!tire) return 'Pneu não encontrado';
    if (tire.status === 'DESCARTADO') return 'Pneu já foi descartado';
  }
}
```

### Verificar Container Existe
```typescript
custom: (value, allValues) => {
  const containers = getContainers();
  const exists = containers.some(c => c.id === value);
  if (!exists) return 'Contêiner inválido';
}
```

### Validar Ano
```typescript
pattern: /^(20)\d{2}$/,
custom: (value) => {
  const year = parseInt(value);
  const currentYear = new Date().getFullYear();
  if (year < 2020 || year > currentYear + 1) {
    return `Ano deve estar entre 2020 e ${currentYear + 1}`;
  }
}
```

### Validar CPF (exemplo)
```typescript
pattern: /^\d{3}\.\d{3}\.\d{3}-\d{2}$/,
custom: (value) => {
  // Implementar algoritmo de validação de CPF
  if (!isValidCPF(value)) return 'CPF inválido';
}
```

---

## 📝 CHECKLIST DE REFATORAÇÃO

### Para cada componente:

#### Passo 1: Importar
```tsx
import { useFormValidation } from '../utils/useFormValidation';
import { ValidatedInput, ValidatedTextarea, ValidatedSelect } from './ValidatedInput';
```

#### Passo 2: Definir initialValues
```tsx
const initialValues = {
  barcode: '',
  modelId: '',
  // ... outros campos
};
```

#### Passo 3: Definir validationRules
```tsx
const validationRules = {
  barcode: {
    required: true,
    minLength: 8,
    maxLength: 8,
    pattern: /^\d{8}$/,
    asyncValidation: async (value) => {
      // validação assíncrona
    },
  },
  // ... outros campos
};
```

#### Passo 4: Usar hook
```tsx
const {
  values,
  errors,
  touched,
  handleChange,
  handleBlur,
  handleSubmit,
  isValid,
  isSubmitting,
  reset,
} = useFormValidation({
  initialValues,
  validationRules,
  onSubmit: async (values) => {
    // lógica de submit
  },
});
```

#### Passo 5: Substituir inputs
```tsx
// ANTES
<Input
  value={barcode}
  onChange={(e) => setBarcode(e.target.value)}
  placeholder="Digite 8 dígitos"
/>

// DEPOIS
<ValidatedInput
  label="Código de Barras"
  name="barcode"
  value={values.barcode}
  error={errors.barcode}
  touched={touched.barcode}
  onChange={(e) => handleChange('barcode', e.target.value)}
  onBlur={() => handleBlur('barcode')}
  placeholder="Digite 8 dígitos"
  required
  helperText="Escaneie ou digite o código de 8 dígitos"
/>
```

#### Passo 6: Substituir submit
```tsx
// ANTES
<Button onClick={handleSave}>Salvar</Button>

// DEPOIS
<form onSubmit={handleSubmit}>
  <Button type="submit" disabled={!isValid || isSubmitting}>
    {isSubmitting ? 'Salvando...' : 'Salvar'}
  </Button>
</form>
```

---

## ✅ STATUS FINAL

**Fase 2 - Base Implementada:** ✅ 100%  
**Refatoração Pendente:** 🟡 0/5 componentes

### Próximos Passos:
1. Refatorar TireStockEntry.tsx
2. Refatorar TireDiscard.tsx
3. Refatorar TireMovement.tsx
4. Refatorar ContainerRegistration.tsx (opcional)
5. Refatorar TireModelRegistration.tsx (opcional)

**Tempo Total Estimado:** 5-7 horas

---

## 🎯 RESULTADO ESPERADO

Após refatoração completa:
- ✅ Validação consistente em todos os formulários
- ✅ Feedback visual imediato para o usuário
- ✅ Menos erros de dados incorretos no sistema
- ✅ Código mais limpo e manutenível
- ✅ Melhor experiência de acessibilidade
- ✅ TypeScript type-safe em todo o fluxo

