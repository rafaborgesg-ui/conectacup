import { LayoutDashboard, Package, CircleDot, Box, BarChart3, Menu, X, LogOut, Shield, Settings, Database, ArrowRightLeft, Trash2, ChevronDown, ChevronRight, FileText, UserCircle, Truck, Smartphone, Monitor, Globe, MapPin, Code, ClipboardList } from 'lucide-react';
import { useState, useEffect } from 'react';
import porscheCupLogo from 'figma:asset/3ae08ff326060d9638298673cda23da363101b9f.png';
import { usePermissions } from '../utils/usePermissions';
import { PAGES } from '../utils/permissions';

interface SidebarProps {
  currentModule: string;
  onModuleChange: (module: string) => void;
}

export function Sidebar({ currentModule, onModuleChange, onLogout, userRole = 'operator' }: SidebarProps) {
  const [isOpen, setIsOpen] = useState(false);
  const [expandedMenus, setExpandedMenus] = useState<string[]>([]); // Todos os menus iniciam recolhidos
  const [hasUserInteracted, setHasUserInteracted] = useState(false); // Flag para controlar interação do usuário
  const { hasPageAccess, isLoading, profile } = usePermissions();
  
  // Log para debug
  useEffect(() => {
    if (!isLoading && profile) {
      console.log('🔐 Sidebar - Perfil carregado:', profile.name);
      console.log('📋 Páginas permitidas:', profile.pages);
    }
  }, [isLoading, profile]);

  // Mapeamento de IDs de menu para páginas do sistema de permissões
  const menuToPageMap: Record<string, keyof typeof PAGES> = {
    'gestao-carga': 'GESTAO_CARGA',
    'dashboard': 'DASHBOARD',
    'tire-stock': 'STOCK_ENTRY',
    'tire-movement': 'TIRE_MOVEMENT',
    'tire-consumption': 'TIRE_CONSUMPTION',
    'tire-status-change': 'TIRE_STATUS_CHANGE',
    'arcs-data-update': 'ARCS_UPDATE',
    'tire-discard-entry': 'TIRE_DISCARD',
    'tire-discard-reports': 'DISCARD_REPORTS',
    'tire-models': 'TIRE_MODEL',
    'tire-status': 'STATUS_REGISTRATION',
    'containers': 'CONTAINER',
    'reports': 'REPORTS',
    'data-import': 'DATA_IMPORT',
    'stock-adjustment': 'STOCK_ADJUSTMENT',
    'users': 'USER_MANAGEMENT',
    'access-profiles': 'USER_MANAGEMENT',
    'master-data': 'MASTER_DATA',
  };

  // Filtra itens do menu baseado em permissões
  const filterMenuItems = (items: any[]): any[] => {
    return items.filter(item => {
      // Se perfil "carga", exibe apenas o item específico "gestao-carga"
      if (!isLoading && profile?.id === 'carga') {
        return item.id === 'gestao-carga';
      }

      // Links externos: se houver mapeamento para PAGES, respeita RBAC; senão, mantém visível
      if (item.externalUrl) {
        const pageKey = menuToPageMap[item.id];
        if (pageKey) {
          return hasPageAccess(PAGES[pageKey]);
        }
        return true;
      }
      
      // Se tem subItems, filtra recursivamente
      if (item.subItems) {
        const filteredSubItems = filterMenuItems(item.subItems);
        // Se não sobrou nenhum subitem, oculta o item pai
        if (filteredSubItems.length === 0) return false;
        item.subItems = filteredSubItems;
        return true;
      }
      
      // Verifica se tem acesso à página
      const pageKey = menuToPageMap[item.id];
      if (pageKey) {
        return hasPageAccess(PAGES[pageKey]);
      }
      
      // Se não tem mapeamento, mantém comportamento antigo (adminOnly)
      if (item.adminOnly && userRole !== 'admin') {
        return false;
      }
      
      return true;
    });
  };
  
  // Expande automaticamente os menus SOMENTE APÓS o usuário clicar em algum item
  useEffect(() => {
    // Não expande automaticamente se o usuário ainda não interagiu
    if (!hasUserInteracted) {
      return;
    }
    
    const pneusModules = [
      'tire-stock',
      'tire-movement', 'reports', 
      'tire-discard-entry',
      'tire-status-change', 'arcs-data-update'
    ];
    
    const cadastroModules = ['tire-models', 'containers', 'tire-status', 'master-data'];
    
    const administracaoModules = ['users', 'access-profiles', 'stock-adjustment', 'dashboard', 'data-import', 'tire-consumption', 'tire-discard-reports', 'em-desenvolvimento'];
    
    const freteModules = ['frete-smartphone', 'frete-web', 'frete-internacional'];
    
    if (pneusModules.includes(currentModule)) {
      setExpandedMenus(prev => {
        if (!prev.includes('pneus')) {
          return [...prev, 'pneus'];
        }
        return prev;
      });
    }
    
    if (cadastroModules.includes(currentModule)) {
      setExpandedMenus(prev => {
        if (!prev.includes('cadastro')) {
          return [...prev, 'cadastro'];
        }
        return prev;
      });
    }
    
    if (administracaoModules.includes(currentModule)) {
      setExpandedMenus(prev => {
        if (!prev.includes('administracao')) {
          return [...prev, 'administracao'];
        }
        return prev;
      });
    }
    
    if (freteModules.includes(currentModule)) {
      setExpandedMenus(prev => {
        const newExpanded = [...prev];
        if (!newExpanded.includes('solicitacao-frete')) newExpanded.push('solicitacao-frete');
        if (currentModule === 'frete-smartphone' || currentModule === 'frete-web') {
          if (!newExpanded.includes('frete-nacional')) newExpanded.push('frete-nacional');
        }
        return newExpanded;
      });
    }
    
    // Expande submenu de descarte se necessário
    if (currentModule === 'tire-discard-entry' || currentModule === 'tire-discard-reports') {
      setExpandedMenus(prev => {
        const newExpanded = [...prev];
        if (!newExpanded.includes('pneus')) newExpanded.push('pneus');
        if (!newExpanded.includes('tire-discard')) newExpanded.push('tire-discard');
        return newExpanded;
      });
    }
  }, [currentModule, hasUserInteracted]);

  const menuItems = [
    { 
      id: 'gestao-carga', 
      label: 'Gestão de Carga', 
      icon: ClipboardList, 
      isMain: true,
      externalUrl: 'https://script.google.com/a/porschegt3cup.com.br/macros/s/AKfycbzs06M_vQcA34boc3ciyd9LzUzsYN3aNIXGZd-SfCsygtWAv07sc8K3ngt2UE0-cr9C/exec'
    },
    { 
      id: 'solicitacao-frete', 
      label: 'Solicitação de frete', 
      icon: Truck, 
      isMain: true,
      subItems: [
        { 
          id: 'frete-nacional', 
          label: 'Nacional', 
          icon: MapPin,
          subItems: [
            { id: 'frete-smartphone', label: 'Smartphone', icon: Smartphone, externalUrl: 'https://sites.google.com/view/motoristacup/in%C3%ADcio' },
            { id: 'frete-web', label: 'Web', icon: Monitor, externalUrl: 'https://script.google.com/macros/s/AKfycbxG8e_GeG9vOLBtnkv06Su-XjNGl_a2xS0R9swdyjjQZo_dnmQkegBiV3l1Z-FnzEhL/exec' },
          ]
        },
        { id: 'frete-internacional', label: 'Internacional', icon: Globe, externalUrl: 'https://docs.google.com/spreadsheets/d/1-z_PLPueulEfPa7J3Owhg_mfjFKHF3nLDvRVVtyeUvQ/edit?usp=sharing' },
      ]
    },
    { 
      id: 'pneus', 
      label: 'Pneus', 
      icon: Package, 
      isMain: true,
      subItems: [
        { id: 'tire-stock', label: 'Entrada de Estoque', icon: Package },
        { id: 'tire-movement', label: 'Movimentação de Pneus', icon: ArrowRightLeft },
        { id: 'tire-status-change', label: 'Mudar Status', icon: CircleDot },
        { id: 'arcs-data-update', label: 'Atualizar Base ARCS', icon: Database, adminOnly: true },
        { id: 'tire-discard-entry', label: 'Registro de Descarte', icon: Trash2 },
        { id: 'reports', label: 'Relatórios & Histórico', icon: BarChart3 },
      ]
    },
    { 
      id: 'cadastro', 
      label: 'Cadastro', 
      icon: Settings, 
      isMain: true,
      adminOnly: true,
      subItems: [
        { id: 'tire-models', label: 'Cadastro de Modelos', icon: CircleDot },
        { id: 'tire-status', label: 'Cadastro de Status', icon: CircleDot },
        { id: 'containers', label: 'Cadastro de Contêineres', icon: Box },
        { id: 'master-data', label: 'Master Data', icon: Database },
      ]
    },
    { 
      id: 'administracao', 
      label: 'Administração', 
      icon: Shield, 
      isMain: true,
      adminOnly: true,
      subItems: [
        { id: 'users', label: 'Gerenciar Usuários', icon: Shield },
        { id: 'access-profiles', label: 'Perfis de Acesso', icon: UserCircle },
        { id: 'stock-adjustment', label: 'Ajuste de Estoque', icon: Settings },
        { 
          id: 'em-desenvolvimento', 
          label: 'Em Desenvolvimento', 
          icon: Code,
          subItems: [
            { id: 'dashboard', label: 'Dashboard', icon: LayoutDashboard },
            { id: 'tire-consumption', label: 'Transferir para Piloto', icon: UserCircle },
            { id: 'data-import', label: 'Importação de Dados', icon: Database },
            { id: 'tire-discard-reports', label: 'Relatórios & Histórico de Descarte', icon: FileText },
          ]
        },
      ]
    },
  ];

  const toggleSubmenu = (itemId: string) => {
    setHasUserInteracted(true); // Marca que o usuário interagiu
    setExpandedMenus(prev => 
      prev.includes(itemId) 
        ? prev.filter(id => id !== itemId)
        : [...prev, itemId]
    );
  };

  // Função recursiva para verificar se um item está ativo
  const isItemActive = (item: any): boolean => {
    if (currentModule === item.id) return true;
    if (item.subItems) {
      return item.subItems.some((sub: any) => isItemActive(sub));
    }
    return false;
  };

  // Componente de título de seção
  const renderSectionTitle = (title: string) => (
    <div className="px-4 pt-4 pb-2">
      <h3 
        className="text-xs font-semibold uppercase tracking-wider"
        style={{ color: '#6B7280' }}
      >
        {title}
      </h3>
    </div>
  );

  // Função recursiva para renderizar itens de menu
  const renderMenuItem = (item: any, level: number = 0, isFirstInSection: boolean = false) => {
    const Icon = item.icon;
    const hasSubItems = item.subItems && item.subItems.length > 0;
    const isExpanded = expandedMenus.includes(item.id);
    const isActive = isItemActive(item);
    const isDirectlyActive = currentModule === item.id;
    const isExternalLink = item.externalUrl;
    
    // Esconde itens adminOnly se não for admin
    if (item.adminOnly && userRole !== 'admin') {
      return null;
    }

    return (
      <li key={item.id}>
        {/* Botão do menu - Premium Design */}
        <button
          onClick={() => {
            if (isExternalLink) {
              // Abre link externo em nova aba
              window.open(item.externalUrl, '_blank', 'noopener,noreferrer');
            } else if (hasSubItems) {
              toggleSubmenu(item.id);
            } else {
              setHasUserInteracted(true); // Marca que o usuário interagiu
              onModuleChange(item.id);
              setIsOpen(false);
            }
          }}
          className={`
            w-full flex items-center gap-3 px-4 py-3 rounded-xl
            transition-all duration-200 relative overflow-hidden
            ${level > 0 ? 'text-sm' : 'font-medium'}
          `}
          style={{
            paddingLeft: `${(level * 16) + 16}px`,
            ...(isDirectlyActive && !hasSubItems ? {
              background: 'linear-gradient(135deg, #D50000 0%, #B00000 100%)',
              color: '#ffffff',
              boxShadow: '0 2px 8px rgba(213, 0, 0, 0.2), 0 1px 2px rgba(213, 0, 0, 0.1)',
            } : {
              color: level > 0 ? '#9CA3AF' : '#E5E7EB',
              background: 'transparent',
            })
          }}
          onMouseEnter={(e) => {
            if (!isDirectlyActive || hasSubItems) {
              e.currentTarget.style.background = 'rgba(255, 255, 255, 0.05)';
              if (!isDirectlyActive) {
                e.currentTarget.style.color = '#FFFFFF';
              }
            }
          }}
          onMouseLeave={(e) => {
            if (!isDirectlyActive || hasSubItems) {
              e.currentTarget.style.background = 'transparent';
              e.currentTarget.style.color = level > 0 ? '#9CA3AF' : '#E5E7EB';
            }
            if (isDirectlyActive && !hasSubItems) {
              e.currentTarget.style.background = 'linear-gradient(135deg, #D50000 0%, #B00000 100%)';
              e.currentTarget.style.color = '#ffffff';
            }
          }}
        >
          <Icon size={level > 0 ? 18 : 20} strokeWidth={2} className="flex-shrink-0" />
          <span className="flex-1 text-left">{item.label}</span>
          
          {/* Active indicator dot */}
          {isDirectlyActive && !hasSubItems && (
            <div 
              className="w-1.5 h-1.5 rounded-full"
              style={{
                background: '#ffffff',
                boxShadow: '0 0 8px rgba(255, 255, 255, 0.5)',
              }}
            />
          )}
          
          {hasSubItems && (
            <ChevronDown 
              size={16} 
              className="transition-transform duration-300 flex-shrink-0"
              style={{ 
                transform: isExpanded ? 'rotate(0deg)' : 'rotate(-90deg)' 
              }} 
            />
          )}
        </button>

        {/* Subitens recursivos com animação */}
        {hasSubItems && (
          <div 
            className="overflow-hidden transition-all duration-300"
            style={{
              maxHeight: isExpanded ? '1000px' : '0',
              opacity: isExpanded ? 1 : 0,
            }}
          >
            <ul className="mt-1 space-y-1" style={{
              marginLeft: level > 0 ? '12px' : '0',
              paddingLeft: level > 0 ? '12px' : '0',
              borderLeft: level > 0 ? '2px solid rgba(255, 255, 255, 0.1)' : 'none',
            }}>
              {item.subItems.map((subItem: any) => renderMenuItem(subItem, level + 1))}
            </ul>
          </div>
        )}
      </li>
    );
  };

  // Aplica filtro de permissões
  const filteredMenuItems = filterMenuItems(menuItems);

  return (
    <>
      {/* Sidebar Desktop - Premium Design */}
      <aside
        className={`
          fixed top-0 left-0 h-full w-72 z-40 
          transition-transform duration-300 ease-in-out flex-col
          hidden lg:flex
          bg-black shadow-2xl
        `}
      >
        {/* Header com Glassmorphism Premium */}
        <div 
          className="p-6 border-b flex justify-center"
          style={{
            background: 'linear-gradient(180deg, rgba(0, 0, 0, 1) 0%, rgba(26, 26, 26, 1) 100%)',
            backdropFilter: 'blur(8px)',
            borderColor: 'rgba(255, 255, 255, 0.1)',
          }}
        >
          <img
            src={porscheCupLogo}
            alt="Conecta Cup"
            className="h-16 w-auto object-contain"
          />
        </div>

        {/* Menu Items - Scrollable com Scroll Indicators */}
        <nav className="flex-1 overflow-y-auto" style={{
          WebkitOverflowScrolling: 'touch',
          scrollBehavior: 'smooth',
        }}>
          <div className="py-2">
            {filteredMenuItems.map((item, index) => {
              // Renderiza separador antes de certos itens
              const showSeparator = index > 0;
              
              return (
                <div key={item.id}>
                  {showSeparator && (
                    <div className="mx-4 my-3">
                      <div className="h-px bg-gradient-to-r from-transparent via-gray-700 to-transparent" />
                    </div>
                  )}
                  <ul className="px-4 space-y-1">
                    {renderMenuItem(item, 0, index === 0)}
                  </ul>
                </div>
              );
            })}
          </div>
        </nav>

        {/* Logout Button - Premium */}
        {onLogout && (
          <div 
            className="p-4 border-t"
            style={{
              background: 'linear-gradient(0deg, rgba(0, 0, 0, 1) 0%, rgba(26, 26, 26, 1) 100%)',
              boxShadow: '0 -4px 12px rgba(0, 0, 0, 0.3), 0 -1px 3px rgba(0, 0, 0, 0.2)',
              borderColor: 'rgba(255, 255, 255, 0.1)',
            }}
          >
            <button
              onClick={onLogout}
              className="w-full flex items-center justify-center gap-3 px-6 py-3 rounded-xl transition-all duration-200 border"
              style={{
                color: '#DC2626',
                background: 'rgba(220, 38, 38, 0.08)',
                borderColor: 'rgba(220, 38, 38, 0.2)',
              }}
              onMouseEnter={(e) => {
                e.currentTarget.style.background = 'rgba(220, 38, 38, 0.12)';
                e.currentTarget.style.borderColor = 'rgba(220, 38, 38, 0.3)';
              }}
              onMouseLeave={(e) => {
                e.currentTarget.style.background = 'rgba(220, 38, 38, 0.08)';
                e.currentTarget.style.borderColor = 'rgba(220, 38, 38, 0.2)';
              }}
            >
              <LogOut size={20} strokeWidth={2} />
              <span className="font-semibold">Sair do Sistema</span>
            </button>
          </div>
        )}

        {/* Footer */}
        <div className="p-4 border-t bg-black" style={{ borderColor: 'rgba(255, 255, 255, 0.1)' }}>
          <p className="text-gray-500 text-xs text-center font-medium">
            © 2025 Porsche Cup Brasil
          </p>
        </div>
      </aside>
    </>
  );
}
