-- USIS V2.1 discount columns. Run after the existing PDF settings migration.
BEGIN;
ALTER TABLE public.quotations ADD COLUMN IF NOT EXISTS discount_type text NOT NULL DEFAULT 'none';
ALTER TABLE public.quotations ADD COLUMN IF NOT EXISTS discount_value numeric(14,2) NOT NULL DEFAULT 0;
ALTER TABLE public.quotations ADD COLUMN IF NOT EXISTS discount_amount numeric(14,2) NOT NULL DEFAULT 0;
ALTER TABLE public.quotations DROP CONSTRAINT IF EXISTS quotations_discount_type_check;
ALTER TABLE public.quotations ADD CONSTRAINT quotations_discount_type_check CHECK (discount_type IN ('none','percent','fixed'));
ALTER TABLE public.quotations DROP CONSTRAINT IF EXISTS quotations_discount_value_check;
ALTER TABLE public.quotations ADD CONSTRAINT quotations_discount_value_check CHECK (discount_value >= 0 AND (discount_type <> 'percent' OR discount_value <= 100));
ALTER TABLE public.quotations DROP CONSTRAINT IF EXISTS quotations_discount_amount_check;
ALTER TABLE public.quotations ADD CONSTRAINT quotations_discount_amount_check CHECK (discount_amount >= 0);
COMMIT;
