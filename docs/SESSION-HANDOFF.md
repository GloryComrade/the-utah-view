# Session handoff — The Utah View

**Read this first when resuming in a new Claude Code session.** Last updated
**2026-10-22**. Pairs with `CLAUDE.md` (workflow), `docs/WEBSITE-ROADMAP.md`
(website feature log) and `docs/RELEASE.md` (app release notes).

> **On a new computer?** Do §8 first (clone, tools, logins, Android signing files).

---

## 1. Current state (HEAD `0c2eef2` or later, all pushed)

**The website and the app are now separate products in one repo.**

- **Website — theutahview.com — is the static site in `site/`** (plain
  HTML/CSS/JS, no build step), *not* the Flutter web build. It's the original
  May 2026 site (Pages deployment `e233abd9`), restored on Ryan's request,
  then extended one approved feature at a time (all 11 roadmap items are
  live; see `docs/WEBSITE-ROADMAP.md`). Live production deployment:
  `18dda6ca` (wrangler labels it `b69908c` because it was deployed just
  before the wordmark commit `0c2eef2`; the content is `0c2eef2`).
- **Website look:** May design (Georgia body, Helvetica UI, red `#C4352A`)
  with the new logo mark and a **Playfair Display Black Italic** "The Utah
  View" wordmark (self-hosted in `site/fonts/`). Light and dark mode.
- **App (iOS/Android, Flutter `lib/`)** is unchanged since the red/white
  redesign (`3ad11fb`) except the **new logo** (`5dc578b`). Ryan said: change
  the website only unless he explicitly includes the app.
  - iPhone 15 Pro (`00008130-001E258138A1401C`): has the build with the new logo.
  - iPhone 16 Pro (`00008140-000E39AA0C28801C`): **not updated** (was
    "unavailable" all session). Reinstall when it's connected and unlocked.
  - Android: signed AAB with the new logo built at
    `build/app/outputs/bundle/release/app-release.aab` (1.0.0+1), **not
    uploaded** — Play upload is Ryan's step (bump the version if a build was
    ever uploaded before).
- `flutter analyze` clean; `flutter test` = **158 passing** (app code).
- **Backend security fixed 2026-10-22:** the leaked shared admin-key login was
  removed from the Worker (live version `778dab4c`) and the `ADMIN_API_KEY`
  secret deleted. Admin access is Google sign-in only. See §6.

## 2. Ryan's working preferences (learned the hard way)

- **Show before going live.** For anything visual: deploy a *preview*, send
  the link + screenshots, and deploy to production only after he says yes.
  (A restyle pushed straight to production on 2026-10-21 "ruined the
  website" and was rolled back.)
- **One feature at a time.** Small approved steps; he answers with short
  replies ("yes", "go ahead", "next one").
- **"commit" means commit and push only** — ask before deploying.
- **Ask him with concrete options** (he likes multiple-choice questions with
  previews) when a request is ambiguous.
- **Website only** unless he names the app.

## 3. Environment gotchas (Salt Lake Mac)

*(Everything in this section is about the Salt Lake Mac; a new computer
won't have the proxy/filter quirks — see §8.)*

- **Real repo:** `/Users/ryancheng/Downloads/the utah view app /testing`
  (space after `app`). Sessions sometimes open in the **stale, unrelated**
  `/Users/ryancheng/Downloads/the test code project /testing`
  (canyons-connect, Firebase) and the shell resets its cwd there after every
  command, so prefix commands with `cd "<real repo>" && …` or use absolute paths.
- **Proxy:** `git`/`gh`/`curl https://theutahview.com` = proxy **ON** (leave
  the shell as-is). `wrangler`/`npx`/`pub` = proxy **OFF** — run them in a
  subshell: `(unset HTTP_PROXY HTTPS_PROXY ALL_PROXY http_proxy https_proxy all_proxy; …)`
  so later commands keep the proxy. `curl api.theutahview.com` fails (TLS
  filter); headless Chrome reaches it fine.
- **Tests:** `NO_PROXY=localhost,127.0.0.1,::1 flutter test` or they hang.
- **wrangler:** use **`npx --yes wrangler@4.151.1`** (the global 4.81 isn't
  D1-authorized; unpinned `npx wrangler` fails with "Invalid Version").
- **Network filter:** some external photos (e.g. draperutah.gov,
  pco.gov.ph) don't load in headless Chrome on this machine; that's the
  filter, not the site.

## 4. Website workflow

```bash
cd "/Users/ryancheng/Downloads/the utah view app /testing"
# Preview (any branch name except main) → https://<name>.the-utah-view.pages.dev
(unset HTTP_PROXY HTTPS_PROXY ALL_PROXY http_proxy https_proxy all_proxy; \
  NO_PROXY=localhost,127.0.0.1,::1 npx --yes wrangler@4.151.1 pages deploy site \
  --project-name=the-utah-view --branch=<feature-name> --commit-dirty=true)
# Production (only after Ryan's yes) — run from the repo root so functions/ ships
(unset HTTP_PROXY HTTPS_PROXY ALL_PROXY http_proxy https_proxy all_proxy; \
  NO_PROXY=localhost,127.0.0.1,::1 npx --yes wrangler@4.151.1 pages deploy site \
  --project-name=the-utah-view --branch=main)
```

- **Before deploying:** syntax-check every page's inline JS (extract the
  `<script>` bodies and `node --check` them) and `node --check site/*.js`.
- **Verify a deploy:** `curl -sS "https://theutahview.com/…?v=$RANDOM"` and grep
  for the new code (Cloudflare adds a bot-protection `<script>` to HTML at the
  edge, so live HTML never byte-matches `site/`).
- **Rollback:** wrangler has no Pages rollback command. Use the API with
  wrangler's OAuth token (`~/.wrangler/config/default.toml`, `oauth_token`):
  `POST https://api.cloudflare.com/client/v4/accounts/0405da01a73bef87f1d07da2a4cb8c11/pages/projects/the-utah-view/deployments/<deployment-id>/rollback`.
  List deployments with `npx --yes wrangler@4.151.1 pages deployment list --project-name=the-utah-view`.
- **Browser testing** (used for every feature this session): `puppeteer-core`
  driving the installed Chrome, kept in a scratch folder (not the repo):
  `PUPPETEER_SKIP_DOWNLOAD=1 npm i puppeteer-core@23.11.1`, then launch with
  `executablePath: '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome'`.
  Tips: open a fresh page per origin; `page.screenshot({clip})` uses
  *document* coordinates (screenshot the viewport and crop to see fixed bars);
  wait for `img.complete` before shooting photos.
- **Editor testing without touching production:** in puppeteer, set a fake
  `utv_token`/`utv_user` (admin) in localStorage, answer `/api/me` with
  `{role:'admin'}`, pass public GETs through, and intercept every
  non-GET request (respond 200 locally) — then read what would have been saved.

## 5. Website code map (`site/`)

| File | What |
|------|------|
| `index.html` | Front page + `?cat=` sections, `?view=archive`, `?view=saved`. Briefing bar (tap → full list; height/speed from the editor), loading placeholders, slim pinned bar on computers. |
| `article.html` | `?id=` story: reading progress bar, styled pull quotes/captions, lead photo + caption/credit, A−/A+ text size, Listen (read aloud), placeholders. |
| `page.html` | `?p=` static pages (About, Mission…). |
| `search.js` | Shared search (top-bar button and `/` key), same rules as the app. |
| `theme.css` / `theme.js` | Dark mode (device setting + sun/moon switch) and the wordmark `@font-face`. A two-line script in each page's `<head>` sets `data-theme` before first paint. |
| `fonts/` | Playfair Display Black Italic (Latin subset) + `OFL.txt`. |
| `editor.html` | Admin editor (Google sign-in). Homepage → Briefing strip: one headline per line, plus website bar height/speed (`ticker_height`/`ticker_speed` in the layout; the app ignores them). |
| `privacy.html`, `delete-account.html` | Play Store–required pages (keep live). |
| `logo.png`, `favicon.png`, `apple-touch-icon.png` | New logo. |
| `../functions/article.html.js` | Injects per-story share (Open Graph) tags into `article.html`. |

The logo everywhere (app + website) comes from one vector traced from Ryan's
artwork: `tool/brand_assets/logo-source.png` → `vectorize_logo.py` →
`emit_logo.py` (see the docstring for the full pipeline).

## 6. Open items

1. ~~Security: leaked admin key~~ — **done 2026-10-22.** The Worker's shared
   `Bearer <ADMIN_API_KEY>` (+ `X-User-Email`) login was removed (live version
   `778dab4c`; the live code was first confirmed identical to the repo), CORS
   no longer allows `X-User-Email`, and the secret was deleted (remaining
   secrets: FCM_SERVICE_ACCOUNT, RESEND_API_KEY, IG_ACCESS_TOKEN, IG_USER_ID).
   Checked from a browser: the old key now gets 401/403 and the public API
   still works. Read-only D1 check: no `audit_log` entries, story edits,
   settings changes or new admin users since the leak (04:58 UTC); the
   `users` table is still the three known admins. Reads (e.g. the subscriber
   list) aren't logged, so access during the ~6-hour window can't be ruled
   out, but nothing points to it.
2. Reinstall the app on the iPhone 16 Pro.
3. Upload the Android AAB to Google Play (Ryan).
4. Website ideas offered but not requested yet: lead photo in shared-link
   previews (`og:image` in `functions/article.html.js`); pin the article header
   on computers; see-through logo counters in dark mode.
5. Known website gaps (from the compatibility audit): the editor's Sections
   hide/labels settings don't affect the website (the May homepage ignores
   them); no hero-caption field in the editor; the subscribe form says
   "Welcome aboard" even if the request fails; no
   `/.well-known/assetlinks.json` (Android app links open in the browser);
   Flutter-era `#/…` bookmarks land on the homepage.
6. `git stash list` → `stash@{0}` holds the rejected 2026-10-21 restyle of the
   *app* (five colours, Arial Black). Safe to drop: `git stash drop stash@{0}`.

## 7. What happened on 2026-10-21/22 (short)

- A five-colour/Arial Black restyle went straight to production; Ryan
  rejected it → rolled back via the API, changes stashed.
- Last session's "live" deploys had used `--branch=production` (a preview),
  so the Flutter redesign never reached the website.
- Website restored to the May static site in `site/` (`be69e36`); deploy
  scripts/docs now ship `site/`.
- New logo everywhere — app icons, splash, in-app, website (`5dc578b`); Play
  Store screenshots regenerated (`cebbcdf`).
- Website roadmap #1–#11, each previewed and approved (`f800e34` … `b69908c`):
  progress bar, quotes/captions, lead photo, text size, placeholders,
  Briefing list + editor controls, Listen, search, page fade, slim bar, dark mode.
- Playfair Display Black Italic wordmark (`0c2eef2`), chosen from five options.
- Leaked admin key fixed: login removed from the Worker, secret deleted, no
  misuse found in the logs (§6).

## 8. Setting up a new computer

Git carries everything except a few machine-local items. In order:

1. **Clone:** `gh auth login` (once), then
   `gh repo clone GloryComrade/the-utah-view && cd the-utah-view`.
2. **Tools:** Git, GitHub CLI, **Node.js 20+** (this Mac: 24.14), **Flutter
   3.47.x stable** (this Mac: 3.47.6; `flutter doctor`), Google Chrome, Claude
   Code (+ the VS Code Flutter/Dart extensions if using VS Code). Then
   `flutter pub get` and `NO_PROXY=localhost,127.0.0.1,::1 flutter test` (expect 158 passing; the
   `NO_PROXY` prefix only matters on the Salt Lake Mac).
3. **Cloudflare:** `npx --yes wrangler@4.151.1 login` (browser OAuth with the
   account that owns `the-utah-view` / `utv-api`, account ID
   `0405da01a73bef87f1d07da2a4cb8c11`). Check with
   `npx --yes wrangler@4.151.1 pages deployment list --project-name=the-utah-view`.
   Website deploys work from any OS; on Windows run the same `npx` commands in
   PowerShell without the `unset … proxy` subshell.
4. **Android signing (needed for Play Store builds) — copy by hand, never
   commit:** `android/key.properties` and `android/app/upload-keystore.jks`
   from the old machine into the same paths (AirDrop/USB/password manager).
   Keep a backup somewhere safe; losing them means an upload-key reset with
   Google Play. Upload-key SHA-1:
   `A9:17:9A:3F:CD:11:72:97:5F:85:E2:F2:8C:DD:E7:B9:9E:2C:7E:28`
   (check with `keytool -printcert -jarfile <aab>`).
5. **iOS builds need a Mac** with Xcode, signed in to the Apple ID for team
   `2Y9KNT8528` (paid; the old free team `WJV7UGJ2AS` is retired) (on Windows only web/Android are possible). Build and install
   to a plugged-in, unlocked iPhone (`xcrun devicectl list devices` shows
   whether it's "available"):
   ```bash
   flutter build ios --release
   xcrun devicectl device install app --device 00008130-001E258138A1401C build/ios/iphoneos/Runner.app   # iPhone 15 Pro
   xcrun devicectl device install app --device 00008140-000E39AA0C28801C build/ios/iphoneos/Runner.app   # iPhone 16 Pro
   ```
   Android release bundle: `flutter build appbundle --release` (needs step 4).
6. **Claude Code memory does not transfer** (it lives in `~/.claude` on each
   machine). This file + `CLAUDE.md` + `docs/WEBSITE-ROADMAP.md` are the
   source of truth. Start the first session with:
   > Read docs/SESSION-HANDOFF.md and docs/WEBSITE-ROADMAP.md first. The
   > website is the static site in site/; only the website changes unless I
   > say the app. Show me a preview link and screenshots before anything goes
   > live, one change at a time.
7. **Browser testing** (optional): in a scratch folder outside the repo,
   `PUPPETEER_SKIP_DOWNLOAD=1 npm i puppeteer-core@23.11.1` and point
   `executablePath` at the installed Chrome (§4).
8. **Old Mac leftovers that do not transfer** (nothing needed): `git stash`
   `stash@{0}` (the rejected app restyle), build outputs, and the scratch test
   scripts.
