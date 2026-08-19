-- ExecuteOS Supabase schema (run in SQL editor)
-- Enable RLS on every table.

-- Profiles (extends auth.users)
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text,
  full_name text,
  working_hours_start int default 9,
  working_hours_end int default 18,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

alter table public.profiles enable row level security;

create policy "Users can view own profile"
  on public.profiles for select using (auth.uid() = id);
create policy "Users can update own profile"
  on public.profiles for update using (auth.uid() = id);

-- Tasks
create table if not exists public.tasks (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null,
  description text,
  priority text not null default 'medium',
  status text not null default 'notStarted',
  due_at timestamptz,
  start_at timestamptz,
  estimated_minutes int,
  project_id uuid,
  goal_id uuid,
  tags text[] default '{}',
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  completed_at timestamptz
);

create index if not exists tasks_user_due_idx on public.tasks (user_id, due_at);
create index if not exists tasks_user_status_idx on public.tasks (user_id, status);

alter table public.tasks enable row level security;

create policy "Users manage own tasks"
  on public.tasks for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- Goals
create table if not exists public.goals (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null,
  description text,
  status text not null default 'active',
  target_date date,
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  completed_at timestamptz
);

alter table public.goals enable row level security;

create policy "Users manage own goals"
  on public.goals for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- Meetings
create table if not exists public.meetings (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null,
  description text,
  start_at timestamptz not null,
  end_at timestamptz not null,
  location text,
  meeting_link text,
  google_event_id text,
  participants text[] default '{}',
  created_at timestamptz default now()
);

alter table public.meetings enable row level security;

create policy "Users manage own meetings"
  on public.meetings for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
