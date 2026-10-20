-- Per-story lead image, with caption and credit (2026 redesign).
ALTER TABLE stories ADD COLUMN image_url TEXT DEFAULT '';
ALTER TABLE stories ADD COLUMN image_caption TEXT DEFAULT '';
ALTER TABLE stories ADD COLUMN image_credit TEXT DEFAULT '';
