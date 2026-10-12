-- Cloud mirror for Mess Fellows' offline-first sync (see lib/sync/).
--
-- One generic table rather than one per local table: each row is a local
-- SQLite row stored as JSON, keyed by (owner, table, id). The app's local
-- schema can then change without a matching server migration, and old and
-- new app versions can sync through the same table.

create table if not exists public.sync_records (
  user_id    uuid        not null default auth.uid()
                         references auth.users (id) on delete cascade,
  table_name text        not null,
  row_id     text        not null,
  data       jsonb,
  deleted    boolean     not null default false,
  -- Set by the trigger below, never by clients: devices pull "everything
  -- changed since the last updated_at I saw", so it must come from one
  -- clock (the server's), not each phone's.
  updated_at timestamptz not null default clock_timestamp(),
  primary key (user_id, table_name, row_id),
  constraint sync_records_data_present check (deleted or data is not null)
);

create index if not exists sync_records_user_updated_idx
  on public.sync_records (user_id, updated_at);

create or replace function public.sync_records_touch()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at := clock_timestamp();
  if tg_op = 'UPDATE' then
    new.user_id := old.user_id;
  end if;
  return new;
end;
$$;

drop trigger if exists sync_records_touch on public.sync_records;
create trigger sync_records_touch
  before insert or update on public.sync_records
  for each row execute function public.sync_records_touch();

-- Each account sees and writes only its own rows.
alter table public.sync_records enable row level security;

drop policy if exists "Own rows: select" on public.sync_records;
create policy "Own rows: select" on public.sync_records
  for select to authenticated
  using ((select auth.uid()) = user_id);

drop policy if exists "Own rows: insert" on public.sync_records;
create policy "Own rows: insert" on public.sync_records
  for insert to authenticated
  with check ((select auth.uid()) = user_id);

drop policy if exists "Own rows: update" on public.sync_records;
create policy "Own rows: update" on public.sync_records
  for update to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

drop policy if exists "Own rows: delete" on public.sync_records;
create policy "Own rows: delete" on public.sync_records
  for delete to authenticated
  using ((select auth.uid()) = user_id);

revoke all on public.sync_records from anon;
grant select, insert, update, delete on public.sync_records to authenticated;

-- Lets other signed-in devices hear about changes straight away instead of
-- waiting for their next periodic sync.
do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'sync_records'
  ) then
    alter publication supabase_realtime add table public.sync_records;
  end if;
end;
$$;
