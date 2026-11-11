# Funil Vetor

CRM de prospecção da Vetor Digital: funil em Kanban, base de leads com classes A/B/C, dashboard e manual da SDR.
Site estático (`public/index.html`) na Vercel; login e banco no Supabase.

## Montagem (uma vez)

1. **Supabase**: crie um projeto. Em *Authentication > Sign In / Providers > Email*, desligue **Allow new users to sign up**.
2. Em *Authentication > Users > Add user*, crie dois usuários (e-mail + senha, com *Auto Confirm User*): Filipe e a SDR.
3. Edite `supabase/schema.sql` (os dois e-mails no final) e rode no *SQL Editor*.
4. Em *Project Settings > API*, copie **Project URL** e a chave **anon public**.
5. **Vercel**: *Add New > Project*, importe este repositório (Framework Preset: Other). Em *Environment Variables* crie `SUPABASE_URL` e `SUPABASE_ANON_KEY`. Faça o deploy.

## Segurança

- A chave `anon` é pública por desenho. Quem protege os dados é a política de acesso (RLS) do `schema.sql`: só e-mails da tabela `allowed_users` leem ou gravam.
- Cadastro público desligado: ninguém cria conta sozinho.
- Papéis: `admin` vê tudo; `sdr` não vê classes A/B/C, Base, Importar nem Configurações (ocultação na interface, não bloqueio técnico).

## Dados

Tabela `docs (collection, id, data jsonb)`: `leads`, `config` (follow-ups, proporção A/B/C, número de WhatsApp, manual).
Backup: *Table Editor > docs > Export*.
