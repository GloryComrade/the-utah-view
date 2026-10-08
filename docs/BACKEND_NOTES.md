# Notes on the live API and content

Found while building and verifying the app against `api.theutahview.com` on
October 6, 2026 (`dart run tool/verify_api.dart`). The backend was not
changed. The app handles every item below gracefully, but each one is
visible to readers, so they are worth fixing at the source.

## Fix soon (readers see these)

1. **The "About Us" page can't be fetched.** `GET /api/pages` lists slug
   `About Us`, but `GET /api/pages/About%20Us` (and every other encoding)
   returns 404. The Worker appears to compare the still-encoded path to the
   slug. Fix either way: `decodeURIComponent` the slug in the route handler,
   or rename the slug to `about-us` and update the footer link. The app shows
   "Not available yet" for it, and the website's About Us link has the same
   problem.
2. **A test post is live and newest.** Story
   `we-are-charlieeee-kirrkkkkkkkkkkkkkkkkk` ("WE ARE CHARLIEEEE KIRRKKK…",
   region Global, `read_time` "Charlie Kirk") is published. Because it's
   Global, it appears in Archive, Analysis, Opinion, Data and search. The app
   hides the bogus read time, but the story itself shows. Unpublish it if it
   isn't intentional.
3. **The Contact page is placeholder text** (`<p>Start writing...</p>`).
   Google Play's news policy expects publisher contact details in the app,
   so this matters for the store review.

## Worth knowing

4. `editorial-team` (named in the website's default footer) doesn't exist
   (404). The app lists only what `/api/pages` returns, so nothing breaks.
5. `site.nav_categories` is missing, so both the app and the website use
   the built-in list (The Americas … Data).
6. No story has region Analysis, Opinion or Data, so those three sections
   all show the same 5 Global + Utah Lens stories. That matches the website's
   rule.
7. `layout.sidebar_data` is empty, so "Data Brief" is hidden (as on the
   site).
8. Story bodies contain pasted Google Docs markup (`div`/`span` with inline
   styles). The app strips inline styles so dark mode and text size work.
   Cleaner HTML from the editor would help the website as well.
9. The hero image is hot-linked from NPR's CDN. Hosting images under
   `api.theutahview.com/images/` avoids broken images and licensing
   questions. (It also fixes the browser preview: that CDN sends no CORS
   headers.)

## Suggestions

10. **Per-story images.** The stories list has no image field; only the
    layout's single `hero_image` exists. An optional `image` (and
    `image_alt`) per story would allow WSJ-style thumbnails throughout. The
    app change is small.
11. **Saved-story sync** needs new endpoints (`/api/me` only identifies the
    user). See docs/PHASE2.md.
12. **Security check, not verified:** CORS allows an `X-User-Email` request
    header. If any write endpoint trusts that header instead of verifying
    the Google ID token, it can be spoofed by anyone. Worth a quick look at
    the Worker's auth.
