# Auto-post new stories to Instagram

When a story is **published**, the Worker can automatically post it to your
Instagram account (photo + caption). The code is already deployed but **dormant**
— it does nothing until you complete the Meta setup below and set two secrets.

## How it behaves
- Fires once per story, the first time it's published (deduped via the `ig_posted`
  table, so editing/re-publishing never double-posts).
- Caption = headline + summary + "Read the full story at theutahview.com (link in
  bio)" + hashtags.
- **Image:** Instagram requires a public **JPEG** URL, and it can't post text-only.
  The Worker uses the story's **first body image**; if the story has none it uses
  `IG_FALLBACK_IMAGE` (if you set one); if neither, it skips that story.
  → Practical tip: put an image in each story, or set a branded fallback JPEG.

## Prerequisites (Meta side — one-time, ~30–45 min)
1. **Make the Instagram account a Business or Creator account** (IG app → Settings
   → Account type) and **link it to a Facebook Page** (Page → Settings → Linked
   accounts → Instagram). Content publishing requires this.
2. **Create a Meta app** at https://developers.facebook.com → My Apps → Create App
   → type **Business**. Add the **Instagram** product (the "Instagram API with
   Facebook Login" / Graph API path).
3. Add yourself and the Page/IG account under the app's roles (admin/tester) so you
   can use it immediately in development mode.

## Get the two values you need
**A) `IG_USER_ID`** — your Instagram Business account id:
1. Open the **Graph API Explorer** (developers.facebook.com/tools/explorer), select
   your app, and generate a **User Token** with these permissions:
   `instagram_basic`, `instagram_content_publish`, `pages_show_list`,
   `pages_read_engagement`, `business_management`.
2. Run `GET /me/accounts` → note your Page's `id`.
3. Run `GET /{page-id}?fields=instagram_business_account` → the returned
   `instagram_business_account.id` is your **IG_USER_ID**.

**B) `IG_ACCESS_TOKEN`** — a long-lived token that can publish:
1. Exchange your short token for a **long-lived user token** (≈60 days):
   `GET /oauth/access_token?grant_type=fb_exchange_token&client_id={APP_ID}&client_secret={APP_SECRET}&fb_exchange_token={SHORT_TOKEN}`
2. Then `GET /me/accounts` **with the long-lived token** → copy your Page's
   `access_token`. A **Page token derived from a long-lived user token does not
   expire** (as long as permissions/password don't change), so use that Page token
   as `IG_ACCESS_TOKEN`. (For a truly permanent, hands-off setup, create a
   **System User** in Business Settings and generate a never-expiring token for it
   with the same permissions — recommended if you want to never touch this again.)

## Turn it on (set the Worker secrets)
From the repo root on the Mac (proxy **off** for wrangler):
```bash
unset HTTP_PROXY HTTPS_PROXY ALL_PROXY http_proxy https_proxy all_proxy
wrangler secret put IG_ACCESS_TOKEN --config backend/deploy/wrangler.toml   # paste the Page/System-User token
wrangler secret put IG_USER_ID       --config backend/deploy/wrangler.toml   # paste the IG business account id
# optional branded fallback image (must be a public JPEG):
wrangler secret put IG_FALLBACK_IMAGE --config backend/deploy/wrangler.toml
```
No redeploy needed — secrets apply immediately.

## Test it
Publish a story that has an image (or set `IG_FALLBACK_IMAGE` first). It should
appear on the Instagram feed within a few seconds. If nothing shows up, check the
Worker logs:
```bash
wrangler tail --config backend/deploy/wrangler.toml
```
Look for `IG posted story …` (success) or `IG create/publish failed: …` (the
message explains why — usually a non-JPEG image, a private image URL, or a token
scope problem).

## Gotchas
- **JPEG only** — PNG/WebP images are often rejected. Hero photos are usually JPEG;
  editor-uploaded PNGs may not post. A JPEG `IG_FALLBACK_IMAGE` sidesteps this.
- **Public URL** — the image must be reachable by Meta's servers (yours are, via
  `api.theutahview.com`).
- **App Review** — using `instagram_content_publish` for your *own* account works
  while you're an admin/tester of the app. To keep it running long-term Meta may
  require submitting the app for **Advanced Access** + **Business Verification**.
- **Token expiry** — if you used a plain long-lived *user* token it lapses in ~60
  days; the **Page token** or **System User** token avoids that.
