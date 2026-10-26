-- =====================================================================
-- Migration: Add pgvector extension and vector search for coach messages
-- =====================================================================

-- 1. Enable pgvector extension
create extension if not exists vector with schema extensions;

-- 2. Add embedding column to public.messages (1536 dimensions for OpenAI/text-embedding-3-small)
alter table public.messages 
add column if not exists embedding extensions.vector(1536);

-- 3. Create HNSW index for ultra-fast cosine similarity search (< 1 ms)
create index if not exists messages_embedding_idx 
on public.messages 
using hnsw (embedding extensions.vector_cosine_ops);

-- 4. Secure PostgreSQL RPC function (Row Level Security / security invoker)
-- Allows the coach to search relevant past messages belonging to the authenticated user
create or replace function public.match_messages (
  query_embedding extensions.vector(1536),
  match_threshold float default 0.65,
  match_count int default 4
)
returns table (
  id uuid,
  user_id uuid,
  role text,
  content text,
  context jsonb,
  created_at timestamptz,
  similarity float
)
language plpgsql
security invoker
set search_path = public, extensions
as $$
begin
  return query
  select
    m.id,
    m.user_id,
    m.role,
    m.content,
    m.context,
    m.created_at,
    1 - (m.embedding <=> query_embedding) as similarity
  from public.messages m
  where m.user_id = auth.uid()                    -- Strict security: user can only search their own messages
    and m.embedding is not null
    and 1 - (m.embedding <=> query_embedding) > match_threshold
  order by m.embedding <=> query_embedding
  limit match_count;
end;
$$;

-- 5. RPC execute permissions for authenticated users and service_role
grant execute on function public.match_messages to authenticated, service_role;
