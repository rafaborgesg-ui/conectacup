
  import { defineConfig } from 'vite';
  import react from '@vitejs/plugin-react-swc';
  import { VitePWA } from 'vite-plugin-pwa';
  import path from 'path';

  export default defineConfig({
    plugins: [
      react(),
      VitePWA({
        registerType: 'autoUpdate',
        // Evita registro duplo do SW: usamos registro manual via virtual:pwa-register em App.tsx
        injectRegister: null,
        workbox: {
          navigateFallback: '/index.html',
          globPatterns: ['**/*.{js,css,html,ico,png,svg,webp,woff2}'],
          maximumFileSizeToCacheInBytes: 6 * 1024 * 1024, // permite até ~6MB
          globIgnores: [
            'assets/259c0344182d6b72c303b23272de9d50609534c2*.*', // grande background
          ],
          runtimeCaching: [
            {
              urlPattern: ({ request }) => request.destination === 'image',
              handler: 'CacheFirst',
              options: {
                cacheName: 'images',
                expiration: { maxEntries: 200, maxAgeSeconds: 60 * 60 * 24 * 30 },
                cacheableResponse: { statuses: [0, 200] },
              },
            },
            {
              // Supabase REST/storage/auth
              urlPattern: /^https:\/\/[a-zA-Z0-9-.]+\.supabase\.co\/.*/,
              handler: 'NetworkFirst',
              options: {
                cacheName: 'supabase-api',
                networkTimeoutSeconds: 10,
                cacheableResponse: { statuses: [0, 200, 204] },
                expiration: { maxEntries: 200, maxAgeSeconds: 60 * 60 * 24 },
              },
            },
          ],
        },
        manifest: {
          id: '/?source=pwa',
          name: 'Conecta Cup',
          short_name: 'Conectacup',
          description: 'Gestão operacional Porsche Cup',
          theme_color: '#000000',
          background_color: '#000000',
          display: 'standalone',
          display_override: ['standalone', 'fullscreen'],
          start_url: '/',
          scope: '/',
          orientation: 'portrait',
          categories: ['productivity', 'business'],
          icons: [
            { src: '/icons/iconeapp.png', sizes: '192x192', type: 'image/png', purpose: 'any' },
            { src: '/icons/iconeapp.png', sizes: '512x512', type: 'image/png', purpose: 'any' },
            { src: '/icons/iconeapp.png', sizes: '512x512', type: 'image/png', purpose: 'maskable' },
          ],
          shortcuts: [
            { name: 'Gestão de Carga', short_name: 'Carga', url: '/?m=gestao-carga', description: 'Abrir Gestão de Carga' },
            { name: 'Entrada de Estoque', short_name: 'Estoque', url: '/?m=tire-stock' },
            { name: 'Relatórios', short_name: 'Relatórios', url: '/?m=reports' },
          ],
        },
        includeAssets: ['icons/iconeapp.png'],
      }),
    ],
    resolve: {
      extensions: ['.js', '.jsx', '.ts', '.tsx', '.json'],
      alias: {
        'vaul@1.1.2': 'vaul',
        'sonner@2.0.3': 'sonner',
        'recharts@2.15.2': 'recharts',
        'react-resizable-panels@2.1.7': 'react-resizable-panels',
        'react-hook-form@7.55.0': 'react-hook-form',
        'react-day-picker@8.10.1': 'react-day-picker',
        'next-themes@0.4.6': 'next-themes',
        'lucide-react@0.487.0': 'lucide-react',
        'input-otp@1.4.2': 'input-otp',
        'hono@4': 'hono',
        'figma:asset/714dd59c6efd84795d4e42fadd6c600fd2c510ee.png': path.resolve(__dirname, './src/assets/714dd59c6efd84795d4e42fadd6c600fd2c510ee.png'),
        'figma:asset/3ae08ff326060d9638298673cda23da363101b9f.png': path.resolve(__dirname, './src/assets/3ae08ff326060d9638298673cda23da363101b9f.png'),
        'figma:asset/259c0344182d6b72c303b23272de9d50609534c2.png': path.resolve(__dirname, './src/assets/259c0344182d6b72c303b23272de9d50609534c2.png'),
        'embla-carousel-react@8.6.0': 'embla-carousel-react',
        'cmdk@1.1.1': 'cmdk',
        'class-variance-authority@0.7.1': 'class-variance-authority',
        '@radix-ui/react-tooltip@1.1.8': '@radix-ui/react-tooltip',
        '@radix-ui/react-toggle@1.1.2': '@radix-ui/react-toggle',
        '@radix-ui/react-toggle-group@1.1.2': '@radix-ui/react-toggle-group',
        '@radix-ui/react-tabs@1.1.3': '@radix-ui/react-tabs',
        '@radix-ui/react-switch@1.1.3': '@radix-ui/react-switch',
        '@radix-ui/react-slot@1.1.2': '@radix-ui/react-slot',
        '@radix-ui/react-slider@1.2.3': '@radix-ui/react-slider',
        '@radix-ui/react-separator@1.1.2': '@radix-ui/react-separator',
        '@radix-ui/react-select@2.1.6': '@radix-ui/react-select',
        '@radix-ui/react-scroll-area@1.2.3': '@radix-ui/react-scroll-area',
        '@radix-ui/react-radio-group@1.2.3': '@radix-ui/react-radio-group',
        '@radix-ui/react-progress@1.1.2': '@radix-ui/react-progress',
        '@radix-ui/react-popover@1.1.6': '@radix-ui/react-popover',
        '@radix-ui/react-navigation-menu@1.2.5': '@radix-ui/react-navigation-menu',
        '@radix-ui/react-menubar@1.1.6': '@radix-ui/react-menubar',
        '@radix-ui/react-label@2.1.2': '@radix-ui/react-label',
        '@radix-ui/react-hover-card@1.1.6': '@radix-ui/react-hover-card',
        '@radix-ui/react-dropdown-menu@2.1.6': '@radix-ui/react-dropdown-menu',
        '@radix-ui/react-dialog@1.1.6': '@radix-ui/react-dialog',
        '@radix-ui/react-context-menu@2.2.6': '@radix-ui/react-context-menu',
        '@radix-ui/react-checkbox@1.1.4': '@radix-ui/react-checkbox',
        '@radix-ui/react-avatar@1.1.3': '@radix-ui/react-avatar',
        '@radix-ui/react-aspect-ratio@1.1.2': '@radix-ui/react-aspect-ratio',
        '@radix-ui/react-accordion@1.2.3': '@radix-ui/react-accordion',
        '@jsr/supabase__supabase-js@2.49.8': '@jsr/supabase__supabase-js',
        '@jsr/supabase__supabase-js@2': '@jsr/supabase__supabase-js',
        '@': path.resolve(__dirname, './src'),
      },
    },
    build: {
      target: 'esnext',
      outDir: 'build',
      rollupOptions: {
        output: {
          manualChunks: {
            react: ['react', 'react-dom'],
            recharts: ['recharts'],
            xlsx: ['xlsx'],
            pdf: ['jspdf', 'jspdf-autotable', 'html2canvas'],
            supabase: ['@supabase/supabase-js', '@jsr/supabase__supabase-js'],
            icons: ['lucide-react'],
          },
        },
      },
      chunkSizeWarningLimit: 2000,
    },
    server: {
      port: 3000,
      open: true,
    },
  });