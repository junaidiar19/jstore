ALTER TABLE public.products RENAME COLUMN ai_caption TO ai_caption_tiktok;
ALTER TABLE public.products ADD COLUMN ai_caption_shopee text;
