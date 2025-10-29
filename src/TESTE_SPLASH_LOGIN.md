# 🧪 Teste: Splash Screen + Login Redesenhado

## ✅ Checklist de Verificação

### 1. Splash Screen (3 segundos)

**Visual:**
- [ ] Fundo gradiente (preto → cinza → vermelho escuro)
- [ ] Grid tecnológico animado em movimento
- [ ] 20 partículas flutuantes visíveis
- [ ] 3 círculos de pulso expandindo
- [ ] Glow vermelho atrás do logo

**Logo:**
- [ ] Logo aparece com efeito bounce (pequeno → grande)
- [ ] Container com backdrop blur visível
- [ ] Logo nítido e bem posicionado

**Textos:**
- [ ] "Conecta Cup" com gradiente branco → cinza → vermelho
- [ ] "Sistema de Gestão de Pneus" em cinza
- [ ] "v2.2.0" aparece com delay

**Barra de Progresso:**
- [ ] Aparece após ~0.8s
- [ ] Preenche de 0% → 100% em ~2.5s
- [ ] Gradiente vermelho (from-red-600 to-red-400)

**Transição:**
- [ ] Fade out suave (600ms)
- [ ] Login aparece sem flicker

---

### 2. Tela de Login

**Header:**
- [ ] Logo do Porsche Cup visível
- [ ] Título: "Bem-vindo de volta" (branco, bold)
- [ ] Subtítulo: "Faça login para acessar o sistema" (cinza)

**Campos:**
- [ ] Label "E-mail" (com hífen, branco, text-sm)
- [ ] Placeholder "seu@email.com"
- [ ] Ícone de usuário (User) à esquerda
- [ ] Validação visual (verde/vermelho) à direita

- [ ] Label "Senha" (branco, text-sm)
- [ ] Placeholder "••••••••" (8 bullets)
- [ ] Ícone de cadeado (Lock) à esquerda
- [ ] Ícone de olho (Eye/EyeOff) à direita
- [ ] Validação visual (verde/vermelho) antes do olho

**Botão Entrar:**
- [ ] Texto "Entrar" (font-semibold)
- [ ] Gradiente vermelho (from-[#D50000] to-[#B00000])
- [ ] Hover: escala 1.02 + sombra maior
- [ ] Loading: spinner + "Entrando..."

**Links:**
- [ ] "Esqueceu sua senha?" (esquerda, cinza)
- [ ] "Criar nova conta" (direita, vermelho)
- [ ] Hover funciona em ambos

**Divisor:**
- [ ] Linha horizontal sutil
- [ ] Texto "ou" centralizado
- [ ] Background semi-transparente com blur
- [ ] Formato pill (rounded-full)

**Botão Google:**
- [ ] Logo do Google (cores corretas)
- [ ] Texto "Continuar com Google" (font-medium)
- [ ] Fundo branco com borda sutil
- [ ] Hover: bg-gray-100

---

## 🎯 Testes Funcionais

### Teste A: Primeira Entrada
1. Abra a aplicação em aba anônima
2. Splash deve aparecer automaticamente
3. Aguarde 3 segundos
4. Login deve aparecer após fade out

**✅ Sucesso se:**
- Splash mostra todas animações
- Transição é suave
- Login carrega corretamente

---

### Teste B: Validação de Campos
1. Clique no campo E-mail
2. Digite "teste" (inválido)
3. Clique fora
4. Ícone vermelho (AlertCircle) deve aparecer

5. Digite "teste@email.com" (válido)
6. Ícone verde (CheckCircle2) deve aparecer

7. Repita para senha (mínimo 6 caracteres)

**✅ Sucesso se:**
- Validação acontece em tempo real
- Ícones corretos aparecem
- Bordas mudam de cor

---

### Teste C: Interatividade
1. **Mostrar/Ocultar Senha:**
   - Clique no ícone de olho
   - Senha deve alternar entre visível/oculta

2. **Hover nos Links:**
   - Passe mouse sobre "Esqueceu sua senha?"
   - Texto deve ficar branco
   - Passe mouse sobre "Criar nova conta"
   - Texto deve ficar vermelho claro

3. **Hover no Botão:**
   - Passe mouse sobre "Entrar"
   - Botão deve escalar ligeiramente (1.02x)
   - Sombra deve aumentar

**✅ Sucesso se:**
- Todas as interações respondem
- Transições são suaves
- Nenhum erro no console

---

### Teste D: Estados de Loading
1. Digite credenciais válidas
2. Clique em "Entrar"
3. Observe o botão

**✅ Sucesso se:**
- Spinner aparece
- Texto muda para "Entrando..."
- Botão fica desabilitado
- Não pode clicar múltiplas vezes

---

### Teste E: Login com Google
1. Clique em "Continuar com Google"
2. Observe redirecionamento

**✅ Sucesso se:**
- Redirecionamento acontece
- Nenhum erro aparece
- Loading state é mostrado

---

## 📱 Teste Responsivo

### Mobile (< 768px)
- [ ] Splash screen adapta ao tamanho
- [ ] Partículas respondem ao viewport
- [ ] Logo tem tamanho apropriado
- [ ] Formulário de login é legível
- [ ] Botões são tocáveis (min 44x44px)

### Tablet (768px - 1024px)
- [ ] Layout centralizado
- [ ] Espaçamentos proporcionais
- [ ] Todos os elementos visíveis

### Desktop (> 1024px)
- [ ] Card de login max-w-md
- [ ] Splash screen preenche tela
- [ ] Efeitos visuais destacados

---

## 🐛 Possíveis Problemas

### Problema: Splash não aparece
**Solução:**
- Verifique se `showSplash` inicia como `true`
- Confirme import do `SplashScreen`
- Limpe cache do navegador

### Problema: Animações travadas
**Solução:**
- Verifique se Motion/React está importado
- Confirme GPU acceleration habilitada
- Reduza número de partículas se necessário

### Problema: Textos não atualizados
**Solução:**
- Force refresh (Ctrl+Shift+R)
- Verifique se arquivo Login.tsx foi salvo
- Confirme que não há cache service worker

---

## 📊 Performance Esperada

| Métrica | Valor Esperado |
|---------|----------------|
| **Splash Load Time** | < 100ms |
| **Animações FPS** | 60fps |
| **Splash → Login** | ~3.6s |
| **First Paint** | < 1s |
| **Interactive** | < 1.5s |

---

## ✅ Critérios de Aprovação

### Mínimo (MVP)
- [x] Splash aparece e desaparece
- [x] Login carrega após splash
- [x] Todos os textos corretos
- [x] Campos funcionam
- [x] Validação funciona

### Ideal (Premium)
- [x] Todas as animações fluidas
- [x] Efeitos visuais destacados
- [x] Transições suaves
- [x] Performance 60fps
- [x] Responsivo em todos os dispositivos

---

## 🎬 Sequência Ideal (Timeline)

```
0.0s  │ Splash aparece
      │ ├─ Fundo gradiente renderiza
      │ ├─ Grid tecnológico inicia movimento
      │ └─ Partículas começam a flutuar
      │
0.4s  │ Logo aparece (bounce)
      │ └─ Glow effect ativo
      │
0.8s  │ Texto e barra de progresso aparecem
      │ └─ Barra inicia preenchimento
      │
3.0s  │ Splash completa
      │ └─ Fade out inicia (600ms)
      │
3.6s  │ Login aparece
      │ ├─ "Bem-vindo de volta"
      │ ├─ Campos de E-mail/Senha
      │ └─ Botões Entrar/Google
```

---

**Data:** 25 de outubro de 2025  
**Status:** ✅ Pronto para teste

Desenvolvido pela equipe Conecta Cup 🏎️
