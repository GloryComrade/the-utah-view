# Backend & data flow — how every part works

This documents the backend the app talks to and how the app consumes it, end
to end. It was verified live against the production backend on
**2026-10-06** (`dart run tool/verify_api.dart`, plus raw `curl` probes).

> **Scope note.** The backend is a Cloudflare Worker that is already deployed
> and is **not** part of this repository — the brief said not to modify it, and
> its source code isn't available here. So this file documents the Worker's
> **observed HTTP contract and behavior** (what it accepts and returns), not
> its internal source lines. Everything marked "Observed" was captured from
> the live service; anything marked "Inferred" is a reasonable deduction from
> that behavior.

---

## 1. Is it really the Cloudflare backend? Yes.

Every response to `https://api.theutahview.com` comes back through Cloudflare:

```
$ curl -sD- https://api.theutahview.com/api/stories
HTTP/2 200
content-type: application/json
server: cloudflare              <- served by Cloudflare's edge
cf-ray: a4684df1ea428766-MCI    <- Cloudflare ray id; MCI = Kansas City edge
access-control-allow-origin: *
```

- **`server: cloudflare`** and the **`cf-ray`** header are added by Cloudflare's
  edge — a dead giveaway that this is a Cloudflare Worker.
- **Observed:** there is **no `cf-cache-status` header and no `cache-control`**,
  so the edge does **not** cache these responses. Every request runs the
  Worker and reads from D1. (Inferred: this is why the app keeps its own
  on-device cache — see §4.)
- The app only ever uses this one host. It is hard-coded in one place:
  [`lib/core/api/api_config.dart`](../lib/core/api/api_config.dart) →
  `baseUrl = 'https://api.theutahview.com'`. There is no other server, and
  the app creates none.

**Architecture (as described in the brief + observed behavior):**

```
 The Utah View app  ──HTTPS──▶  Cloudflare Worker  ──▶  D1 (SQLite) database
 (iOS / Android / web)          (api.theutahview.com)   (stories, config, pages,
                                                          subscribers)
```

The same Worker + D1 also powers the website (theutahview.com). The app is
just a second client of the identical API.

---

## 2. Every endpoint (observed contract)

All endpoints are public except `/api/me`. All return JSON. Dates are
`YYYY-MM-DD` strings. The app's wrappers for these live in
[`lib/core/api/news_repository.dart`](../lib/core/api/news_repository.dart)
and the parsers in
[`lib/core/api/parsers.dart`](../lib/core/api/parsers.dart).

### GET /api/stories
- **Returns:** `{ "stories": [ { id, title, author, region, summary, read_time, date } ] }`
- **Observed:** 200, 62 published stories, newest first, **no `body` field** in
  the list. Regions seen: The Americas 16, Asia-Pacific 17, Europe 10, Middle
  East 8, Africa 6, Global 3, The Utah Lens 2.
- **Inferred:** the Worker runs something like
  `SELECT … FROM stories WHERE status='published' ORDER BY date DESC`.
- **App use:** the master story list. Cached, and used to resolve every
  layout id and to power Search.

### GET /api/stories?region=Europe
- **Returns:** the same list shape, filtered server-side to that exact region.
- **Observed:** `?region=Europe` → 10 stories, all region `Europe`.
- **App use:** used by `verify_api.dart` to cross-check the client-side
  category filter. The app's Sections tab filters the already-cached full
  list (so it works offline); the server filter is the source of truth it's
  checked against.

### GET /api/stories/{id}
- **Returns:** the full story:
  `{ id, title, author, region, status, summary, body, read_time, date, created_at, updated_at, created_by, updated_by }`.
  `body` is HTML.
- **Observed:** 200 with `status: "published"`; the HTML body uses the tags
  `p, h3-ish, strong/b, em, img, blockquote, ul, ol, br, div, span`. (The CMS
  pastes Google-Docs markup, so `div`/`span` with inline styles appear — the
  app strips those, see §5.) `created_by`/`updated_by` are editor emails the
  app ignores.
- **Observed (missing id):** `GET /api/stories/this-does-not-exist` →
  **404** `{"error":"Not found"}`.
- **App use:** the Article screen. Cached per id, and the full JSON is also
  stored when you bookmark, so saved stories open offline.

### GET /api/config/layout
- **Returns:** `{ "value": { ticker, hero_image, hero_center_caption,
  hero_lead, hero_secondary, hero_center, hero_right:[ids], editorial:[ids],
  regions:{name:id}, featured:[ids], sidebar_utah:[ids], sidebar_data:[ids] } }`.
- **Observed:** 200. Every story reference is an **id** into the stories list.
  Live values resolve to: hero_lead 1, hero_right 3, editorial 3, regions 5,
  featured 4, sidebar_utah 2, sidebar_data 0.
- **Inferred:** a key/value config row in D1 (`value` holds the JSON blob);
  the editor dashboard writes it.
- **App use:** the Home front page. Ids that point at unpublished/deleted
  stories are skipped silently; if the lead is unpublished the next placed
  story is promoted; if this call fails entirely Home falls back to
  newest-first. (`lib/features/home/home_feed.dart`.)

### GET /api/config/site
- **Returns:** `{ "value": { sub_overline, sub_heading, sub_desc, copyright,
  footer_cols, about_text, about_url, nav_categories? } }`.
- **Observed:** 200. In production **`nav_categories` is absent**, so the app
  (and website) use the built-in list: The Americas, Europe, Asia-Pacific,
  Middle East, Africa, and the sections Analysis, Opinion, Data.
- **App use:** the subscribe-card copy, the footer/copyright, and (when
  present) the navigation categories.

### GET /api/pages  and  GET /api/pages/{slug}
- **List returns:** `{ "pages": [ { slug, title, subtitle } ] }`.
- **Detail returns:** `{ slug, title, subtitle, body }` (HTML body).
- **Observed:** list has 8 pages. `our-mission` → 200. **`About Us` → 404**
  for every URL-encoding — a backend bug (the slug has a space/capitals the
  route handler doesn't match). The app shows "Not available yet" for it; the
  website's About Us link is broken the same way. See
  [BACKEND_NOTES.md](BACKEND_NOTES.md).
- **App use:** the More tab's About pages.

### POST /api/subscribe  /  POST /api/unsubscribe
- **Body:** `{ "email": "…" }`.
- **subscribe returns:** `{ "message": "Subscribed" }` or
  `{ "message": "Already subscribed" }`.
- **Observed (safely):** the **CORS preflight** `OPTIONS /api/subscribe` →
  200 with `access-control-allow-methods: GET, POST, PUT, DELETE, OPTIONS`.
  The actual POST was **not** exercised against production to avoid writing a
  junk email into the real subscriber list; it's covered by tests against a
  fake server (`test/core/news_repository_test.dart`).
- **App use:** the subscribe card (Home + More) and the unsubscribe dialog
  (More).

### GET /api/me  (Phase 2 only)
- **Observed:** with no token → **401** `{"error":"Authentication required"}`.
- **Contract:** accepts a Google ID token as `Authorization: Bearer <token>`
  and identifies the user (returns a role). The app wires this
  (`ApiClient.getMe`) but **does not call it in v1** — there's no sign-in yet.
  See [PHASE2.md](PHASE2.md). Note: it only *identifies* a user; there is no
  server storage for bookmarks yet.

### CORS (for the web build)
- **Observed:** `access-control-allow-origin: *`,
  `access-control-allow-headers: Content-Type, Authorization, X-User-Email`,
  `access-control-allow-methods: GET, POST, PUT, DELETE, OPTIONS` on every
  response. That's why the Flutter **web** build can call the API from a
  browser. (Native iOS/Android don't need CORS.)

---

## 3. Status codes & errors the app handles

| What happens | Backend | App behavior |
|---|---|---|
| Normal read | `200` + JSON | parse, show, cache |
| Unknown story / page | `404 {"error":"Not found"}` | "Not available" screen; does **not** retry |
| `/api/me` without token | `401` | n/a in v1 (Phase 2) |
| Server error | `5xx` | "Something went wrong", retry with backoff |
| No network / DNS fail | (connection error) | show cached copy; "You're offline" |
| Timeout | (slow) | retry with backoff, then cached copy |
| Malformed JSON | 200 but junk | keep last good cached copy, never overwrite it |

Classification is in
[`lib/core/api/api_client.dart`](../lib/core/api/api_client.dart)
(`ApiException` + `ApiErrorKind`). Retry policy (transient failures only, with
exponential backoff; never retries 404/bad-JSON) is `apiRetry` in
[`lib/core/api/providers.dart`](../lib/core/api/providers.dart).

---

## 4. How the app consumes the backend (data flow)

```
Screen (Riverpod ConsumerWidget)
   │ watches
   ▼
Provider  (storiesProvider, layoutProvider, siteConfigProvider,
   │        pagesProvider, storyDetailProvider, sitePageProvider)
   │  — stale-while-revalidate: returns cached value instantly,
   │    then refreshes in the background
   ▼
NewsRepository.fetch(endpoint)        NewsRepository.cached(endpoint)
   │ dio GET                              │ read last-good JSON
   ▼                                      ▼
ApiClient (dio)  ──HTTPS──▶  Cloudflare Worker  ──▶  D1
   │ raw JSON                              ▲
   ▼                                       │
parsers.dart  → freezed models            │
   │ (lenient: missing/null/wrong-type     │
   │  fields become safe defaults)         │
   └── write raw JSON to Hive  ────────────┘  (local cache: box "api_cache")
```

Key behaviors, all verified by tests:

1. **Cache-first (instant + offline).** Every endpoint provider returns the
   Hive-cached copy synchronously on the first frame, then fetches fresh data
   and swaps it in only if it changed. So the app opens instantly and works
   with no network, then quietly updates. Pull-to-refresh forces a fetch.
2. **A bad response never breaks the app.** The response is parsed *before*
   it's cached, so malformed JSON can't overwrite a good cached copy. Missing,
   `null`, or wrong-type fields become empty defaults (lenient converters in
   `lib/core/api/models/json_converters.dart`).
3. **Dangling ids are safe.** Layout references to unpublished stories resolve
   to nothing (`StoryIndex`), so the front page never shows a blank card.
4. **Saved = fully offline.** Bookmarking stores the whole story JSON locally
   (box `saved_stories`), so saved articles read with no network.
5. **Search is on-device.** There is no search endpoint; the app searches the
   cached story list (`lib/core/domain/story_search.dart`).

Local storage (Hive) boxes: `api_cache` (raw responses), `saved_stories`
(bookmarked full stories), `settings` (theme, text size, recent searches).
None of it leaves the device.

---

## 5. Content/HTML handling

Story and page bodies are HTML authored in a CMS that pastes Google-Docs
markup (inline `style=` on `div`/`span`, forcing white backgrounds and fixed
colors). The app **sanitizes** this (`lib/shared/widgets/article_body.dart`):
strips inline styles/classes and empty paragraphs, then re-styles everything
to the app's type scale — so dark mode and the reader's text-size setting
work. Images in bodies are resolved to absolute URLs and shown with the
gradient placeholder.

---

## 6. Verifying the backend yourself

```sh
# Full parse of every live endpoint through the app's own models:
dart run tool/verify_api.dart

# Refresh the test fixtures from live data:
dart run tool/verify_api.dart --fixtures

# Raw contract check (headers, status codes):
curl -sD- https://api.theutahview.com/api/stories | head
curl -s -o /dev/null -w "%{http_code}\n" https://api.theutahview.com/api/stories/nope   # 404
```

The offline test suite (`flutter test`) exercises the same parsing and the
error/caching behavior against captured fixtures and a fake HTTP server, so
it runs with no network.

---

## 7. Known backend issues (surfaced, not fixed — it's your Worker)

Full list in [BACKEND_NOTES.md](BACKEND_NOTES.md). The ones readers see:

1. **`About Us` page returns 404** for every slug encoding (route doesn't
   match the slug's space/capitals). Rename the slug to `about-us`, or
   `decodeURIComponent` the slug in the Worker.
2. **A test post is live** (`we-are-charlieeee-kirrkkk…`, region Global) and
   shows up in Archive, the section lists and search. Unpublish it if
   unintended.
3. **Contact page is placeholder** (`<p>Start writing...</p>`) — Google Play's
   news policy wants real publisher contact info reachable in the app.
4. **Security check (unverified):** CORS allows an `X-User-Email` header. If
   any write endpoint trusts that header instead of the Google ID token, it
   can be spoofed. Worth a look at the Worker's auth before Phase 2.
