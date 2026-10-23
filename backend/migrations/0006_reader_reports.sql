-- Reader error reports ("Report an error" on article pages), reviewed in the
-- editor's Reader reports panel.
CREATE TABLE IF NOT EXISTS reader_reports (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  created_at TEXT DEFAULT (datetime('now')),
  story_id TEXT DEFAULT '',
  page_url TEXT DEFAULT '',
  kind TEXT DEFAULT 'error',
  message TEXT NOT NULL,
  reporter_email TEXT DEFAULT '',
  status TEXT DEFAULT 'new',
  resolved_by TEXT DEFAULT '',
  resolved_at TEXT DEFAULT '',
  note TEXT DEFAULT ''
);
CREATE INDEX IF NOT EXISTS idx_reader_reports_status ON reader_reports (status, created_at);
