# App Store listing — The Utah View

Copy-paste these into **App Store Connect → Apps → The Utah View**. Limits are
App Store Connect's; character counts are in brackets.

## App information
- **Name** (max 30): `The Utah View` [13]
- **Subtitle** (max 30): `Global politics, from Utah` [26]
- **Bundle ID:** `com.theutahview.ios` (Android is `com.theutahview.app`) · **SKU:** `utahview-ios`
- **Primary language:** English (U.S.)
- **Primary category:** News · **Secondary:** Magazines & Newspapers
- **Content rights:** "Does not contain, show, or access third-party content"
  → No (all stories are The Utah View's own). If wire photos are ever used,
  answer Yes and confirm you have the rights.

## Version page
### Promotional text (max 170, can change without review)
```
Independent global-politics journalism and analysis from Salt Lake City. A new issue every month, built for reading in depth.
```
[125]

### Description (max 4000)
```
The Utah View is an independent publication of global-politics journalism and analysis, based in Salt Lake City and published monthly. The app brings each issue to your phone and iPad in a clean, distraction-free reader built for people who want depth, not noise.

WHAT YOU GET
• A new issue every month: reported features, editorials, and analysis on world affairs.
• Organized the way an editor would arrange a front page: a lead story, Editorial & Opinion, Around the World (The Americas, Europe, Asia-Pacific, the Middle East, and Africa), In This Issue, The Utah Lens, and a Data Brief.
• Search across every story and browse the full archive.

READ YOUR WAY
• Adjustable text size, high-contrast mode, reduced motion, and light and dark themes, all built into the app.
• Listen to any article with read-aloud.
• Save stories to read later. Your saved stories work offline.
• Create a free account (optional), with email or Google, to keep your saved stories in sync across devices.
• Share any story as a link.

STAY CURRENT
• Turn on notifications to know when a new issue or story is published.

ABOUT US
The Utah View is editorially independent. We cover global politics with rigor and clarity, from a Salt Lake City point of view. Reading the app is free, with no ads and no tracking.

Questions or feedback? Email theutahview@gmail.com or visit theutahview.com.
```

### Keywords (max 100, comma-separated, no spaces needed)
```
news,politics,world,global,foreign policy,analysis,magazine,opinion,elections,Salt Lake City,Utah
```
[97]

### URLs
- **Support URL:** https://theutahview.com/page.html?p=Contact
  (the Contact page needs real content first; until then use https://theutahview.com)
- **Marketing URL:** https://theutahview.com
- **Privacy Policy URL:** https://theutahview.com/privacy.html

### What's New (version 1.0.0)
```
The first release of The Utah View for iPhone and iPad.
```

### Copyright
`2026 The Utah View`

## Screenshots
Generated from the real screens with
`flutter test tool/screenshots/app_screenshot_test.dart --plain-name "app store"`:
- **iPhone 6.9"** (1320×2868): `screenshots/iphone-01-home.png` … `iphone-05-more.png`
- **iPad 13"** (2064×2752): `screenshots/ipad-01-home.png` … `ipad-05-more.png`

App Store Connect scales these down for the smaller device sizes. Photos show
the placeholder because the test harness has no network; for nicer shots,
capture on a simulator instead (`xcrun simctl io booted screenshot shot.png`).

## App icon
Comes from the build (`ios/Runner/Assets.xcassets/AppIcon.appiconset`, 1024×1024,
no alpha). Nothing to upload separately.

## Age rating questionnaire
News content covering war and political violence, reported factually:
- Violence (realistic): **Infrequent/Mild**. Everything else (sexual content,
  profanity, drugs, gambling, horror, medical): **None**.
- Unrestricted web access: **No** (links open in the system browser).
- User-generated content, messaging, chat: **No**.
- Expected result: **13+** under Apple's current age ratings (12+ on older
  rating schemes). That's fine for a general-audience news app.

## App Review information
- **Sign-in required:** No. All reading works without an account. Accounts
  only sync saved stories.
- **Demo account:** optional. If you want the reviewer to try sync, create
  `review@theutahview.com` (or similar) with a password and enter it here.
- **Notes:**
  ```
  Reader app for The Utah View, a monthly global-politics publication. No account is required to read. An optional account (email/password or Google) syncs saved stories across devices and can be deleted in the app under More > Delete account. Notifications announce new stories. The app has no ads, no tracking, and no in-app purchases.
  ```
- **Contact:** Ryan Cheng, theutahview@gmail.com, plus a phone number.

## Export compliance
Already answered in the build (`ITSAppUsesNonExemptEncryption = false`: HTTPS only).

## Pricing and availability
Free, all territories (or limit to the U.S. to start).
