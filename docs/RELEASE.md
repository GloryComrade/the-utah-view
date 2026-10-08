# Releasing The Utah View

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

1. **App ID.** developer.apple.com → Certificates, IDs & Profiles →
   Identifiers → `com.theutahview.app`. Enable **Associated Domains** (and
   Push Notifications later, for Phase 2).
2. **Signing.** `open ios/Runner.xcworkspace` → Runner target → Signing &
   Capabilities → choose your Team (automatic signing).
   Free "Personal Team" accounts can't use Associated Domains. If you must
   build with one, temporarily remove `CODE_SIGN_ENTITLEMENTS` from the
   Runner target.
3. **App Store Connect → New App:** name "The Utah View", bundle id
   `com.theutahview.app`, SKU (e.g. `utahview-ios`), primary language English
   (U.S.), category **News**.
4. **Listing:** subtitle, description, keywords, support URL, marketing URL
   (https://theutahview.com), privacy policy URL
   (https://theutahview.com/page.html?p=Privacy-Policy).
5. **App Privacy:** the app collects one thing: an **email address**, only
   when a reader subscribes to the newsletter, sent to `/api/subscribe`. No
   tracking, no analytics, no ads. Bookmarks, settings and the offline cache
   never leave the device.
6. **Age rating:** answer the questionnaire for news content (war and
   political violence are covered as news).
7. **Screenshots:** 6.9" iPhone (1320×2868). The app supports iPad (two-column
   layout), so 13" iPad screenshots (2064×2752) are required too. Capture with
   `xcrun simctl io booted screenshot shot.png`.
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
           "appIDs": ["<TEAM_ID>.com.theutahview.app"],
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
4. **Store listing:** short description (≤80 chars), full description, 512×512
   icon (resize `assets/brand/app_icon.png`), 1024×500 feature graphic, at
   least two phone screenshots, plus 7" and 10" tablet screenshots.
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
7. Ship to **Internal testing** first, then promote.

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
