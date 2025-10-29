-- ============================================
-- MIGRATION: Access Profiles Table
-- Cria tabela para armazenar perfis de acesso (RBAC)
-- ============================================

-- Desabilita RLS temporariamente para criar tabela
ALTER TABLE IF EXISTS access_profiles DISABLE ROW LEVEL SECURITY;

-- Remove tabela se existir (cuidado em produção!)
DROP TABLE IF EXISTS access_profiles CASCADE;

-- Cria tabela de perfis de acesso
CREATE TABLE access_profiles (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT NOT NULL DEFAULT '',
  pages JSONB NOT NULL DEFAULT '[]'::jsonb,
  features JSONB NOT NULL DEFAULT '[]'::jsonb,
  is_default BOOLEAN NOT NULL DEFAULT false,
  is_system BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Índices para performance
CREATE INDEX idx_access_profiles_name ON access_profiles(name);
CREATE INDEX idx_access_profiles_is_system ON access_profiles(is_system);
CREATE INDEX idx_access_profiles_is_default ON access_profiles(is_default);

-- Comentários
COMMENT ON TABLE access_profiles IS 'Perfis de acesso do sistema (RBAC)';
COMMENT ON COLUMN access_profiles.id IS 'Identificador único do perfil (ex: admin, operator)';
COMMENT ON COLUMN access_profiles.name IS 'Nome amigável do perfil';
COMMENT ON COLUMN access_profiles.description IS 'Descrição do que o perfil permite';
COMMENT ON COLUMN access_profiles.pages IS 'Array JSON de páginas acessíveis';
COMMENT ON COLUMN access_profiles.features IS 'Array JSON de funcionalidades permitidas';
COMMENT ON COLUMN access_profiles.is_default IS 'Perfil padrão para novos usuários';
COMMENT ON COLUMN access_profiles.is_system IS 'Perfil do sistema (não pode ser deletado)';

-- Trigger para atualizar updated_at automaticamente
CREATE OR REPLACE FUNCTION update_access_profiles_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER access_profiles_updated_at
  BEFORE UPDATE ON access_profiles
  FOR EACH ROW
  EXECUTE FUNCTION update_access_profiles_updated_at();

-- Insere perfis padrão do sistema
INSERT INTO access_profiles (id, name, description, pages, features, is_default, is_system, created_at, updated_at) VALUES
(
  'admin',
  'Administrador',
  'Acesso total ao sistema, incluindo gerenciamento de usuários e configurações',
  '["dashboard","stock_entry","tire_model","container","reports","discard_reports","user_management","master_data","status_registration","stock_adjustment","tire_movement","tire_status_change","tire_discard","tire_consumption","data_import","arcs_update"]'::jsonb,
  '["stock_create","stock_edit","stock_delete","stock_export","model_create","model_edit","model_delete","container_create","container_edit","container_delete","reports_view","reports_export","user_create","user_edit","user_delete","user_view","master_data_edit","status_create","status_edit","status_delete","movement_create","movement_approve","discard_create","discard_view","import_data","arcs_update","arcs_view"]'::jsonb,
  true,
  true,
  NOW(),
  NOW()
),
(
  'operator',
  'Operador',
  'Acesso às funcionalidades operacionais básicas (entrada, movimentação, consultas)',
  '["dashboard","stock_entry","tire_model","container","reports","tire_movement","tire_status_change"]'::jsonb,
  '["stock_create","stock_export","model_create","container_create","reports_view","reports_export","movement_create"]'::jsonb,
  true,
  true,
  NOW(),
  NOW()
),
(
  'supervisor',
  'Supervisor',
  'Acesso operacional completo + aprovações e descartes',
  '["dashboard","stock_entry","tire_model","container","reports","discard_reports","stock_adjustment","tire_movement","tire_status_change","tire_discard","tire_consumption"]'::jsonb,
  '["stock_create","stock_edit","stock_export","model_create","model_edit","container_create","container_edit","reports_view","reports_export","movement_create","movement_approve","discard_create","discard_view"]'::jsonb,
  false,
  true,
  NOW(),
  NOW()
),
(
  'viewer',
  'Visualizador',
  'Acesso somente leitura (consultas e relatórios)',
  '["dashboard","reports","discard_reports"]'::jsonb,
  '["reports_view","reports_export","discard_view"]'::jsonb,
  false,
  true,
  NOW(),
  NOW()
);

-- Habilita RLS (Row Level Security)
ALTER TABLE access_profiles ENABLE ROW LEVEL SECURITY;

-- Política: Todos podem ler perfis
CREATE POLICY "Everyone can read access profiles"
  ON access_profiles
  FOR SELECT
  USING (true);

-- Política: Apenas admins podem criar/atualizar perfis
CREATE POLICY "Only admins can insert access profiles"
  ON access_profiles
  FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM auth.users
      WHERE auth.users.id = auth.uid()
      AND auth.users.raw_user_meta_data->>'role' = 'admin'
    )
  );

CREATE POLICY "Only admins can update access profiles"
  ON access_profiles
  FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM auth.users
      WHERE auth.users.id = auth.uid()
      AND auth.users.raw_user_meta_data->>'role' = 'admin'
    )
  );

-- Política: Apenas admins podem deletar perfis não-sistema
CREATE POLICY "Only admins can delete non-system profiles"
  ON access_profiles
  FOR DELETE
  USING (
    is_system = false
    AND EXISTS (
      SELECT 1 FROM auth.users
      WHERE auth.users.id = auth.uid()
      AND auth.users.raw_user_meta_data->>'role' = 'admin'
    )
  );

-- Verificação
SELECT 
  id,
  name,
  description,
  jsonb_array_length(pages) as num_pages,
  jsonb_array_length(features) as num_features,
  is_default,
  is_system
FROM access_profiles
ORDER BY is_system DESC, is_default DESC, name;

-- Resultado esperado:
-- ✅ 4 perfis criados (admin, operator, supervisor, viewer)
-- ✅ Todos com is_system = true (protegidos)
-- ✅ Admin e Operator com is_default = true
