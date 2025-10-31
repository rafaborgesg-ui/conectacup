import { useState, useEffect } from 'react';
import { Plus, Edit2, Trash2, Shield, Save, X as XIcon, Copy, ChevronDown, ChevronRight, RefreshCcw } from 'lucide-react';
import { Input } from './ui/input';
import { Button } from './ui/button';
import { Label } from './ui/label';
import { Badge } from './ui/badge';
import { Checkbox } from './ui/checkbox';
import { toast } from 'sonner';
import { ActionButton } from './ActionFeedback';
import { projectId, publicAnonKey } from '../utils/supabase/info';
import { getAccessToken } from '../utils/supabase/client';
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from './ui/alert-dialog';
import {
  AccessProfile,
  DEFAULT_PROFILES,
  PAGES,
  FEATURES,
  PAGE_LABELS,
  FEATURE_LABELS,
  PAGE_CATEGORIES,
  FEATURE_CATEGORIES,
  PageKey,
  FeatureKey,
} from '../utils/permissions';
import { menuItems as NAV_MENU_ITEMS, menuToPageMap, type MenuItem } from '../navigation/menu';

export function AccessProfileManagement() {
  const [profiles, setProfiles] = useState<AccessProfile[]>([]);
  const [formData, setFormData] = useState<{
    name: string;
    description: string;
    pages: PageKey[];
    features: FeatureKey[];
  }>({
    name: '',
    description: '',
    pages: [],
    features: [],
  });
  const [editingId, setEditingId] = useState<string | null>(null);
  const [deleteDialogOpen, setDeleteDialogOpen] = useState(false);
  const [profileToDelete, setProfileToDelete] = useState<AccessProfile | null>(null);
  const [isSaving, setIsSaving] = useState(false);
  const [isDeleting, setIsDeleting] = useState(false);
  const [isLoading, setIsLoading] = useState(true);
  const [expandedCategories, setExpandedCategories] = useState<{
    pages: Set<string>;
    features: Set<string>;
  }>({
    pages: new Set(Object.keys(PAGE_CATEGORIES)),
    features: new Set(Object.keys(FEATURE_CATEGORIES)),
  });
  // Expansão para árvore de menus dinâmica (perfís → Páginas Acessíveis)
  const [expandedMenus, setExpandedMenus] = useState<Set<string>>(new Set());

  // Carrega perfis do Supabase
  useEffect(() => {
    console.log('🔐 AccessProfileManagement - Carregando perfis do Supabase...');
    loadProfiles();
  }, []);

  async function loadProfiles() {
    try {
      setIsLoading(true);
      
      const token = await getAccessToken();
      
      if (!token) {
        throw new Error('Sessão expirada. Faça login novamente.');
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
        const errorData = await response.json();
        
        // Se tabela não existe, mostra mensagem específica
        if (errorData.needsMigration) {
          toast.error('Banco de dados não configurado', {
            description: 'Execute MIGRATION_ACCESS_PROFILES_TABLE.sql no Supabase',
            duration: 10000,
          });
          
          // Carrega perfis padrão do localStorage como fallback
          const storedProfiles = localStorage.getItem('porsche-cup-profiles');
          if (storedProfiles) {
            setProfiles(JSON.parse(storedProfiles));
          } else {
            const defaultProfiles: AccessProfile[] = DEFAULT_PROFILES.map(p => ({
              ...p,
              createdAt: new Date().toISOString(),
              updatedAt: new Date().toISOString(),
            }));
            setProfiles(defaultProfiles);
            localStorage.setItem('porsche-cup-profiles', JSON.stringify(defaultProfiles));
          }
          return;
        }
        
        throw new Error(errorData.error || 'Erro ao carregar perfis');
      }
      
      const result = await response.json();
      
      if (!result.success) {
        throw new Error(result.error || 'Erro ao carregar perfis');
      }
      
  console.log(`✅ ${result.data.length} perfil(is) carregado(s) do Supabase`);
  setProfiles(result.data);
  // Atualiza cache do localStorage
  localStorage.setItem('porsche-cup-profiles', JSON.stringify(result.data));
      
    } catch (error: any) {
      console.error('❌ Erro ao carregar perfis:', error);
      toast.error('Erro ao carregar perfis', {
        description: error?.message || 'Não foi possível carregar os perfis de acesso.',
        duration: 5000,
      });
      
      // Fallback para localStorage
      try {
        const storedProfiles = localStorage.getItem('porsche-cup-profiles');
        if (storedProfiles) {
          setProfiles(JSON.parse(storedProfiles));
          toast.info('Usando cache local', {
            description: 'Perfis carregados do cache. Alguns dados podem estar desatualizados.',
          });
        }
      } catch {
        // Se tudo falhar, usa perfis padrão
        const defaultProfiles: AccessProfile[] = DEFAULT_PROFILES.map(p => ({
          ...p,
          createdAt: new Date().toISOString(),
          updatedAt: new Date().toISOString(),
        }));
        setProfiles(defaultProfiles);
      }
    } finally {
      setIsLoading(false);
    }
  }

  // Função removida - agora salva no Supabase via API

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    if (!formData.name.trim()) {
      toast.error('Nome obrigatório', {
        description: 'Digite um nome para o perfil.',
      });
      return;
    }

    if (formData.pages.length === 0) {
      toast.error('Selecione ao menos uma página', {
        description: 'O perfil precisa ter acesso a pelo menos uma página.',
      });
      return;
    }

    setIsSaving(true);

    try {
      const token = await getAccessToken();
      
      if (!token) {
        throw new Error('Sessão expirada. Faça login novamente.');
      }
      
      if (editingId) {
        // Atualiza perfil existente
        const response = await fetch(
          `https://${projectId}.supabase.co/functions/v1/make-server-02726c7c/access-profiles/${editingId}`,
          {
            method: 'PUT',
            headers: {
              'Authorization': `Bearer ${token}`,
              'Content-Type': 'application/json'
            },
            body: JSON.stringify({
              name: formData.name,
              description: formData.description,
              pages: formData.pages,
              features: formData.features,
              isDefault: false,
            })
          }
        );
        
        const result = await response.json();
        
        if (!result.success) {
          throw new Error(result.error || 'Erro ao atualizar perfil');
        }
        
        toast.success('✅ Perfil atualizado', {
          description: `${formData.name} foi atualizado com sucesso.`,
        });
        setEditingId(null);
      } else {
        // Cria novo perfil
        const newId = `profile-${Date.now()}`;
        
        const response = await fetch(
          `https://${projectId}.supabase.co/functions/v1/make-server-02726c7c/access-profiles`,
          {
            method: 'POST',
            headers: {
              'Authorization': `Bearer ${token}`,
              'Content-Type': 'application/json'
            },
            body: JSON.stringify({
              id: newId,
              name: formData.name,
              description: formData.description,
              pages: formData.pages,
              features: formData.features,
              isDefault: false,
            })
          }
        );
        
        const result = await response.json();
        
        if (!result.success) {
          throw new Error(result.error || 'Erro ao criar perfil');
        }
        
        toast.success('✅ Perfil criado', {
          description: `${formData.name} foi criado com sucesso.`,
        });
      }

      // Recarrega lista de perfis
      await loadProfiles();
      resetForm();
    } catch (error: any) {
      console.error('Erro ao salvar perfil:', error);
      toast.error('Erro ao salvar perfil', {
        description: error?.message || 'Não foi possível salvar o perfil.',
      });
    } finally {
      setIsSaving(false);
    }
  };

  const handleEdit = (profile: AccessProfile) => {
    setFormData({
      name: profile.name,
      description: profile.description,
      pages: [...profile.pages],
      features: [...profile.features],
    });
    setEditingId(profile.id);
  };

  const handleClone = (profile: AccessProfile) => {
    setFormData({
      name: `${profile.name} (Cópia)`,
      description: profile.description,
      pages: [...profile.pages],
      features: [...profile.features],
    });
    setEditingId(null);
    toast.success('Perfil clonado', {
      description: 'Edite e salve para criar um novo perfil.',
    });
  };

  const handleDeleteClick = (profile: AccessProfile) => {
    if (profile.isSystem) {
      toast.error('Operação não permitida', {
        description: 'Perfis do sistema não podem ser excluídos.',
      });
      return;
    }

    setProfileToDelete(profile);
    setDeleteDialogOpen(true);
  };

  const confirmDelete = async () => {
    if (!profileToDelete) return;

    setIsDeleting(true);

    try {
      const token = await getAccessToken();
      
      if (!token) {
        throw new Error('Sessão expirada. Faça login novamente.');
      }
      
      const response = await fetch(
        `https://${projectId}.supabase.co/functions/v1/make-server-02726c7c/access-profiles/${profileToDelete.id}`,
        {
          method: 'DELETE',
          headers: {
            'Authorization': `Bearer ${token}`,
            'Content-Type': 'application/json'
          }
        }
      );
      
      const result = await response.json();
      
      if (!result.success) {
        throw new Error(result.error || 'Erro ao excluir perfil');
      }
      
      toast.success('🗑️ Perfil excluído', {
        description: `${profileToDelete.name} foi removido.`,
      });
      
      // Recarrega lista de perfis
      await loadProfiles();
    } catch (error: any) {
      console.error('Erro ao excluir perfil:', error);
      toast.error('Erro ao excluir perfil', {
        description: error?.message || 'Não foi possível excluir o perfil.',
      });
    } finally {
      setIsDeleting(false);
      setDeleteDialogOpen(false);
      setProfileToDelete(null);
    }
  };

  const resetForm = () => {
    setFormData({
      name: '',
      description: '',
      pages: [],
      features: [],
    });
    setEditingId(null);
  };

  const togglePage = (page: PageKey) => {
    setFormData(prev => ({
      ...prev,
      pages: prev.pages.includes(page)
        ? prev.pages.filter(p => p !== page)
        : [...prev.pages, page],
    }));
  };

  const toggleFeature = (feature: FeatureKey) => {
    setFormData(prev => ({
      ...prev,
      features: prev.features.includes(feature)
        ? prev.features.filter(f => f !== feature)
        : [...prev.features, feature],
    }));
  };

  const toggleCategoryPages = (category: string, pages: PageKey[]) => {
    const allSelected = pages.every(p => formData.pages.includes(p));
    if (allSelected) {
      // Remove todos
      setFormData(prev => ({
        ...prev,
        pages: prev.pages.filter(p => !pages.includes(p)),
      }));
    } else {
      // Adiciona todos
      setFormData(prev => ({
        ...prev,
        pages: [...new Set([...prev.pages, ...pages])],
      }));
    }
  };

  const toggleCategoryFeatures = (category: string, features: FeatureKey[]) => {
    const allSelected = features.every(f => formData.features.includes(f));
    if (allSelected) {
      // Remove todos
      setFormData(prev => ({
        ...prev,
        features: prev.features.filter(f => !features.includes(f)),
      }));
    } else {
      // Adiciona todos
      setFormData(prev => ({
        ...prev,
        features: [...new Set([...prev.features, ...features])],
      }));
    }
  };

  const toggleCategory = (type: 'pages' | 'features', category: string) => {
    setExpandedCategories(prev => {
      const newSet = new Set(prev[type]);
      if (newSet.has(category)) {
        newSet.delete(category);
      } else {
        newSet.add(category);
      }
      return {
        ...prev,
        [type]: newSet,
      };
    });
  };

  // Helpers para árvore de menus → páginas
  const getPageKeyFromMenuId = (id: string): PageKey | null => {
    const enumKey = menuToPageMap[id];
    return enumKey ? PAGES[enumKey] : null;
  };

  const collectPageKeys = (item: MenuItem): PageKey[] => {
    const direct = getPageKeyFromMenuId(item.id);
    const children = (item.subItems || []).flatMap(collectPageKeys);
    return direct ? [direct, ...children] : children;
  };

  const areAllSelected = (pages: PageKey[]) => pages.every(p => formData.pages.includes(p));
  const areSomeSelected = (pages: PageKey[]) => pages.some(p => formData.pages.includes(p));

  const toggleMenuGroup = (item: MenuItem) => {
    const pagesUnder = collectPageKeys(item);
    if (pagesUnder.length === 0) return;
    const allSelected = areAllSelected(pagesUnder);
    setFormData(prev => ({
      ...prev,
      pages: allSelected
        ? prev.pages.filter(p => !pagesUnder.includes(p))
        : [...new Set([...prev.pages, ...pagesUnder])]
    }));
  };

  const toggleSingleMenu = (item: MenuItem) => {
    const pageKey = getPageKeyFromMenuId(item.id);
    if (!pageKey) return;
    setFormData(prev => ({
      ...prev,
      pages: prev.pages.includes(pageKey)
        ? prev.pages.filter(p => p !== pageKey)
        : [...prev.pages, pageKey]
    }));
  };

  const toggleMenuExpand = (id: string) => {
    setExpandedMenus(prev => {
      const n = new Set(prev);
      if (n.has(id)) n.delete(id); else n.add(id);
      return n;
    });
  };

  const renderMenuTree = (items: MenuItem[], level = 0) => {
    return (
      <div className={level === 0 ? 'space-y-2' : 'space-y-1.5'}>
        {items.map(item => {
          const pageKey = getPageKeyFromMenuId(item.id);
          const childPages = collectPageKeys(item);
          const hasChildren = (item.subItems && item.subItems.length > 0) || false;
          const isExpanded = expandedMenus.has(item.id);
          const allSel = childPages.length > 0 ? areAllSelected(childPages) : (pageKey ? formData.pages.includes(pageKey) : false);
          const someSel = childPages.length > 0 ? areSomeSelected(childPages) && !allSel : false;

          return (
            <div key={item.id} className="space-y-1">
              <div className="flex items-center gap-2">
                {hasChildren ? (
                  <button type="button" onClick={() => toggleMenuExpand(item.id)} className="text-gray-600 hover:text-gray-900">
                    {isExpanded ? <ChevronDown size={16} /> : <ChevronRight size={16} />}
                  </button>
                ) : (
                  <span className="w-4" />
                )}

                {/* Checkbox do grupo/folha */}
                <Checkbox
                  checked={allSel}
                  onCheckedChange={() => (hasChildren ? toggleMenuGroup(item) : toggleSingleMenu(item))}
                  className={someSel && !allSel ? 'opacity-50' : ''}
                />
                <span className="text-sm font-medium text-gray-700">
                  {item.label}
                </span>
              </div>

              {/* Filhos */}
              {hasChildren && isExpanded && (
                <div className="ml-6 pl-2 border-l border-gray-200">
                  {renderMenuTree(item.subItems || [], level + 1)}
                </div>
              )}
            </div>
          );
        })}
      </div>
    );
  };

  return (
    <div className="flex-1 p-3 sm:p-4 lg:p-8 w-full max-w-full overflow-x-hidden">
      <div className="max-w-7xl lg:mx-auto w-full">
        <div className="mb-4 sm:mb-6 lg:mb-8">
          <h1 className="text-gray-900 mb-1 sm:mb-2 text-xl sm:text-2xl lg:text-3xl">Perfis de Acesso</h1>
          <p className="text-gray-500 text-sm sm:text-base">Configure perfis de acesso e permissões do sistema</p>
        </div>

        <div className="grid lg:grid-cols-3 gap-4 sm:gap-6">
          {/* Form */}
          <div className="lg:col-span-1 order-2 lg:order-1">
            <div className="bg-white rounded-xl border border-gray-200 p-4 sm:p-6 shadow-sm lg:sticky lg:top-4">
              <h2 className="text-gray-900 mb-4 sm:mb-6 text-base sm:text-lg">
                {editingId ? 'Editar Perfil' : 'Novo Perfil'}
              </h2>

              <form onSubmit={handleSubmit} className="space-y-3 sm:space-y-4">
                <div>
                  <Label htmlFor="profile-name">Nome do Perfil *</Label>
                  <Input
                    id="profile-name"
                    type="text"
                    value={formData.name}
                    onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                    placeholder="Ex: Gerente de Operações"
                    className="mt-1.5"
                    required
                  />
                </div>

                <div>
                  <Label htmlFor="profile-description">Descrição</Label>
                  <Input
                    id="profile-description"
                    type="text"
                    value={formData.description}
                    onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                    placeholder="Breve descrição do perfil"
                    className="mt-1.5"
                  />
                </div>

                {/* Páginas (dinâmico a partir do menu) */}
                <div>
                  <Label className="mb-3 block">Páginas Acessíveis ({formData.pages.length})</Label>
                  <div className="border border-gray-200 rounded-lg p-3 max-h-64 overflow-y-auto space-y-2">
                    {renderMenuTree(NAV_MENU_ITEMS)}
                  </div>
                </div>

                {/* Funcionalidades */}
                <div>
                  <Label className="mb-3 block">Funcionalidades ({formData.features.length})</Label>
                  <div className="border border-gray-200 rounded-lg p-3 max-h-64 overflow-y-auto space-y-2">
                    {Object.entries(FEATURE_CATEGORIES).map(([category, features]) => {
                      const isExpanded = expandedCategories.features.has(category);
                      const allSelected = features.every(f => formData.features.includes(f));
                      const someSelected = features.some(f => formData.features.includes(f));

                      return (
                        <div key={category} className="space-y-2">
                          <div className="flex items-center gap-2">
                            <button
                              type="button"
                              onClick={() => toggleCategory('features', category)}
                              className="text-gray-600 hover:text-gray-900"
                            >
                              {isExpanded ? <ChevronDown size={16} /> : <ChevronRight size={16} />}
                            </button>
                            <Checkbox
                              checked={allSelected}
                              onCheckedChange={() => toggleCategoryFeatures(category, features as FeatureKey[])}
                              className={someSelected && !allSelected ? 'opacity-50' : ''}
                            />
                            <span className="text-sm font-medium text-gray-700">{category}</span>
                          </div>
                          {isExpanded && (
                            <div className="ml-8 space-y-1.5">
                              {features.map(feature => (
                                <div key={feature} className="flex items-center gap-2">
                                  <Checkbox
                                    checked={formData.features.includes(feature)}
                                    onCheckedChange={() => toggleFeature(feature)}
                                  />
                                  <span className="text-sm text-gray-600">{FEATURE_LABELS[feature]}</span>
                                </div>
                              ))}
                            </div>
                          )}
                        </div>
                      );
                    })}
                  </div>
                </div>

                <div className="flex gap-2 pt-4">
                  <ActionButton
                    type="submit"
                    isLoading={isSaving}
                    loadingText={editingId ? 'Atualizando...' : 'Salvando...'}
                    variant="primary"
                    icon={editingId ? <Edit2 size={16} /> : <Plus size={16} />}
                    className="flex-1"
                  >
                    {editingId ? 'Atualizar' : 'Adicionar'}
                  </ActionButton>
                  {editingId && (
                    <Button type="button" variant="outline" onClick={resetForm}>
                      Cancelar
                    </Button>
                  )}
                </div>
              </form>
            </div>
          </div>

          {/* List */}
          <div className="lg:col-span-2 order-1 lg:order-2">
            <div className="bg-white rounded-xl border border-gray-200 shadow-sm overflow-hidden">
              <div className="p-4 sm:p-6 border-b border-gray-200">
                <div className="flex items-start sm:items-center justify-between flex-col sm:flex-row gap-3 sm:gap-4">
                  <div>
                    <h3 className="text-gray-900 text-base sm:text-lg">Perfis Cadastrados</h3>
                    <p className="text-gray-500 text-xs sm:text-sm">
                      {profiles.length} {profiles.length === 1 ? 'perfil' : 'perfis'} configurado(s)
                    </p>
                  </div>
                  <Button
                    variant="outline"
                    size="sm"
                    onClick={loadProfiles}
                    disabled={isLoading}
                    title="Recarregar perfis do Supabase"
                  >
                    <RefreshCcw size={16} className={isLoading ? 'animate-spin mr-2' : 'mr-2'} />
                    Atualizar
                  </Button>
                </div>
              </div>

              <div className="divide-y divide-gray-200">
                {isLoading ? (
                  <div className="p-8 text-center">
                    <div className="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-gray-900"></div>
                    <p className="text-gray-600 text-sm mt-3">Carregando perfis...</p>
                  </div>
                ) : profiles.length === 0 ? (
                  <div className="p-8 text-center">
                    <Shield className="mx-auto h-12 w-12 text-gray-400 mb-3" />
                    <h3 className="text-gray-900 mb-1">Nenhum perfil encontrado</h3>
                    <p className="text-gray-600 text-sm">Crie o primeiro perfil de acesso</p>
                  </div>
                ) : profiles.map((profile) => (
                  <div key={profile.id} className="p-4 sm:p-6 hover:bg-gray-50 transition-colors">
                    <div className="flex items-start justify-between gap-4">
                      <div className="flex-1 min-w-0">
                        <div className="flex items-center gap-2 mb-2">
                          <h4 className="text-gray-900 font-medium truncate">{profile.name}</h4>
                          {profile.isSystem && (
                            <Badge variant="secondary" className="text-xs">Sistema</Badge>
                          )}
                          {profile.isDefault && (
                            <Badge variant="outline" className="text-xs">Padrão</Badge>
                          )}
                        </div>
                        <p className="text-sm text-gray-600 mb-3">{profile.description}</p>
                        <div className="flex flex-wrap gap-2 text-xs">
                          <Badge variant="outline" className="bg-blue-50 text-blue-700 border-blue-200">
                            {profile.pages.length} páginas
                          </Badge>
                          <Badge variant="outline" className="bg-green-50 text-green-700 border-green-200">
                            {profile.features.length} funcionalidades
                          </Badge>
                        </div>
                      </div>
                      <div className="flex items-center gap-2">
                        <Button
                          variant="outline"
                          size="sm"
                          onClick={() => handleClone(profile)}
                          title="Clonar perfil"
                        >
                          <Copy size={16} />
                        </Button>
                        {/* Editar disponível para todos os perfis (inclui sistema) */}
                        <Button
                          variant="outline"
                          size="sm"
                          onClick={() => handleEdit(profile)}
                          title="Editar perfil"
                        >
                          <Edit2 size={16} />
                        </Button>
                        {/* Excluir permanece bloqueado para perfis do sistema */}
                        {!profile.isSystem && (
                          <Button
                            variant="outline"
                            size="sm"
                            onClick={() => handleDeleteClick(profile)}
                            className="text-red-600 hover:text-red-700 hover:bg-red-50"
                            title="Excluir perfil"
                          >
                            <Trash2 size={16} />
                          </Button>
                        )}
                      </div>
                    </div>
                  </div>
                ))
                }
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Delete Dialog */}
      <AlertDialog open={deleteDialogOpen} onOpenChange={setDeleteDialogOpen}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>Excluir Perfil</AlertDialogTitle>
            <AlertDialogDescription>
              Tem certeza que deseja excluir o perfil "{profileToDelete?.name}"? Esta ação não pode ser desfeita.
              {/* TODO: Adicionar verificação se há usuários usando este perfil */}
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel disabled={isDeleting}>Cancelar</AlertDialogCancel>
            <AlertDialogAction
              onClick={confirmDelete}
              disabled={isDeleting}
              className="bg-red-600 hover:bg-red-700"
            >
              {isDeleting ? 'Excluindo...' : 'Excluir'}
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </div>
  );
}
