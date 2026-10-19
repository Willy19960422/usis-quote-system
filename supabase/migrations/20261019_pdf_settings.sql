-- USIS V2.1 PDF layout settings (run once in Supabase SQL Editor)
-- Does not alter existing quotations or company settings.
begin;
create table if not exists public.pdf_settings (
 id integer primary key default 1 check (id = 1),
 company_name_en text not null default 'USIS INTERNATIONAL INFORMATION SECURITY',
 document_title text not null default '報 價 單',
 document_title_en text not null default 'QUOTATION',
 client_sign_title text not null default '客戶訂購確認欄',
 quote_sign_title text not null default '報價確認欄',
 client_sign_label text not null default '承辦人簽章：',
 quote_sign_label text not null default '承辦人簽章：',
 approval_label text not null default '主管簽核：',
 client_confirm_text text not null default '客戶確認後請加蓋公司章簽回，簽回後即視同正式訂購單。',
 brand_color text not null default '#0F625E' check (brand_color ~ '^#[0-9A-Fa-f]{6}$'),
 logo_size text not null default 'medium' check (logo_size in ('small','medium','large')),
 logo_path text,
 updated_at timestamptz not null default now()
);
insert into public.pdf_settings(id) values(1) on conflict(id) do nothing;
alter table public.pdf_settings enable row level security;
drop policy if exists "pdf_settings_read" on public.pdf_settings;
create policy "pdf_settings_read" on public.pdf_settings for select to authenticated using (true);
drop policy if exists "pdf_settings_admin_insert" on public.pdf_settings;
create policy "pdf_settings_admin_insert" on public.pdf_settings for insert to authenticated with check (public.is_admin());
drop policy if exists "pdf_settings_admin_update" on public.pdf_settings;
create policy "pdf_settings_admin_update" on public.pdf_settings for update to authenticated using (public.is_admin()) with check (public.is_admin());
insert into storage.buckets (id,name,public,file_size_limit,allowed_mime_types)
values ('usis-pdf-assets','usis-pdf-assets',true,2097152,array['image/png','image/jpeg','image/webp'])
on conflict (id) do update set public=true,file_size_limit=2097152,allowed_mime_types=array['image/png','image/jpeg','image/webp'];
drop policy if exists "usis_pdf_assets_admin_insert" on storage.objects;
create policy "usis_pdf_assets_admin_insert" on storage.objects for insert to authenticated
with check (bucket_id='usis-pdf-assets' and public.is_admin());
drop policy if exists "usis_pdf_assets_admin_update" on storage.objects;
create policy "usis_pdf_assets_admin_update" on storage.objects for update to authenticated
using (bucket_id='usis-pdf-assets' and public.is_admin())
with check (bucket_id='usis-pdf-assets' and public.is_admin());
drop policy if exists "usis_pdf_assets_admin_delete" on storage.objects;
create policy "usis_pdf_assets_admin_delete" on storage.objects for delete to authenticated
using (bucket_id='usis-pdf-assets' and public.is_admin());
commit;
-- Verification:
-- select * from public.pdf_settings;
-- select id, public from storage.buckets where id='usis-pdf-assets';
