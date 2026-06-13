-- Create "products" bucket for images
insert into storage.buckets (id, name, public)
values ('products', 'products', true);

-- Set up row level security for storage.objects
-- Note: storage.objects already has RLS enabled by default in Supabase

-- Allow public to read images
create policy "Public access for products bucket"
on storage.objects for select
using ( bucket_id = 'products' );

-- Allow authenticated users to upload images
create policy "Auth users can upload to products bucket"
on storage.objects for insert
with check ( bucket_id = 'products' and auth.role() = 'authenticated' );

-- Allow authenticated users to update their images
create policy "Auth users can update in products bucket"
on storage.objects for update
using ( bucket_id = 'products' and auth.role() = 'authenticated' );

-- Allow authenticated users to delete images
create policy "Auth users can delete from products bucket"
on storage.objects for delete
using ( bucket_id = 'products' and auth.role() = 'authenticated' );
