-- =====================================================
-- QUICK FIX - Solução Rápida para o Erro de Policy
-- Copie TUDO e cole no Supabase SQL Editor
-- =====================================================

-- PASSO 1: Limpa tudo que existe
DROP TRIGGER IF EXISTS trigger_update_business_rules_updated_at ON business_rules;
DROP FUNCTION IF EXISTS update_business_rules_updated_at();
DROP POLICY IF EXISTS "business_rules_select_all" ON business_rules;
DROP POLICY IF EXISTS "business_rules_insert_service_role" ON business_rules;
DROP POLICY IF EXISTS "business_rules_update_service_role" ON business_rules;
DROP POLICY IF EXISTS "business_rules_delete_service_role" ON business_rules;
DROP INDEX IF EXISTS idx_business_rules_type;
DROP INDEX IF EXISTS idx_business_rules_category_championship;
DROP INDEX IF EXISTS idx_business_rules_unique;
DROP TABLE IF EXISTS business_rules CASCADE;

-- PASSO 2: Cria tabela do zero
CREATE TABLE business_rules (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  rule_type TEXT NOT NULL CHECK (rule_type IN ('wildcard', 'slick', 'wet')),
  categoria TEXT NOT NULL CHECK (categoria IN ('Carrera', 'Challenge', 'Trophy')),
  campeonato TEXT NOT NULL CHECK (campeonato IN ('Sprint', 'Endurance')),
  quantidade INTEGER NOT NULL CHECK (quantidade >= 0),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT unique_business_rule UNIQUE (rule_type, categoria, campeonato)
);

-- PASSO 3: Comentários
COMMENT ON TABLE business_rules IS 'Regras de Negócio da Porsche Cup Brasil';
COMMENT ON COLUMN business_rules.rule_type IS 'Tipo: wildcard, slick ou wet';
COMMENT ON COLUMN business_rules.categoria IS 'Categoria: Carrera, Challenge ou Trophy';
COMMENT ON COLUMN business_rules.campeonato IS 'Campeonato: Sprint ou Endurance';
COMMENT ON COLUMN business_rules.quantidade IS 'Quantidade permitida';

-- PASSO 4: Índices
CREATE INDEX idx_business_rules_type ON business_rules(rule_type);
CREATE INDEX idx_business_rules_category_championship ON business_rules(categoria, campeonato);
CREATE UNIQUE INDEX idx_business_rules_unique ON business_rules(rule_type, categoria, campeonato);

-- PASSO 5: Trigger para updated_at
CREATE OR REPLACE FUNCTION update_business_rules_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_business_rules_updated_at
  BEFORE UPDATE ON business_rules
  FOR EACH ROW
  EXECUTE FUNCTION update_business_rules_updated_at();

-- PASSO 6: RLS
ALTER TABLE business_rules ENABLE ROW LEVEL SECURITY;

CREATE POLICY "business_rules_select_all"
  ON business_rules
  FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "business_rules_insert_service_role"
  ON business_rules
  FOR INSERT
  TO service_role
  WITH CHECK (true);

CREATE POLICY "business_rules_update_service_role"
  ON business_rules
  FOR UPDATE
  TO service_role
  USING (true)
  WITH CHECK (true);

CREATE POLICY "business_rules_delete_service_role"
  ON business_rules
  FOR DELETE
  TO service_role
  USING (true);

-- PASSO 7: Insere dados padrão
INSERT INTO business_rules (rule_type, categoria, campeonato, quantidade) VALUES
  ('wildcard', 'Carrera', 'Sprint', 4),
  ('wildcard', 'Carrera', 'Endurance', 4),
  ('wildcard', 'Challenge', 'Sprint', 4),
  ('wildcard', 'Challenge', 'Endurance', 4),
  ('wildcard', 'Trophy', 'Sprint', 8),
  ('slick', 'Carrera', 'Sprint', 3),
  ('slick', 'Carrera', 'Endurance', 3),
  ('slick', 'Challenge', 'Sprint', 3),
  ('slick', 'Challenge', 'Endurance', 3),
  ('slick', 'Trophy', 'Sprint', 1),
  ('wet', 'Carrera', 'Sprint', 4),
  ('wet', 'Carrera', 'Endurance', 4),
  ('wet', 'Challenge', 'Sprint', 4),
  ('wet', 'Challenge', 'Endurance', 4),
  ('wet', 'Trophy', 'Sprint', 4)
ON CONFLICT (rule_type, categoria, campeonato) 
DO UPDATE SET quantidade = EXCLUDED.quantidade;

-- PASSO 8: Validação
SELECT 
  rule_type,
  COUNT(*) as total_regras,
  SUM(quantidade) as soma_quantidades
FROM business_rules
GROUP BY rule_type
ORDER BY rule_type;

-- Resultado esperado:
-- slick    | 5 | 13
-- wet      | 5 | 20
-- wildcard | 5 | 24

-- =====================================================
-- ✅ MIGRAÇÃO COMPLETA!
-- Agora teste no frontend: Master Data → Regras
-- =====================================================
