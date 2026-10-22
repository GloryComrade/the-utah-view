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
| 5 | Loading placeholders | Pulsing grey bars while stories load (no pulse under reduce motion) | |
| 6 | Briefing: tap to see all | Keep the scrolling Briefing bar; tapping opens the full list | |
| 7 | Listen (read aloud) | Browser speech; play/pause/stop | |
| 8 | Search | Find stories by headline, author or region as you type | |
| 9 | Smooth page changes | Quick fade (about 0.25s); browsers without support load normally | |
| 10 | Shrinking masthead | **Computers only**; phones keep the header as it is | |
| 11 | Dark mode | Follows the device setting, plus a sun/moon switch in the top bar | |

Not wanted (for now): the accessibility panel.

Respect `prefers-reduced-motion` for every animation.
