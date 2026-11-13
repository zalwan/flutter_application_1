-- ============================================================
-- Migration Praktikum 10
-- Jalankan seluruh isi file ini di Supabase Dashboard > SQL Editor > Run.
-- File ini idempotent: aman dijalankan lebih dari sekali.
-- ============================================================

-- ------------------------------------------------------------
-- 1. Kolom baru pada tabel todos
-- ------------------------------------------------------------
alter table public.todos
  add column if not exists description text;

alter table public.todos
  add column if not exists photo_url text;

alter table public.todos
  add column if not exists latitude double precision;

alter table public.todos
  add column if not exists longitude double precision;

-- ------------------------------------------------------------
-- 2. Storage bucket untuk foto dari kamera
--    (public = true supaya URL publik bisa ditampilkan langsung)
-- ------------------------------------------------------------
insert into storage.buckets (id, name, public)
values ('todo-photos', 'todo-photos', true)
on conflict (id) do nothing;

-- Kebijakan RLS bucket: user hanya boleh menyentuh folder dengan
-- nama yang sama dengan user_id miliknya.
drop policy if exists "todo_photos_select_own" on storage.objects;
create policy "todo_photos_select_own" on storage.objects for
select
  to authenticated using (
    bucket_id = 'todo-photos'
    and (storage.foldername (name))[1] = auth.uid ()::text
  );

drop policy if exists "todo_photos_insert_own" on storage.objects;
create policy "todo_photos_insert_own" on storage.objects for
insert
  to authenticated
  with
    check (
      bucket_id = 'todo-photos'
      and (storage.foldername (name))[1] = auth.uid ()::text
    );

drop policy if exists "todo_photos_update_own" on storage.objects;
create policy "todo_photos_update_own" on storage.objects for
update
  to authenticated
  using (
    bucket_id = 'todo-photos'
    and (storage.foldername (name))[1] = auth.uid ()::text
  )
  with
    check (
      bucket_id = 'todo-photos'
      and (storage.foldername (name))[1] = auth.uid ()::text
    );

drop policy if exists "todo_photos_delete_own" on storage.objects;
create policy "todo_photos_delete_own" on storage.objects for
delete
  to authenticated
  using (
    bucket_id = 'todo-photos'
    and (storage.foldername (name))[1] = auth.uid ()::text
  );

-- ------------------------------------------------------------
-- 3. Tabel token FCM (Push Notification)
-- ------------------------------------------------------------
create table
  if not exists public.fcm_tokens (
    user_id uuid primary key references auth.users (id) on delete cascade,
    token text not null,
    updated_at timestamptz not null default now ()
  );

alter table public.fcm_tokens enable row level security;

drop policy if exists "fcm_tokens_select_own" on public.fcm_tokens;
create policy "fcm_tokens_select_own" on public.fcm_tokens for
select
  to authenticated using (auth.uid () = user_id);

drop policy if exists "fcm_tokens_insert_own" on public.fcm_tokens;
create policy "fcm_tokens_insert_own" on public.fcm_tokens for
insert
  to authenticated
  with
    check (auth.uid () = user_id);

drop policy if exists "fcm_tokens_update_own" on public.fcm_tokens;
create policy "fcm_tokens_update_own" on public.fcm_tokens for
update
  to authenticated
  using (auth.uid () = user_id)
  with
    check (auth.uid () = user_id);

drop policy if exists "fcm_tokens_delete_own" on public.fcm_tokens;
create policy "fcm_tokens_delete_own" on public.fcm_tokens for
delete
  to authenticated using (auth.uid () = user_id);
