// ============================================================================
// The Utah View — Worker additions: reader accounts + saved-story sync
// ============================================================================
// These are ADDITIVE. Paste the two blocks below into your existing worker.js
// and `wrangler deploy`. No existing code changes. Run the D1 migration first
// (backend/migrations/0001_accounts_saved.sql).
//
// Nothing here touches stories, subscribers, the editor, or the cron.
// ============================================================================


// ---------------------------------------------------------------------------
// BLOCK 1 — helpers. Paste these top-level functions anywhere above
// `export default` (e.g. right after the existing `corsHeaders()` function).
// ---------------------------------------------------------------------------

function json(obj, status) {
  return new Response(JSON.stringify(obj), {
    status: status || 200,
    headers: corsHeaders(),
  });
}

function bytesToHex(bytes) {
  return [...bytes].map((b) => b.toString(16).padStart(2, '0')).join('');
}
function hexToBytes(hex) {
  const out = new Uint8Array(hex.length / 2);
  for (let i = 0; i < out.length; i++) out[i] = parseInt(hex.substr(i * 2, 2), 16);
  return out;
}
function timingSafeEqual(a, b) {
  if (typeof a !== 'string' || typeof b !== 'string' || a.length !== b.length) return false;
  let r = 0;
  for (let i = 0; i < a.length; i++) r |= a.charCodeAt(i) ^ b.charCodeAt(i);
  return r === 0;
}

// PBKDF2-SHA256, 100k iterations. Pass an existing saltHex to verify a password.
async function hashPassword(password, saltHex) {
  const enc = new TextEncoder();
  const salt = saltHex ? hexToBytes(saltHex) : crypto.getRandomValues(new Uint8Array(16));
  const keyMaterial = await crypto.subtle.importKey(
    'raw', enc.encode(password), 'PBKDF2', false, ['deriveBits']
  );
  const bits = await crypto.subtle.deriveBits(
    { name: 'PBKDF2', salt, iterations: 100000, hash: 'SHA-256' }, keyMaterial, 256
  );
  return { saltHex: bytesToHex(salt), hashHex: bytesToHex(new Uint8Array(bits)) };
}

function newToken() {
  return bytesToHex(crypto.getRandomValues(new Uint8Array(32)));
}
async function createSession(env, accountId) {
  const token = newToken();
  const expires = new Date(Date.now() + 1000 * 60 * 60 * 24 * 30).toISOString(); // 30 days
  await env.DB.prepare(
    'INSERT INTO sessions (token, account_id, expires_at) VALUES (?, ?, ?)'
  ).bind(token, accountId, expires).run();
  return token;
}

// Resolve the caller's reader identity from the Authorization header:
// a password-account session token OR a verified Google ID token.
async function resolveSavedIdentity(request, env) {
  const authHeader = request.headers.get('Authorization') || '';
  if (!authHeader.startsWith('Bearer ')) return null;
  const token = authHeader.slice(7);

  const acct = await env.DB.prepare(
    'SELECT a.email AS email, a.name AS name FROM sessions s ' +
    'JOIN accounts a ON a.id = s.account_id ' +
    'WHERE s.token = ? AND s.expires_at > ?'
  ).bind(token, new Date().toISOString()).first();
  if (acct) return { email: acct.email.toLowerCase(), name: acct.name || '' };

  try {
    const u = await verifyGoogleToken(token); // existing function in worker.js
    return { email: u.email, name: u.name || '' };
  } catch (e) { /* not a Google token */ }
  return null;
}


// ---------------------------------------------------------------------------
// BLOCK 2 — routes. Paste these inside `export default { async fetch(...) }`,
// in the PUBLIC section (e.g. right after the `POST /api/unsubscribe` block).
// ---------------------------------------------------------------------------

// POST /api/account/signup  { email, password, name? } -> { token, email, name }
if (path === '/api/account/signup' && method === 'POST') {
  const { email, password, name } = await request.json();
  if (!email || !email.includes('@') || !password || password.length < 8) {
    return json({ error: 'Email and an 8+ character password are required' }, 400);
  }
  const clean = email.toLowerCase().trim();
  const existing = await env.DB.prepare('SELECT id FROM accounts WHERE email = ?').bind(clean).first();
  if (existing) return json({ error: 'An account with that email already exists' }, 409);
  const { saltHex, hashHex } = await hashPassword(password);
  const id = crypto.randomUUID();
  await env.DB.prepare(
    'INSERT INTO accounts (id, email, password_hash, password_salt, name, provider) VALUES (?, ?, ?, ?, ?, ?)'
  ).bind(id, clean, hashHex, saltHex, name || '', 'password').run();
  await auditLog(env, clean, 'signup', 'account', id, null, ip);
  const token = await createSession(env, id);
  return json({ token, email: clean, name: name || '' });
}

// POST /api/account/login  { email, password } -> { token, email, name }
if (path === '/api/account/login' && method === 'POST') {
  const { email, password } = await request.json();
  const clean = (email || '').toLowerCase().trim();
  const acct = await env.DB.prepare(
    'SELECT id, email, name, password_hash, password_salt FROM accounts WHERE email = ?'
  ).bind(clean).first();
  if (!acct || !acct.password_hash) return json({ error: 'Invalid email or password' }, 401);
  const { hashHex } = await hashPassword(password, acct.password_salt);
  if (!timingSafeEqual(hashHex, acct.password_hash)) {
    return json({ error: 'Invalid email or password' }, 401);
  }
  const token = await createSession(env, acct.id);
  return json({ token, email: acct.email, name: acct.name || '' });
}

// POST /api/account/logout  (Bearer <session token>)
if (path === '/api/account/logout' && method === 'POST') {
  const authHeader = request.headers.get('Authorization') || '';
  if (authHeader.startsWith('Bearer ')) {
    await env.DB.prepare('DELETE FROM sessions WHERE token = ?').bind(authHeader.slice(7)).run();
  }
  return json({ message: 'Logged out' });
}

// GET /api/me/saved -> { ids: [...] }   (Bearer: Google ID token OR session token)
if (path === '/api/me/saved' && method === 'GET') {
  const id = await resolveSavedIdentity(request, env);
  if (!id) return json({ error: 'Authentication required' }, 401);
  const rows = await env.DB.prepare(
    'SELECT story_id FROM saved_stories WHERE email = ? ORDER BY saved_at DESC'
  ).bind(id.email).all();
  return json({ ids: rows.results.map((r) => r.story_id) });
}

// PUT /api/me/saved  { ids: [...] }  -> { ids: [...] }   (replaces the set)
if (path === '/api/me/saved' && method === 'PUT') {
  const id = await resolveSavedIdentity(request, env);
  if (!id) return json({ error: 'Authentication required' }, 401);
  const { ids } = await request.json();
  if (!Array.isArray(ids)) return json({ error: 'ids array required' }, 400);
  const stmts = [env.DB.prepare('DELETE FROM saved_stories WHERE email = ?').bind(id.email)];
  for (const sid of ids.slice(0, 500)) {
    stmts.push(
      env.DB.prepare('INSERT OR IGNORE INTO saved_stories (email, story_id) VALUES (?, ?)')
        .bind(id.email, String(sid))
    );
  }
  await env.DB.batch(stmts);
  return json({ ids });
}
