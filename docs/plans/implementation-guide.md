# Prioritized implementation guide

Updated on 2026-11-19 from the current project status. This guide contains steps
for open, deferred and ongoing work; completed outcomes remain in the status
record. Recommendations here do not implement or resolve an item. The existing
contact form remains working, as confirmed by the owner.

## How to use this guide

- **P1 - High:** remove accessibility barriers, misleading navigation or
  misleading interpretation; maintain existing form operations.
- **P2 - Normal:** correct configuration, metadata and editorial issues, or
  deliver requested features after their prerequisites are satisfied.
- **P3 - Later:** optional polish and features with unresolved scope.
- These are recommended priorities, not new implementation decisions. No
  confirmed outage warrants a P0. A blocked P2 does not outrank a ready P1.
- Each item identifies existing files to modify and proposed files to create.
  Conditional files must not be changed unless that branch is actually needed.
  Paths in code spans are repository-relative Windows paths. Linked paths refer
  to existing files; proposed paths are deliberately not links.
- For every completed change, update its ID in [project status](../project-status.md)
  with evidence and date. Update this guide and the relevant feature/R notes if
  the agreed approach changes. Those documentation updates are additional to the
  implementation file lists below.
- Do not hand-edit `public\`, `resources\` or generated programming tables.
  Change their inputs/generators and regenerate. Netlify runs Hugo, not R.
- Preserve historical URLs, the Progetto-only main menu, approved privacy
  decisions and the no-chart-recalculation decision unless separately agreed.

## Priority and dependency overview

| ID | Work | Priority | Prerequisite / scheduling |
| --- | --- | --- | --- |
| [O02](#o02-poster-navigation) | Fix placeholder and unsupported links | Deferred | Resume after poster/database decisions are finalized |
| [O03](#o03-country-and-imdb-reconciliation) | Resolve country-only film ID | P2, deferred | Verified external/poster evidence |
| [O04](#o04-chart-explanations) | Explain chart conventions accurately | Deferred | Resume with a fresh check after the database is finalized |
| [M01](#m01-form-and-privacy-maintenance) | Monitor form, usage and retention | P1, ongoing | Owner/dashboard access |
| [F01](#f01-cinema-image-attachments) | Add optional image attachments | Deferred | Owner prefers email for photos for now |
| [F02](#f02-poster-collection-pilot) | Deliver a poster catalogue pilot | P2, blocked on data | Database, images and agreed identifiers |
| [F03](#f03-film-search) | Add film search | P3 | Agree result model; need not wait for posters |
| [F04](#f04-later-editorial-features) | Timeline, identification, collections | P3, deferred | Choose one feature and its content |
| [F05](#f05-shiny-dashboard-maintenance) | Improve the existing Shiny dashboard | P2, proposed | Agree the next improvement and verification scope |

Continue M01 as routine maintenance. O02/O03/O04 remain deferred until the
poster/database decisions and evidence are ready; F02 is blocked on those
inputs. F01 and F04 remain deferred. For F05, retain the Shiny app and iframe;
agree a specific improvement before changing the app. Use the completed V01
checks recorded in project status for relevant post-change verification.

## O02: Poster navigation

**Status:** DEFERRED on 2026-11-18. The owner chose to keep the current links and
text unchanged until the poster and database decisions are finalized.
**Priority:** Resume after data finalization.
**Depends on:** finalized poster/database content and source evidence. This now
applies to both the interim link cleanup and the full content delivery.

**Files to modify:** [home](../../content/_index.md),
[editorial sitemap](../../content/sitemap.md), and
[Fonti index](../../content/programmazione-storica/fonti/_index.md).
When real screening data change, modify the applicable CSVs in
[static/data](../../static/data/) and regenerate affected annual/source pages.
**Files to create:** none for interim cleanup. In the final phase, proposed
`content\programmazione-storica\fonti\note-sui-manifesti\index.md`; the actual
poster catalogue files belong to F02, not a second parallel implementation here.

**Steps**

1. While content is unavailable, replace the homepage self-link and empty
   sitemap link with clearly labelled non-linked "under construction" text.
   Preserve the invitation to explore existing sections.
2. Replace the unsupported poster-notes category link in the Fonti introduction
   with honest non-linked pending text. Do not remove the other working categories.
   This interim phase can be completed without inventing a source page.
3. When evidence arrives, agree the source page's stable route and metadata.
   Create one page titled `Note sui manifesti`, with that category, an editorial
   introduction and the required generated-table marker from the
   [R guide](../guides/historical-programming.md). Do not invent a historical date merely
   to satisfy the site's dated permalink pattern; use an explicit stable URL
   if appropriate and verify it with Hugo.
4. Add only verified poster-date screening records and their source values.
   The existing source and annual generators already recognize the supported
   poster-notes names and use Hugo references for source links; do not duplicate
   that mapping. Run the existing R workflow after data changes.
5. Confirm the new page has content, the category is generated, and annual-page
   source references reach the correct route. Then restore the relevant links.
   Link Home/sitemap to the actual F02 catalogue only when that catalogue exists.

**Done when:** the interim phase has no misleading destinations; mark the full
item DONE only after the promised source/category/catalogue links are real and
working. Keep the remaining data-dependent phase explicitly open meanwhile.

## F02: Poster collection pilot

**Priority:** P2, currently blocked on inputs. **Depends on:** external database,
representative images, stable identifiers and agreed public metadata.

**Files to modify:** eventually [home](../../content/_index.md) and
[sitemap](../../content/sitemap.md) to link the working catalogue. Existing
screening/source data change only through verified O02/O03 work. The separate
image-conversion project is outside this repository.
**Files to create:** proposed `R\update-manifesti.R`,
`content\manifesti\_index.md`, `content\manifesti\film\<film-id>\index.md`,
`layouts\manifesti\list.html`, `layouts\manifesti\single.html`, and
`layouts\partials\manifesto-card.html`. Approved web derivatives can live under
`static\manifesti\gallery\` and `static\manifesti\large\`.
After the film-page pilot, propose browse indexes under
`content\manifesti\anni\`, `titoli\`, `generi\` and `formati\` as needed.
`data\manifesti.json` is conditional if shared lookup data are needed.
These names are proposals; final files/counts depend on the inspected data.

**Steps**

1. Inspect `manifesti_archivio.csv` outside the project plus examples covering
   local IDs, handmade variants, several formats and front/back scans. Agree
   identifiers, sorting, public fields, formats and rights; do not assume every
   local code is an IMDb ID.
2. In the separate conversion project, inventory originals and generate a small
   sample of uncropped, oriented web derivatives. Keep masters/private metadata
   out of `static\`; compare text readability, dimensions and file sizes.
3. Implement validation before writing pages: unique item/image keys, safe
   paths, readable images, correct dimensions, verified joins, and explicit
   unmatched/ambiguous records. Avoid multiplying posters by screening rows.
4. Generate one film-page pilot for one physical format plus its listing/card.
   Preserve manually written introductions and document every generated output.
   Do not wire this optional pipeline into the mandatory historical updater in
   a way that makes existing updates depend on the external poster database.
5. Verify multiple screenings/variants, no matching screening, missing genre and
   local-ID cases. Link existing source/year pages by verified routes, not guessed
   dated strings. Show all evidence/uncertainty without invented metadata.
6. Only after pilot review, add alphabetical, year, genre and size browse views
   over the same underlying items; the film page holds all versions. Agree
   pagination/filter behavior before scaling to the whole collection.
7. Measure repository/deploy size, page weight, build time and Netlify allowances.
   Check images, phone layout, keyboard access and no-JavaScript browsing on a
   preview. Then publish the real navigation links and document the update flow.

**Done when:** the small pilot is accurate, reproducible and usable with measured
costs. Do not mark the entire catalogue DONE until the agreed browse views,
full import and checks are complete; keep staged progress explicit.

## F03: Film search

**Priority:** P3. **Depends on:** agreed result granularity and search scope;
programming-only search does not require the poster catalogue.

**Files to modify:** [main.css](../../static/css/main.css),
[sitemap](../../content/sitemap.md), and conditionally [home](../../content/_index.md)
for a search link while retaining the Progetto-only top menu.
For the proposed R-index approach, modify
[update-programmazione-storica.R](../../R/update-programmazione-storica.R)
to refresh the index after a successful full data update.
**Files to create:** proposed `R\update-ricerca.R`,
`static\data\ricerca.json`, `content\ricerca.md`,
`layouts\shortcodes\film-search.html`, and `static\js\film-search.js`.
This is one proposed approach; a Hugo-built JSON index is an alternative, not
an additional index to maintain in parallel.

**Steps**

1. Agree whether each result is a film, screening or poster, what fields are
   searchable, Italian/original titles, partial matches, accents and case.
   For a film-level model, retain all relevant screenings without one result per
   row. Release year and screening year must remain distinct.
2. Build the public index from validated CSV joins, using stable film IDs and
   actual page destinations. Exclude private form submissions. Measure index
   size and choose a page-weight/response target before selecting extra libraries.
3. Choose one generation route. A small R generator fits the existing local
   workflow; commit its generated JSON because Netlify will not run R. Document
   how partial data updates refresh it, avoiding a stale search index.
4. Create an accessible Italian search page/shortcode and client script with
   loading, empty-query, no-results and failure states. Render text safely and
   resolve result links to actual pages. Keep existing browse links as the
   no-JavaScript alternative; do not imply client search works with JS disabled.
5. Test accents/case, partial titles, ambiguous titles with distinct IDs, repeated
   screenings, missing metadata, failed JSON loading and keyboard use. Measure
   the agreed targets on a representative mobile device/network.
6. Add the page to the editorial sitemap and chosen discovery point, and verify
   a subsequent data refresh updates results predictably.

**Done when:** agreed queries return the right result shapes/destinations, errors
are explicit, index freshness is reproducible and the performance target passes.