-- Waxtix database: run this whole file in Supabase SQL Editor.
create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text unique,
  avatar_url text,
  bio text default '',
  followers_count integer not null default 0,
  following_count integer not null default 0,
  views_count bigint not null default 0,
  theme_colour text default '#8b5cf6',
  language text default 'en',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.videos (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  title text not null,
  video_url text not null,
  thumbnail_url text,
  duration integer not null default 60 check (duration between 1 and 60),
  views_count bigint not null default 0,
  likes_count bigint not null default 0,
  comments_count bigint not null default 0,
  created_at timestamptz not null default now()
);

create table if not exists public.news (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  title text not null,
  body text not null default '',
  image_url text,
  created_at timestamptz not null default now()
);

create table if not exists public.follows (
  follower_id uuid references public.profiles(id) on delete cascade,
  following_id uuid references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (follower_id, following_id),
  check (follower_id <> following_id)
);

create table if not exists public.likes (
  user_id uuid references public.profiles(id) on delete cascade,
  video_id uuid references public.videos(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (user_id, video_id)
);

create table if not exists public.comments (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references public.profiles(id) on delete cascade,
  video_id uuid references public.videos(id) on delete cascade,
  body text not null,
  created_at timestamptz not null default now()
);

create table if not exists public.chat_messages (
  id uuid primary key default gen_random_uuid(),
  sender_id uuid references public.profiles(id) on delete cascade,
  receiver_id uuid references public.profiles(id) on delete cascade,
  body text not null,
  created_at timestamptz not null default now()
);

alter table public.profiles enable row level security;
alter table public.videos enable row level security;
alter table public.news enable row level security;
alter table public.follows enable row level security;
alter table public.likes enable row level security;
alter table public.comments enable row level security;
alter table public.chat_messages enable row level security;

drop policy if exists "profiles public read" on public.profiles;
create policy "profiles public read" on public.profiles for select using (true);
drop policy if exists "profiles own insert" on public.profiles;
create policy "profiles own insert" on public.profiles for insert with check (auth.uid()=id);
drop policy if exists "profiles own update" on public.profiles;
create policy "profiles own update" on public.profiles for update using (auth.uid()=id) with check (auth.uid()=id);

drop policy if exists "videos public read" on public.videos;
create policy "videos public read" on public.videos for select using (true);
drop policy if exists "videos own insert" on public.videos;
create policy "videos own insert" on public.videos for insert with check (auth.uid()=user_id);
drop policy if exists "videos own update" on public.videos;
create policy "videos own update" on public.videos for update using (auth.uid()=user_id);
drop policy if exists "videos own delete" on public.videos;
create policy "videos own delete" on public.videos for delete using (auth.uid()=user_id);

drop policy if exists "news public read" on public.news;
create policy "news public read" on public.news for select using (true);
drop policy if exists "news own insert" on public.news;
create policy "news own insert" on public.news for insert with check (auth.uid()=user_id);
drop policy if exists "news own update" on public.news;
create policy "news own update" on public.news for update using (auth.uid()=user_id);
drop policy if exists "news own delete" on public.news;
create policy "news own delete" on public.news for delete using (auth.uid()=user_id);

drop policy if exists "follows public read" on public.follows;
create policy "follows public read" on public.follows for select using (true);
drop policy if exists "follows own insert" on public.follows;
create policy "follows own insert" on public.follows for insert with check (auth.uid()=follower_id);
drop policy if exists "follows own delete" on public.follows;
create policy "follows own delete" on public.follows for delete using (auth.uid()=follower_id);

drop policy if exists "likes public read" on public.likes;
create policy "likes public read" on public.likes for select using (true);
drop policy if exists "likes own insert" on public.likes;
create policy "likes own insert" on public.likes for insert with check (auth.uid()=user_id);
drop policy if exists "likes own delete" on public.likes;
create policy "likes own delete" on public.likes for delete using (auth.uid()=user_id);

drop policy if exists "comments public read" on public.comments;
create policy "comments public read" on public.comments for select using (true);
drop policy if exists "comments signed insert" on public.comments;
create policy "comments signed insert" on public.comments for insert with check (auth.uid()=user_id);
drop policy if exists "comments own delete" on public.comments;
create policy "comments own delete" on public.comments for delete using (auth.uid()=user_id);

drop policy if exists "chat participants read" on public.chat_messages;
create policy "chat participants read" on public.chat_messages for select using (auth.uid()=sender_id or auth.uid()=receiver_id);
drop policy if exists "chat sender insert" on public.chat_messages;
create policy "chat sender insert" on public.chat_messages for insert with check (auth.uid()=sender_id);
drop policy if exists "chat sender delete" on public.chat_messages;
create policy "chat sender delete" on public.chat_messages for delete using (auth.uid()=sender_id);

insert into storage.buckets (id,name,public) values ('videos','videos',true) on conflict (id) do nothing;
insert into storage.buckets (id,name,public) values ('news-media','news-media',true) on conflict (id) do nothing;

drop policy if exists "public video files read" on storage.objects;
create policy "public video files read" on storage.objects for select using (bucket_id='videos');
drop policy if exists "own video files upload" on storage.objects;
create policy "own video files upload" on storage.objects for insert to authenticated with check (bucket_id='videos' and (storage.foldername(name))[1]=auth.uid()::text);
drop policy if exists "own video files delete" on storage.objects;
create policy "own video files delete" on storage.objects for delete to authenticated using (bucket_id='videos' and (storage.foldername(name))[1]=auth.uid()::text);
drop policy if exists "public news files read" on storage.objects;
create policy "public news files read" on storage.objects for select using (bucket_id='news-media');
drop policy if exists "own news files upload" on storage.objects;
create policy "own news files upload" on storage.objects for insert to authenticated with check (bucket_id='news-media' and (storage.foldername(name))[1]=auth.uid()::text);
drop policy if exists "own news files delete" on storage.objects;
create policy "own news files delete" on storage.objects for delete to authenticated using (bucket_id='news-media' and (storage.foldername(name))[1]=auth.uid()::text);

create or replace function public.handle_new_user() returns trigger language plpgsql security definer set search_path=public as $$
begin
  insert into public.profiles (id, username) values (new.id, coalesce(new.raw_user_meta_data->>'user_name', split_part(coalesce(new.email,new.phone,'waxtixuser'),'@',1))) on conflict (id) do nothing;
  return new;
end;$$;
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users for each row execute procedure public.handle_new_user();
