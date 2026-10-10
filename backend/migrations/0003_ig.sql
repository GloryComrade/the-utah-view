-- Dedup table for Instagram auto-posts: one row per story once it's been
-- posted, so re-publishing/editing a published story never double-posts.
CREATE TABLE IF NOT EXISTS ig_posted (
  story_id TEXT PRIMARY KEY,
  ig_media_id TEXT,
  posted_at TEXT DEFAULT (datetime('now'))
);
