import { useState } from 'react';
import { 
  LayoutDashboard, Package, CircleDot, Box, BarChart3, 
  ArrowRightLeft, Trash2, ChevronDown, FileText, UserCircle, 
  Truck, Smartphone, Monitor, Globe, MapPin, Shield, Settings, LogOut, ClipboardList, Database 
} from 'lucide-react';
import { Separator } from './ui/separator';
import porscheCarreraCupLogo from 'figma:asset/714dd59c6efd84795d4e42fadd6c600fd2c510ee.png';
import { usePermissions } from '../utils/usePermissions';
import { PAGES } from '../utils/permissions';

interface MobileNavProps {
  currentModule: string;
  onModuleChange: (module: string) => void;
  onLogout: () => void;
  userRole: string;
}

export function MobileNav({ currentModule, onModuleChange, onLogout, userRole }: MobileNavProps) {
  const [open, setOpen] = useState(false);
  const [expandedMenus, setExpandedMenus] = useState<string[]>([]);
  const { hasPageAccess, profile, isLoading } = usePermissions();

  // Mapeamento de IDs de menu para páginas (mesmo do Sidebar)
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

  // Estrutura do menu (espelho do Sidebar)
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
          icon: FileText,
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

  // Filtra itens do menu baseado em permissões (espelho do Sidebar)
  const filterMenuItems = (items: any[]): any[] => {
    return items.filter(item => {
      // Perfil "carga": só vê Gestão de Carga
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

      // Filtra recursivamente subitens
      if (item.subItems) {
        const filteredSubItems = filterMenuItems(item.subItems);
        if (filteredSubItems.length === 0) return false;
        item.subItems = filteredSubItems;
        return true;
      }

      // Verifica acesso à página
      const pageKey = menuToPageMap[item.id];
      if (pageKey) {
        return hasPageAccess(PAGES[pageKey]);
      }

      return true;
    });
  };

  const filteredMenuItems = filterMenuItems(menuItems);

  const toggleSubmenu = (itemId: string) => {
    setExpandedMenus(prev => 
      prev.includes(itemId) 
        ? prev.filter(id => id !== itemId)
        : [...prev, itemId]
    );
  };

  const isItemActive = (item: any): boolean => {
    if (currentModule === item.id) return true;
    if (item.subItems) {
      return item.subItems.some((sub: any) => isItemActive(sub));
    }
    return false;
  };

  const handleItemClick = (moduleId: string, externalUrl?: string) => {
    if (externalUrl) {
      window.open(externalUrl, '_blank', 'noopener,noreferrer');
      setOpen(false);
    } else {
      onModuleChange(moduleId);
      setOpen(false);
    }
  };

  return (
    <>
      {/* Animated Hamburger Button - Premium Design */}
      <button
        onClick={() => setOpen(!open)}
        className={`fixed top-4 left-4 z-[60] mobile-nav-hamburger ${open ? 'open' : ''}`}
        aria-label={open ? 'Fechar menu de navegação' : 'Abrir menu de navegação'}
        aria-expanded={open}
      >
        <div className="mobile-nav-hamburger-lines">
          <span className="mobile-nav-hamburger-line"></span>
          <span className="mobile-nav-hamburger-line"></span>
          <span className="mobile-nav-hamburger-line"></span>
        </div>
      </button>

      {/* Backdrop Overlay */}
      {open && (
        <div 
          className="lg:hidden fixed inset-0 z-40 bg-black/40 backdrop-blur-sm animate-fade-in"
          onClick={() => setOpen(false)}
          aria-hidden="true"
        />
      )}

      {/* Menu Fullscreen Mobile - Premium Slide Animation */}
      <div 
        className={`lg:hidden fixed inset-y-0 left-0 z-50 w-[85%] max-w-sm bg-white shadow-2xl transform transition-transform duration-300 ease-out ${
          open ? 'translate-x-0' : '-translate-x-full'
        }`}
      >
        <div className="flex flex-col h-full">
          {/* Header com Glassmorphism Premium */}
          <div className="mobile-nav-header">
            <img 
              src={porscheCarreraCupLogo} 
              alt="Porsche Carrera Cup Brasil" 
              className="h-14 w-auto object-contain"
            />
          </div>

          {/* Conteúdo Scrollável com Scroll Indicators */}
          <div className="flex-1 overflow-y-auto mobile-nav-scroll">
            <nav className="px-4 py-4 space-y-1">
              {/* Lista de itens (paridade com Sidebar) */}
              <ul className="space-y-1">
                {filteredMenuItems.map((item) => {
                  const Icon = item.icon;
                  const hasSubItems = item.subItems && item.subItems.length > 0;
                  const isExpanded = expandedMenus.includes(item.id);
                  const isDirectlyActive = currentModule === item.id;
                  const isExternalLink = item.externalUrl;

                  // Esconde itens adminOnly se não for admin
                  if (item.adminOnly && userRole !== 'admin') {
                    return null;
                  }

                  return (
                    <li key={item.id}>
                      <button
                        onClick={() => {
                          if (isExternalLink) {
                            handleItemClick(item.id, item.externalUrl);
                          } else if (hasSubItems) {
                            toggleSubmenu(item.id);
                          } else {
                            handleItemClick(item.id);
                          }
                        }}
                        className={`mobile-nav-item ${isDirectlyActive && !hasSubItems ? 'active' : ''}`}
                      >
                        <Icon className="w-5 h-5 flex-shrink-0" />
                        <span className="flex-1 text-left">{item.label}</span>
                        {hasSubItems && (
                          <ChevronDown 
                            className={`w-5 h-5 transition-transform duration-300 ${isExpanded ? 'rotate-0' : '-rotate-90'}`}
                          />
                        )}
                      </button>

                      {/* Subitens recursivos */}
                      {hasSubItems && (
                        <div className={`mobile-nav-submenu ${isExpanded ? 'open' : ''}`}>
                          <ul className="space-y-1">
                            {item.subItems.map((subItem: any) => {
                              const SubIcon = subItem.icon;
                              const subHasSub = subItem.subItems && subItem.subItems.length > 0;
                              const subExpanded = expandedMenus.includes(subItem.id);
                              const subActive = currentModule === subItem.id;
                              const subExternal = subItem.externalUrl;

                              if (subItem.adminOnly && userRole !== 'admin') {
                                return null;
                              }

                              return (
                                <li key={subItem.id}>
                                  <button
                                    onClick={() => {
                                      if (subExternal) {
                                        handleItemClick(subItem.id, subItem.externalUrl);
                                      } else if (subHasSub) {
                                        toggleSubmenu(subItem.id);
                                      } else {
                                        handleItemClick(subItem.id);
                                      }
                                    }}
                                    className={`mobile-nav-subitem ${subActive && !subHasSub ? 'active' : ''}`}
                                  >
                                    <SubIcon className="w-4 h-4 flex-shrink-0" />
                                    <span>{subItem.label}</span>
                                    {subHasSub && (
                                      <ChevronDown 
                                        className={`w-4 h-4 transition-transform duration-300 ${subExpanded ? 'rotate-0' : '-rotate-90'}`}
                                      />
                                    )}
                                  </button>

                                  {/* Terceiro nível */}
                                  {subHasSub && (
                                    <div className={`mobile-nav-submenu ${subExpanded ? 'open' : ''}`}>
                                      <ul className="space-y-1">
                                        {subItem.subItems.map((third: any) => {
                                          const ThirdIcon = third.icon;
                                          const thirdActive = currentModule === third.id;
                                          const thirdExternal = third.externalUrl;

                                          if (third.adminOnly && userRole !== 'admin') {
                                            return null;
                                          }

                                          return (
                                            <li key={third.id}>
                                              <button
                                                onClick={() => handleItemClick(third.id, thirdExternal)}
                                                className={`mobile-nav-subitem ${thirdActive ? 'active' : ''}`}
                                              >
                                                <ThirdIcon className="w-4 h-4 flex-shrink-0" />
                                                <span>{third.label}</span>
                                              </button>
                                            </li>
                                          );
                                        })}
                                      </ul>
                                    </div>
                                  )}
                                </li>
                              );
                            })}
                          </ul>
                        </div>
                      )}
                    </li>
                  );
                })}
              </ul>
            </nav>
          </div>

          {/* Footer - Logout com Shadow Premium */}
          <div className="mobile-nav-footer">
            <button
              onClick={() => {
                setOpen(false);
                onLogout();
              }}
              className="mobile-nav-logout"
            >
              <LogOut className="w-5 h-5" />
              <span>Sair</span>
            </button>
          </div>
        </div>
      </div>
    </>
  );
}
