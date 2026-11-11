-- Funil Vetor: banco e permissões.
-- Cole este arquivo inteiro no Supabase: SQL Editor > New query > Run.
-- ANTES de rodar, troque os dois e-mails no final pelos e-mails reais (o seu e o da SDR).

create table if not exists public.docs (
  collection text not null,
  id         text not null,
  data       jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now(),
  primary key (collection, id)
);

create table if not exists public.allowed_users (
  email text primary key,
  role  text not null default 'sdr' check (role in ('admin','sdr'))
);

alter table public.docs enable row level security;
alter table public.allowed_users enable row level security;
-- allowed_users não tem política: ninguém lê pela API. Só as funções abaixo consultam.

create or replace function public.is_allowed() returns boolean
language sql security definer stable set search_path = public as $$
  select exists (select 1 from public.allowed_users where lower(email) = lower(auth.jwt() ->> 'email'))
$$;

create or replace function public.my_role() returns text
language sql security definer stable set search_path = public as $$
  select role from public.allowed_users where lower(email) = lower(auth.jwt() ->> 'email')
$$;

drop policy if exists docs_acesso on public.docs;
create policy docs_acesso on public.docs for all to authenticated
  using (public.is_allowed()) with check (public.is_allowed());

-- Atualização parcial atômica (mescla os campos enviados no documento).
create or replace function public.doc_update(p_collection text, p_id text, p_patch jsonb) returns void
language plpgsql security invoker as $$
begin
  update public.docs set data = data || p_patch, updated_at = now()
  where collection = p_collection and id = p_id;
end $$;

revoke all on function public.is_allowed() from public, anon;
revoke all on function public.my_role() from public, anon;
revoke all on function public.doc_update(text, text, jsonb) from public, anon;
grant execute on function public.is_allowed() to authenticated;
grant execute on function public.my_role() to authenticated;
grant execute on function public.doc_update(text, text, jsonb) to authenticated;

-- Atualização em tempo real entre os dois usuários.
alter table public.docs replica identity full;
do $$ begin
  alter publication supabase_realtime add table public.docs;
exception when duplicate_object then null; end $$;

-- Quem pode entrar. TROQUE OS E-MAILS.
insert into public.allowed_users (email, role) values
  ('TROQUE_PELO_SEU_EMAIL@exemplo.com', 'admin'),
  ('TROQUE_PELO_EMAIL_DA_SDR@exemplo.com', 'sdr')
on conflict (email) do update set role = excluded.role;
