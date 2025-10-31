import { type LucideIcon, LayoutDashboard, Package, CircleDot, Box, BarChart3, Shield, Settings, Database, ArrowRightLeft, Trash2, FileText, UserCircle, Truck, Smartphone, Monitor, Globe, MapPin, Code, ClipboardList } from 'lucide-react';
import { PAGES } from '../utils/permissions';

export type MenuItem = {
  id: string;
  label: string;
  icon?: LucideIcon;
  isMain?: boolean;
  adminOnly?: boolean;
  externalUrl?: string;
  subItems?: MenuItem[];
};

// Central mapping between sidebar ids and permission pages
export const menuToPageMap: Record<string, keyof typeof PAGES> = {
  'pneus': 'PNEUS',
  'gestao-carga': 'GESTAO_CARGA',
  'solicitacao-frete': 'SOLICITACAO_FRETE',
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

// Single source-of-truth menu tree
export const menuItems: MenuItem[] = [
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
