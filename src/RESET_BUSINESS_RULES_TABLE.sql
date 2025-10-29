-- =====================================================
-- RESET COMPLETO: business_rules
-- Execute APENAS se precisar limpar tudo e recomeçar
-- =====================================================

-- ⚠️ ATENÇÃO: Isso deleta TUDO relacionado à tabela business_rules
-- Use com cuidado em produção!

-- 1. Remove trigger
DROP TRIGGER IF EXISTS trigger_update_business_rules_updated_at ON business_rules;

-- 2. Remove função do trigger
DROP FUNCTION IF EXISTS update_business_rules_updated_at();

-- 3. Remove políticas RLS
DROP POLICY IF EXISTS "business_rules_select_all" ON business_rules;
DROP POLICY IF EXISTS "business_rules_insert_service_role" ON business_rules;
DROP POLICY IF EXISTS "business_rules_update_service_role" ON business_rules;
DROP POLICY IF EXISTS "business_rules_delete_service_role" ON business_rules;

-- 4. Remove índices
DROP INDEX IF EXISTS idx_business_rules_type;
DROP INDEX IF EXISTS idx_business_rules_category_championship;
DROP INDEX IF EXISTS idx_business_rules_unique;

-- 5. Remove tabela (CASCADE remove tudo que depende dela)
DROP TABLE IF EXISTS business_rules CASCADE;

-- =====================================================
-- ✅ RESET COMPLETO - Tabela business_rules removida
-- =====================================================

-- Agora execute MIGRATION_BUSINESS_RULES_TABLE.sql
-- para recriar a tabela do zero
