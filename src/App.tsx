import { useState, useEffect, lazy, Suspense, memo } from 'react';
import { Toaster } from './components/ui/sonner';
import { Sidebar } from './components/Sidebar';
import { MobileNav } from './components/MobileNav';
import { Login } from './components/Login';
import { SignUp } from './components/SignUp';
import { PWAInstallPrompt } from './components/PWAInstallPrompt';
import { Onboarding } from './components/Onboarding';
import { OnboardingChecklist } from './components/OnboardingChecklist';
import { QuickTips } from './components/QuickTips';
import { ZoomPrevention } from './components/ZoomPrevention';
import { DatabaseMigrationAlert } from './components/DatabaseMigrationAlert';
import { CacheBuster } from './components/CacheBuster';
import { LoadingSpinner } from './components/LoadingSpinner';
import { ErrorBoundary } from './components/ErrorBoundary';
import { useRef } from 'react';

// 🚨 PROTEÇÃO GLOBAL: Garante que só há UM listener de auth em toda a aplicação
let GLOBAL_AUTH_LISTENER_INITIALIZED = false;

import { registerServiceWorker, setupInstallPrompt } from './utils/pwa';
import { createClient, getCurrentUser } from './utils/supabase/client';
import { TireStatusProvider } from './utils/TireStatusContext';
import { projectId } from './utils/supabase/info';
import { ProtectedRoute } from './components/ProtectedRoute';
import { PAGES } from './utils/permissions';

// 🚀 LAZY LOADING - Componentes pesados carregados apenas quando necessários
// Protege contra erro de chunk desincronizado (cache antigo do HTML apontando para hash novo)
function lazyWithRetry(factory: () => Promise<any>) {
  return lazy(() =>
    factory().catch((error: any) => {
      const msg = String((error as any)?.message || error);
      if (
        msg.includes('Failed to fetch dynamically imported module') ||
        msg.includes('Importing a module script failed') ||
        msg.includes('Loading chunk')
      ) {
        console.warn('⚠️ Erro ao carregar chunk dinâmico. Forçando reload para sincronizar cache...');
        // Hard refresh para alinhar index.html e assets com hash
        window.location.reload();
        // Retorna uma Promise que nunca resolve apenas para satisfazer o tipo até o reload
        return new Promise(() => {});
      }
      throw error;
    })
  );
}

const Welcome = lazyWithRetry(() => import('./components/Welcome'));
const Dashboard = lazyWithRetry(() => import('./components/Dashboard').then(m => ({ default: m.Dashboard })));
const TireStockEntry = lazyWithRetry(() => import('./components/TireStockEntry').then(m => ({ default: m.TireStockEntry })));
const TireDiscard = lazyWithRetry(() => import('./components/TireDiscard').then(m => ({ default: m.TireDiscard })));
const DiscardReports = lazyWithRetry(() => import('./components/DiscardReports').then(m => ({ default: m.DiscardReports })));
const TireModelRegistration = lazyWithRetry(() => import('./components/TireModelRegistration').then(m => ({ default: m.TireModelRegistration })));
const ContainerRegistration = lazyWithRetry(() => import('./components/ContainerRegistration').then(m => ({ default: m.ContainerRegistration })));
const TireMovement = lazyWithRetry(() => import('./components/TireMovement').then(m => ({ default: m.TireMovement })));
const TireConsumption = lazyWithRetry(() => import('./components/TireConsumption').then(m => ({ default: m.TireConsumption })));
const TireStatusChange = lazyWithRetry(() => import('./components/TireStatusChange').then(m => ({ default: m.TireStatusChange })));
const StatusRegistration = lazyWithRetry(() => import('./components/StatusRegistration').then(m => ({ default: m.StatusRegistration })));
const ARCSDataUpdate = lazyWithRetry(() => import('./components/ARCSDataUpdate').then(m => ({ default: m.ARCSDataUpdate })));
const Reports = lazyWithRetry(() => import('./components/Reports').then(m => ({ default: m.Reports })));
const DataImport = lazyWithRetry(() => import('./components/DataImport').then(m => ({ default: m.DataImport })));
const StockAdjustment = lazyWithRetry(() => import('./components/StockAdjustment').then(m => ({ default: m.StockAdjustment })));
const UserManagement = lazyWithRetry(() => import('./components/UserManagement').then(m => ({ default: m.UserManagement })));
const MasterData = lazyWithRetry(() => import('./components/MasterData').then(m => ({ default: m.MasterData })));
const AccessProfileManagement = lazyWithRetry(() => import('./components/AccessProfileManagement').then(m => ({ default: m.AccessProfileManagement })));

// 🎯 Loading Fallback Component
const ModuleLoadingFallback = memo(() => (
  <div className="flex items-center justify-center min-h-screen bg-gray-50">
    <div className="flex flex-col items-center gap-4">
      <LoadingSpinner size="lg" />
      <p className="text-gray-600 text-sm">Carregando módulo...</p>
    </div>
  </div>
));

// 🚫 Access Denied Component (Memoizado para evitar re-renderizações)
const AccessDenied = memo(() => (
  <div className="flex items-center justify-center min-h-screen">
    <div className="text-center p-8">
      <h2 className="text-gray-900 mb-2">Acesso Negado</h2>
      <p className="text-gray-600">Esta área é restrita para administradores.</p>
    </div>
  </div>
));

/**
 * Setup de usuário de desenvolvimento
 * Cria automaticamente o usuário admin para desenvolvimento local
 */
async function setupDevUser() {
  // Só executa em localhost
  if (window.location.hostname !== 'localhost' && window.location.hostname !== '127.0.0.1') {
    return;
  }
  
  // Verifica se já rodou o setup (cache de 24h)
  const lastSetup = localStorage.getItem('dev-user-setup-timestamp');
  if (lastSetup) {
    const timeSinceSetup = Date.now() - parseInt(lastSetup);
    const ONE_DAY = 24 * 60 * 60 * 1000;
    if (timeSinceSetup < ONE_DAY) {
      return; // Já rodou recentemente
    }
  }
  
  try {
    const response = await fetch(`https://${projectId}.supabase.co/functions/v1/make-server-02726c7c/dev/setup-user`, {
      method: 'POST'
    });
    
    if (response.ok) {
      localStorage.setItem('dev-user-setup-timestamp', Date.now().toString());
      console.log('✅ DEV: Usuário admin configurado');
    }
  } catch (error) {
    console.log('ℹ️ DEV: Setup automático falhou (normal se servidor não estiver rodando)');
  }
}

export default function App() {
  const [currentModule, setCurrentModule] = useState('welcome');
  const [userRole, setUserRole] = useState<string>('operator');
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [isLoading, setIsLoading] = useState(true);
  const [authView, setAuthView] = useState<'login' | 'signup'>('login');
  const [showOnboarding, setShowOnboarding] = useState(false);
  const [dbError, setDbError] = useState<{ code?: string; message?: string } | null>(null);

  // 🔐 PROTEÇÃO ANTI-LOOP: Refs persistem entre re-renders
  const authChangeCount = useRef(0);
  const loopDetected = useRef(false);
  const isProcessingOAuth = useRef(false);
  const authInitialized = useRef(false); // 🚨 NOVA FLAG: Só inicializa auth UMA VEZ
  const lastProcessedEvent = useRef<string>(''); // 🆕 Último evento processado

  useEffect(() => {
    // 🚨 PROTEÇÃO GLOBAL: Verifica flag GLOBAL primeiro
    if (GLOBAL_AUTH_LISTENER_INITIALIZED) {
      console.warn('🚫 GLOBAL: Auth listener já existe - ABORTANDO');
      return;
    }
    
    // 🚨 PROTEÇÃO LOCAL: Verifica flag do componente
    if (authInitialized.current) {
      console.warn('⚠️ LOCAL: Auth já inicializado - IGNORANDO execução do useEffect');
      return;
    }
    
    // Marca como inicializado IMEDIATAMENTE (GLOBAL + LOCAL)
    GLOBAL_AUTH_LISTENER_INITIALIZED = true;
    authInitialized.current = true;
    
    // 🔍 DEBUG: Contador de execuções
    let checkAuthCount = parseInt(sessionStorage.getItem('checkAuthCount') || '0');
    checkAuthCount++;
    sessionStorage.setItem('checkAuthCount', checkAuthCount.toString());
    
    console.log(`\n${'='.repeat(60)}`);
    console.log(`🔍 [${checkAuthCount}x] useEffect EXECUTADO`);
    console.log(`🔍 authChangeCount.current:`, authChangeCount.current);
    console.log(`🔍 loopDetected.current:`, loopDetected.current);
    console.log(`🔍 authInitialized:`, authInitialized.current);
    console.log(`${'='.repeat(60)}\n`);
    
    const checkAuth = async () => {
      try {
        // 🔐 PROTEÇÃO ANTI-LOOP: Detecta se é um OAuth callback
        // OAuth callbacks têm tokens na URL que o Supabase precisa processar
        const urlHash = window.location.hash;
        const urlSearch = window.location.search;
        
        console.log('📍 URL Check:');
        console.log('  Full URL:', window.location.href);
        console.log('  Hash:', urlHash || '(vazio)');
        console.log('  Search:', urlSearch || '(vazio)');
        
        const isOAuthCallback = 
          urlHash.includes('access_token') ||
          urlHash.includes('refresh_token') ||
          urlHash.includes('error=') ||
          urlSearch.includes('code='); // PKCE flow
        
        console.log('  É OAuth callback?', isOAuthCallback);
        
        if (isOAuthCallback) {
          console.log('🔐 ✅ OAuth callback detectado, aguardando processamento...');
          console.log('   Hash preview:', urlHash.substring(0, 60) + '...');
          console.log('   ⏳ Loading continua ativo');
          console.log('   ⏳ onAuthStateChange vai processar\n');
          // NÃO verifica auth ainda - deixa onAuthStateChange processar
          // Continua mostrando loading screen
          return;
        }
        
        console.log('ℹ️ NÃO é OAuth callback - verificando sessão normal...');
        
        // Setup de desenvolvimento (apenas para localhost)
        await setupDevUser();
        
        const user = await getCurrentUser();
        
        if (user) {
          console.log('✅ Usuário autenticado:', user.email);
          setUserRole(user.role);
          setIsAuthenticated(true);
          
          // 🔐 RBAC: Define profileId baseado no role se não estiver definido
          const profileId = user.profileId || user.role;
          
          // Salva dados do usuário separadamente
          localStorage.setItem('porsche-cup-user', JSON.stringify({
            id: user.id,
            email: user.email,
            name: user.name,
            role: user.role,
            profileId, // ✅ Adiciona profileId para sistema RBAC
          }));
          
          // Verifica onboarding
          const onboardingCompleted = localStorage.getItem('onboarding-completed');
          if (!onboardingCompleted) {
            setShowOnboarding(true);
          }
        } else {
          console.log('ℹ️ Nenhuma sessão encontrada - mostrando login');
          setIsAuthenticated(false);
        }
      } catch (error: any) {
        console.warn('Erro na verificação de autenticação:', error);
        setIsAuthenticated(false);
      } finally {
        // Só remove loading se NÃO for OAuth callback
        const urlHash = window.location.hash;
        const urlSearch = window.location.search;
        const isOAuthCallback = 
          urlHash.includes('access_token') ||
          urlHash.includes('refresh_token') ||
          urlSearch.includes('code='); // PKCE flow
        
        if (!isOAuthCallback) {
          setIsLoading(false);
        } else {
          // Timeout de segurança: se OAuth não processar em 10s, remove loading
          setTimeout(() => {
            if (isLoading) {
              setIsLoading(false);
              // Se ainda não autenticou, mostra login
              if (!isAuthenticated) {
                // Limpa URL problemática
                window.history.replaceState(null, '', window.location.pathname);
              }
            }
          }, 10000);
        }
      }
    };
    
    checkAuth();
    
    // 🔐 OAUTH: Supabase processa automaticamente via detectSessionInUrl
    // Detectamos callback para debug, mas NÃO processamos manualmente
    const urlHash = window.location.hash;
    const urlSearch = window.location.search;
    
    if (urlHash.includes('access_token') || urlHash.includes('code=')) {
      console.log('🔐 OAuth callback detectado (HASH):', urlHash.substring(0, 50));
    }
    if (urlSearch.includes('code=')) {
      console.log('🔐 OAuth callback detectado (PKCE):', urlSearch.substring(0, 50));
    }
    
    const supabase = createClient();
    
    // 🔐 OAuth Callback Listener - Detecta retorno do Google OAuth
    const { data: { subscription } } = supabase.auth.onAuthStateChange(async (event, session) => {
      // 🚨 PROTEÇÃO: Ignora se event for undefined/null
      if (!event) {
        console.warn('⚠️ Evento de auth é null/undefined - ignorando');
        return;
      }
      
      // 🛠️ TRATAMENTO ESPECIAL: Após OAuth, o Supabase pode disparar INITIAL_SESSION
      // Se houver sessão, tratamos como SIGNED_IN para concluir o fluxo
      if (event === 'INITIAL_SESSION' && session?.user) {
        console.log('🔐 INITIAL_SESSION com sessão detectada - tratando como SIGNED_IN');
        event = 'SIGNED_IN';
      }

      // 🎯 FILTRAGEM INTELIGENTE: Ignora apenas eventos realmente automáticos e não críticos
      const EVENTOS_IGNORADOS = ['TOKEN_REFRESHED', 'USER_UPDATED'];
      if (EVENTOS_IGNORADOS.includes(event)) {
        console.log(`ℹ️ Evento ${event} ignorado (automático do Supabase)`);
        return;
      }
      
      // 🚫 ANTI-DUPLICAÇÃO: Ignora eventos duplicados consecutivos
      const eventKey = `${event}-${session?.user?.id || 'no-user'}`;
      if (lastProcessedEvent.current === eventKey) {
        console.log(`⚠️ Evento duplicado ignorado: ${event}`);
        return; // NÃO processa evento idêntico
      }
      lastProcessedEvent.current = eventKey;
      
      authChangeCount.current++;
      console.log(`🔐 Auth mudou [${authChangeCount.current}]: ${event}`, session ? '(com sessão)' : '(sem sessão)');
      
      // PROTEÇÃO ANTI-LOOP: Para tudo após 3 tentativas
      if (authChangeCount.current > 3 || loopDetected.current) {
        if (!loopDetected.current) {
          console.error(`⚠️ Loop OAuth detectado! Auth mudou ${authChangeCount.current} vezes`);
          console.error('🛑 PARANDO processamento para evitar loop infinito');
          console.error('🛑 DESATIVANDO listener para prevenir mais eventos');
          loopDetected.current = true;
          
          // Remove loading se estiver preso
          setIsLoading(false);
          
          // Limpa URL OAuth se houver
          if (window.location.hash || window.location.search) {
            window.history.replaceState(null, '', window.location.pathname);
          }
          
          // 🚨 DESINSCREVE o listener para PARAR completamente
          subscription.unsubscribe();
        }
        return; // Ignora se está em loop
      }
      
  if (event === 'SIGNED_IN' && session && !isProcessingOAuth.current) {
        console.log('✅ SIGNED_IN detectado - processando...');
        isProcessingOAuth.current = true;
        
        // ⭐ FALLBACK IMEDIATO: Se já tem role no metadata, usa direto
        const existingRole = session.user.user_metadata?.role;
        if (existingRole) {
          console.log('⚡ FAST PATH: Role já existe no metadata:', existingRole);
          
          setUserRole(existingRole);
          setIsAuthenticated(true);
          setIsLoading(false);
          
          const userName = session.user.user_metadata?.name || 
                          session.user.user_metadata?.full_name || 
                          session.user.email?.split('@')[0] || 
                          'Usuário';
          
          // 🔐 RBAC: Define profileId baseado no role
          const profileId = session.user.user_metadata?.profileId || existingRole;
          
          localStorage.setItem('porsche-cup-user', JSON.stringify({
            id: session.user.id,
            email: session.user.email,
            name: userName,
            role: existingRole,
            profileId, // ✅ Adiciona profileId para sistema RBAC
          }));
          
          // ✅ Limpa URL OAuth após processar (hash OU query string)
          if (window.location.hash || window.location.search) {
            window.history.replaceState(null, '', window.location.pathname);
          }
          
          isProcessingOAuth.current = false;
          return;
        }
        
        try {
          console.log('🔄 Chamando ensure-role...');
          // Garante que usuário OAuth tenha role definida
          const ensureRoleResponse = await fetch(
            `https://${projectId}.supabase.co/functions/v1/make-server-02726c7c/auth/ensure-role`,
            {
              method: 'POST',
              headers: {
                'Authorization': `Bearer ${session.access_token}`,
                'Content-Type': 'application/json',
              },
            }
          );
          
          if (ensureRoleResponse.ok) {
            const ensureRoleData = await ensureRoleResponse.json();
            console.log('✅ ensure-role OK:', ensureRoleData);
            
            // Atualiza estado com dados do usuário
            if (ensureRoleData.user) {
              setUserRole(ensureRoleData.user.role);
              setIsAuthenticated(true);
              
              // 🔐 RBAC: Define profileId baseado no role
              const profileId = ensureRoleData.user.profileId || ensureRoleData.user.role;
              
              localStorage.setItem('porsche-cup-user', JSON.stringify({
                id: ensureRoleData.user.id,
                email: ensureRoleData.user.email,
                name: ensureRoleData.user.name,
                role: ensureRoleData.user.role,
                profileId, // ✅ Adiciona profileId para sistema RBAC
              }));
              
              // ✅ IMPORTANTE: Remove loading após OAuth
              setIsLoading(false);
              
              // Verifica onboarding
              const onboardingCompleted = localStorage.getItem('onboarding-completed');
              if (!onboardingCompleted) {
                setShowOnboarding(true);
              }
              
              // ✅ CRÍTICO: Limpa URL OAuth após processamento
              if (window.location.hash || window.location.search) {
                window.history.replaceState(null, '', window.location.pathname);
              }
            }
          } else {
            console.warn('⚠️ ensure-role FALHOU - usando fallback');
            // ⭐ FALLBACK DIRETO: Define role='operator' localmente
            
            const defaultRole = 'operator';
            const userName = session.user.user_metadata?.name || 
                            session.user.user_metadata?.full_name || 
                            session.user.email?.split('@')[0] || 
                            'Usuário';
            
            setUserRole(defaultRole);
            setIsAuthenticated(true);
            setIsLoading(false);
            
            // 🔐 RBAC: Define profileId baseado no role
            const profileId = session.user.user_metadata?.profileId || defaultRole;
            
            localStorage.setItem('porsche-cup-user', JSON.stringify({
              id: session.user.id,
              email: session.user.email,
              name: userName,
              role: defaultRole,
              profileId, // ✅ Adiciona profileId para sistema RBAC
            }));
            
            const onboardingCompleted = localStorage.getItem('onboarding-completed');
            if (!onboardingCompleted) {
              setShowOnboarding(true);
            }
            
            // Limpa URL OAuth
            if (window.location.hash || window.location.search) {
              window.history.replaceState(null, '', window.location.pathname);
            }
          }
        } catch (error) {
          console.error('❌ Erro ao chamar ensure-role:', error);
          // ⭐ FALLBACK CRÍTICO: Define role='operator' localmente SEM servidor
          
          const defaultRole = 'operator';
          const userName = session.user.user_metadata?.name || 
                          session.user.user_metadata?.full_name || 
                          session.user.email?.split('@')[0] || 
                          'Usuário';
          
          setUserRole(defaultRole);
          setIsAuthenticated(true);
          setIsLoading(false);
          
          // 🔐 RBAC: Define profileId baseado no role
          const profileId = session.user.user_metadata?.profileId || defaultRole;
          
          localStorage.setItem('porsche-cup-user', JSON.stringify({
            id: session.user.id,
            email: session.user.email,
            name: userName,
            role: defaultRole,
            profileId, // ✅ Adiciona profileId para sistema RBAC
          }));
          
          const onboardingCompleted = localStorage.getItem('onboarding-completed');
          if (!onboardingCompleted) {
            setShowOnboarding(true);
          }
          
          // Limpa hash
          if (window.location.hash.includes('access_token')) {
            window.history.replaceState(null, '', window.location.pathname);
          }
        } finally {
          isProcessingOAuth.current = false;
        }
      } else if (event === 'SIGNED_OUT') {
        console.log('👋 SIGNED_OUT detectado - limpando sessão');
        setIsAuthenticated(false);
        setUserRole('');
        localStorage.removeItem('porsche-cup-user');
        setIsLoading(false);
      } else {
        // Qualquer outro evento (PASSWORD_RECOVERY, etc)
        console.log(`ℹ️ Evento ${event} recebido mas não processado`);
      }
    });
    
    // Timeout de segurança: Reseta contador após 2 segundos
    // Isso previne que um loop temporário bloqueie auth permanentemente
    const resetCounterTimeout = setTimeout(() => {
      if (authChangeCount.current > 0) {
        console.log(`🔄 Auto-reset: Contador de auth changes resetado (estava em ${authChangeCount.current})`);
        authChangeCount.current = 0;
        loopDetected.current = false;
        lastProcessedEvent.current = '';
      }
    }, 2000);
    
    // Inicializa PWA
    registerServiceWorker();
    setupInstallPrompt();
    
    // Expõe função global para reativar onboarding (silencioso)
    (window as any).resetOnboarding = () => {
      localStorage.removeItem('onboarding-completed');
      localStorage.removeItem('onboarding-checklist-dismissed');
      localStorage.removeItem('quick-tips-disabled');
      localStorage.removeItem('dismissed-tips');
      window.location.reload();
    };
    
    // Cleanup: Remove listener quando componente desmontar
    return () => {
      console.log('🧹 Limpando auth listener e resetando flags');
      subscription.unsubscribe();
      clearTimeout(resetCounterTimeout);
      // 🚨 IMPORTANTE: Reset flags para permitir re-inicialização em HMR/dev
      GLOBAL_AUTH_LISTENER_INITIALIZED = false;
      authInitialized.current = false;
    };
  }, []);

  const handleModuleChange = (module: string) => {
    setCurrentModule(module);
  };

  const handleLogin = (role: string) => {
    setUserRole(role);
    setIsAuthenticated(true);
    setAuthView('login'); // Reset auth view
  };

  const handleSignUpSuccess = () => {
    setAuthView('login'); // Volta para login após cadastro
  };

  const handleLogout = async () => {
    try {
      // Logout do Supabase Auth
      const supabase = createClient();
      await supabase.auth.signOut();
    } catch (error) {
      console.error('Logout error:', error);
    } finally {
      // Limpa dados do usuário (Supabase Auth já limpa sua própria sessão)
      localStorage.removeItem('porsche-cup-user');
      setIsAuthenticated(false);
      setUserRole('operator');
    }
  };

  // Loading state
  if (isLoading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center p-4">
        <div className="flex flex-col items-center gap-4 max-w-md">
          <div className="w-12 h-12 border-4 border-[#D50000] border-t-transparent rounded-full animate-spin" />
          <p className="text-gray-600 text-sm">Verificando autenticação...</p>
          
          {/* Info DEV - Apenas em localhost */}
          {(window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1') && (
            <div className="mt-6 p-4 bg-blue-50 border border-blue-200 rounded-lg text-sm">
              <p className="text-blue-900 font-medium mb-2">💻 Modo Desenvolvimento</p>
              <p className="text-blue-700 text-xs mb-2">
                Configurando usuário admin automaticamente...
              </p>
              <div className="mt-2 p-2 bg-white rounded border border-blue-200">
                <p className="text-blue-800 text-xs font-mono">
                  <strong>Email:</strong> rafael.borges@porschegt3cup.com.br<br />
                  <strong>Senha:</strong> Porschegt3cupHere
                </p>
              </div>
            </div>
          )}
        </div>
      </div>
    );
  }

  // Auth screens (Login & SignUp)
  if (!isAuthenticated) {
    return (
      <ErrorBoundary>
        {authView === 'login' ? (
          <Login 
            onLogin={handleLogin} 
            onSignUp={() => setAuthView('signup')}
          />
        ) : (
          <SignUp 
            onSignUpSuccess={handleSignUpSuccess}
            onBackToLogin={() => setAuthView('login')}
          />
        )}
        <Toaster />
      </ErrorBoundary>
    );
  }

  // Main application
  return (
    <ErrorBoundary>
      <TireStatusProvider onError={setDbError}>
      {/* ✅ WCAG 2.1 AA - Skip Links para Navegação por Teclado */}
      <a 
        href="#main-content" 
        className="sr-only focus:not-sr-only focus:fixed focus:top-4 focus:left-4 
                   focus:z-[9999] focus:px-4 focus:py-2 focus:bg-[#D50000] 
                   focus:text-white focus:rounded-lg focus:shadow-lg
                   focus:outline-none focus:ring-2 focus:ring-white focus:ring-offset-2"
      >
        Pular para conteúdo principal
      </a>

      {/* Cache Buster - Detecta código desatualizado */}
      <CacheBuster />
      
      <div className="min-h-screen bg-gray-50 flex tap-highlight-none">
        {/* Componente de Prevenção de Zoom */}
        <ZoomPrevention />
        
        {/* Alerta de Migração de Banco de Dados */}
        <DatabaseMigrationAlert 
          errorCode={dbError?.code} 
          errorMessage={dbError?.message} 
        />
      

      
      {/* Desktop Sidebar */}
      <Sidebar 
        currentModule={currentModule} 
        onModuleChange={handleModuleChange}
        onLogout={handleLogout}
        userRole={userRole}
      />
      
      {/* Mobile Navigation */}
      <MobileNav
        currentModule={currentModule}
        onModuleChange={handleModuleChange}
        onLogout={handleLogout}
        userRole={userRole}
      />
      
      {/* ✅ WCAG 2.1 AA - Main landmark com id para skip link */}
      <main 
        id="main-content" 
        tabIndex={-1}
        className="flex-1 lg:ml-72 min-h-screen pb-16 lg:pb-0 no-overscroll focus:outline-none"
      >
        {/* 🚀 SUSPENSE - Envolve todos os componentes lazy loaded */}
        <Suspense fallback={<ModuleLoadingFallback />}>
          {currentModule === 'welcome' && <Welcome onNavigate={handleModuleChange} />}
          {currentModule === 'dashboard' && (
            <ProtectedRoute page={PAGES.DASHBOARD}>
              <Dashboard />
            </ProtectedRoute>
          )}
          {currentModule === 'tire-stock' && (
            <ProtectedRoute page={PAGES.STOCK_ENTRY}>
              <TireStockEntry />
            </ProtectedRoute>
          )}
          {currentModule === 'tire-movement' && (
            <ProtectedRoute page={PAGES.TIRE_MOVEMENT}>
              <TireMovement />
            </ProtectedRoute>
          )}
          {currentModule === 'tire-consumption' && (
            <ProtectedRoute page={PAGES.TIRE_CONSUMPTION}>
              <TireConsumption />
            </ProtectedRoute>
          )}
          {currentModule === 'tire-status-change' && (
            <ProtectedRoute page={PAGES.TIRE_STATUS_CHANGE}>
              <TireStatusChange />
            </ProtectedRoute>
          )}
          {currentModule === 'arcs-data-update' && (
            <ProtectedRoute page={PAGES.ARCS_UPDATE}>
              <ARCSDataUpdate />
            </ProtectedRoute>
          )}
          {currentModule === 'tire-discard-entry' && (
            <ProtectedRoute page={PAGES.TIRE_DISCARD}>
              <TireDiscard />
            </ProtectedRoute>
          )}
          {currentModule === 'tire-discard-reports' && (
            <ProtectedRoute page={PAGES.DISCARD_REPORTS}>
              <DiscardReports />
            </ProtectedRoute>
          )}
          {currentModule === 'tire-models' && (
            <ProtectedRoute page={PAGES.TIRE_MODEL}>
              <TireModelRegistration />
            </ProtectedRoute>
          )}
          {currentModule === 'tire-status' && (
            <ProtectedRoute page={PAGES.STATUS_REGISTRATION}>
              <StatusRegistration />
            </ProtectedRoute>
          )}
          {currentModule === 'containers' && (
            <ProtectedRoute page={PAGES.CONTAINER}>
              <ContainerRegistration />
            </ProtectedRoute>
          )}
          {currentModule === 'reports' && (
            <ProtectedRoute page={PAGES.REPORTS}>
              <Reports />
            </ProtectedRoute>
          )}
          {currentModule === 'data-import' && (
            <ProtectedRoute page={PAGES.DATA_IMPORT}>
              <DataImport />
            </ProtectedRoute>
          )}
          {currentModule === 'stock-adjustment' && (
            <ProtectedRoute page={PAGES.STOCK_ADJUSTMENT}>
              <StockAdjustment />
            </ProtectedRoute>
          )}
          {currentModule === 'users' && (
            <ProtectedRoute page={PAGES.USER_MANAGEMENT}>
              <UserManagement />
            </ProtectedRoute>
          )}
          {currentModule === 'access-profiles' && (
            <ProtectedRoute page={PAGES.USER_MANAGEMENT}>
              <AccessProfileManagement />
            </ProtectedRoute>
          )}
          {currentModule === 'master-data' && (
            <ProtectedRoute page={PAGES.MASTER_DATA}>
              <MasterData />
            </ProtectedRoute>
          )}
        </Suspense>
      </main>
      
      <PWAInstallPrompt />
      <QuickTips />
      <OnboardingChecklist />
      <Toaster />
      
      {/* Onboarding Modal */}
      {showOnboarding && (
        <Onboarding onComplete={() => setShowOnboarding(false)} />
      )}
      </div>
    </TireStatusProvider>
    </ErrorBoundary>
  );
}
