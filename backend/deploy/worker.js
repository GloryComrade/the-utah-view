// ============================================
// The Utah View — Secure API Worker
// Server-side auth, D1 database, R2 images, audit logging
// ============================================

const GOOGLE_CERTS_URL = 'https://www.googleapis.com/oauth2/v3/certs';
const GOOGLE_CLIENT_ID = '562818410025-d6n1627aucueem1npk03mg5n7gs8i5t7.apps.googleusercontent.com';

// ── JWT Verification ──

async function verifyGoogleToken(token) {
  const parts = token.split('.');
  if (parts.length !== 3) throw new Error('Invalid token format');

  const header = JSON.parse(atob(parts[0].replace(/-/g, '+').replace(/_/g, '/')));
  const payload = JSON.parse(atob(parts[1].replace(/-/g, '+').replace(/_/g, '/')));

  // Check expiry
  if (payload.exp && payload.exp < Date.now() / 1000) {
    throw new Error('Token expired');
  }

  // Check audience
  if (payload.aud !== GOOGLE_CLIENT_ID) {
    throw new Error('Invalid audience');
  }

  // Check issuer
  if (payload.iss !== 'accounts.google.com' && payload.iss !== 'https://accounts.google.com') {
    throw new Error('Invalid issuer');
  }

  // Verify signature against Google's public keys
  const certsRes = await fetch(GOOGLE_CERTS_URL);
  const certsData = await certsRes.json();
  const key = certsData.keys.find(k => k.kid === header.kid);
  if (!key) throw new Error('Unknown signing key');

  const cryptoKey = await crypto.subtle.importKey(
    'jwk', key, { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' }, false, ['verify']
  );

  const signatureBytes = Uint8Array.from(atob(parts[2].replace(/-/g, '+').replace(/_/g, '/')), c => c.charCodeAt(0));
  const dataBytes = new TextEncoder().encode(parts[0] + '.' + parts[1]);

  const valid = await crypto.subtle.verify('RSASSA-PKCS1-v1_5', cryptoKey, signatureBytes, dataBytes);
  if (!valid) throw new Error('Invalid signature');

  return { email: payload.email.toLowerCase(), name: payload.name || '', picture: payload.picture || '' };
}

async function authenticate(request, env) {
  const authHeader = request.headers.get('Authorization');
  if (!authHeader) return null;

  // API key auth (never expires)
  if (authHeader === 'Bearer ' + (env.ADMIN_API_KEY || '')) {
    const email = request.headers.get('X-User-Email') || 'theutahview@gmail.com';
    const row = await env.DB.prepare('SELECT role FROM users WHERE email = ?').bind(email).first();
    return { email, name: email.split('@')[0], role: row ? row.role : null };
  }

  // Google JWT auth (expires after 1 hour)
  if (authHeader.startsWith('Bearer ')) {
    try {
      const token = authHeader.slice(7);
      const user = await verifyGoogleToken(token);
      const row = await env.DB.prepare('SELECT role FROM users WHERE email = ?').bind(user.email).first();
      user.role = row ? row.role : null;
      return user;
    } catch (e) { return null; }
  }
  return null;
}

function requireAuth(user) {
  if (!user) {
    return new Response(JSON.stringify({ error: 'Authentication required' }), {
      status: 401, headers: corsHeaders()
    });
  }
  return null;
}

function requireRole(user, roles) {
  if (!user || !roles.includes(user.role)) {
    return new Response(JSON.stringify({ error: 'Insufficient permissions' }), {
      status: 403, headers: corsHeaders()
    });
  }
  return null;
}

function corsHeaders() {
  return {
    'Content-Type': 'application/json',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type, Authorization, X-User-Email',
  };
}

// ── Reader accounts + saved-story sync (added) ──

function json(obj, status) {
  return new Response(JSON.stringify(obj), { status: status || 200, headers: corsHeaders() });
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
async function hashPassword(password, saltHex) {
  const enc = new TextEncoder();
  const salt = saltHex ? hexToBytes(saltHex) : crypto.getRandomValues(new Uint8Array(16));
  const keyMaterial = await crypto.subtle.importKey('raw', enc.encode(password), 'PBKDF2', false, ['deriveBits']);
  const bits = await crypto.subtle.deriveBits({ name: 'PBKDF2', salt, iterations: 100000, hash: 'SHA-256' }, keyMaterial, 256);
  return { saltHex: bytesToHex(salt), hashHex: bytesToHex(new Uint8Array(bits)) };
}
function newToken() { return bytesToHex(crypto.getRandomValues(new Uint8Array(32))); }
async function createSession(env, accountId) {
  const token = newToken();
  const expires = new Date(Date.now() + 1000 * 60 * 60 * 24 * 30).toISOString();
  await env.DB.prepare('INSERT INTO sessions (token, account_id, expires_at) VALUES (?, ?, ?)').bind(token, accountId, expires).run();
  return token;
}
async function resolveSavedIdentity(request, env) {
  const authHeader = request.headers.get('Authorization') || '';
  if (!authHeader.startsWith('Bearer ')) return null;
  const token = authHeader.slice(7);
  const acct = await env.DB.prepare(
    'SELECT a.email AS email, a.name AS name FROM sessions s JOIN accounts a ON a.id = s.account_id WHERE s.token = ? AND s.expires_at > ?'
  ).bind(token, new Date().toISOString()).first();
  if (acct) return { email: acct.email.toLowerCase(), name: acct.name || '' };
  try { const u = await verifyGoogleToken(token); return { email: u.email, name: u.name || '' }; } catch (e) {}
  return null;
}

// ── Push notifications (FCM HTTP v1) ──

function b64url(input) {
  const bin = typeof input === 'string' ? input : String.fromCharCode(...new Uint8Array(input));
  return btoa(bin).replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');
}
async function importServiceAccountKey(pem) {
  const b64 = pem.replace(/-----(BEGIN|END) PRIVATE KEY-----/g, '').replace(/\s+/g, '');
  const der = Uint8Array.from(atob(b64), (c) => c.charCodeAt(0));
  return crypto.subtle.importKey('pkcs8', der, { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' }, false, ['sign']);
}
async function getGoogleAccessToken(sa) {
  const now = Math.floor(Date.now() / 1000);
  const header = b64url(JSON.stringify({ alg: 'RS256', typ: 'JWT' }));
  const claim = b64url(JSON.stringify({
    iss: sa.client_email,
    scope: 'https://www.googleapis.com/auth/firebase.messaging',
    aud: 'https://oauth2.googleapis.com/token',
    iat: now, exp: now + 3600,
  }));
  const unsigned = header + '.' + claim;
  const key = await importServiceAccountKey(sa.private_key);
  const sig = await crypto.subtle.sign('RSASSA-PKCS1-v1_5', key, new TextEncoder().encode(unsigned));
  const jwt = unsigned + '.' + b64url(sig);
  const res = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: 'grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=' + encodeURIComponent(jwt),
  });
  const j = await res.json();
  if (!j.access_token) throw new Error('token exchange failed: ' + JSON.stringify(j));
  return j.access_token;
}
// Sends one push to the "new-stories" topic the first time a story is published.
async function maybeNotifyNewStory(env, storyId, data) {
  try {
    if (!env.FCM_SERVICE_ACCOUNT) return;                 // not configured yet
    const seen = await env.DB.prepare('SELECT story_id FROM fcm_sent WHERE story_id = ?').bind(storyId).first();
    if (seen) return;                                     // already notified
    const sa = JSON.parse(env.FCM_SERVICE_ACCOUNT);
    const token = await getGoogleAccessToken(sa);
    const body = (data && data.title) ? String(data.title) : 'A new story was just published.';
    await fetch('https://fcm.googleapis.com/v1/projects/' + sa.project_id + '/messages:send', {
      method: 'POST',
      headers: { 'Authorization': 'Bearer ' + token, 'Content-Type': 'application/json' },
      body: JSON.stringify({
        message: {
          topic: 'new-stories',
          notification: { title: 'The Utah View', body },
          data: { storyId: String(storyId) },
        },
      }),
    });
    await env.DB.prepare('INSERT OR IGNORE INTO fcm_sent (story_id) VALUES (?)').bind(storyId).run();
  } catch (e) { console.error('FCM notify failed:', e); }
}


// ── Audit Logging ──

async function auditLog(env, userEmail, action, resourceType, resourceId, details, ip) {
  await env.DB.prepare(
    'INSERT INTO audit_log (user_email, action, resource_type, resource_id, details, ip_address) VALUES (?, ?, ?, ?, ?, ?)'
  ).bind(userEmail, action, resourceType, resourceId || '', details || '', ip || '').run();
}

// ── Main Router ──

export default {
  async fetch(request, env, ctx) {
    const url = new URL(request.url);
    const path = url.pathname;
    const method = request.method;
    const ip = request.headers.get('CF-Connecting-IP') || '';

    if (method === 'OPTIONS') {
      return new Response(null, { headers: corsHeaders() });
    }

    // ── PUBLIC ENDPOINTS ──

    // GET /api/stories — list published stories (public)
    if (path === '/api/stories' && method === 'GET') {
      const region = url.searchParams.get('region');
      let query = 'SELECT id, title, author, region, summary, read_time, date FROM stories WHERE status = ?';
      const params = ['published'];
      if (region) { query += ' AND region = ?'; params.push(region); }
      query += ' ORDER BY date DESC';
      const results = await env.DB.prepare(query).bind(...params).all();
      return new Response(JSON.stringify({ stories: results.results }), { headers: corsHeaders() });
    }

    // GET /api/stories/:id — get single story (public if published)
    if (path.startsWith('/api/stories/') && method === 'GET') {
      const id = path.split('/')[3];
      const story = await env.DB.prepare('SELECT * FROM stories WHERE id = ?').bind(id).first();
      if (!story) return new Response(JSON.stringify({ error: 'Not found' }), { status: 404, headers: corsHeaders() });
      if (story.status !== 'published') {
        const user = await authenticate(request, env);
        const deny = requireRole(user, ['admin', 'editor']);
        if (deny) return new Response(JSON.stringify({ error: 'Not found' }), { status: 404, headers: corsHeaders() });
      }
      return new Response(JSON.stringify(story), { headers: corsHeaders() });
    }

    // GET /api/config/:key — get site config (public)
    if (path.startsWith('/api/config/') && method === 'GET') {
      const key = path.split('/')[3];
      const row = await env.DB.prepare('SELECT value FROM site_config WHERE key = ?').bind(key).first();
      return new Response(JSON.stringify({ value: row ? JSON.parse(row.value) : null }), { headers: corsHeaders() });
    }

    // POST /api/subscribe — subscribe to newsletter (public)
    if (path === '/api/subscribe' && method === 'POST') {
      const { email } = await request.json();
      if (!email || !email.includes('@')) {
        return new Response(JSON.stringify({ error: 'Invalid email' }), { status: 400, headers: corsHeaders() });
      }
      const clean = email.toLowerCase().trim();
      const existing = await env.DB.prepare('SELECT email FROM subscribers WHERE email = ?').bind(clean).first();
      if (existing) {
        return new Response(JSON.stringify({ message: 'Already subscribed' }), { headers: corsHeaders() });
      }
      await env.DB.prepare('INSERT INTO subscribers (email) VALUES (?)').bind(clean).run();
      await auditLog(env, clean, 'subscribe', 'subscriber', clean, null, ip);

      // Send welcome email
      if (env.RESEND_API_KEY) {
        const siteUrl = env.SITE_URL || 'https://theutahview.com';
        try {
          await fetch('https://api.resend.com/emails', {
            method: 'POST',
            headers: { 'Authorization': `Bearer ${env.RESEND_API_KEY}`, 'Content-Type': 'application/json' },
            body: JSON.stringify({
              from: env.FROM_EMAIL || 'The Utah View <newsletter@theutahview.com>',
              to: [clean],
              subject: 'Welcome to The Utah View',
              html: `<!DOCTYPE html><html><body style="margin:0;padding:0;background:#f5f5f5;font-family:Georgia,serif">
<table width="100%" cellpadding="0" cellspacing="0" style="background:#f5f5f5;padding:24px 0"><tr><td align="center">
<table width="600" cellpadding="0" cellspacing="0" style="background:#fff;border-radius:4px;max-width:600px">
<tr><td style="background:#C4352A;padding:28px 32px;text-align:center">
<p style="font-family:Helvetica,sans-serif;font-size:24px;font-weight:800;letter-spacing:2px;text-transform:uppercase;color:#fff;margin:0">THE UTAH VIEW</p>
<p style="font-family:Helvetica,sans-serif;font-size:11px;letter-spacing:3px;text-transform:uppercase;color:rgba(255,255,255,0.7);margin:6px 0 0">Every Region · Every Month</p>
</td></tr>
<tr><td style="padding:32px">
<h1 style="font-family:Georgia,serif;font-size:24px;color:#121212;margin:0 0 16px">Welcome aboard.</h1>
<p style="font-size:16px;line-height:1.6;color:#333;margin:0 0 16px">You've subscribed to The Utah View — independent analysis of global politics, delivered monthly from Salt Lake City.</p>
<p style="font-size:16px;line-height:1.6;color:#333;margin:0 0 16px">Every issue covers five regions — The Americas, Europe, Asia-Pacific, the Middle East, and Africa — with the depth of a journal and the clarity of a briefing.</p>
<p style="font-size:16px;line-height:1.6;color:#333;margin:0 0 24px">Your first briefing arrives on the 1st of next month.</p>
<a href="${siteUrl}" style="display:inline-block;padding:12px 32px;background:#C4352A;color:#fff;font-family:Helvetica,sans-serif;font-size:14px;font-weight:700;text-decoration:none;border-radius:4px">Read the Current Issue</a>
</td></tr>
<tr><td style="padding:20px 32px;border-top:1px solid #e5e5e5;text-align:center">
<p style="font-family:Helvetica,sans-serif;font-size:12px;color:#999;margin:0">© ${new Date().getFullYear()} The Utah View. Salt Lake City, Utah.</p>
</td></tr>
</table></td></tr></table></body></html>`,
            }),
          });
        } catch (e) { console.error('Welcome email failed:', e); }
      }

      return new Response(JSON.stringify({ message: 'Subscribed' }), { headers: corsHeaders() });
    }

    // POST /api/unsubscribe
    if (path === '/api/unsubscribe' && method === 'POST') {
      const { email } = await request.json();
      const clean = email.toLowerCase().trim();
      await env.DB.prepare('DELETE FROM subscribers WHERE email = ?').bind(clean).run();
      await auditLog(env, clean, 'unsubscribe', 'subscriber', clean, null, ip);
      return new Response(JSON.stringify({ message: 'Unsubscribed' }), { headers: corsHeaders() });
    }

    // ── Reader accounts + saved stories (added) ──

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
      await env.DB.prepare('INSERT INTO accounts (id, email, password_hash, password_salt, name, provider) VALUES (?, ?, ?, ?, ?, ?)').bind(id, clean, hashHex, saltHex, name || '', 'password').run();
      await auditLog(env, clean, 'signup', 'account', id, null, ip);
      const token = await createSession(env, id);
      return json({ token, email: clean, name: name || '' });
    }

    if (path === '/api/account/login' && method === 'POST') {
      const { email, password } = await request.json();
      const clean = (email || '').toLowerCase().trim();
      const acct = await env.DB.prepare('SELECT id, email, name, password_hash, password_salt FROM accounts WHERE email = ?').bind(clean).first();
      if (!acct || !acct.password_hash) return json({ error: 'Invalid email or password' }, 401);
      const { hashHex } = await hashPassword(password, acct.password_salt);
      if (!timingSafeEqual(hashHex, acct.password_hash)) return json({ error: 'Invalid email or password' }, 401);
      const token = await createSession(env, acct.id);
      return json({ token, email: acct.email, name: acct.name || '' });
    }

    if (path === '/api/account/logout' && method === 'POST') {
      const authHeader = request.headers.get('Authorization') || '';
      if (authHeader.startsWith('Bearer ')) await env.DB.prepare('DELETE FROM sessions WHERE token = ?').bind(authHeader.slice(7)).run();
      return json({ message: 'Logged out' });
    }

    if (path === '/api/me/saved' && method === 'GET') {
      const id = await resolveSavedIdentity(request, env);
      if (!id) return json({ error: 'Authentication required' }, 401);
      const rows = await env.DB.prepare('SELECT story_id FROM saved_stories WHERE email = ? ORDER BY saved_at DESC').bind(id.email).all();
      return json({ ids: rows.results.map((r) => r.story_id) });
    }

    if (path === '/api/me/saved' && method === 'PUT') {
      const id = await resolveSavedIdentity(request, env);
      if (!id) return json({ error: 'Authentication required' }, 401);
      const { ids } = await request.json();
      if (!Array.isArray(ids)) return json({ error: 'ids array required' }, 400);
      const stmts = [env.DB.prepare('DELETE FROM saved_stories WHERE email = ?').bind(id.email)];
      for (const sid of ids.slice(0, 500)) stmts.push(env.DB.prepare('INSERT OR IGNORE INTO saved_stories (email, story_id) VALUES (?, ?)').bind(id.email, String(sid)));
      await env.DB.batch(stmts);
      return json({ ids });
    }


    // Serve images from R2
    if (path.startsWith('/images/') && method === 'GET') {
      const key = path.slice(1);
      const object = await env.UTV_IMAGES.get(key);
      if (!object) return new Response('Not found', { status: 404 });
      const h = new Headers();
      h.set('Content-Type', object.httpMetadata?.contentType || 'image/jpeg');
      h.set('Cache-Control', 'public, max-age=31536000');
      h.set('Access-Control-Allow-Origin', '*');
      return new Response(object.body, { headers: h });
    }

    // ── AUTHENTICATED ENDPOINTS ──

    const user = await authenticate(request, env);

    // GET /api/me — current user info
    if (path === '/api/me' && method === 'GET') {
      const deny = requireAuth(user);
      if (deny) return deny;
      return new Response(JSON.stringify({ email: user.email, name: user.name, role: user.role }), { headers: corsHeaders() });
    }

    // ── STORIES (editor/admin) ──

    // GET /api/admin/stories — list ALL stories including drafts
    if (path === '/api/admin/stories' && method === 'GET') {
      const deny = requireRole(user, ['admin', 'editor']);
      if (deny) return deny;
      const results = await env.DB.prepare('SELECT * FROM stories ORDER BY updated_at DESC').all();
      return new Response(JSON.stringify({ stories: results.results }), { headers: corsHeaders() });
    }

    // POST /api/admin/stories — create story
    if (path === '/api/admin/stories' && method === 'POST') {
      const deny = requireRole(user, ['admin', 'editor']);
      if (deny) return deny;
      const data = await request.json();
      if (!data.title || !data.author) {
        return new Response(JSON.stringify({ error: 'Title and author required' }), { status: 400, headers: corsHeaders() });
      }
      const id = data.id || data.title.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/-+$/, '').substring(0, 60);
      await env.DB.prepare(
        'INSERT OR REPLACE INTO stories (id, title, author, region, status, summary, body, read_time, date, created_by, updated_by) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)'
      ).bind(id, data.title, data.author, data.region || 'Global', data.status || 'draft', data.summary || '', data.body || '', data.read_time || '', data.date || new Date().toISOString().split('T')[0], user.email, user.email).run();
      await auditLog(env, user.email, 'create', 'story', id, JSON.stringify({ title: data.title }), ip);
      if ((data.status || 'draft') === 'published') ctx.waitUntil(maybeNotifyNewStory(env, id, data));
      return new Response(JSON.stringify({ id, message: 'Created' }), { headers: corsHeaders() });
    }

    // PUT /api/admin/stories/:id — update story
    if (path.startsWith('/api/admin/stories/') && method === 'PUT') {
      const deny = requireRole(user, ['admin', 'editor']);
      if (deny) return deny;
      const id = path.split('/')[4];
      const data = await request.json();
      await env.DB.prepare(
        'UPDATE stories SET title=?, author=?, region=?, status=?, summary=?, body=?, read_time=?, date=?, updated_at=datetime(\'now\'), updated_by=? WHERE id=?'
      ).bind(data.title, data.author, data.region, data.status, data.summary, data.body, data.read_time, data.date, user.email, id).run();
      await auditLog(env, user.email, 'update', 'story', id, JSON.stringify({ title: data.title, status: data.status }), ip);
      if (data.status === 'published') ctx.waitUntil(maybeNotifyNewStory(env, id, data));
      return new Response(JSON.stringify({ message: 'Updated' }), { headers: corsHeaders() });
    }

    // DELETE /api/admin/stories/:id — delete story
    if (path.startsWith('/api/admin/stories/') && method === 'DELETE') {
      const deny = requireRole(user, ['admin']);
      if (deny) return deny;
      const id = path.split('/')[4];
      const story = await env.DB.prepare('SELECT title FROM stories WHERE id = ?').bind(id).first();
      await env.DB.prepare('DELETE FROM stories WHERE id = ?').bind(id).run();
      await auditLog(env, user.email, 'delete', 'story', id, JSON.stringify({ title: story?.title }), ip);
      return new Response(JSON.stringify({ message: 'Deleted' }), { headers: corsHeaders() });
    }

    // ── SITE CONFIG (admin) ──

    // PUT /api/admin/config/:key
    if (path.startsWith('/api/admin/config/') && method === 'PUT') {
      const deny = requireRole(user, ['admin']);
      if (deny) return deny;
      const key = path.split('/')[4];
      const data = await request.json();
      await env.DB.prepare(
        'INSERT OR REPLACE INTO site_config (key, value, updated_at, updated_by) VALUES (?, ?, datetime(\'now\'), ?)'
      ).bind(key, JSON.stringify(data.value), user.email).run();
      await auditLog(env, user.email, 'update', 'config', key, null, ip);
      return new Response(JSON.stringify({ message: 'Saved' }), { headers: corsHeaders() });
    }

    // ── ACCESS MANAGEMENT (admin) ──

    // GET /api/admin/users
    if (path === '/api/admin/users' && method === 'GET') {
      const deny = requireRole(user, ['admin']);
      if (deny) return deny;
      const results = await env.DB.prepare('SELECT email, role, name, granted_by, created_at FROM users ORDER BY created_at').all();
      return new Response(JSON.stringify({ users: results.results }), { headers: corsHeaders() });
    }

    // POST /api/admin/users — grant access
    if (path === '/api/admin/users' && method === 'POST') {
      const deny = requireRole(user, ['admin']);
      if (deny) return deny;
      const data = await request.json();
      if (!data.email || !data.role) {
        return new Response(JSON.stringify({ error: 'Email and role required' }), { status: 400, headers: corsHeaders() });
      }
      await env.DB.prepare(
        'INSERT OR REPLACE INTO users (email, role, name, granted_by) VALUES (?, ?, ?, ?)'
      ).bind(data.email.toLowerCase(), data.role, data.name || '', user.email).run();
      await auditLog(env, user.email, 'grant_access', 'user', data.email, JSON.stringify({ role: data.role }), ip);
      return new Response(JSON.stringify({ message: 'Access granted' }), { headers: corsHeaders() });
    }

    // DELETE /api/admin/users?email=xxx
    if (path === '/api/admin/users' && method === 'DELETE') {
      const deny = requireRole(user, ['admin']);
      if (deny) return deny;
      const email = url.searchParams.get('email');
      if (email === 'theutahview@gmail.com') {
        return new Response(JSON.stringify({ error: 'Cannot remove owner' }), { status: 403, headers: corsHeaders() });
      }
      await env.DB.prepare('DELETE FROM users WHERE email = ?').bind(email).run();
      await auditLog(env, user.email, 'revoke_access', 'user', email, null, ip);
      return new Response(JSON.stringify({ message: 'Access revoked' }), { headers: corsHeaders() });
    }

    // ── SUBSCRIBERS (admin) ──

    // GET /api/admin/subscribers
    if (path === '/api/admin/subscribers' && method === 'GET') {
      const deny = requireRole(user, ['admin']);
      if (deny) return deny;
      const results = await env.DB.prepare('SELECT email, subscribed_at FROM subscribers ORDER BY subscribed_at DESC').all();
      return new Response(JSON.stringify({ count: results.results.length, subscribers: results.results }), { headers: corsHeaders() });
    }

    // ── IMAGE UPLOAD (editor/admin) ──

    if (path === '/api/upload' && method === 'POST') {
      const deny = requireRole(user, ['admin', 'editor']);
      if (deny) return deny;
      const formData = await request.formData();
      const file = formData.get('file');
      if (!file) return new Response(JSON.stringify({ error: 'No file' }), { status: 400, headers: corsHeaders() });

      const allowed = ['image/jpeg', 'image/png', 'image/gif', 'image/webp', 'image/svg+xml'];
      if (!allowed.includes(file.type)) {
        return new Response(JSON.stringify({ error: 'Invalid file type' }), { status: 400, headers: corsHeaders() });
      }
      if (file.size > 5 * 1024 * 1024) {
        return new Response(JSON.stringify({ error: 'File too large (5MB max)' }), { status: 400, headers: corsHeaders() });
      }

      const ext = file.name.split('.').pop().toLowerCase();
      const key = `images/${Date.now()}-${Math.random().toString(36).substring(2, 8)}.${ext}`;

      await env.UTV_IMAGES.put(key, file.stream(), {
        httpMetadata: { contentType: file.type },
        customMetadata: { originalName: file.name, uploadedBy: user.email },
      });

      const publicUrl = `${env.R2_PUBLIC_URL || url.origin}/${key}`;
      await auditLog(env, user.email, 'upload', 'image', key, JSON.stringify({ name: file.name, size: file.size }), ip);

      return new Response(JSON.stringify({ url: publicUrl, key }), { headers: corsHeaders() });
    }

    // GET /api/admin/images — list images
    if (path === '/api/admin/images' && method === 'GET') {
      const deny = requireRole(user, ['admin', 'editor']);
      if (deny) return deny;
      const listed = await env.UTV_IMAGES.list({ prefix: 'images/' });
      const images = listed.objects.map(obj => ({
        key: obj.key,
        size: obj.size,
        uploaded: obj.uploaded,
        url: `${env.R2_PUBLIC_URL || url.origin}/${obj.key}`,
      }));
      return new Response(JSON.stringify({ images }), { headers: corsHeaders() });
    }

    // DELETE /api/admin/images?key=xxx
    if (path === '/api/admin/images' && method === 'DELETE') {
      const deny = requireRole(user, ['admin']);
      if (deny) return deny;
      const key = url.searchParams.get('key');
      await env.UTV_IMAGES.delete(key);
      await auditLog(env, user.email, 'delete', 'image', key, null, ip);
      return new Response(JSON.stringify({ message: 'Deleted' }), { headers: corsHeaders() });
    }

    // ── PAGES (public read, admin write) ──

    // GET /api/pages — list all pages
    if (path === '/api/pages' && method === 'GET') {
      const results = await env.DB.prepare('SELECT slug, title, subtitle FROM pages ORDER BY title').all();
      return new Response(JSON.stringify({ pages: results.results }), { headers: corsHeaders() });
    }

    // GET /api/pages/:slug
    if (path.startsWith('/api/pages/') && method === 'GET') {
      const slug = path.split('/')[3];
      const page = await env.DB.prepare('SELECT * FROM pages WHERE slug = ?').bind(slug).first();
      if (!page) return new Response(JSON.stringify({ error: 'Not found' }), { status: 404, headers: corsHeaders() });
      return new Response(JSON.stringify(page), { headers: corsHeaders() });
    }

    // POST /api/admin/pages — create page
    if (path === '/api/admin/pages' && method === 'POST') {
      const deny = requireRole(user, ['admin']);
      if (deny) return deny;
      const data = await request.json();
      const slug = data.slug || data.title.toLowerCase().replace(/[^a-z0-9]+/g, '-').substring(0, 40);
      await env.DB.prepare('INSERT OR REPLACE INTO pages (slug, title, subtitle, body, updated_at, updated_by) VALUES (?, ?, ?, ?, datetime(\'now\'), ?)').bind(slug, data.title, data.subtitle || '', data.body || '', user.email).run();
      await auditLog(env, user.email, 'upsert', 'page', slug, JSON.stringify({ title: data.title }), ip);
      return new Response(JSON.stringify({ slug, message: 'Saved' }), { headers: corsHeaders() });
    }

    // DELETE /api/admin/pages/:slug
    if (path.startsWith('/api/admin/pages/') && method === 'DELETE') {
      const deny = requireRole(user, ['admin']);
      if (deny) return deny;
      const slug = path.split('/')[4];
      await env.DB.prepare('DELETE FROM pages WHERE slug = ?').bind(slug).run();
      await auditLog(env, user.email, 'delete', 'page', slug, null, ip);
      return new Response(JSON.stringify({ message: 'Deleted' }), { headers: corsHeaders() });
    }

    // ── AUDIT LOG (admin) ──

    // GET /api/admin/audit — view audit log
    if (path === '/api/admin/audit' && method === 'GET') {
      const deny = requireRole(user, ['admin']);
      if (deny) return deny;
      const limit = parseInt(url.searchParams.get('limit') || '100');
      const results = await env.DB.prepare('SELECT * FROM audit_log ORDER BY timestamp DESC LIMIT ?').bind(limit).all();
      return new Response(JSON.stringify({ entries: results.results }), { headers: corsHeaders() });
    }

    // ── BACKUP (admin) ──

    // GET /api/admin/backup — export all data as JSON
    if (path === '/api/admin/backup' && method === 'GET') {
      const deny = requireRole(user, ['admin']);
      if (deny) return deny;
      const stories = await env.DB.prepare('SELECT * FROM stories').all();
      const users = await env.DB.prepare('SELECT * FROM users').all();
      const subscribers = await env.DB.prepare('SELECT * FROM subscribers').all();
      const config = await env.DB.prepare('SELECT * FROM site_config').all();
      const audit = await env.DB.prepare('SELECT * FROM audit_log ORDER BY timestamp DESC LIMIT 1000').all();

      const backup = {
        exported_at: new Date().toISOString(),
        exported_by: user.email,
        stories: stories.results,
        users: users.results,
        subscribers: subscribers.results,
        config: config.results,
        recent_audit: audit.results,
      };

      await auditLog(env, user.email, 'export_backup', 'system', null, null, ip);

      return new Response(JSON.stringify(backup, null, 2), {
        headers: {
          'Content-Type': 'application/json',
          'Content-Disposition': `attachment; filename="utv-backup-${new Date().toISOString().split('T')[0]}.json"`,
          'Access-Control-Allow-Origin': '*',
        },
      });
    }

    return new Response(JSON.stringify({ error: 'Not found' }), { status: 404, headers: corsHeaders() });
  },

  // ── CRON: Monthly newsletter ──
  async scheduled(event, env) {
    const subscribers = await env.DB.prepare('SELECT email FROM subscribers').all();
    if (!subscribers.results.length) return;

    const stories = await env.DB.prepare(
      'SELECT id, title, author, region, summary, read_time FROM stories WHERE status = ? ORDER BY date DESC LIMIT 8'
    ).bind('published').all();

    const siteUrl = env.SITE_URL || 'https://the-utah-view.pages.dev';
    const months = ['January','February','March','April','May','June','July','August','September','October','November','December'];
    const now = new Date();
    const monthYear = months[now.getMonth()] + ' ' + now.getFullYear();

    let storyRows = '';
    stories.results.forEach(s => {
      storyRows += `<tr><td style="padding:20px 0;border-bottom:1px solid #e5e5e5">
        <p style="font-family:Helvetica,sans-serif;font-size:11px;font-weight:700;letter-spacing:1px;text-transform:uppercase;color:#C4352A;margin:0 0 6px">${s.region}</p>
        <a href="${siteUrl}/article.html?id=${s.id}" style="font-family:Georgia,serif;font-size:20px;font-weight:700;color:#121212;text-decoration:none;line-height:1.3;display:block;margin-bottom:6px">${s.title}</a>
        <p style="font-family:Georgia,serif;font-size:15px;color:#666;line-height:1.5;margin:0 0 6px">${s.summary}</p>
        <p style="font-family:Helvetica,sans-serif;font-size:12px;color:#888;margin:0">By ${s.author}</p>
      </td></tr>`;
    });

    const emailHtml = `<!DOCTYPE html><html><body style="margin:0;padding:0;background:#f5f5f5">
      <table width="100%" cellpadding="0" cellspacing="0" style="background:#f5f5f5;padding:24px 0"><tr><td align="center">
      <table width="600" cellpadding="0" cellspacing="0" style="background:#fff;border-radius:4px;max-width:600px">
      <tr><td style="background:#C4352A;padding:28px 32px;text-align:center">
      <p style="font-family:Helvetica,sans-serif;font-size:24px;font-weight:800;letter-spacing:2px;text-transform:uppercase;color:#fff;margin:0">THE UTAH VIEW</p></td></tr>
      <tr><td style="padding:28px 32px 16px"><p style="font-family:Helvetica,sans-serif;font-size:13px;font-weight:700;letter-spacing:1px;text-transform:uppercase;color:#C4352A;margin:0 0 8px">${monthYear} Briefing</p></td></tr>
      <tr><td style="padding:0 32px"><table width="100%">${storyRows}</table></td></tr>
      <tr><td style="padding:28px 32px;text-align:center"><a href="${siteUrl}" style="display:inline-block;padding:12px 32px;background:#C4352A;color:#fff;font-family:Helvetica,sans-serif;font-size:14px;font-weight:700;text-decoration:none;border-radius:4px">Read Full Issue</a></td></tr>
      <tr><td style="padding:20px 32px;border-top:1px solid #e5e5e5;text-align:center"><p style="font-family:Helvetica,sans-serif;font-size:12px;color:#999;margin:0">© ${now.getFullYear()} The Utah View</p></td></tr>
      </table></td></tr></table></body></html>`;

    for (const sub of subscribers.results) {
      try {
        await fetch('https://api.resend.com/emails', {
          method: 'POST',
          headers: { 'Authorization': `Bearer ${env.RESEND_API_KEY}`, 'Content-Type': 'application/json' },
          body: JSON.stringify({
            from: env.FROM_EMAIL || 'The Utah View <newsletter@theutahview.com>',
            to: [sub.email],
            subject: `The Utah View — ${monthYear} Briefing`,
            html: emailHtml,
          }),
        });
      } catch (e) { console.error('Email failed:', sub.email, e); }
    }

    await env.DB.prepare(
      "INSERT INTO audit_log (user_email, action, resource_type, details) VALUES (?, ?, ?, ?)"
    ).bind('system', 'send_newsletter', 'newsletter', JSON.stringify({ recipients: subscribers.results.length, month: monthYear })).run();
  },
};
