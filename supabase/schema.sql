create table
  if not exists public.todos (
    id uuid primary key default gen_random_uuid (),
    user_id uuid not null default auth.uid () references auth.users (id) on delete cascade,
    title text not null check (char_length(btrim (title)) between 1 and 200),
    description text,
    photo_url text,
    latitude double precision,
    longitude double precision,
    is_done boolean not null default false,
    created_at timestamptz not null default now ()
  );

create index if not exists todos_user_id_created_at_idx on public.todos (user_id, is_done, created_at desc);

alter table public.todos enable row level security;

drop policy if exists "todos_select_own" on public.todos;

create policy "todos_select_own" on public.todos for
select
  to authenticated using (auth.uid () = user_id);

drop policy if exists "todos_insert_own" on public.todos;

create policy "todos_insert_own" on public.todos for insert to authenticated
with
  check (auth.uid () = user_id);

drop policy if exists "todos_update_own" on public.todos;

create policy "todos_update_own" on public.todos for
update to authenticated using (auth.uid () = user_id)
with
  check (auth.uid () = user_id);

drop policy if exists "todos_delete_own" on public.todos;

create policy "todos_delete_own" on public.todos for delete to authenticated using (auth.uid () = user_id);

-- ------------------------------------------------------------
-- Praktikum 10: Storage bucket foto + tabel token FCM
-- (idempotent, aman dijalankan ulang pada database lama)
-- ------------------------------------------------------------

insert into storage.buckets (id, name, public)
values ('todo-photos', 'todo-photos', true)
on conflict (id) do nothing;

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
