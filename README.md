# The Utah View — iOS & Android reader app

A Flutter reader app for [theutahview.com](https://theutahview.com), a monthly
global politics publication. Editorial, serif-led design in the spirit of the
WSJ and Washington Post apps. Reader only: there are no editor or admin
features.

| | |
|---|---|
| App name | The Utah View |
| Bundle / application id | `com.theutahview.app` |
| Backend | `https://api.theutahview.com` (Cloudflare Worker + D1, unchanged) |
| Flutter / Dart | 3.47 stable / 3.13 |

Screenshots of every screen are in [`docs/screenshots/`](docs/screenshots/).
They are rendered from the live API data captured in `test/fixtures/`.

## Run it

```sh
flutter pub get

# iOS Simulator (needs full Xcode, see docs/RELEASE.md)
open -a Simulator
flutter run -d iPhone

# Android emulator (needs Android Studio + an emulator)
flutter emulators --launch <emulator_id>   # list ids with: flutter emulators
flutter run -d emulator

# Browser preview (works today without Xcode or the Android SDK)
flutter run -d chrome
```

Test a deep link (opens the article screen):

```sh
# Android
adb shell am start -a android.intent.action.VIEW \
  -d "https://theutahview.com/article.html?id=zelenskyy-replaces-his-top-general-overnight" \
  com.theutahview.app
# iOS Simulator (custom scheme; https links need the AASA file, see docs/RELEASE.md)
xcrun simctl openurl booted "theutahview://article?id=zelenskyy-replaces-his-top-general-overnight"
```

## Check it

```sh
flutter analyze                 # no issues
flutter test                    # unit + widget tests (offline, from fixtures)
dart run tool/verify_api.dart   # parses every live endpoint with the app's models
```

If you're behind an HTTP proxy, `flutter test` needs localhost excluded:
`export NO_PROXY=localhost,127.0.0.1,::1`.

Regenerate generated code, images and fixtures:

```sh
dart run build_runner build                                   # freezed / json_serializable
flutter test tool/screenshots/app_screenshot_test.dart        # docs/screenshots/*.png
flutter test tool/screenshots/gallery_screenshot_test.dart    # design gallery PNGs
flutter test tool/brand_assets/generate_brand_assets_test.dart # icon + splash PNGs
dart run flutter_launcher_icons && dart run flutter_native_splash:create
dart run tool/verify_api.dart --fixtures                      # refresh test/fixtures
```

## How it works

- **Data:** `NewsRepository` (dio) fetches each endpoint and stores the raw
  JSON in Hive. Every provider is stale-while-revalidate: it returns the
  cached copy synchronously (instant open, works offline), then refreshes in
  the background. Pull to refresh forces it. A malformed response never
  overwrites a good cached one.
- **Models:** freezed + json_serializable with lenient converters. Missing,
  `null` or wrong-type fields become empty values. Layout ids that point at
  unpublished stories are skipped (`StoryIndex.resolve`). If the lead story
  is unpublished, the next placed story is promoted. If the layout can't
  load, Home falls back to newest-first.
- **Category rule:** shared with the website, in
  `lib/core/domain/story_filters.dart` and covered by tests. Sections
  (Analysis, Opinion, Data) also include "Global" and "The Utah Lens"
  stories.
- **Saved:** bookmarks store the full story JSON locally, so they read
  offline. Saved copies refresh when a newer version is fetched.
- **Search:** runs on the device over the cached story list (title, summary,
  author, region). It's accent-insensitive, every word must match, and
  results are ranked by where the words match.
- **Routing:** go_router with four tabs (`StatefulShellRoute`). Articles open
  full-screen above the tabs, with a Hero headline transition. Website URLs
  (`/article.html?id=`, `/page.html?p=`, `/?cat=`, `/?view=archive|saved`)
  are mapped in `lib/core/router/deep_links.dart`. Deep-linked stories open
  above Home, so Back stays in the app.
- **Design system:** `lib/core/theme`. Colors are semantic tokens
  (`context.palette`) and every text style has a name (`context.news`).
  Contrast is enforced by `test/core/contrast_test.dart`. Fonts are
  bundled: Source Serif 4 (a text cut and a display cut) and Inter, all OFL.
  Debug builds have More → Design gallery.
- **Material:** Flutter 3.47 split Material into the `material_ui` package.
  The app imports `package:material_ui/material_ui.dart` throughout (go_router
  18 requires it).

```
lib/
  app.dart, main.dart
  core/       api (client, models, repository, providers), auth (phase 2),
              domain (filters, search, index), notifications (phase 2),
              router, settings, storage, theme, utils
  features/   home, article, sections, saved, search, more, gallery
  shared/     widgets (logo, cards, ticker, HTML body, subscribe card, …)
test/         core (unit), widget (end-to-end over fixtures), support, fixtures
tool/         verify_api.dart, screenshots/, brand_assets/
docs/         RELEASE.md, PHASE2.md, BACKEND_NOTES.md, screenshots/
```

## More docs

- [docs/RELEASE.md](docs/RELEASE.md): machine setup, App Store and Google
  Play submission, deep-link verification files.
- [docs/PHASE2.md](docs/PHASE2.md): push notifications and Google Sign-In
  (scaffolded, not enabled).
- [docs/BACKEND_NOTES.md](docs/BACKEND_NOTES.md): issues found in the live
  API and content.
