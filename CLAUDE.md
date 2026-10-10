# CLAUDE.md — The Utah View

Guidance for Claude Code (and the developer) working in this repo, on **either**
machine. Keep this file current when workflows change.

## What this is
**The Utah View** (theutahview.com) — a monthly global-politics publication based
in Salt Lake City. This repo is one Flutter codebase that ships **iOS, Android,
and web** from `lib/`, plus a **Cloudflare** backend in `backend/` and
`functions/`, and a standalone **admin editor** at `web/editor.html`.

- Live site + web app: https://theutahview.com (Cloudflare Pages project `the-utah-view`)
- API: https://api.theutahview.com (Cloudflare Worker `utv-api`)
- Admin editor: https://theutahview.com/editor (Google sign-in only)
- Repo: https://github.com/GloryComrade/the-utah-view (private)

## Repo layout
| Path | What |
|------|------|
| `lib/` | The Flutter app (Riverpod + go_router + dio). Features in `lib/features/`, shared in `lib/shared/`, core/api/auth/theme in `lib/core/`. |
| `web/` | Web shell. **`web/editor.html`** is the admin console (plain HTML/JS, no framework). `_redirects`, `_headers` ship with the build. |
| `backend/deploy/` | The Worker (`worker.js`) + `wrangler.toml`. D1/R2/KV bindings. |
| `backend/migrations/` | D1 SQL migrations (already applied to production). |
| `functions/` | Cloudflare **Pages Functions** (e.g. `article.html.js` injects per-story share/OG meta). Must stay at repo root, not inside `build/`. |
| `ios/`, `android/` | Native shells + Firebase config (client config, safe to commit). |
| `test/` | Widget/unit tests. |
| `tool/` | Helper scripts (brand assets, screenshots, `verify_api.dart`). |
| `docs/` | Longer docs incl. `RELEASE.md`. |

## Setup on a fresh machine
```bash
gh auth login                       # once per machine
gh repo clone GloryComrade/the-utah-view
cd the-utah-view
flutter pub get                      # generated *.g.dart/*.freezed.dart are committed, so no build_runner needed
```
Install the **Flutter**, **Dart**, and **Claude Code** VS Code extensions.

- **iOS builds require macOS** — only the Salt Lake Mac can build/run iOS.
- The **HP Spectre (Windows)** builds/runs **web + Android**; no proxy quirks there.

## Common commands
```bash
flutter run -d chrome                # web preview (works without Xcode/Android SDK)
flutter test                         # on the Mac, prefix: NO_PROXY=localhost,127.0.0.1,::1 flutter test
flutter build web --release          # output in build/web
dart run build_runner build --delete-conflicting-outputs   # only after editing a @freezed / json model
```
Note: `pubspec.yaml` pins `analyzer: '>=14.0.0 <14.5.0'` (build_runner 2.16.1
incompatibility). Don't bump it without testing codegen.

## Deploy
```bash
# Web / editor (Pages). editor.html lives in web/, so it's copied by the build.
flutter build web --release
wrangler pages deploy build/web --project-name=the-utah-view

# Backend Worker
wrangler deploy --config backend/deploy/wrangler.toml
```
After editing only `web/editor.html`, you can `cp web/editor.html build/web/editor.html`
and redeploy without a full rebuild. **Always `node --check` the editor's JS before
deploying** (a past single-quote bug blanked the site).

## Admin editor (`web/editor.html`)
- **Google sign-in only**; no admin key in the source. Access is gated by the
  `users` table (admin/editor roles), managed in the **Access** panel.
- Google ID tokens expire ~1h; the editor silently re-issues one before admin
  calls (`tokenFresh()`/`refreshToken()`), so saves/grants don't 403.
- The **Homepage & app layout** panel's Sections manager (order / show-hide /
  labels) and story-slot pickers drive **both the website and the mobile apps'**
  front page. The app reads the same `/api/config/layout`.

## Daily two-machine workflow
Work from the Mac or the Spectre — just stay in sync through GitHub.

**Start of a session (either machine):**
```bash
git pull
```
**When done / to back up:**
```bash
git add -A
git commit -m "describe the change"
git push
```
Push from one machine, pull on the other. `build/`, `.dart_tool/`, Pods, and
machine-specific config are git-ignored, so each machine builds locally and the
two never fight over generated files.

> If `git pull`/`push` ever reports *"non-fast-forward"*, you committed on both
> machines without pulling. Run `git pull --rebase`, resolve any conflicts, then
> `git push`.

## Salt Lake Mac ONLY — network quirks (ignore on the Spectre)
This Mac sits behind a transparent TLS filter (ContentKeeper) + a local proxy.
- **GitHub (`git`/`gh`): proxy ON** — leave the shell as-is. Direct access hits
  the filter → `SSL certificate problem: self signed certificate`.
- **Cloudflare (`wrangler`): proxy OFF** — prefix with
  `unset HTTP_PROXY HTTPS_PROXY ALL_PROXY http_proxy https_proxy all_proxy`.
- **Tests:** `export NO_PROXY=localhost,127.0.0.1,::1` or `flutter test` hangs.
- iOS 26/27 simulator: use **Xcode 27 + DeviceHub.app** (`open -a DeviceHub`), not
  `Simulator.app`. See `docs/RELEASE.md`.

## Instagram
- **Share to Instagram (app):** the article share button offers "Share as image",
  which renders a branded 1080×1350 card (`lib/features/article/share_card.dart`)
  and opens the OS share sheet (Instagram Stories/Feed, etc.).
- **Auto-post on publish (backend):** `maybePostInstagram()` in `worker.js` posts a
  newly published story to Instagram via the Graph API. Dormant until the Worker
  secrets `IG_ACCESS_TOKEN` + `IG_USER_ID` (and optional `IG_FALLBACK_IMAGE`) are
  set. Deduped via the `ig_posted` D1 table. Full setup: `docs/INSTAGRAM_AUTOPOST.md`.

## Security notes
- No secrets live in the repo. The admin API key and Firebase FCM service-account
  key are **Cloudflare Worker secrets** (`wrangler secret put …`), never committed.
  Firebase *client* config (`GoogleService-Info.plist`, `google-services.json`,
  `firebase_options.dart`) is committed on purpose — those are not secrets.
- Known hole to close someday: the Worker still accepts `Bearer <ADMIN_API_KEY>` +
  `X-User-Email` as an auth bypass. Remove that branch, redeploy, and
  `wrangler secret delete ADMIN_API_KEY` to rotate.
- Backend is **live production with real subscriber data** — keep changes additive
  and never POST real addresses to `/api/subscribe`.
