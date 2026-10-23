# Releasing The Utah View

## What's in this build (2026 red/white redesign)

Current status: **web is live** on Cloudflare Pages; the iOS build is **installed
on the iPhone 15 Pro** (dev-signed). Not yet submitted to either store.
`version: 1.0.0+1` — **bump the build number before any store upload**. Full
detail + resume notes: **`docs/SESSION-HANDOFF.md`**; design tokens: `CLAUDE.md`.

What changed (store "What's new" / review context):
- **New identity:** two fonts only — Archivo Black wordmark + Newsreader
  everywhere else — on a white / `#CE1126` red / grey palette. Logo, icons and
  splash recolored to the new red (splash background is now white).
- **Desktop/web navigation:** bottom tab bar replaced by a top menu + search on
  wide screens; phones keep the bottom bar.
- **Accessibility (first-party, not OS-reliant):** in-app text size, high-contrast
  mode, reduce motion, a web skip link, and **article read-aloud** via
  `flutter_tts`.
- Removed the home "Stay briefed" card and two footer links (newsletter pages).

**Store answers are unchanged by TTS:** `flutter_tts` uses the OS speech engine
(`AVSpeechSynthesizer` / Android TextToSpeech) and needs **no new permission** and
collects **no data** — the "email only, no tracking" privacy declarations below
still hold. It does not support Swift Package Manager, so iOS keeps using
**CocoaPods** (already covered in Machine setup).

## 1. Machine setup

As of October 6, 2026, `flutter doctor` on the development Mac reports three
gaps. Fix them once:

```sh
# Xcode (full app from the App Store), then:
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
xcodebuild -downloadPlatform iOS        # simulator runtime

# CocoaPods (for plugins that don't support Swift Package Manager yet)
brew install cocoapods

# Android: install Android Studio, then SDK Manager → SDK Platform,
# Build-Tools, Command-line Tools, Emulator. Device Manager → create a Pixel.
flutter doctor --android-licenses

flutter doctor          # everything should be green except Proxy (below)
```

This Mac uses an HTTP proxy, so exclude localhost or `flutter test` will fail
to start: `export NO_PROXY=localhost,127.0.0.1,::1` (add it to `~/.zshrc`).

## 2. Run on a simulator / emulator

```sh
flutter pub get

# iOS Simulator
open -a Simulator
flutter run -d iPhone

# Android emulator
flutter emulators                         # lists emulator ids
flutter emulators --launch <emulator_id>
flutter run -d emulator
```

## 3. Versioning

`pubspec.yaml` → `version: 1.0.0+1` (name + build number). Bump the build
number for every upload to either store.

## 4. App Store (iOS)

**You need:** an Apple Developer Program membership ($99/year). Enroll as an
organization if the seller should read "The Utah View" (that requires a
D-U-N-S number); an individual enrollment shows your personal name.

   **Team:** paid Individual team `2Y9KNT8528` (seller name "Sau Ling Cheng").
   **iOS bundle ID is `com.theutahview.ios`** (Android stays
   `com.theutahview.app`): the old free Personal Team `WJV7UGJ2AS` still holds
   `com.theutahview.app` on Apple's side, so it can't be registered to the paid
   team. Firebase has a matching iOS app and Google Cloud project 562818410025
   has the iOS OAuth client "The Utah View iOS (App Store)".

1. **App ID.** developer.apple.com → Certificates, IDs & Profiles →
   Identifiers → `com.theutahview.ios`. Enable **Associated Domains** and
   **Push Notifications**.
   - **Push:** Keys → create an APNs key (.p8), then Firebase console
     (project `theutahview`) → Project settings → Cloud Messaging → Apple app
     → upload it with the Key ID and Team ID. Without it, iOS never gets
     new-story notifications (the app still runs).
2. **Signing.** `open ios/Runner.xcworkspace` → Runner target → Signing &
   Capabilities → choose your paid Team (automatic signing).
   `ios/Runner/Runner.entitlements` is kept empty so a free "Personal Team"
   can still install dev builds. For an App Store build, swap in the store
   entitlements (push + universal links) first, and don't commit the swap:
   ```sh
   cp ios/Runner/Runner.appstore.entitlements ios/Runner/Runner.entitlements
   flutter build ipa --release
   git checkout ios/Runner/Runner.entitlements
   ```
   The app supports iOS 15 and later (the Runner target used to say 27.0,
   which would have hidden it from anyone not on iOS 27).
3. **App Store Connect → New App:** name "The Utah View", bundle id
   `com.theutahview.ios`, SKU (e.g. `utahview-ios`), primary language English
   (U.S.), category **News**.
4. **Listing:** copy-paste from `docs/app-store/LISTING.md` (subtitle,
   description, keywords, URLs, age rating, review notes).
5. **App Privacy:** answers are in `docs/app-store/APP_PRIVACY.md` (email and
   name for optional accounts, saved stories when signed in, the push token).
   No tracking, no analytics, no ads.
   **Sign in with Apple (guideline 4.8):** the app offers Google sign-in, so
   App Review may require Sign in with Apple as an equal option (email/password
   doesn't count, because it can't hide the reader's email). Either add Sign in
   with Apple or hide the Google button on iOS before submitting.
6. **Age rating:** answer the questionnaire for news content (war and
   political violence are covered as news).
7. **Screenshots:** 6.9" iPhone (1320×2868). The app supports iPad (two-column
   layout), so 13" iPad screenshots (2064×2752) are required too. Ready-made
   ones are in `docs/app-store/screenshots/` (regenerate with
   `flutter test tool/screenshots/app_screenshot_test.dart --plain-name "app store"`);
   they show grey photo placeholders, so simulator captures with real photos
   look better: `xcrun simctl io booted screenshot shot.png`.
8. **Build and upload:**
   ```sh
   flutter build ipa --release
   # Upload build/ios/ipa/*.ipa with Apple's Transporter app (or Xcode → Organizer)
   ```
   Export compliance is already declared (`ITSAppUsesNonExemptEncryption =
   false`; the app only uses HTTPS).
9. **Universal links** (so theutahview.com article links open the app). Host
   this at `https://theutahview.com/.well-known/apple-app-site-association`
   (and on `www.`). Serve it as `application/json`, with no redirect and no
   file extension:
   ```json
   {
     "applinks": {
       "details": [
         {
           "appIDs": ["2Y9KNT8528.com.theutahview.ios"],
           "components": [{ "/": "/article*" }, { "/": "/page*" }]
         }
       ]
     }
   }
   ```
10. **Review notes:** "Reader app for a monthly news publication. No account
    is required. Newsletter sign-up is under More."

## 5. Google Play (Android)

**You need:** a Play Console developer account ($25, one time). New
*personal* accounts must run a closed test with at least 12 testers for 14
days before production; organization accounts (D-U-N-S) skip that.

1. **Upload key** (keep it and its passwords safe):
   ```sh
   keytool -genkey -v -keystore ~/keys/utah-view-upload.jks \
     -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```
   Create `android/key.properties` (git-ignored):
   ```properties
   storePassword=…
   keyPassword=…
   keyAlias=upload
   storeFile=/Users/<you>/keys/utah-view-upload.jks
   ```
   `android/app/build.gradle.kts` picks it up automatically. Without it,
   release builds are signed with the debug key, which Play rejects.
2. **Build:** `flutter build appbundle --release` →
   `build/app/outputs/bundle/release/app-release.aab`.
3. **Create the app** with package `com.theutahview.app` and enroll in **Play
   App Signing**.
   **Then fix Google sign-in for Play installs:** Play re-signs the app with
   its own key, so copy the **App signing key SHA-1** (Test and release →
   App integrity) and create an Android OAuth client for it in Google Cloud
   project `the-utah-view` (562818410025) → APIs & Services → Credentials,
   package `com.theutahview.app`. Clients already exist for the upload key
   (`A9:17:…:7E:28`) and the Spectre debug key.
4. **Store listing:** copy-paste from `docs/play-store/LISTING.md`; icon,
   feature graphic and phone screenshots are in `docs/play-store/`. Tablet
   screenshots are optional (only needed to be featured on tablets).
   Data safety answers: `docs/play-store/DATA_SAFETY.md`.
5. **App content:** privacy policy URL; **Data safety** (email address,
   optional, for the newsletter, sent over HTTPS, not shared, no ads); target
   audience; content rating questionnaire; **News app declaration** (Play's
   news policy wants publisher contact details reachable from the app.
   More → Contact covers it once the Contact page has real content).
6. **App Links:** host this at
   `https://theutahview.com/.well-known/assetlinks.json`:
   ```json
   [
     {
       "relation": ["delegate_permission/common.handle_all_urls"],
       "target": {
         "namespace": "android_app",
         "package_name": "com.theutahview.app",
         "sha256_cert_fingerprints": [
           "<App signing key SHA-256: Play Console → Setup → App signing>",
           "<Upload key SHA-256: keytool -list -v -keystore …>"
         ]
       }
     }
   ]
   ```
   Check on a device: `adb shell pm get-app-links com.theutahview.app`.
7. Ship to **Internal testing** first, then promote. A *personal* developer
   account (the current one is "Ryan Cheng") must run a **closed test with at
   least 12 testers for 14 days in a row** before it can apply for production.
   Start that closed test as early as possible; it's the longest wait.

## 6. Already prepared vs. still needed

| Already prepared in the project | You supply |
|---|---|
| Bundle id `com.theutahview.app`, display name, icons (incl. Android adaptive + themed), white splash | Apple Developer + Play Console accounts |
| `INTERNET` permission for release builds, URL-launcher queries, predictive back | Apple Team ID (goes in the AASA file) |
| App Links / universal-link intent filters + `Runner.entitlements` | Hosting the two `.well-known` files on theutahview.com |
| `ITSAppUsesNonExemptEncryption = false` | Upload keystore + `android/key.properties` |
| Release signing wiring in Gradle | Store copy, screenshots, support email/URL |
| Privacy-friendly v1 (no analytics, no tracking) | Real content on the Contact page (see BACKEND_NOTES.md) |

## 7. Pre-release checklist

```sh
flutter analyze
flutter test
dart run tool/verify_api.dart          # live API still parses
flutter build ipa --release
flutter build appbundle --release
```

Then on real devices: cold start offline (airplane mode) after one online
launch, pull to refresh, open a website link to an article, save a story and
read it offline, try 200% text size, and check dark mode.
