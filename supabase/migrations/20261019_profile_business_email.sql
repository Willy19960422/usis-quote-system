-- USIS: personal sales contact email used on quotations
ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS business_email text NOT NULL DEFAULT '';
