# Play Console — Data safety form answers

Fill these into Play Console → **Policy → App content → Data safety**. Answers
reflect what the app actually does: an optional email/password account that syncs
saved stories (or Google sign-in for the same account), a newsletter email signup,
and Firebase Cloud Messaging for push.

## Overview questions
- **Does your app collect or share any of the required user data types?** → **Yes**
- **Is all of the user data collected by your app encrypted in transit?** → **Yes** (all API traffic is HTTPS/TLS).
- **Do you provide a way for users to request that their data is deleted?** → **Yes** — in-app (More → Delete account) and on the web. **Delete account URL:** https://theutahview.com/delete-account.html

## Data types collected

### 1) Personal info → Email address
- **Collected:** Yes · **Shared:** No
- **Processing:** Not ephemeral (stored)
- **Required or optional:** Optional (only if the user creates an account or subscribes to the newsletter)
- **Purposes:** Account management; App functionality (newsletter delivery)

### 1b) Personal info → Name
- **Collected:** Yes · **Shared:** No
- **Required or optional:** Optional (the name a reader types when creating an
  account, or the name on their Google account if they sign in with Google)
- **Purposes:** Account management

### 2) App activity → App interactions / user-generated content (saved stories)
- **Collected:** Yes (only when signed in — saved-story bookmarks sync to the account) · **Shared:** No
- **Required or optional:** Optional
- **Purposes:** App functionality (sync saved stories across devices)

### 3) Device or other IDs → Device or other identifiers
- **Collected:** Yes · **Shared:** No
- **Required or optional:** Optional (only if the user enables notifications)
- **Purposes:** App functionality (push notifications for new issues, via Firebase Cloud Messaging)
- Note: handled by Google Firebase as a service provider; used to deliver notifications, not for advertising.

## NOT collected (leave unchecked)
- Location, financial info, health, contacts, calendar, SMS/call logs, photos/videos, audio, browsing history.
- No advertising or third-party marketing use. Data is **not sold** and **not shared** for ads.
- Analytics/Crashlytics are **not** enabled (the app uses only Firebase Core + Firebase Cloud Messaging).

## Google sign-in
Signing in with Google sends the app the reader's Google email, name and
profile photo URL; the backend keeps the email and name. Those are covered by
"Email address" and "Name" above. Google acts as the sign-in provider, which
does not count as "sharing" in the Data safety form.

## Passwords
Account passwords are transmitted over HTTPS and stored only as salted hashes on the
backend (never in plaintext). In the form, password handling falls under
"Account management" above — Play does not have a separate "password" data type.
