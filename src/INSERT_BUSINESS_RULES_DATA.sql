-- =====================================================
-- INSERIR DADOS: business_rules
-- Execute se a tabela JÁ EXISTE mas está vazia
-- =====================================================

-- Limpa dados existentes (opcional)
-- DELETE FROM business_rules;

-- =====================================================
-- INSERE DADOS PADRÃO
-- =====================================================

-- Regras de CORINGAS (Curinga)
INSERT INTO business_rules (rule_type, categoria, campeonato, quantidade) VALUES
  ('curinga', 'Carrera', 'Sprint', 4),
  ('curinga', 'Carrera', 'Endurance', 4),
  ('curinga', 'Challenge', 'Sprint', 4),
  ('curinga', 'Challenge', 'Endurance', 4),
  ('curinga', 'Trophy', 'Sprint', 8)
ON CONFLICT (rule_type, categoria, campeonato) 
DO UPDATE SET quantidade = EXCLUDED.quantidade;

-- Regras de PNEUS SLICK
INSERT INTO business_rules (rule_type, categoria, campeonato, quantidade) VALUES
  ('slick', 'Carrera', 'Sprint', 3),
  ('slick', 'Carrera', 'Endurance', 3),
  ('slick', 'Challenge', 'Sprint', 3),
  ('slick', 'Challenge', 'Endurance', 3),
  ('slick', 'Trophy', 'Sprint', 1)
ON CONFLICT (rule_type, categoria, campeonato) 
DO UPDATE SET quantidade = EXCLUDED.quantidade;

-- Regras de PNEUS WET
INSERT INTO business_rules (rule_type, categoria, campeonato, quantidade) VALUES
  ('wet', 'Carrera', 'Sprint', 4),
  ('wet', 'Carrera', 'Endurance', 4),
  ('wet', 'Challenge', 'Sprint', 4),
  ('wet', 'Challenge', 'Endurance', 4),
  ('wet', 'Trophy', 'Sprint', 4)
ON CONFLICT (rule_type, categoria, campeonato) 
DO UPDATE SET quantidade = EXCLUDED.quantidade;

-- =====================================================
-- VALIDAÇÃO
-- =====================================================

-- Verifica se os dados foram inseridos corretamente
SELECT 
  rule_type,
  COUNT(*) as total_regras,
  SUM(quantidade) as soma_quantidades
FROM business_rules
GROUP BY rule_type
ORDER BY rule_type;

-- Deve retornar:
-- curinga | 5 | 24
-- slick   | 5 | 13
-- wet     | 5 | 20

-- Ver todas as regras
SELECT * FROM business_rules ORDER BY rule_type, categoria, campeonato;

-- =====================================================
-- ✅ DADOS INSERIDOS COM SUCESSO
-- =====================================================
