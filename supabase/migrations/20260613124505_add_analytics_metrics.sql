-- Add counter columns to products table
ALTER TABLE products ADD COLUMN view_count INTEGER DEFAULT 0;
ALTER TABLE products ADD COLUMN click_count INTEGER DEFAULT 0;

-- Create analytics_events table
CREATE TABLE analytics_events (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  event_type TEXT NOT NULL, -- 'view', 'click', 'copy', 'search'
  product_id UUID REFERENCES products(id) ON DELETE CASCADE,
  search_query TEXT,
  session_id TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Enable RLS
ALTER TABLE analytics_events ENABLE ROW LEVEL SECURITY;

-- Allow public insertion
CREATE POLICY "Anyone can insert analytics events" ON analytics_events
  FOR INSERT WITH CHECK (true);

-- Allow authenticated users (Admin) to view events
CREATE POLICY "Admins can view analytics events" ON analytics_events
  FOR SELECT USING (auth.role() = 'authenticated');

-- Create RPC to track events and increment counters safely
CREATE OR REPLACE FUNCTION track_event(p_event_type TEXT, p_product_id UUID DEFAULT NULL, p_search_query TEXT DEFAULT NULL, p_session_id TEXT DEFAULT NULL)
RETURNS void AS $$
BEGIN
  -- Increment counters if it's a product-related event
  IF p_product_id IS NOT NULL THEN
    IF p_event_type = 'view' THEN
      UPDATE products SET view_count = COALESCE(view_count, 0) + 1 WHERE id = p_product_id;
    ELSIF p_event_type = 'click' THEN
      UPDATE products SET click_count = COALESCE(click_count, 0) + 1 WHERE id = p_product_id;
    END IF;
  END IF;

  -- Insert the granular event log
  INSERT INTO analytics_events (event_type, product_id, search_query, session_id) 
  VALUES (p_event_type, p_product_id, p_search_query, p_session_id);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
