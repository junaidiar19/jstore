CREATE TABLE products (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  slug TEXT NOT NULL UNIQUE,
  category TEXT,
  price_text TEXT,
  image_url TEXT,
  affiliate_url TEXT,
  short_description TEXT,
  tags TEXT[],
  is_active BOOLEAN DEFAULT true,
  sort_order INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Enable Row Level Security
ALTER TABLE products ENABLE ROW LEVEL SECURITY;

-- Allow public read access (for the landing page)
CREATE POLICY "Public products are viewable by everyone." ON products
  FOR SELECT USING (true);

-- Allow authenticated users (Admin) to perform all actions
CREATE POLICY "Admins can insert products." ON products
  FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Admins can update products." ON products
  FOR UPDATE USING (auth.role() = 'authenticated');

CREATE POLICY "Admins can delete products." ON products
  FOR DELETE USING (auth.role() = 'authenticated');
