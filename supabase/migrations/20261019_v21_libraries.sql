-- USIS V2.1 reusable service bundles and quotation templates
-- Execute in Supabase SQL editor before using these two features.
BEGIN;
CREATE TABLE IF NOT EXISTS public.service_bundles (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 name text NOT NULL UNIQUE,
 items jsonb NOT NULL DEFAULT '[]'::jsonb,
 created_at timestamptz NOT NULL DEFAULT now(),
 CONSTRAINT service_bundles_items_array CHECK (jsonb_typeof(items)='array')
);
CREATE TABLE IF NOT EXISTS public.quotation_templates (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 name text NOT NULL UNIQUE,
 items jsonb NOT NULL DEFAULT '[]'::jsonb,
 notes text NOT NULL DEFAULT '',
 tax_rate numeric NOT NULL DEFAULT 5,
 created_at timestamptz NOT NULL DEFAULT now(),
 CONSTRAINT quotation_templates_items_array CHECK (jsonb_typeof(items)='array'),
 CONSTRAINT quotation_templates_tax_rate CHECK (tax_rate BETWEEN 0 AND 100)
);
ALTER TABLE public.service_bundles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.quotation_templates ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "v21_bundles_read" ON public.service_bundles;
CREATE POLICY "v21_bundles_read" ON public.service_bundles FOR SELECT TO authenticated USING (true);
DROP POLICY IF EXISTS "v21_bundles_manage" ON public.service_bundles;
CREATE POLICY "v21_bundles_manage" ON public.service_bundles FOR ALL TO authenticated USING (public.get_my_role() IN ('admin','manager')) WITH CHECK (public.get_my_role() IN ('admin','manager'));
DROP POLICY IF EXISTS "v21_templates_read" ON public.quotation_templates;
CREATE POLICY "v21_templates_read" ON public.quotation_templates FOR SELECT TO authenticated USING (true);
DROP POLICY IF EXISTS "v21_templates_manage" ON public.quotation_templates;
CREATE POLICY "v21_templates_manage" ON public.quotation_templates FOR ALL TO authenticated USING (public.get_my_role() IN ('admin','manager')) WITH CHECK (public.get_my_role() IN ('admin','manager'));
COMMIT;
