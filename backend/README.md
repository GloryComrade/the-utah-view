# Backend changes — reader accounts + saved-story sync

Two additive pieces for your `utv-api` Worker + `utv-db`. Nothing existing is
changed or dropped. **You deploy these** (they touch production).

## 1. Apply the database migration (additive — safe)
From your Worker project (the folder with `wrangler.toml`), after copying the
migration file over, or run it straight from this repo:

```sh
# production
wrangler d1 execute utv-db --remote --file=backend/migrations/0001_accounts_saved.sql
# (optional) local dev copy
wrangler d1 execute utv-db --local  --file=backend/migrations/0001_accounts_saved.sql
```
Adds three tables: `accounts`, `sessions`, `saved_stories`. Re-running is safe
(`CREATE TABLE IF NOT EXISTS`).

## 2. Add the Worker code
Open `backend/worker-additions.js` and paste its two blocks into your `worker.js`:
- **Block 1 (helpers)** — top-level functions, paste above `export default`
  (e.g. right after `corsHeaders()`).
- **Block 2 (routes)** — paste inside `export default { async fetch() { … } }`,
  in the public section (e.g. right after the `POST /api/unsubscribe` block).

Then deploy:
```sh
wrangler deploy
```

## 3. What it adds
- `POST /api/account/signup` `{ email, password, name? }` → `{ token, email, name }`
- `POST /api/account/login`  `{ email, password }` → `{ token, email, name }`
- `POST /api/account/logout` (Bearer session token)
- `GET  /api/me/saved` → `{ ids: [...] }`
- `PUT  /api/me/saved` `{ ids: [...] }` → replaces the set

`/api/me/saved` accepts **either** a password-account **session token** or a
**Google ID token** as `Authorization: Bearer …`, so saved stories work for both
sign-in types, keyed by email.

## 4. Quick test after deploy
```sh
# sign up
curl -s -X POST https://api.theutahview.com/api/account/signup \
  -H 'Content-Type: application/json' \
  -d '{"email":"you@example.com","password":"testpass123","name":"You"}'
# -> {"token":"…","email":"you@example.com","name":"You"}

# save some stories (use the token from above)
curl -s -X PUT https://api.theutahview.com/api/me/saved \
  -H "Authorization: Bearer <TOKEN>" -H 'Content-Type: application/json' \
  -d '{"ids":["some-story-id"]}'

# read them back
curl -s https://api.theutahview.com/api/me/saved -H "Authorization: Bearer <TOKEN>"
# -> {"ids":["some-story-id"]}
```

## Security notes
- Passwords are PBKDF2-SHA256 (100k iterations, per-user salt). Sessions are
  random 256-bit tokens, 30-day expiry.
- This does NOT fix the pre-existing `ADMIN_API_KEY` + `X-User-Email` bypass in
  `authenticate()` — still recommended to remove that and rotate the key.
- The app will send the session/Google token over HTTPS only.
