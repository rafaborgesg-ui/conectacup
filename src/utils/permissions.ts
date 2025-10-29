// ============================================
// SISTEMA DE PERMISSÕES (RBAC)
// Role-Based Access Control para Porsche Cup
// ============================================

import { projectId, publicAnonKey } from './supabase/info';
import { getAccessToken } from './supabase/client';

/**
 * Páginas do Sistema
 */
export const PAGES = {
  DASHBOARD: 'dashboard',
  STOCK_ENTRY: 'stock_entry',
  TIRE_MODEL: 'tire_model',
  CONTAINER: 'container',
  REPORTS: 'reports',
  DISCARD_REPORTS: 'discard_reports',
  USER_MANAGEMENT: 'user_management',
  MASTER_DATA: 'master_data',
  STATUS_REGISTRATION: 'status_registration',
  STOCK_ADJUSTMENT: 'stock_adjustment',
  TIRE_MOVEMENT: 'tire_movement',
  TIRE_STATUS_CHANGE: 'tire_status_change',
  TIRE_DISCARD: 'tire_discard',
  TIRE_CONSUMPTION: 'tire_consumption',
  DATA_IMPORT: 'data_import',
  ARCS_UPDATE: 'arcs_update',
  // Menu externo controlado por RBAC
  GESTAO_CARGA: 'gestao_carga',
} as const;

export type PageKey = typeof PAGES[keyof typeof PAGES];

/**
 * Funcionalidades do Sistema
 */
export const FEATURES = {
  // Entrada de Estoque
  STOCK_CREATE: 'stock_create',
  STOCK_EDIT: 'stock_edit',
  STOCK_DELETE: 'stock_delete',
  STOCK_EXPORT: 'stock_export',
  
  // Modelos de Pneu
  MODEL_CREATE: 'model_create',
  MODEL_EDIT: 'model_edit',
  MODEL_DELETE: 'model_delete',
  
  // Contêineres
  CONTAINER_CREATE: 'container_create',
  CONTAINER_EDIT: 'container_edit',
  CONTAINER_DELETE: 'container_delete',
  
  // Relatórios
  REPORTS_VIEW: 'reports_view',
  REPORTS_EXPORT: 'reports_export',
  
  // Usuários
  USER_CREATE: 'user_create',
  USER_EDIT: 'user_edit',
  USER_DELETE: 'user_delete',
  USER_VIEW: 'user_view',
  
  // Master Data
  MASTER_DATA_EDIT: 'master_data_edit',
  
  // Status
  STATUS_CREATE: 'status_create',
  STATUS_EDIT: 'status_edit',
  STATUS_DELETE: 'status_delete',
  
  // Movimentação
  MOVEMENT_CREATE: 'movement_create',
  MOVEMENT_APPROVE: 'movement_approve',
  
  // Descarte
  DISCARD_CREATE: 'discard_create',
  DISCARD_VIEW: 'discard_view',
  
  // Importação
  IMPORT_DATA: 'import_data',
  
  // ARCS
  ARCS_UPDATE: 'arcs_update',
  ARCS_VIEW: 'arcs_view',
} as const;

export type FeatureKey = typeof FEATURES[keyof typeof FEATURES];

/**
 * Interface do Perfil de Acesso
 */
export interface AccessProfile {
  id: string;
  name: string;
  description: string;
  pages: PageKey[];
  features: FeatureKey[];
  isDefault: boolean;
  isSystem: boolean; // Perfis do sistema não podem ser deletados
  createdAt: string;
  updatedAt: string;
}

/**
 * Perfis Padrão do Sistema
 */
export const DEFAULT_PROFILES: Omit<AccessProfile, 'createdAt' | 'updatedAt'>[] = [
  {
    id: 'admin',
    name: 'Administrador',
    description: 'Acesso total ao sistema, incluindo gerenciamento de usuários e configurações',
    isDefault: true,
    isSystem: true,
    pages: Object.values(PAGES),
    features: Object.values(FEATURES),
  },
  {
    id: 'operator',
    name: 'Operador',
    description: 'Acesso às funcionalidades operacionais básicas (entrada, movimentação, consultas)',
    isDefault: true,
    isSystem: true,
    pages: [
      PAGES.DASHBOARD,
      PAGES.STOCK_ENTRY,
      PAGES.TIRE_MODEL,
      PAGES.CONTAINER,
      PAGES.REPORTS,
      PAGES.TIRE_MOVEMENT,
      PAGES.TIRE_STATUS_CHANGE,
    ],
    features: [
      FEATURES.STOCK_CREATE,
      FEATURES.STOCK_EXPORT,
      FEATURES.MODEL_CREATE,
      FEATURES.CONTAINER_CREATE,
      FEATURES.REPORTS_VIEW,
      FEATURES.REPORTS_EXPORT,
      FEATURES.MOVEMENT_CREATE,
    ],
  },
  {
    id: 'supervisor',
    name: 'Supervisor',
    description: 'Acesso operacional completo + aprovações e descartes',
    isDefault: false,
    isSystem: true,
    pages: [
      PAGES.DASHBOARD,
      PAGES.STOCK_ENTRY,
      PAGES.TIRE_MODEL,
      PAGES.CONTAINER,
      PAGES.REPORTS,
      PAGES.DISCARD_REPORTS,
      PAGES.STOCK_ADJUSTMENT,
      PAGES.TIRE_MOVEMENT,
      PAGES.TIRE_STATUS_CHANGE,
      PAGES.TIRE_DISCARD,
      PAGES.TIRE_CONSUMPTION,
    ],
    features: [
      FEATURES.STOCK_CREATE,
      FEATURES.STOCK_EDIT,
      FEATURES.STOCK_EXPORT,
      FEATURES.MODEL_CREATE,
      FEATURES.MODEL_EDIT,
      FEATURES.CONTAINER_CREATE,
      FEATURES.CONTAINER_EDIT,
      FEATURES.REPORTS_VIEW,
      FEATURES.REPORTS_EXPORT,
      FEATURES.MOVEMENT_CREATE,
      FEATURES.MOVEMENT_APPROVE,
      FEATURES.DISCARD_CREATE,
      FEATURES.DISCARD_VIEW,
    ],
  },
  {
    id: 'viewer',
    name: 'Visualizador',
    description: 'Acesso somente leitura (consultas e relatórios)',
    isDefault: false,
    isSystem: true,
    pages: [
      PAGES.DASHBOARD,
      PAGES.REPORTS,
      PAGES.DISCARD_REPORTS,
    ],
    features: [
      FEATURES.REPORTS_VIEW,
      FEATURES.REPORTS_EXPORT,
      FEATURES.DISCARD_VIEW,
    ],
  },
  {
    id: 'carga',
    name: 'Carga',
    description: 'Acesso exclusivo ao menu externo "Gestão de Carga"',
    isDefault: false,
    isSystem: true,
    pages: [
      PAGES.GESTAO_CARGA,
    ],
    features: [],
  },
];

/**
 * Labels amigáveis para páginas
 */
export const PAGE_LABELS: Record<PageKey, string> = {
  [PAGES.DASHBOARD]: 'Dashboard',
  [PAGES.STOCK_ENTRY]: 'Entrada de Estoque',
  [PAGES.TIRE_MODEL]: 'Modelos de Pneu',
  [PAGES.CONTAINER]: 'Contêineres',
  [PAGES.REPORTS]: 'Relatórios & Histórico',
  [PAGES.DISCARD_REPORTS]: 'Relatórios de Descarte',
  [PAGES.USER_MANAGEMENT]: 'Gerenciar Usuários',
  [PAGES.MASTER_DATA]: 'Master Data',
  [PAGES.STATUS_REGISTRATION]: 'Cadastro de Status',
  [PAGES.STOCK_ADJUSTMENT]: 'Ajuste de Estoque',
  [PAGES.TIRE_MOVEMENT]: 'Movimentação de Pneus',
  [PAGES.TIRE_STATUS_CHANGE]: 'Alteração de Status',
  [PAGES.TIRE_DISCARD]: 'Descarte de Pneus',
  [PAGES.TIRE_CONSUMPTION]: 'Consumo de Pneus',
  [PAGES.DATA_IMPORT]: 'Importação de Dados',
  [PAGES.ARCS_UPDATE]: 'Atualização ARCS',
  [PAGES.GESTAO_CARGA]: 'Gestão de Carga',
};

/**
 * Labels amigáveis para funcionalidades
 */
export const FEATURE_LABELS: Record<FeatureKey, string> = {
  [FEATURES.STOCK_CREATE]: 'Criar Entrada',
  [FEATURES.STOCK_EDIT]: 'Editar Entrada',
  [FEATURES.STOCK_DELETE]: 'Excluir Entrada',
  [FEATURES.STOCK_EXPORT]: 'Exportar Dados',
  
  [FEATURES.MODEL_CREATE]: 'Criar Modelo',
  [FEATURES.MODEL_EDIT]: 'Editar Modelo',
  [FEATURES.MODEL_DELETE]: 'Excluir Modelo',
  
  [FEATURES.CONTAINER_CREATE]: 'Criar Contêiner',
  [FEATURES.CONTAINER_EDIT]: 'Editar Contêiner',
  [FEATURES.CONTAINER_DELETE]: 'Excluir Contêiner',
  
  [FEATURES.REPORTS_VIEW]: 'Visualizar Relatórios',
  [FEATURES.REPORTS_EXPORT]: 'Exportar Relatórios',
  
  [FEATURES.USER_CREATE]: 'Criar Usuário',
  [FEATURES.USER_EDIT]: 'Editar Usuário',
  [FEATURES.USER_DELETE]: 'Excluir Usuário',
  [FEATURES.USER_VIEW]: 'Visualizar Usuários',
  
  [FEATURES.MASTER_DATA_EDIT]: 'Editar Master Data',
  
  [FEATURES.STATUS_CREATE]: 'Criar Status',
  [FEATURES.STATUS_EDIT]: 'Editar Status',
  [FEATURES.STATUS_DELETE]: 'Excluir Status',
  
  [FEATURES.MOVEMENT_CREATE]: 'Criar Movimentação',
  [FEATURES.MOVEMENT_APPROVE]: 'Aprovar Movimentação',
  
  [FEATURES.DISCARD_CREATE]: 'Criar Descarte',
  [FEATURES.DISCARD_VIEW]: 'Visualizar Descartes',
  
  [FEATURES.IMPORT_DATA]: 'Importar Dados',
  
  [FEATURES.ARCS_UPDATE]: 'Atualizar ARCS',
  [FEATURES.ARCS_VIEW]: 'Visualizar ARCS',
};

/**
 * Agrupa páginas por categoria
 */
export const PAGE_CATEGORIES = {
  'Operacional': [
    PAGES.DASHBOARD,
    PAGES.STOCK_ENTRY,
    PAGES.TIRE_MODEL,
    PAGES.CONTAINER,
    PAGES.GESTAO_CARGA,
  ],
  'Movimentação': [
    PAGES.STOCK_ADJUSTMENT,
    PAGES.TIRE_MOVEMENT,
    PAGES.TIRE_STATUS_CHANGE,
    PAGES.TIRE_DISCARD,
    PAGES.TIRE_CONSUMPTION,
  ],
  'Relatórios': [
    PAGES.REPORTS,
    PAGES.DISCARD_REPORTS,
  ],
  'Administração': [
    PAGES.USER_MANAGEMENT,
    PAGES.MASTER_DATA,
    PAGES.STATUS_REGISTRATION,
  ],
  'Integração': [
    PAGES.DATA_IMPORT,
    PAGES.ARCS_UPDATE,
  ],
};

/**
 * Agrupa funcionalidades por categoria
 */
export const FEATURE_CATEGORIES = {
  'Entrada de Estoque': [
    FEATURES.STOCK_CREATE,
    FEATURES.STOCK_EDIT,
    FEATURES.STOCK_DELETE,
    FEATURES.STOCK_EXPORT,
  ],
  'Modelos de Pneu': [
    FEATURES.MODEL_CREATE,
    FEATURES.MODEL_EDIT,
    FEATURES.MODEL_DELETE,
  ],
  'Contêineres': [
    FEATURES.CONTAINER_CREATE,
    FEATURES.CONTAINER_EDIT,
    FEATURES.CONTAINER_DELETE,
  ],
  'Relatórios': [
    FEATURES.REPORTS_VIEW,
    FEATURES.REPORTS_EXPORT,
  ],
  'Usuários': [
    FEATURES.USER_CREATE,
    FEATURES.USER_EDIT,
    FEATURES.USER_DELETE,
    FEATURES.USER_VIEW,
  ],
  'Configurações': [
    FEATURES.MASTER_DATA_EDIT,
    FEATURES.STATUS_CREATE,
    FEATURES.STATUS_EDIT,
    FEATURES.STATUS_DELETE,
  ],
  'Movimentação': [
    FEATURES.MOVEMENT_CREATE,
    FEATURES.MOVEMENT_APPROVE,
  ],
  'Descarte': [
    FEATURES.DISCARD_CREATE,
    FEATURES.DISCARD_VIEW,
  ],
  'Integração': [
    FEATURES.IMPORT_DATA,
    FEATURES.ARCS_UPDATE,
    FEATURES.ARCS_VIEW,
  ],
};

/**
 * Verifica se um perfil tem acesso a uma página
 */
export function hasPageAccess(profile: AccessProfile, page: PageKey): boolean {
  return profile.pages.includes(page);
}

/**
 * Verifica se um perfil tem acesso a uma funcionalidade
 */
export function hasFeatureAccess(profile: AccessProfile, feature: FeatureKey): boolean {
  return profile.features.includes(feature);
}

/**
 * Inicializa perfis padrão no localStorage se não existirem
 * NOTA: Esta é apenas uma inicialização local de fallback.
 * Os perfis oficiais devem estar no Supabase (tabela access_profiles).
 */
function initializeDefaultProfiles(): void {
  try {
    const profilesStr = localStorage.getItem('porsche-cup-profiles');
    if (!profilesStr) {
      const defaultProfiles: AccessProfile[] = DEFAULT_PROFILES.map(p => ({
        ...p,
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString(),
      }));
      localStorage.setItem('porsche-cup-profiles', JSON.stringify(defaultProfiles));
      console.log('ℹ️ Perfis padrão inicializados no localStorage (cache)');
      console.log('💡 Execute MIGRATION_ACCESS_PROFILES_TABLE.sql para salvar no Supabase');
    }
  } catch (error) {
    console.error('Erro ao inicializar perfis padrão:', error);
  }
}

/**
 * Carrega perfis do Supabase e atualiza cache local
 */
async function loadProfilesFromSupabase(): Promise<AccessProfile[]> {
  try {
    const token = await getAccessToken();
    
    if (!token) {
      console.warn('⚠️ Sem token de autenticação - usando cache local');
      const profilesStr = localStorage.getItem('porsche-cup-profiles');
      return profilesStr ? JSON.parse(profilesStr) : DEFAULT_PROFILES.map(p => ({
        ...p,
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString(),
      }));
    }
    
    const response = await fetch(
      `https://${projectId}.supabase.co/functions/v1/make-server-02726c7c/access-profiles`,
      {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        }
      }
    );
    
    if (!response.ok) {
      throw new Error('Erro ao carregar perfis do Supabase');
    }
    
    const result = await response.json();
    
    if (!result.success) {
      throw new Error(result.error || 'Erro ao carregar perfis');
    }
    
    // Atualiza cache local
    localStorage.setItem('porsche-cup-profiles', JSON.stringify(result.data));
    
    console.log(`✅ ${result.data.length} perfis carregados do Supabase`);
    return result.data;
    
  } catch (error) {
    console.error('❌ Erro ao carregar perfis do Supabase:', error);
    
    // Fallback para cache local
    const profilesStr = localStorage.getItem('porsche-cup-profiles');
    if (profilesStr) {
      console.log('ℹ️ Usando perfis do cache local');
      return JSON.parse(profilesStr);
    }
    
    // Último fallback: perfis padrão
    console.log('ℹ️ Usando perfis padrão embutidos');
    return DEFAULT_PROFILES.map(p => ({
      ...p,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    }));
  }
}

/**
 * Obtém perfil do usuário atual (ASYNC - busca do Supabase)
 */
export async function getCurrentUserProfileAsync(): Promise<AccessProfile | null> {
  try {
    const userStr = localStorage.getItem('porsche-cup-user');
    if (!userStr) {
      console.warn('⚠️ Nenhum usuário logado');
      return null;
    }
    
    const user = JSON.parse(userStr);
    let profileId = user.profileId || user.role; // Compatibilidade com role antiga
    
    if (!profileId) {
      console.warn('⚠️ Usuário sem profileId ou role definido');
      return null;
    }
    
    console.log(`🔍 Buscando perfil: ${profileId}`);
    
    // Carrega perfis do Supabase (ou cache)
    const profiles = await loadProfilesFromSupabase();
    
    // Busca perfil específico
    let profile = profiles.find(p => p.id === profileId);
    
    if (profile) {
      console.log(`✅ Perfil encontrado: ${profile.name} (${profile.id})`);
      console.log(`📋 Páginas permitidas:`, profile.pages);
      console.log(`⚙️ Funcionalidades permitidas:`, profile.features);
      return profile;
    }
    
    // FALLBACK: Se perfil não existe, tenta usar perfil padrão baseado na role
    console.warn(`⚠️ Perfil "${profileId}" não encontrado`);
    console.warn(`📋 Perfis disponíveis:`, profiles.map(p => ({ id: p.id, name: p.name })));
    
    // Se profileId parece ser um ID customizado (profile-xxxxx), tenta usar 'admin' ou 'operator'
    if (profileId.startsWith('profile-')) {
      console.warn(`💡 Perfil customizado "${profileId}" não existe no Supabase`);
      console.warn(`🔄 Tentando fallback para perfil "operator"...`);
      
      profile = profiles.find(p => p.id === 'operator');
      if (profile) {
        console.log(`✅ Usando perfil "operator" como fallback`);
        
        // Atualiza usuário para usar operator
        try {
          const updatedUser = { ...user, profileId: 'operator' };
          localStorage.setItem('porsche-cup-user', JSON.stringify(updatedUser));
          console.log(`💾 ProfileId atualizado para "operator" localmente`);
          console.warn(`⚠️ IMPORTANTE: Atualize o usuário no Supabase para usar um perfil válido!`);
        } catch (err) {
          console.error('Erro ao atualizar usuário localmente:', err);
        }
        
        return profile;
      }
    }
    
    console.error(`❌ Nenhum perfil encontrado e fallback falhou`);
    console.error(`💡 SOLUÇÃO: Execute no SQL do Supabase:`);
    console.error(`   UPDATE auth.users`);
    console.error(`   SET raw_user_meta_data = raw_user_meta_data || '{"profileId": "admin"}'::jsonb`);
    console.error(`   WHERE email = '${user.email}';`);
    
    return null;
  } catch (error) {
    console.error('❌ Erro ao obter perfil do usuário:', error);
    return null;
  }
}

/**
 * Obtém perfil do usuário atual do localStorage (SYNC - apenas cache)
 * DEPRECATED: Use getCurrentUserProfileAsync() para buscar do Supabase
 */
export function getCurrentUserProfile(): AccessProfile | null {
  try {
    // Garante que perfis padrão estejam inicializados
    initializeDefaultProfiles();
    
    const userStr = localStorage.getItem('porsche-cup-user');
    if (!userStr) return null;
    
    const user = JSON.parse(userStr);
    const profileId = user.profileId || user.role; // Compatibilidade com role antiga
    
    if (!profileId) {
      console.warn('⚠️ Usuário sem profileId ou role definido');
      return null;
    }
    
    // Busca perfil salvo no localStorage (CACHE)
    const profilesStr = localStorage.getItem('porsche-cup-profiles');
    if (profilesStr) {
      const profiles: AccessProfile[] = JSON.parse(profilesStr);
      const profile = profiles.find(p => p.id === profileId);
      if (profile) {
        console.log(`✅ Perfil encontrado (cache): ${profile.name} (${profile.id})`);
        return profile;
      }
    }
    
    // Fallback para perfis padrão (caso o localStorage esteja vazio)
    const defaultProfile = DEFAULT_PROFILES.find(p => p.id === profileId);
    if (defaultProfile) {
      console.log(`ℹ️ Usando perfil padrão: ${defaultProfile.name} (${defaultProfile.id})`);
      return {
        ...defaultProfile,
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString(),
      };
    }
    
    console.warn(`⚠️ Perfil não encontrado para profileId/role: ${profileId}`);
    return null;
  } catch (error) {
    console.error('Erro ao obter perfil do usuário:', error);
    return null;
  }
}

/**
 * Verifica se usuário atual tem acesso a uma página
 */
export function canAccessPage(page: PageKey): boolean {
  const profile = getCurrentUserProfile();
  if (!profile) return false;
  return hasPageAccess(profile, page);
}

/**
 * Verifica se usuário atual tem acesso a uma funcionalidade
 */
export function canAccessFeature(feature: FeatureKey): boolean {
  const profile = getCurrentUserProfile();
  if (!profile) return false;
  return hasFeatureAccess(profile, feature);
}

/**
 * Verifica se usuário atual é admin
 */
export function isAdmin(): boolean {
  const profile = getCurrentUserProfile();
  return profile?.id === 'admin';
}
