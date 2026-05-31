create extension if not exists "uuid-ossp";

create table if not exists public.profiles (
    id uuid references auth.users on delete cascade primary key,
    full_name text not null,    
    email text,
    phone text,
    role text check (role in ('patient', 'petugas')) default 'patient',
    fcm_token text,
    avatar_url text,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null,
    updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Upgrade profiles
do $$
begin
    if not exists (select 1 from information_schema.columns where table_name='profiles' and column_name='facility_name') then
        alter table public.profiles add column facility_name text;
    end if;
    if not exists (select 1 from information_schema.columns where table_name='profiles' and column_name='nip') then
        alter table public.profiles add column nip text;
    end if;
    if not exists (select 1 from information_schema.columns where table_name='profiles' and column_name='role') then
        alter table public.profiles add column role text check (role in ('patient', 'petugas')) default 'patient';
    end if;
end $$;

create table if not exists public.patients (
    id uuid primary key default uuid_generate_v4(),
    profile_id uuid references public.profiles(id) on delete set null,
    activation_code text unique,
    address text,
    domicile_lat float8,
    domicile_lng float8,
    diagnosis_date date,
    tb_type text,
    zone text default 'hijau',
    is_active boolean default true,
    gps_consent boolean default false,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null,
    updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Upgrade patients
do $$
begin
    if not exists (select 1 from information_schema.columns where table_name='patients' and column_name='full_name') then
        alter table public.patients add column full_name text;
    end if;
    if not exists (select 1 from information_schema.columns where table_name='patients' and column_name='nik') then
        alter table public.patients add column nik text;
    end if;
    if not exists (select 1 from information_schema.columns where table_name='patients' and column_name='phone') then
        alter table public.patients add column phone text;
    end if;
    if not exists (select 1 from information_schema.columns where table_name='patients' and column_name='facility_name') then
        alter table public.patients add column facility_name text;
    end if;
    if not exists (select 1 from information_schema.columns where table_name='patients' and column_name='district') then
        alter table public.patients add column district text;
    end if;
end $$;

create table if not exists public.tracing_logs (
    id uuid primary key default uuid_generate_v4(),
    patient_id uuid references public.patients(id) on delete set null,
    tracing_ref text,
    latitude float8 not null,
    longitude float8 not null,
    place_name text,
    visited_at timestamp with time zone default timezone('utc'::text, now()) not null,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

create table if not exists public.facilities (
    id uuid primary key default uuid_generate_v4(),
    name text not null,
    type text not null,
    address text,
    latitude float8 not null,
    longitude float8 not null,
    phone text,
    opening_hours jsonb,
    updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

create table if not exists public.zones (
    id uuid primary key default uuid_generate_v4(),
    name text not null,
    level text check (level in ('hijau', 'kuning', 'merah')) default 'hijau',
    case_count integer default 0,
    latitude float8,
    longitude float8,
    updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

create table if not exists public.articles (
    id uuid primary key default uuid_generate_v4(),
    title text not null,
    link text,
    description text,
    pub_date timestamp with time zone default timezone('utc'::text, now()),
    source text default 'Kemenkes RI',
    created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

alter table public.profiles enable row level security;
alter table public.patients enable row level security;
alter table public.tracing_logs enable row level security;
alter table public.facilities enable row level security;
alter table public.zones enable row level security;
alter table public.articles enable row level security;

do $$
begin
    if not exists (select 1 from pg_policies where policyname = 'Public profiles are viewable by everyone.') then
        create policy "Public profiles are viewable by everyone." on public.profiles for select using (true);
    end if;
    if not exists (select 1 from pg_policies where policyname = 'Users can update own profile.') then
        create policy "Users can update own profile." on public.profiles for update using (auth.uid() = id);
    end if;
    if not exists (select 1 from pg_policies where policyname = 'Facilities are viewable by everyone.') then
        create policy "Facilities are viewable by everyone." on public.facilities for select using (true);
    end if;
    if not exists (select 1 from pg_policies where policyname = 'Articles are viewable by everyone.') then
        create policy "Articles are viewable by everyone." on public.articles for select using (true);
    end if;
    if not exists (select 1 from pg_policies where policyname = 'Only petugas can insert/update facilities.') then
        create policy "Only petugas can insert/update facilities." on public.facilities using ( exists (select 1 from public.profiles where id = auth.uid() and role = 'petugas') );
    end if;
    if not exists (select 1 from pg_policies where policyname = 'Petugas can view all patients.') then
        create policy "Petugas can view all patients." on public.patients for select using ( exists (select 1 from public.profiles where id = auth.uid() and role = 'petugas') );
    end if;
    if not exists (select 1 from pg_policies where policyname = 'Patients can view their own data.') then
        create policy "Patients can view their own data." on public.patients for select using ( auth.uid() = profile_id );
    end if;
    if not exists (select 1 from pg_policies where policyname = 'Only petugas can insert patients.') then
        create policy "Only petugas can insert patients." on public.patients for insert with check ( exists (select 1 from public.profiles where id = auth.uid() and role = 'petugas') );
    end if;
    if not exists (select 1 from pg_policies where policyname = 'Only petugas can update patients.') then
        create policy "Only petugas can update patients." on public.patients for update using ( exists (select 1 from public.profiles where id = auth.uid() and role = 'petugas') );
    end if;
    if not exists (select 1 from pg_policies where policyname = 'Patients can update their own data.') then
        create policy "Patients can update their own data." on public.patients for update using ( auth.uid() = profile_id );
    end if;
    if not exists (select 1 from pg_policies where policyname = 'Only petugas can delete patients.') then
        create policy "Only petugas can delete patients." on public.patients for delete using ( exists (select 1 from public.profiles where id = auth.uid() and role = 'petugas') );
    end if;
    if not exists (select 1 from pg_policies where policyname = 'Petugas can insert tracing logs.') then
        create policy "Petugas can insert tracing logs." on public.tracing_logs for insert with check ( exists (select 1 from public.profiles where id = auth.uid() and role = 'petugas') );
    end if;
    if not exists (select 1 from pg_policies where policyname = 'Petugas can view all tracing logs.') then
        create policy "Petugas can view all tracing logs." on public.tracing_logs for select using ( exists (select 1 from public.profiles where id = auth.uid() and role = 'petugas') );
    end if;
    if not exists (select 1 from pg_policies where policyname = 'Petugas can update tracing logs.') then
        create policy "Petugas can update tracing logs." on public.tracing_logs for update using ( exists (select 1 from public.profiles where id = auth.uid() and role = 'petugas') );
    end if;
    if not exists (select 1 from pg_policies where policyname = 'Petugas can delete tracing logs.') then
        create policy "Petugas can delete tracing logs." on public.tracing_logs for delete using ( exists (select 1 from public.profiles where id = auth.uid() and role = 'petugas') );
    end if;
    if not exists (select 1 from pg_policies where policyname = 'Patients can insert own tracing logs.') then
        create policy "Patients can insert own tracing logs." on public.tracing_logs for insert with check (
            exists (
                select 1 from public.patients 
                where patients.id = patient_id 
                and patients.profile_id = auth.uid()
            )
        );
    end if;
    if not exists (select 1 from pg_policies where policyname = 'Patients can view own tracing logs.') then
        create policy "Patients can view own tracing logs." on public.tracing_logs for select using (
            exists (
                select 1 from public.patients 
                where patients.id = patient_id 
                and patients.profile_id = auth.uid()
            )
        );
    end if;
    if not exists (select 1 from pg_policies where policyname = 'Patients can delete own tracing logs.') then
        create policy "Patients can delete own tracing logs." on public.tracing_logs for delete using (
            exists (
                select 1 from public.patients 
                where patients.id = patient_id 
                and patients.profile_id = auth.uid()
            )
        );
    end if;
    if not exists (select 1 from pg_policies where policyname = 'Zones are viewable by everyone.') then
        create policy "Zones are viewable by everyone." on public.zones for select using (true);
    end if;
    if not exists (select 1 from pg_policies where policyname = 'Anyone can insert a profile during registration.') then
        create policy "Anyone can insert a profile during registration." on public.profiles for insert with check (true);
    end if;
end
$$;

create table if not exists public.chat_sessions (
    id uuid primary key default uuid_generate_v4(),
    profile_id uuid references public.profiles(id) on delete cascade,
    title text,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

create table if not exists public.chat_messages (
    id uuid primary key default uuid_generate_v4(),
    session_id uuid references public.chat_sessions(id) on delete cascade,
    role text check (role in ('user', 'model')),
    content text not null,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

alter table public.chat_sessions enable row level security;
alter table public.chat_messages enable row level security;

do $$
begin
    if not exists (select 1 from pg_policies where policyname = 'Users can view their own chat sessions.') then
        create policy "Users can view their own chat sessions." on public.chat_sessions for select using (auth.uid() = profile_id);
    end if;
    if not exists (select 1 from pg_policies where policyname = 'Users can insert their own chat sessions.') then
        create policy "Users can insert their own chat sessions." on public.chat_sessions for insert with check (auth.uid() = profile_id);
    end if;
    if not exists (select 1 from pg_policies where policyname = 'Users can view their own messages.') then
        create policy "Users can view their own messages." on public.chat_messages for select using (exists (select 1 from public.chat_sessions where id = session_id and profile_id = auth.uid()));
    end if;
    if not exists (select 1 from pg_policies where policyname = 'Users can insert their own messages.') then
        create policy "Users can insert their own messages." on public.chat_messages for insert with check (exists (select 1 from public.chat_sessions where id = session_id and profile_id = auth.uid()));
    end if;
end
$$;

insert into public.articles (title, link, description, source)
select 'Mengenal Gejala TBC pada Anak', 'https://tbcindonesia.or.id/gejala-tbc-anak/', 'TBC pada anak seringkali sulit dideteksi karena gejalanya yang tidak spesifik...', 'TBC Indonesia'
where not exists (select 1 from public.articles where title = 'Mengenal Gejala TBC pada Anak');

insert into public.articles (title, link, description, source)
select 'Pentingnya Kepatuhan Minum Obat TBC', 'https://ayosehat.kemkes.go.id/pentingnya-kepatuhan-obat-tbc', 'Pengobatan TBC membutuhkan waktu yang lama, minimal 6 bulan tanpa putus...', 'Kemkes RI'
where not exists (select 1 from public.articles where title = 'Pentingnya Kepatuhan Minum Obat TBC');

insert into public.articles (title, link, description, source)
select 'Gaya Hidup Sehat untuk Pasien TBC', 'https://stoptbindonesia.org/news/', 'Nutrisi yang baik dan lingkungan yang bersih membantu proses penyembuhan...', 'Stop TB Partnership'
where not exists (select 1 from public.articles where title = 'Gaya Hidup Sehat untuk Pasien TBC');

create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, full_name, email, avatar_url, role)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'full_name', ''),
    new.email,
    new.raw_user_meta_data->>'avatar_url',
    'patient'
  );
  return new;
end;
$$ language plpgsql security definer;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

create or replace function public.handle_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

drop trigger if exists set_profiles_updated_at on public.profiles;
create trigger set_profiles_updated_at before update on public.profiles for each row execute procedure public.handle_updated_at();

drop trigger if exists set_patients_updated_at on public.patients;
create trigger set_patients_updated_at before update on public.patients for each row execute procedure public.handle_updated_at();

drop trigger if exists set_facilities_updated_at on public.facilities;
create trigger set_facilities_updated_at before update on public.facilities for each row execute procedure public.handle_updated_at();

drop trigger if exists set_zones_updated_at on public.zones;
create trigger set_zones_updated_at before update on public.zones for each row execute procedure public.handle_updated_at();

insert into public.facilities (name, type, address, latitude, longitude)
select 'Puskesmas Sukajadi', 'Puskesmas', 'Jl. Sukajadi No. 123', -6.8893, 107.5901
where not exists (select 1 from public.facilities where name = 'Puskesmas Sukajadi');

insert into public.facilities (name, type, address, latitude, longitude)
select 'RSUD Hasan Sadikin', 'RSUD', 'Jl. Pasteur No. 38', -6.8966, 107.5976
where not exists (select 1 from public.facilities where name = 'RSUD Hasan Sadikin');

insert into public.facilities (name, type, address, latitude, longitude)
select 'Puskesmas Coblong', 'Puskesmas', 'Jl. Sangkuriang No. 1', -6.8833, 107.6103
where not exists (select 1 from public.facilities where name = 'Puskesmas Coblong');

insert into public.zones (name, level, case_count, latitude, longitude)
select 'Kecamatan Coblong', 'merah', 45, -6.8833, 107.6103
where not exists (select 1 from public.zones where name = 'Kecamatan Coblong');

insert into public.zones (name, level, case_count, latitude, longitude)
select 'Kecamatan Sukajadi', 'kuning', 12, -6.8893, 107.5901
where not exists (select 1 from public.zones where name = 'Kecamatan Sukajadi');

insert into public.zones (name, level, case_count, latitude, longitude)
select 'Kecamatan Sumur Bandung', 'hijau', 3, -6.9147, 107.6098
where not exists (select 1 from public.zones where name = 'Kecamatan Sumur Bandung');

insert into public.facilities (name, type, address, latitude, longitude)
select 'Apotek Kimia Farma Pasteur', 'Apotek', 'Jl. Pasteur No. 50', -6.8973, 107.5985
where not exists (select 1 from public.facilities where name = 'Apotek Kimia Farma Pasteur');

create or replace function public.activate_patient(
    p_code text,
    p_profile_id uuid
)
returns boolean as $$
declare
    v_patient_id uuid;
begin
    select id into v_patient_id 
    from public.patients 
    where activation_code = p_code 
    and profile_id is null;

    if v_patient_id is null then
        return false;
    end if;

    update public.patients
    set profile_id = p_profile_id,
        activation_code = null
    where id = v_patient_id;

    return true;
end;
$$ language plpgsql security definer;

-- Upgrade patients with created_by field for tracking
do $$
begin
    if not exists (select 1 from information_schema.columns where table_name='patients' and column_name='created_by') then
        alter table public.patients add column created_by uuid references public.profiles(id);
    end if;
end $$;

-- Policy to allow authenticated petugas to insert/publish articles
do $$
begin
    if not exists (select 1 from pg_policies where policyname = 'Only petugas can insert articles.') then
        create policy "Only petugas can insert articles." on public.articles for insert with check ( exists (select 1 from public.profiles where id = auth.uid() and role = 'petugas') );
    end if;
    if not exists (select 1 from pg_policies where policyname = 'Allow insert for authenticated users') then
        create policy "Allow insert for authenticated users" on public.articles for insert with check (auth.role() = 'authenticated');
    end if;
end $$;

-- ═══════════════════════════════════════════════════════════════════════════
-- PATIENT SELF-SERVICE FUNCTIONS (bypass RLS via SECURITY DEFINER)
-- Jalankan SQL ini di Supabase Dashboard → SQL Editor
-- ═══════════════════════════════════════════════════════════════════════════

-- 1. Pasien dapat mengubah persetujuan GPS milik sendiri
create or replace function public.set_gps_consent(p_consent boolean)
returns void as $$
begin
  update public.patients
  set gps_consent = p_consent
  where profile_id = auth.uid();
end;
$$ language plpgsql security definer;

-- 2. Pasien dapat menyisipkan log tracing milik sendiri
--    (hanya jika gps_consent = true & is_active = true)
create or replace function public.insert_patient_tracing_log(
  p_lat   double precision,
  p_lng   double precision,
  p_place_name  text    default null,
  p_tracing_ref text    default null
)
returns void as $$
declare
  v_patient_id uuid;
begin
  select id into v_patient_id
  from public.patients
  where profile_id = auth.uid()
    and gps_consent  = true
    and is_active    = true;

  if v_patient_id is null then
    raise exception 'GPS consent not granted or patient not active';
  end if;

  insert into public.tracing_logs
    (patient_id, latitude, longitude, place_name, tracing_ref, visited_at, created_at)
  values
    (v_patient_id, p_lat, p_lng, p_place_name, p_tracing_ref, now(), now());
end;
$$ language plpgsql security definer;

-- 3. Hapus log lama (>10 menit) milik pasien sendiri
create or replace function public.cleanup_patient_tracing_logs()
returns void as $$
declare
  v_patient_id uuid;
begin
  select id into v_patient_id
  from public.patients
  where profile_id = auth.uid();

  if v_patient_id is not null then
    delete from public.tracing_logs
    where patient_id = v_patient_id
      and visited_at < now() - interval '10 minutes';
  end if;
end;
$$ language plpgsql security definer;
