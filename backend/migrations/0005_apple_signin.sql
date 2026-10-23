-- Sign in with Apple (2026-10-23). Apple's stable user id, plus the refresh
-- token the Worker revokes when the reader deletes their account (App Store
-- guideline 5.1.1(v)).
ALTER TABLE accounts ADD COLUMN apple_sub TEXT;
ALTER TABLE accounts ADD COLUMN apple_refresh_token TEXT;
CREATE UNIQUE INDEX IF NOT EXISTS idx_accounts_apple_sub ON accounts(apple_sub);
