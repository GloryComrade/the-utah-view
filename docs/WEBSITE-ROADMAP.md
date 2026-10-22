# Website roadmap — bringing later features to the static site

Agreed with Ryan on 2026-10-22. **Keep the current website design** (the
restored May 2026 static site in `site/`: Georgia/Helvetica, red `#C4352A`,
the new logo) and add animations and features from the later Flutter versions
**one at a time**. Restyle each to match the site's look.

**Website only.** The iOS/Android app is not changed by any of this.

## Process for each item
1. Build it in `site/` only.
2. Deploy a preview (`--branch=<feature>` → `<feature>.the-utah-view.pages.dev`).
3. Send Ryan the preview link and screenshots.
4. Deploy to production (`--branch=main`) only after he says yes. Then move to
   the next item.

## Order (small wins first)
| # | Feature | Decisions | Status |
|---|---------|-----------|--------|
| 1 | Reading progress bar | 3px bar in the site red, pinned to the top of the window; full at the end of the article text | **Live** 2026-10-22 |
| 2 | Styled quotes & captions | Pull quotes large italic with a red rule (back-to-back quote blocks joined on display; writer's bold kept); small grey captions under in-article photos | **Live** 2026-10-22 |
| 3 | Lead photo + credit | Story's lead image after the headline/byline, text-column width, max 560px tall (cropped toward the top); caption + italic credit | **Live** 2026-10-22 |
| 4 | Text size A− / A+ | A−/A+ buttons in the byline row; five steps (88–140%) like the app; scales paragraphs, subheads, pull quotes, lists; remembered between visits | **Live** 2026-10-22 |
| 5 | Loading placeholders | Pulsing light-grey bars shaped like the homepage grid, list views, article and static pages while they load (no pulse under reduce motion) | **Live** 2026-10-22 |
| 6 | Briefing: tap to see all | Scrolling bar kept, with a "See all ›" hint; tap/Enter opens the full list (panel on desktop, bottom sheet on phones; Esc/×/outside closes); a blank briefing hides the bar. Bar shrunk to 34px. Editor: headlines one per line, plus website bar height (Slim 27 / Normal 34 / Tall 44px) and scroll speed (Slow 45s / Normal 30s / Fast 20s), saved as `ticker_height` / `ticker_speed` in the layout (the app ignores them) | **Live** 2026-10-22 |
| 7 | Listen (read aloud) | Browser speech (Web Speech API, en-US local voice preferred): ▶ Listen / ❚❚ Pause / ▶ Resume / ■ Stop in the byline row; reads headline, summary, then the text (no captions) in ≤~240-char pieces split at sentence ends, not abbreviations; hidden where unsupported; stops on leaving the page | **Live** 2026-10-22 |
| 8 | Search | Shared `site/search.js`: "Search" in the top bar (magnifier only on phones) or the / key opens a panel; results as you type, same rules as the app (every word in headline/author/region/summary, accents ignored, headline matches first, then newest); highlighted words; ↑↓ + Enter; Esc/×/outside closes; full screen on phones | **Live** 2026-10-22 |
| 9 | Smooth page changes | CSS cross-document view transitions (`@view-transition`) on all five public pages: 0.25s cross-fade; Chrome/Edge 126+ and Safari 18.2+ fade, others (Firefox) load normally; off under reduce motion | **Live** 2026-10-22 |
| 10 | Shrinking masthead | **Computers only**; phones keep the header as it is | |
| 11 | Dark mode | Follows the device setting, plus a sun/moon switch in the top bar | |

Not wanted (for now): the accessibility panel.

Respect `prefers-reduced-motion` for every animation.
