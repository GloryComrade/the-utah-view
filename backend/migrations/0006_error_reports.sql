-- Reader error reports ("Report an error" on articles and report.html),
-- shown to editors and admins in the editor's Reader reports panel.
CREATE TABLE IF NOT EXISTS error_reports (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  story_id TEXT DEFAULT '',
  page_url TEXT DEFAULT '',
  message TEXT NOT NULL,
  email TEXT DEFAULT '',
  status TEXT DEFAULT 'new',
  created_at TEXT DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_error_reports_status ON error_reports(status, created_at);
