# CLAUDE.md — The Utah View

Guidance for Claude Code (and the developer) working in this repo, on **either**
machine. Keep this file current when workflows change.

## What this is
**The Utah View** (theutahview.com) — a monthly global-politics publication based
in Salt Lake City. This repo holds the **website** (a hand-written static site
in `site/`), one Flutter codebase that ships the **iOS and Android apps** from
`lib/`, a **Cloudflare** backend in `backend/` and `functions/`, and a
standalone **admin editor** at `site/editor.html`.

- Website: https://theutahview.com (Cloudflare Pages project `the-utah-view`,
  production branch `main`) — deployed from `site/`, **not** from the Flutter
  web build. The Flutter web build is dev-only; never deploy it to production.
- API: https://api.theutahview.com (Cloudflare Worker `utv-api`)
- Admin editor: https://theutahview.com/editor (Google sign-in only)
- Repo: https://github.com/GloryComrade/the-utah-view (**PUBLIC** — never commit secrets)

> **Resuming a session?** Read **`docs/SESSION-HANDOFF.md`** first — current
> deploy/device state, environment gotchas, and what the last redesign changed.

## The website (`site/`)
- Plain HTML/CSS/JS, no build step: `index.html` (front page, sections, archive,
  saved), `article.html?id=…`, `page.html?p=…`, plus `editor.html`,
  `privacy.html`, `delete-account.html`, `logo.png`, `_headers`.
- `index.html`, `article.html` and `page.html` are the original May 2026 site
  (Pages deployment `e233abd9`), restored 2026-10-21 at Ryan's request. They
  read the live API (`/api/stories`, `/api/config/layout`, `/api/config/site`).
  Their look is separate from the app's: Georgia/Helvetica, red `#C4352A`.
- `functions/article.html.js` serves `site/article.html` with per-story share
  (Open Graph) tags injected.
- The apps share and deep-link the same URLs (`article.html?id=`,
  `page.html?p=`, `?cat=`, `?view=`), so links work in both.

## Logo (everywhere)
- One mark for the app, website, icons and splash: `assets/brand/logo.svg`,
  traced from Ryan's artwork `tool/brand_assets/logo-source.png` (red `#B53816`,
  white counters). The app draws it with `UtvLogoPainter` (brand.dart); every
  PNG (app icon, adaptive/themed icon, splash, `logo.png`, web icons, the site's
  `favicon.png`/`apple-touch-icon.png`/`logo.png`) and the inline SVGs in
  `site/*.html` come from that one vector. Pipeline: `tool/brand_assets/vectorize_logo.py`.

## App design system (2026 red/white redesign — Flutter app only)
- **Two fonts only.** `ArchivoBlack` for the "THE UTAH VIEW" wordmark (an
  Arial Black stand-in — Arial can't be bundled); **Newsreader** for everything
  else. `AppFonts.sans`/`body` deliberately alias to Newsreader, so all UI chrome
  is the one serif. Don't add a third family without asking.
- **Color.** White background, `#CE1126` fills, `#A11121` accent text/links,
  `#E3E3E3` rules, near-black ink. `#A2A9AF` is decoration-only (fails text
  contrast). Defined as semantic tokens in `lib/core/theme/app_colors.dart`;
  `test/core/contrast_test.dart` enforces AA for light, dark, and both
  high-contrast palettes — run it after any color change.
- **Accessibility is first-party** (not OS-reliant): in-app text size, high
  contrast, reduce motion, a web skip link, and article read-aloud (TTS). See
  `lib/shared/widgets/accessibility_panel.dart`, `skip_link.dart`,
  `lib/features/article/read_aloud.dart`.
- **Navigation.** Phones: bottom tab bar. Tablet/desktop: top strip with a
  text-only dropdown menu + search (`lib/shared/widgets/app_shell.dart`).

## Repo layout
| Path | What |
|------|------|
| `lib/` | The Flutter app (Riverpod + go_router + dio). Features in `lib/features/`, shared in `lib/shared/`, core/api/auth/theme in `lib/core/`. |
| `site/` | **The website** as deployed (static HTML). **`site/editor.html`** is the admin console (plain HTML/JS, no framework). |
| `web/` | Flutter web shell (dev/preview only — not deployed). |
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
flutter run -d chrome                # app preview in Chrome (dev only; the website is site/)
flutter test                         # on the Mac, prefix: NO_PROXY=localhost,127.0.0.1,::1 flutter test
dart run build_runner build --delete-conflicting-outputs   # only after editing a @freezed / json model
```
Note: `pubspec.yaml` pins `analyzer: '>=14.0.0 <14.5.0'` (build_runner 2.16.1
incompatibility). Don't bump it without testing codegen.

## Deploy
```bash
# Website + editor (Pages): ship site/ as-is, from the repo root so the
# functions/ directory is picked up. --branch=main is production; any other
# branch name makes a preview at <branch>.the-utah-view.pages.dev.
wrangler pages deploy site --project-name=the-utah-view --branch=main

# Backend Worker
wrangler deploy --config backend/deploy/wrangler.toml
```
**Always syntax-check the pages' inline JS before deploying** (a past single-quote
bug blanked the site). Preview first (`--branch=preview`), look at it, then
deploy `--branch=main`.

## Admin editor (`site/editor.html`)
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
