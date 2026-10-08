-- The Utah View — reader accounts + saved-story sync (ADDITIVE; safe to re-run)
-- Apply to production:  wrangler d1 execute utv-db --remote --file=backend/migrations/0001_accounts_saved.sql
-- Apply locally:        wrangler d1 execute utv-db --local  --file=backend/migrations/0001_accounts_saved.sql

-- First-party reader accounts (email/password). Separate from the editor
-- `users` table, which stays for admin/editor roles.
CREATE TABLE IF NOT EXISTS accounts (
  id            TEXT PRIMARY KEY,                 -- uuid
  email         TEXT UNIQUE NOT NULL,
  password_hash TEXT,                             -- PBKDF2-SHA256 hex; NULL for Google-only
  password_salt TEXT,                             -- hex
  name          TEXT DEFAULT '',
  provider      TEXT DEFAULT 'password',          -- 'password' | 'google'
  created_at    TEXT DEFAULT (datetime('now'))
);

-- Opaque session tokens for password accounts (Bearer <token>).
CREATE TABLE IF NOT EXISTS sessions (
  token      TEXT PRIMARY KEY,
  account_id TEXT NOT NULL,
  created_at TEXT DEFAULT (datetime('now')),
  expires_at TEXT NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_sessions_account ON sessions(account_id);

-- Saved stories keyed by the reader's email (works for both Google and
-- password identities, which both have an email).
CREATE TABLE IF NOT EXISTS saved_stories (
  email    TEXT NOT NULL,
  story_id TEXT NOT NULL,
  saved_at TEXT DEFAULT (datetime('now')),
  PRIMARY KEY (email, story_id)
);
CREATE INDEX IF NOT EXISTS idx_saved_email ON saved_stories(email);
