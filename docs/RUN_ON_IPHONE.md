# Run The Utah View on your iPhone (from source, free Apple ID)

This lets you build the app from this repo on **your own Mac** and install it on
**your own iPhone** to test — no paid Apple Developer account needed. (A free
Apple ID can sign apps onto a phone you physically plug into your Mac; the build
just expires after 7 days and you re-run it to refresh.)

You need: a **Mac**, an **iPhone + USB cable**, and about 30–45 min the first time
(mostly Xcode downloading).

---

## 1. Install the tools (one-time)
1. **Xcode** — install the full app from the Mac App Store, open it once, and let
   it finish "installing components." Then run:
   ```bash
   sudo xcodebuild -license accept
   xcodebuild -runFirstLaunch
   ```
2. **Flutter** — follow flutter.dev/docs/get-started/install/macos (download the
   SDK, add `flutter/bin` to your PATH). Then:
   ```bash
   flutter doctor      # follow anything it flags; "CocoaPods" especially
   ```
3. **CocoaPods** (if `flutter doctor` says it's missing):
   ```bash
   sudo gem install cocoapods
   ```

## 2. Get the code
```bash
git clone https://github.com/GloryComrade/the-utah-view.git
cd the-utah-view
flutter pub get
```

## 3. Point signing at YOUR Apple ID (the important part)
1. Open the iOS workspace **in Xcode** — use the `.xcworkspace`, **not** the
   `.xcodeproj` (opening the project file causes a "Missing package product" error):
   ```bash
   open ios/Runner.xcworkspace
   ```
2. In Xcode: **Xcode menu → Settings → Accounts → ➕ → Apple ID** and sign in with
   your own Apple ID (a free one is fine).
3. In the left sidebar click the blue **Runner** project → select the **Runner**
   target → **Signing & Capabilities** tab.
4. Tick **Automatically manage signing**.
5. **Team** → choose your own name's **(Personal Team)**.
6. **Bundle Identifier** → change it to something unique that's yours, e.g.
   `com.yourname.utahview` (the default `com.theutahview.app` is registered to the
   original developer, so a free account can't reuse it). Xcode should then show a
   green "signing certificate" line with no errors.

## 4. Prepare your iPhone
1. Plug the iPhone into the Mac with a cable; on the phone tap **Trust** this
   computer.
2. On the phone enable developer mode: **Settings → Privacy & Security →
   Developer Mode → On** (it restarts the phone). (iOS 16+.)

## 5. Build and install
With the phone unlocked and connected:
```bash
flutter devices                 # confirm your iPhone is listed
flutter run --release           # builds and installs it on the phone
```
(Use `--release` so the app keeps working after you unplug — a plain `flutter run`
leaves it tied to the debugger.)

## 6. Trust the app on first launch
The first time you tap the app it says the developer is untrusted. Fix once:
**Settings → General → VPN & Device Management → [your Apple ID] → Trust**.
Now the app opens. It loads live content from the public API, so it just works on
normal Wi‑Fi/cellular.

---

## Good to know
- **7-day expiry:** free-signed apps stop launching after a week. To refresh, plug
  in and run `flutter run --release` again.
- **Free-account limits:** up to 3 sideloaded apps at a time; you can only install
  on a phone you connect to this Mac (remote installs need TestFlight + a paid
  account).
- **No Xcode/Mac?** You don't need any of this to *see* the app — open
  **https://theutahview.com** in Safari and "Add to Home Screen"; it's the same app
  as a web install.

## Troubleshooting
- **"Missing package product …"** → you opened `Runner.xcodeproj`. Close it and
  open `Runner.xcworkspace` instead.
- **Signing error about the bundle ID being unavailable** → change the Bundle
  Identifier (step 3.6) to something more unique.
- **"iOS 27.0 is not installed" / deployment target too high** → in Xcode, Runner
  target → Build Settings → **iOS Deployment Target**, set it to your phone's iOS
  version or lower (e.g. 15.0).
- **CocoaPods errors** → `cd ios && pod install --repo-update && cd ..` then retry.
- **Device not showing** → unlock the phone, re-tap Trust, and make sure Developer
  Mode is on (step 4).
