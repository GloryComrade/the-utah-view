# Session handoff — The Utah View

**Read this first when resuming in a new Claude Code session.** Last updated
**2026-10-21**. Pairs with `CLAUDE.md` (workflow) and `docs/RELEASE.md`.

---

## 1. Current state (as of HEAD `e232277`)

- **Branch `main`, all pushed** to `github.com/GloryComrade/the-utah-view` (**PUBLIC**).
- **Website (updated 2026-10-21, later session):** theutahview.com is the
  original May 2026 **static site**, restored from Pages deployment `e233abd9`
  and now kept in `site/` (with today's editor/privacy/delete-account pages).
  The red/white Flutter redesign below was never live on the web (its deploys
  went to a preview branch) and the website no longer uses the Flutter build.
  The apps keep the Flutter redesign.
- **iOS app installed** on **Ryan's iPhone 15 Pro** (`00008130-001E258138A1401C`),
  bundle `com.theutahview.app`. The **iPhone 16 Pro** (`00008140-000E39AA0C28801C`)
  was NOT updated (it was unavailable) — reinstall there when it's connected.
- **Android**: not rebuilt/released this session (code is ready; `.aab` via
  `flutter build appbundle`).
- `flutter analyze` clean; **`flutter test` = 158 passing**.

## 2. How to resume — environment gotchas (Salt Lake Mac)

These are non-obvious and WILL bite a fresh session:

- **Project path has a trailing space and is NOT the shell's default cwd.**
  The real project is `/Users/ryancheng/Downloads/the utah view app /testing`
  (space after `app`). The shell keeps resetting cwd to a STALE copy at
  `/Users/ryancheng/Downloads/the test code project /testing` (old
  Firebase/Supabase history — do not work there). **Prefix every command**:
  `cd "/Users/ryancheng/Downloads/the utah view app /testing" && …`
- **Proxy rules:** `git`/`gh` = **proxy ON** (leave shell as-is). `wrangler`,
  Cloudflare, and `pub` = **proxy OFF** (`unset HTTP_PROXY HTTPS_PROXY ALL_PROXY
  http_proxy https_proxy all_proxy`). Tests need `NO_PROXY=localhost,127.0.0.1,::1`
  or they hang. `curl`/`urllib` to `api.theutahview.com` **fail** (TLS filter,
  exit 60 / self-signed) — read prod data with `wrangler d1` instead.
- **wrangler version:** the global `/usr/local/bin/wrangler` (4.81) is **NOT
  authorized for D1** (`code 7403`). Use **`npx wrangler@4.151.1`** for D1 and
  Pages (it's the authenticated one). Plain `npx wrangler` tried to fetch 4.151.3
  and failed with `Invalid Version` — pin `@4.151.1`.
- Gradle (Android) needs proxy `1087`; stop a stale daemon with
  `cd android && ./gradlew --stop` if you hit a handshake error.

## 3. Deploy / prod commands (copy-paste, from the project dir)

```bash
cd "/Users/ryancheng/Downloads/the utah view app /testing"

# Website (site/ + editor)
unset HTTP_PROXY HTTPS_PROXY ALL_PROXY http_proxy https_proxy all_proxy
# The website is the static site in site/ (since 2026-10-21) — not the
# Flutter web build. Production branch is `main`; any other --branch (e.g.
# "production") only makes a PREVIEW that never reaches theutahview.com.
NO_PROXY=localhost,127.0.0.1,::1 npx wrangler@4.151.1 pages deploy site \
  --project-name=the-utah-view --branch=main

# Read/write prod config or data (D1)
NO_PROXY=localhost,127.0.0.1,::1 npx wrangler@4.151.1 d1 execute utv-db --remote \
  --config backend/deploy/wrangler.toml --command "SELECT key FROM site_config"

# iOS to the plugged-in iPhone 15 Pro
NO_PROXY=localhost,127.0.0.1,::1 flutter build ios --release
xcrun devicectl device install app --device 00008130-001E258138A1401C \
  "build/ios/iphoneos/Runner.app"
```

Cloudflare IDs: account `0405da01a73bef87f1d07da2a4cb8c11`, D1 `utv-db`
= `c52b6046-8f9c-42ab-a1c0-5bdcdcbfdc90`. iOS signing team `WJV7UGJ2AS`.

## 4. What changed this session (the "2026 red/white" redesign)

Six commits, `a5f72a4` → `e232277`:

1. **`a5f72a4` — type + color foundation.** Dropped Inter, IBM Plex Sans and
   Source Serif 4 (families + TTFs). The app is now **two faces**: **Archivo
   Black** (`assets/fonts/ArchivoBlack-Regular.ttf`, OFL) for the "THE UTAH VIEW"
   wordmark only, and **Newsreader** for everything else (`AppFonts.sans`/`body`
   alias to Newsreader). New **red/white/grey palette** in `app_colors.dart`.
2. **`afd028f` — element tweaks.** Serif, AA-readable photo credits
   (`image_caption.dart`); removed the "Stay briefed" card from the home feed
   (kept in More).
3. **`1c31762` — desktop nav.** `app_shell.dart` is now responsive: phones keep
   the bottom bar; tablet/desktop get a top strip = wordmark + one text-only
   dropdown menu + search. Masthead hides its own search on wide screens.
4. **`cac662d` — accessibility (3/4).** High-contrast palettes + toggle, reduce
   motion (honors OS flag; instant page transitions), web "Skip to main content"
   link (`skip_link.dart`), on-page accessibility panel (`accessibility_panel.dart`).
   Settings persisted in `app_settings.dart`.
5. **`7429ec8` — read-aloud (4/4).** `flutter_tts` + `read_aloud.dart` + a
   "Listen" button in the article toolbar.
6. **`e232277` — brand recolor.** Regenerated logo/icons/splash at `#CE1126`
   (added `logo.png` to `tool/brand_assets/generate_brand_assets_test.dart`, then
   `flutter_launcher_icons` + `flutter_native_splash:create`). `web/manifest.json`
   theme → `#CE1126`.

**Live config edit (not in repo):** removed the footer's "Bi-Monthly Newsletter"
and "An Analysis on Utah Today" (`the-communist-weekly`) links from
`site_config.site` via a `wrangler d1` read-modify-write (4 → 3 columns).

The design tokens are summarized in `CLAUDE.md` → "Design system".

## 5. Security (important)

- **Repo is PUBLIC.** Never commit `key.properties`, `*.jks`, `*.keystore`, or any
  secret. Signing + API secrets are Worker secrets / gitignored.
- **`ADMIN_API_KEY` auth-bypass still exists** in `backend/deploy/worker.js`
  (~line 57: `Bearer <ADMIN_API_KEY>` + `X-User-Email`). The key *value* is a
  Worker secret and is **not committed** (not leaked), but the bypass mechanism is
  public and the known value (`utv-admin-2026-secure`) is weak. Recommend: remove
  the branch, redeploy, `wrangler secret delete ADMIN_API_KEY`. **This session did
  NOT use that key** — D1/Pages went through authenticated `wrangler`.
- Backend is **live with real subscribers** — keep changes additive; never POST
  real addresses to `/api/subscribe`. For bulk edits to already-published stories,
  use **direct D1 `UPDATE`** (not the Worker `PUT`) to avoid re-triggering FCM push.

## 6. Open / pending items

- **Data-brief chart style** — the one unfinished item from the *first* redesign
  brief: a single consistent chart component on the palette. Not built yet.
- **Reinstall on the iPhone 16 Pro** when it's connected.
- **Confirm redesign judgment calls** with Ryan: all UI chrome is now serif
  (Newsreader); the logo was recolored terracotta → `#CE1126`; desktop home shows
  a small wordmark (top strip) above the big masthead; the motto "Industry and
  Everything Else" was described as temporary.
- **Remove the `ADMIN_API_KEY` backdoor** (see Security).
- iOS push still needs a paid Apple account + APNs key (from an earlier session).

## 7. Where the new code lives

- Theme: `lib/core/theme/app_colors.dart`, `app_typography.dart`, `app_theme.dart`.
- Settings: `lib/core/settings/app_settings.dart` (themeMode, readingScale,
  highContrast, reduceMotion).
- Accessibility: `lib/shared/widgets/accessibility_panel.dart`,
  `lib/shared/widgets/skip_link.dart`, `lib/features/article/read_aloud.dart`.
- Nav: `lib/shared/widgets/app_shell.dart` (responsive),
  `lib/features/home/widgets/masthead_header.dart`.
- Brand: `lib/shared/widgets/brand.dart`,
  `tool/brand_assets/generate_brand_assets_test.dart`.
- Color guardrail: `test/core/contrast_test.dart` (light + dark + both
  high-contrast palettes must pass AA).

> Note on Claude memory: this project's auto-memory key is currently tangled with
> another project ("PhotoDrop") on this machine. Treat **this repo** (CLAUDE.md +
> this file) as the source of truth, not the memory index.
