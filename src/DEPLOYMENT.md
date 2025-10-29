# 🚀 Deployment Guide - Porsche Cup Brasil PWA

## ✅ Checklist Pré-Deploy

### **1. PWA Assets**
- [ ] Ícones gerados (icon-72.png até icon-512.png)
- [ ] Manifest validado (/manifest.json)
- [ ] Service Worker testado (/sw.js)
- [ ] Screenshots criados (opcional)

### **2. Build**
- [ ] `npm run build` sem erros
- [ ] Assets otimizados
- [ ] Bundle size aceitável (< 500KB inicial)

### **3. Teste Local**
- [ ] Lighthouse PWA score > 90
- [ ] Service Worker funcionando
- [ ] App instalável
- [ ] Offline funciona

### **4. Configuração**
- [ ] HTTPS configurado
- [ ] Domínio apontado
- [ ] DNS propagado

---

## 📦 Opções de Deploy

### **Opção 1: Vercel (RECOMENDADO - Mais Fácil)**

#### **Por que Vercel?**
- ✅ HTTPS automático
- ✅ CDN global
- ✅ Zero-config para React
- ✅ Deploys automáticos (Git)
- ✅ Preview deployments
- ✅ Grátis para hobby

#### **Deploy em 3 passos:**

```bash
# 1. Instale Vercel CLI
npm i -g vercel

# 2. Login
vercel login

# 3. Deploy
vercel --prod
```

#### **Ou via Git:**
1. Push para GitHub/GitLab
2. Conecte no [Vercel Dashboard](https://vercel.com)
3. Import repository
4. Deploy automático! 🎉

#### **Configuração (vercel.json):**
```json
{
  "buildCommand": "npm run build",
  "outputDirectory": "dist",
  "framework": "vite",
  "rewrites": [
    { "source": "/(.*)", "destination": "/index.html" }
  ],
  "headers": [
    {
      "source": "/sw.js",
      "headers": [
        {
          "key": "Cache-Control",
          "value": "max-age=0, no-cache, no-store, must-revalidate"
        }
      ]
    },
    {
      "source": "/manifest.json",
      "headers": [
        {
          "key": "Content-Type",
          "value": "application/manifest+json"
        }
      ]
    }
  ]
}
```

---

### **Opção 2: Netlify**

#### **Deploy:**
```bash
# 1. Instale Netlify CLI
npm i -g netlify-cli

# 2. Login
netlify login

# 3. Deploy
netlify deploy --prod
```

#### **Configuração (netlify.toml):**
```toml
[build]
  command = "npm run build"
  publish = "dist"

[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200

[[headers]]
  for = "/sw.js"
  [headers.values]
    Cache-Control = "max-age=0, no-cache, no-store, must-revalidate"

[[headers]]
  for = "/manifest.json"
  [headers.values]
    Content-Type = "application/manifest+json"
    Cache-Control = "public, max-age=3600"
```

---

### **Opção 3: Firebase Hosting**

```bash
# 1. Instale Firebase CLI
npm i -g firebase-tools

# 2. Login
firebase login

# 3. Inicialize
firebase init hosting

# 4. Configure:
# - Public directory: dist
# - SPA: Yes
# - GitHub Actions: No (ou Yes se quiser CI/CD)

# 5. Build
npm run build

# 6. Deploy
firebase deploy --only hosting
```

---

### **Opção 4: VPS (Ubuntu + Nginx)**

#### **Pré-requisitos:**
- Ubuntu 20.04+ ou Debian 11+
- Nginx instalado
- Certbot para SSL (Let's Encrypt)

#### **Passo a Passo:**

```bash
# 1. SSH no servidor
ssh user@seu-servidor.com

# 2. Instale dependências
sudo apt update
sudo apt install -y nginx certbot python3-certbot-nginx git nodejs npm

# 3. Clone o repositório
cd /var/www
sudo git clone https://github.com/seu-usuario/porsche-cup.git
cd porsche-cup

# 4. Instale dependências
npm install

# 5. Build
npm run build

# 6. Configure Nginx
sudo cp nginx.conf /etc/nginx/sites-available/porsche-cup

# Edite o arquivo:
sudo nano /etc/nginx/sites-available/porsche-cup
# - Ajuste server_name
# - Ajuste root path
# - Ajuste SSL paths (temporariamente comente as linhas SSL)

# 7. Ative o site
sudo ln -s /etc/nginx/sites-available/porsche-cup /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx

# 8. Configure SSL (Let's Encrypt)
sudo certbot --nginx -d seu-dominio.com -d www.seu-dominio.com

# 9. Auto-renovação SSL
sudo certbot renew --dry-run

# 10. Descomente linhas SSL no nginx.conf e recarregue
sudo nano /etc/nginx/sites-available/porsche-cup
sudo systemctl reload nginx
```

#### **Deploy automático com Git:**

```bash
# No servidor, crie um post-receive hook
cd /var/www/porsche-cup
cat > .git/hooks/post-receive << 'EOF'
#!/bin/bash
cd /var/www/porsche-cup
git pull origin main
npm install
npm run build
sudo systemctl reload nginx
echo "Deploy completed!"
EOF

chmod +x .git/hooks/post-receive

# No local, adicione o remote
git remote add production user@seu-servidor.com:/var/www/porsche-cup/.git

# Deploy:
git push production main
```

---

### **Opção 5: Docker + Nginx**

#### **Dockerfile:**
```dockerfile
# Build stage
FROM node:18-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Production stage
FROM nginx:alpine
COPY --from=build /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

#### **docker-compose.yml:**
```yaml
version: '3.8'

services:
  web:
    build: .
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./ssl:/etc/nginx/ssl
    restart: unless-stopped
```

#### **Deploy:**
```bash
# Build
docker-compose build

# Run
docker-compose up -d

# Logs
docker-compose logs -f

# Stop
docker-compose down
```

---

## 🔐 SSL/HTTPS (OBRIGATÓRIO para PWA)

### **Opção A: Vercel/Netlify/Firebase**
✅ **Automático!** Nada a fazer.

### **Opção B: Let's Encrypt (VPS)**
```bash
# Instale Certbot
sudo apt install certbot python3-certbot-nginx

# Obtenha certificado
sudo certbot --nginx -d seu-dominio.com -d www.seu-dominio.com

# Auto-renovação (crontab)
sudo crontab -e
# Adicione:
0 3 * * * certbot renew --quiet
```

### **Opção C: Cloudflare (Grátis)**
1. Adicione site no Cloudflare
2. Mude nameservers do domínio
3. SSL/TLS → Full (strict)
4. Pronto! HTTPS automático

---

## 📊 Verificação Pós-Deploy

### **1. PWA Lighthouse**
```bash
# Chrome DevTools
1. F12
2. Lighthouse
3. Categories: Progressive Web App
4. Generate Report
5. Score deve ser > 90
```

### **2. Instalabilidade**

#### **Desktop (Chrome/Edge):**
- [ ] Ícone ➕ aparece na barra de endereço
- [ ] Clique instala o app
- [ ] App abre em janela standalone

#### **Android (Chrome):**
- [ ] Banner "Adicionar à tela inicial" aparece
- [ ] Instalação funciona
- [ ] Ícone correto na home screen
- [ ] Splash screen aparece

#### **iOS (Safari):**
- [ ] Instruções manuais aparecem
- [ ] Adicionar à tela inicial funciona
- [ ] Ícone correto aparece

### **3. Service Worker**
```bash
# DevTools → Application → Service Workers
- [ ] Status: "activated and running"
- [ ] Scope: /
- [ ] Cache storage tem entradas
```

### **4. Manifest**
```bash
# DevTools → Application → Manifest
- [ ] Nome correto
- [ ] Ícones aparecem sem erro
- [ ] Cores corretas
- [ ] Start URL válida
```

### **5. Offline**
```bash
# DevTools → Network → Offline
- [ ] App carrega (pelo menos parcialmente)
- [ ] Cache fallback funciona
```

---

## 🐛 Troubleshooting

### **Service Worker não registra**
```
Causa: HTTPS não configurado
Solução: Verifique certificado SSL
```

### **App não instalável**
```
Requisitos:
✅ HTTPS
✅ Manifest válido
✅ Service Worker
✅ Ícones 192 e 512
✅ start_url serve 200

Debug:
Chrome DevTools → Application → Manifest
Veja erros em vermelho
```

### **Ícones não aparecem**
```
Causa 1: Arquivos não existem
Solução: Verifique /public/icon-*.png

Causa 2: CORS
Solução: Adicione header CORS no servidor
```

### **Cache não atualiza**
```
Causa: Service Worker antigo
Solução:
1. DevTools → Application → Service Workers
2. Click "Unregister"
3. Click "Update on reload"
4. Ctrl + Shift + R (hard refresh)
```

---

## 📈 Performance Optimization

### **1. Code Splitting**
```javascript
// Lazy load routes
const Dashboard = lazy(() => import('./components/Dashboard'));
const TireStockEntry = lazy(() => import('./components/TireStockEntry'));

// Em App.tsx
<Suspense fallback={<Loading />}>
  <Routes>
    <Route path="/" element={<Dashboard />} />
    <Route path="/tire-stock" element={<TireStockEntry />} />
  </Routes>
</Suspense>
```

### **2. Image Optimization**
```bash
# Instale sharp
npm install -D @squoosh/lib

# Otimize imagens antes do build
npm run optimize-images
```

### **3. Bundle Analysis**
```bash
# Instale bundle analyzer
npm install -D rollup-plugin-visualizer

# Adicione ao vite.config
import { visualizer } from 'rollup-plugin-visualizer';

export default {
  plugins: [
    visualizer({ open: true })
  ]
}

# Build e abra o report
npm run build
```

### **4. Lighthouse CI**
```bash
# Instale
npm install -g @lhci/cli

# Configure .lighthouserc.json
{
  "ci": {
    "collect": {
      "url": ["https://seu-dominio.com"],
      "numberOfRuns": 3
    },
    "assert": {
      "preset": "lighthouse:recommended",
      "assertions": {
        "categories:pwa": ["error", {"minScore": 0.9}]
      }
    }
  }
}

# Run
lhci autorun
```

---

## 🔄 CI/CD com GitHub Actions

### **.github/workflows/deploy.yml:**
```yaml
name: Deploy PWA

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Node
      uses: actions/setup-node@v3
      with:
        node-version: '18'
        cache: 'npm'
    
    - name: Install dependencies
      run: npm ci
    
    - name: Build
      run: npm run build
    
    - name: Deploy to Vercel
      uses: amondnet/vercel-action@v25
      with:
        vercel-token: ${{ secrets.VERCEL_TOKEN }}
        vercel-org-id: ${{ secrets.VERCEL_ORG_ID }}
        vercel-project-id: ${{ secrets.VERCEL_PROJECT_ID }}
        vercel-args: '--prod'
```

---

## 📊 Monitoramento

### **Google Analytics (GA4)**
```javascript
// Adicione ao index.html
<script async src="https://www.googletagmanager.com/gtag/js?id=G-XXXXXXXXXX"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());
  gtag('config', 'G-XXXXXXXXXX');
</script>
```

### **Sentry (Error Tracking)**
```bash
npm install @sentry/react @sentry/tracing
```

```javascript
// App.tsx
import * as Sentry from "@sentry/react";

Sentry.init({
  dsn: "https://xxx@xxx.ingest.sentry.io/xxx",
  integrations: [new Sentry.BrowserTracing()],
  tracesSampleRate: 1.0,
});
```

---

## ✅ Checklist Final

### **Pré-Deploy**
- [ ] Build sem erros
- [ ] Lighthouse > 90
- [ ] Ícones gerados
- [ ] Service Worker testado
- [ ] SSL configurado

### **Deploy**
- [ ] Deploy realizado
- [ ] DNS propagado
- [ ] HTTPS funcionando
- [ ] Manifest válido
- [ ] Service Worker ativo

### **Pós-Deploy**
- [ ] App instalável
- [ ] Offline funciona
- [ ] Performance boa (< 3s LCP)
- [ ] Monitoramento ativo
- [ ] Backups configurados

---

## 🎯 Próximos Passos

1. **Escolha plataforma** (Vercel recomendado)
2. **Configure domínio** e SSL
3. **Gere ícones** (se ainda não fez)
4. **Build** e teste local
5. **Deploy**! 🚀
6. **Verifique** com Lighthouse
7. **Teste instalação** em múltiplos devices

---

**🏁 Porsche Cup Brasil**  
*Sistema de Gestão de Pneus - PWA Profissional*
