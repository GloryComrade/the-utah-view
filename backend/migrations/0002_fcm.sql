-- Remembers which stories already triggered a push, so editing a published
-- story doesn't re-notify. Additive, safe to re-run.
CREATE TABLE IF NOT EXISTS fcm_sent (
  story_id TEXT PRIMARY KEY,
  sent_at  TEXT DEFAULT (datetime('now'))
);
