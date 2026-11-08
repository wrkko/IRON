-- Run in Supabase SQL Editor. The anon key is safe for browser use only with RLS enabled.
create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null default '',
  age smallint check (age between 13 and 110),
  gender text,
  height_cm numeric(5,1) check (height_cm between 80 and 250),
  current_weight_kg numeric(5,2) check (current_weight_kg between 20 and 500),
  experience text check (experience in ('beginner','intermediate','advanced')),
  goal text check (goal in ('muscle_gain','fat_loss','strength','endurance','general_fitness')),
  workout_frequency smallint check (workout_frequency between 1 and 14),
  equipment text[] not null default '{}',
  workout_duration smallint check (workout_duration between 10 and 240),
  units text not null default 'metric' check (units in ('metric','imperial')),
  avatar_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.exercise_library (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  muscle_group text not null check (muscle_group in ('chest','back','shoulders','biceps','triceps','legs','glutes','abs','full_body')),
  secondary_muscles text[] not null default '{}',
  difficulty text not null check (difficulty in ('beginner','intermediate','advanced')),
  equipment text[] not null default '{}',
  exercise_type text not null default 'strength',
  image_url text,
  description text not null default '',
  instructions text[] not null default '{}',
  recommended_sets smallint not null default 3 check (recommended_sets between 1 and 20),
  recommended_reps text not null default '8-12',
  rest_seconds smallint not null default 90 check (rest_seconds between 0 and 900),
  created_at timestamptz not null default now()
);

create table if not exists public.workouts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null check (length(title) between 1 and 120),
  notes text not null default '',
  scheduled_for date,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create table if not exists public.workout_exercises (
  id uuid primary key default gen_random_uuid(),
  workout_id uuid not null references public.workouts(id) on delete cascade,
  exercise_id uuid references public.exercise_library(id) on delete set null,
  position smallint not null default 0,
  exercise_name text not null,
  sets smallint not null default 3 check (sets between 1 and 30),
  reps text not null default '8-12',
  weight_kg numeric(7,2) check (weight_kg >= 0),
  rest_seconds smallint not null default 90 check (rest_seconds between 0 and 900),
  created_at timestamptz not null default now()
);
create table if not exists public.workout_sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  workout_id uuid references public.workouts(id) on delete set null,
  title text not null,
  started_at timestamptz not null default now(),
  finished_at timestamptz,
  duration_seconds integer check (duration_seconds >= 0),
  estimated_calories integer check (estimated_calories >= 0),
  notes text not null default ''
);
create table if not exists public.completed_sets (
  id uuid primary key default gen_random_uuid(),
  session_id uuid not null references public.workout_sessions(id) on delete cascade,
  exercise_name text not null,
  set_number smallint not null check (set_number > 0),
  reps smallint not null check (reps >= 0),
  weight_kg numeric(7,2) check (weight_kg >= 0),
  completed_at timestamptz not null default now()
);
create table if not exists public.weight_history (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  weight_kg numeric(5,2) not null check (weight_kg between 20 and 500),
  measured_at timestamptz not null default now(),
  note text not null default ''
);
create table if not exists public.body_measurements (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  measured_at timestamptz not null default now(),
  chest_cm numeric(5,1), waist_cm numeric(5,1), hips_cm numeric(5,1),
  arm_cm numeric(5,1), thigh_cm numeric(5,1), body_fat_pct numeric(4,1),
  note text not null default ''
);
create table if not exists public.meals (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  meal_type text not null check (meal_type in ('breakfast','lunch','dinner','snack')),
  eaten_at timestamptz not null default now(),
  created_at timestamptz not null default now()
);
create table if not exists public.meal_items (
  id uuid primary key default gen_random_uuid(),
  meal_id uuid not null references public.meals(id) on delete cascade,
  food_name text not null,
  calories numeric(8,1) not null default 0 check (calories >= 0),
  protein_g numeric(7,1) not null default 0 check (protein_g >= 0),
  carbs_g numeric(7,1) not null default 0 check (carbs_g >= 0),
  fat_g numeric(7,1) not null default 0 check (fat_g >= 0),
  serving text not null default '',
  created_at timestamptz not null default now()
);
create table if not exists public.fitness_goals (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null,
  goal_type text not null,
  target_value numeric(10,2),
  current_value numeric(10,2),
  target_date date,
  completed_at timestamptz,
  created_at timestamptz not null default now()
);

create index if not exists workouts_user_schedule_idx on public.workouts(user_id, scheduled_for);
create index if not exists sessions_user_started_idx on public.workout_sessions(user_id, started_at desc);
create index if not exists weight_user_measured_idx on public.weight_history(user_id, measured_at desc);
create index if not exists measurements_user_measured_idx on public.body_measurements(user_id, measured_at desc);
create index if not exists meals_user_eaten_idx on public.meals(user_id, eaten_at desc);
create index if not exists goals_user_created_idx on public.fitness_goals(user_id, created_at desc);
create index if not exists exercises_group_idx on public.exercise_library(muscle_group, difficulty);

alter table public.profiles enable row level security;
alter table public.exercise_library enable row level security;
alter table public.workouts enable row level security;
alter table public.workout_exercises enable row level security;
alter table public.workout_sessions enable row level security;
alter table public.completed_sets enable row level security;
alter table public.weight_history enable row level security;
alter table public.body_measurements enable row level security;
alter table public.meals enable row level security;
alter table public.meal_items enable row level security;
alter table public.fitness_goals enable row level security;

create policy "profiles own rows" on public.profiles for all using (id = auth.uid()) with check (id = auth.uid());
create policy "authenticated exercise library read" on public.exercise_library for select to authenticated using (true);
create policy "workouts own rows" on public.workouts for all using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "workout exercises own workouts" on public.workout_exercises for all using (exists (select 1 from public.workouts w where w.id = workout_id and w.user_id = auth.uid())) with check (exists (select 1 from public.workouts w where w.id = workout_id and w.user_id = auth.uid()));
create policy "sessions own rows" on public.workout_sessions for all using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "sets own sessions" on public.completed_sets for all using (exists (select 1 from public.workout_sessions s where s.id = session_id and s.user_id = auth.uid())) with check (exists (select 1 from public.workout_sessions s where s.id = session_id and s.user_id = auth.uid()));
create policy "weight history own rows" on public.weight_history for all using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "measurements own rows" on public.body_measurements for all using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "meals own rows" on public.meals for all using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "meal items own meals" on public.meal_items for all using (exists (select 1 from public.meals m where m.id = meal_id and m.user_id = auth.uid())) with check (exists (select 1 from public.meals m where m.id = meal_id and m.user_id = auth.uid()));
create policy "goals own rows" on public.fitness_goals for all using (user_id = auth.uid()) with check (user_id = auth.uid());

-- Create an empty profile on sign-up; users update only their own row.
create or replace function public.handle_new_user() returns trigger language plpgsql security definer set search_path = '' as $$
begin
  insert into public.profiles (id, full_name) values (new.id, coalesce(new.raw_user_meta_data ->> 'full_name',''));
  return new;
end;
$$;
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users for each row execute procedure public.handle_new_user();
