# App Store Connect — App Privacy answers

Fill these into **App Store Connect → The Utah View → App Privacy**. They match
`docs/play-store/DATA_SAFETY.md` and https://theutahview.com/privacy.html.

**Do you or your third-party partners collect data from this app?** → **Yes**

| Data type | Linked to the user? | Used for tracking? | Purpose |
|---|---|---|---|
| Contact Info → **Email Address** | Yes | No | App Functionality (account, newsletter) |
| Contact Info → **Name** | Yes | No | App Functionality (account) |
| User Content → **Other User Content** (saved stories, only when signed in) | Yes | No | App Functionality (sync) |
| Identifiers → **Device ID** (Firebase push token) | No | No | App Functionality (notifications) |

Everything else: **not collected** (location, contacts, photos, browsing or
search history, purchases, financial, health, diagnostics, usage data).

- **Tracking:** No. The app has no ads, no analytics and no tracking SDKs, so
  no App Tracking Transparency prompt is needed.
- **Account deletion:** in the app at More → Delete account (Apple requires
  this for apps that let people create accounts).
- **Privacy manifest:** Flutter and the Firebase / Google Sign-In pods ship
  their own `PrivacyInfo.xcprivacy` files. If App Store Connect emails about a
  missing "required reason API" declaration after upload, add a
  `ios/Runner/PrivacyInfo.xcprivacy` listing the reason it names.
