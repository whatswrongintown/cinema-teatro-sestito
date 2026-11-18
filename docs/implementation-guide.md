# Prioritized implementation guide

Prepared on 2026-11-17 from [project status](project-status.txt), with next-task
and Shiny-source findings added on 2026-11-18. This guide covers
the open, deferred and ongoing items, plus the owner's decision on O06.
It describes future work; writing the guide does not implement or resolve it.
The existing contact form remains working, as confirmed by the owner.

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
- For every completed change, update its ID in [project status](project-status.txt)
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
| [O01](#o01-robots-configuration) | Reconcile robots output | Done | Local builds and live response verified |
| [O02](#o02-poster-navigation) | Fix placeholder and unsupported links | Deferred | Resume after poster/database decisions are finalized |
| [O03](#o03-country-and-imdb-reconciliation) | Resolve country-only film ID | P2, deferred | Verified external/poster evidence |
| [O04](#o04-chart-explanations) | Explain chart conventions accurately | Deferred | Resume with a fresh check after the database is finalized |
| [O05](#o05-lightbox-keyboard-accessibility) | Make lightbox keyboard-accessible | Done | Build and integrated-browser checks passed on 2026-11-18 |
| [O06](#o06-visible-focus) | Existing navigation focus styles | Closed | Owner chose to keep current styles |
| [O07](#o07-image-alternatives) | Improve logo/gallery alternatives | P2 | Editorial descriptions; coordinate with O05 |
| [O08](#o08-localization-and-taxonomies) | Localize and improve taxonomy browsing | Done | Reading time updated; current dates/taxonomies accepted 2026-11-18 |
| [V01](#v01-rendering-and-interaction-checks) | Build and interaction verification | P1 | Baseline first; repeat after affected changes |
| [V02](#v02-sitemap-lastmod) | Verify sitemap dates | Done | Explicit editorial dates only; verified on 2026-11-18 |
| [V03](#v03-footer-github-link) | Verify footer repository destination | Done | Normalized URL built and returned HTTP 200 on 2026-11-18 |
| [P01](#p01-short-breadcrumb-labels) | Shorten selected breadcrumb labels | Done | Four programming section labels verified 2026-11-18 |
| [P02](#p02-lightbox-asset-placement) | Normalize lightbox asset loading | Done | Head placement and portable URLs verified 2026-11-18 |
| [M01](#m01-form-and-privacy-maintenance) | Monitor form, usage and retention | P1, ongoing | Owner/dashboard access |
| [F01](#f01-cinema-image-attachments) | Add optional image attachments | Deferred | Owner prefers email for photos for now |
| [F02](#f02-poster-collection-pilot) | Deliver a poster catalogue pilot | P2, blocked on data | Database, images and agreed identifiers |
| [F03](#f03-film-search) | Add film search | P3 | Agree result model; need not wait for posters |
| [F04](#f04-later-editorial-features) | Timeline, identification, collections | P3, deferred | Choose one feature and its content |
| [F05](#f05-integrated-programming-dashboard) | Integrate the database explorer | P2, proposed | Agree pilot, filter/count/ranking rules and performance targets |

Suggested order: run a V01 baseline and continue M01; then address the
remaining ready P2 checks/corrections. F01 is deferred in favor of email for
photos, not a repair of a broken text form. On 2026-11-18, the owner also
deferred all of O02 and O04 until the poster/database work is finalized. Begin
O02, O03, O04 and F02 when the necessary source data arrive. Run V01 again for
affected page types after each implementation batch. P3 work can stay deferred.

### Easiest next task (2026-11-18)

The logo-only part of O07 was completed on 2026-11-18: `avatar` in
[config.yaml](../config.yaml) is now `Cinema Teatro Sestito - Home`. The existing
[navigation template](../layouts/partials/nav.html) uses that configured alt text,
and a Hugo 0.136.5 build confirmed the rendered image alt and home-link name.
This is partial O07 progress, not completion of the gallery alternatives.

For an entire standalone open check, **V02** is a relatively small investigation:
build and inspect representative sitemap dates before deciding whether any
correction is necessary. It is not a known one-line fix. O02/O04 remain deferred,
V03/O05 are already done, and a complete native dashboard is a larger feature.
Within F05, the smallest useful slice is the year selector, two counts and entry
table described below, not all of Shiny at once. These are recommendations only;
this documentation update does not implement any of them.

## O01: Robots configuration

**Status:** DONE. The live `/robots.txt` initially returned HTTP 404 on 2026-11-17.
[config.yaml](../config.yaml) now enables Hugo's built-in robots output;
production and preview builds using Hugo 0.136.5 both generated `User-agent: *`
with no disallow rules. The production build also generated `sitemap.xml`.
The earlier audit's claim that robots.txt was added is historical and does not
describe the earlier source or live response. After deployment on 2026-11-17,
the public `/robots.txt` returned HTTP 200 and `User-agent: *`, with no disallow
rules. A robots file does not guarantee indexing or search-result sitelinks.

## O02: Poster navigation

**Status:** DEFERRED on 2026-11-18. The owner chose to keep the current links and
text unchanged until the poster and database decisions are finalized.
**Priority:** Resume after data finalization.
**Depends on:** finalized poster/database content and source evidence. This now
applies to both the interim link cleanup and the full content delivery.

**Files to modify:** [home](../content/_index.md),
[editorial sitemap](../content/sitemap.md), and
[Fonti index](../content/programmazione-storica/fonti/_index.md).
When real screening data change, modify the applicable CSVs in
[static/data](../static/data/) and regenerate affected annual/source pages.
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
   [R guide](historical-programming.md). Do not invent a historical date merely
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

## O03: Country and IMDb reconciliation

**Priority:** P2, currently deferred. **Depends on:** reliable evidence for `tt0052704`.

**Files to modify:** [country CSV](../static/data/programmazione_paesi.csv)
and/or [IMDb CSV](../static/data/programmazione_imdb.csv), depending on the finding.
Modify [screenings CSV](../static/data/programmazione_agende.csv) only if its
records are independently shown to need correction.
**Files to create:** none required. Existing generated pages/charts may be
rewritten, or new ones generated, only if the corrected data require them.

**Steps**

1. Locate the country-only row and verify that the mismatch still exists.
   Check for whitespace, duplicate identifiers and an identifier transcription error.
2. Compare its film against the real poster database and reliable film evidence.
   Determine whether this is an extra valid country record, a wrong ID, or a
   film that genuinely needs an IMDb metadata record.
3. Choose and document the evidence-backed correction. Do not delete the row,
   fabricate metadata, or substitute a plausible match just to equalize counts.
   An intentionally unmatched record can remain deferred with a clear reason.
4. If data change, run the existing full historical-programming updater locally.
   Review resulting page/chart changes and unexpected stale-page warnings.
5. Recheck identifier uniqueness and screening-to-IMDb coverage. If an intentional
   exception remains, document that exact exception rather than claiming no mismatch.

**Done when:** every affected ID has a verified interpretation and the resulting
joins/pages are correct, or an explicitly approved unmatched-record policy exists.
Otherwise retain DEFERRED; no generator rewrite is assumed.

## O04: Chart explanations

**Status:** DEFERRED on 2026-11-18 until the database is finalized.
**Priority:** Resume with a fresh read-only analysis after data finalization.
**Depends on:** the finalized database and a fresh check of the chart code.

**Files to modify:** the
[methodology article](../content/articoli/2026-11-11-metodologia-ricostruzione-programmazione/index.md)
and [genre introduction](../content/programmazione-storica/generi/_index.md).
Conditionally clarify the [year](../content/programmazione-storica/anni/_index.md),
[source](../content/programmazione-storica/fonti/_index.md) and
[country](../content/programmazione-storica/paesi-di-produzione/_index.md)
introductions if their units remain misleading.
**Files to create:** none.

**Steps**

1. Read the relevant functions in [update-indici.R](../R/update-indici.R) and
   verify the current meaning of expanded genre rows, missing genres and
   country/source associations. Recompute explanatory counts read-only if
   numbers will be published; do not blindly copy the earlier snapshot.
2. Explain that repeated Drammatico-only entries can be excluded by the current
   genre filter; correct the claim that only multi-genre films are affected.
3. Explain how missing genres affect the denominator and adult-share calculation.
   Distinguish "not classified as adult by this calculation" from proof that a
   film is not an adult film.
4. Keep dated-entry, source-association and coproduction explanations consistent
   across introductions and methodology. Preserve the existing historical caveats.
5. Preview the Italian wording with the charts. Check that the edit changes
   explanations only, not R calculations, CSVs, generated tables or chart images.

**Done when:** the text accurately describes the existing calculations and all
newly stated counts have a reproducible basis. Recalculation requires a separate
decision and is not the solution planned here.

## O05: Lightbox keyboard accessibility

**Status:** DONE on 2026-11-18 for the image lightbox currently used by the site.
No YouTube or Vimeo link exists in current content; dormant handlers remain but
were not represented as live-content verification.
**Priority:** P1. **Depends on:** none; coordinate descriptions with O07.

**Files to modify:** [lightbox.js](../static/js/lightbox.js) and
[lightbox.css](../static/css/lightbox.css).
**Files to create:** none required; reuse the current lightbox rather than add a
new library or parallel viewer.

**Steps**

1. Trace image, YouTube and Vimeo opening paths and the shared gallery handling.
   All three paths currently construct controls; fixing only the image branch
   would leave the others inconsistent.
2. Use real buttons with Italian accessible names for close/previous/next.
   Add suitable dialog labelling and modal semantics. Update CSS selectors and
   click handling so they match the new controls and do not close on every
   interaction inside the dialog.
3. Remember the opener, move focus into the viewer when opened, constrain modal
   keyboard focus, and make the background unavailable while the modal is open.
   Preserve pointer navigation and single-image/no-JavaScript link behavior.
4. Add Escape to close and restore focus to the opener. Keep focus stable when
   gallery navigation replaces viewer content; avoid accumulating event handlers.
   Ensure embedded video controls remain operable and video stops on closure.
5. Test Tab/Shift+Tab, Enter/Space, Escape, first/last wrapping, single-image and
   repeated open/close sequences. Inspect screen-reader names and include the
   video paths wherever they are used.

**Done when:** a keyboard-only visitor can open, navigate and close the viewer
without losing focus or entering the obscured page, while mouse/video behavior
and ordinary image links still work.

**Verification:** Hugo 0.136.5 built successfully. A local VS Code integrated
browser preview checked labelled dialog controls, inert background, focus
containment/restoration, Escape and button closing, previous/next navigation,
repeated open/close cycles, and JPEG/PNG/WebP galleries without page errors.
The close control was also checked at a 425-by-443 viewport so both diagonal
strokes remain fully inside the visible button. The owner subsequently
confirmed the corrected implementation worked in a local `serve_site()` preview.

## O06: Visible focus

**Closed 2026-11-17:** The owner chose to retain the existing navigation focus
styles generally, then requested a thinner green breadcrumb underline and the
content links' green hover/focus highlight. The stylesheet removes default link outlines
and does not provide a distinct focus style for the logo or main menu; closing
this item does not mean all links have a visible keyboard focus indicator.
Lightbox keyboard accessibility remains a separate open item (O05).

## O07: Image alternatives

**Priority:** P2. **Depends on:** owner/editor descriptions of the scans.
**Progress:** The logo-only portion was completed on 2026-11-18. The image-only
home link now uses the meaningful Italian name `Cinema Teatro Sestito - Home`.
On 2026-11-18, the owner narrowed the remaining gallery scope: describe
editorial images with distinct subjects individually; for repetitive
programming-source scans, use a concise page-level alternative and retain the
existing filename fallback where a more specific description is unavailable.
The shortcode and lightbox support are implemented. The four-image Settimana
Incom gallery is the initial pilot and awaits editorial review; other galleries
also remain to be reviewed. On 2026-11-18, the owner confirmed that the pilot
works correctly in a local `serve_site()` preview.

Descriptions belong in the front matter of the Markdown page that invokes the
shortcode. The shortcode continues to receive `gallery_dir`, read the actual
files from that directory and locate the relevant metadata for the current page.
No image file is renamed and there is no separate global description catalogue.
This keeps editorial text beside the content it describes and allows reused
images to receive context appropriate to each page.

Proposed shape:

```yaml
galleryDescriptions:
  /images/example-gallery:
    pageAlt: "Scansioni del calendario conservato nell'archivio Sestito."
    images:
      example_03.png:
        alt: "Retro del documento con un'annotazione manoscritta."
```

**Files modified for the mechanism/pilot:**
[image-gallery.html](../layouts/shortcodes/image-gallery.html),
[lightbox.js](../static/js/lightbox.js), and the front matter of pages that use
the gallery. [config.yaml](../config.yaml) needed no further change because the
logo alternative was completed separately. Additional editorial pages will be
modified only as their descriptions are reviewed.
**Files created:** the review-only pilot note
[o07-image-description-test.md](o07-image-description-test.md).

**Steps**

1. Give the home-logo link a meaningful Italian accessible name through its
   existing configurable alt text; do not keep "avatar" as its purpose.
2. Define a small editorial mapping in the invoking page's front matter. Use a
   page-level alternative for repetitive source-series scans and image-specific
   entries only for distinct editorial subjects. Identify reused galleries.
3. The existing shortcode now uses that mapping with the agreed fallback order.
   Unreviewed images keep their filenames and are recorded as fallbacks rather
   than represented as finished descriptions.
4. Preserve descriptions through the lightbox: its current initialization
   replaces some link titles with filenames. Read the selected description
   rather than overwriting it, and keep thumbnail, viewer and caption roles
   distinct. An individual description takes precedence over the page-level
   description, which takes precedence over the filename fallback.
5. For source pages whose editorial prefix is preserved, keep descriptions before
   the generated-table marker. If any target page is fully generated, modify its
   authoritative generator instead of manually editing output.
6. Test filenames with spaces/dots, reused scans and special characters.
   Build all galleries and inspect descriptions with a screen reader. Do not
   redo already descriptive programming charts merely for coverage. Do not
   require hundreds of near-identical source pages to invent unique prose.

**Done when:** reviewed editorial images use accurate distinct alternatives;
repetitive source series use concise page-level alternatives; the lightbox
preserves them; and remaining fallbacks are explicit rather than represented as
finished editorial descriptions. Record any unconverted gallery rather than
declaring it all done.

## O08: Localization and taxonomies

**Status:** DONE on 2026-11-18.
**Priority:** P2. **Depends on:** an agreed policy for duplicate taxonomy views.
**Progress:** On 2026-11-18, article reading time was localized from `min read`
to `min di lettura`. The owner reviewed the date and taxonomy pages with
`serve_site()` and accepted the existing ISO dates, labels and year grouping.
The earlier `0001` concern is therefore closed without template changes.

**Files to modify:** [single.html](../layouts/_default/single.html),
[list.html](../layouts/_default/list.html), and conditionally
[config.yaml](../config.yaml) for the language used by localized date formatting.
**Files to create:** proposed `layouts\_default\taxonomy.html` and
`layouts\_default\term.html` if dedicated views are chosen; proposed
`content\categories\_index.md` and `content\tags\_index.md` for Italian index titles.
Conditional noindex implementation may modify [head.html](../layouts/partials/head.html)
and the selected term metadata instead. Do not implement all alternatives.

**Steps**

1. Build representative taxonomy indexes/terms. Confirm the actual title,
   heading visibility and undated grouping, rather than assuming every earlier
   observation still appears.
2. Agree Italian reading-time and date presentation, including singular/plural
   and machine-readable dates. Preserve historical dates and existing URLs.
   Verify Hugo's configured language before using localized month names.
3. Choose whether duplicate terms stay as useful browse pages, get customized,
   or are marked noindex. Do not delete them without reviewing incoming links.
4. Prefer dedicated taxonomy/term views for non-date-based browsing: alphabetical
   term indexes and sensible term-page lists without headings such as `0001`.
   Give them visible Italian headings independently of whether `.Content` exists.
   Check template selection against Hugo 0.136.5's lookup rules.
5. If noindex is selected instead, implement only the agreed metadata policy,
   verify its emitted robots meta tag and its relationship with sitemap output.
   Do not use robots.txt blocking as a substitute for noindex.
6. Check article/event dates and reading times, category/tag URLs, breadcrumbs,
   canonical metadata and all formerly supported browse links.

**Done when:** the agreed Italian presentation works and taxonomy behavior is
intentional, without breaking sections or turning an optional SEO choice into
an unapproved removal of content.

## V01: Rendering and interaction checks

**Priority:** P1. **Depends on:** pinned Hugo available; affected fixes for final retest.
**Gallery check:** On 2026-11-18, the owner confirmed that the gallery works
well in a local `serve_site()` review. No responsive gallery code change is
required at present. This does not close V01's production/preview, taxonomy,
alias, keyboard/screen-reader or full viewport matrix.

**Files to modify:** normally only [project-status.txt](project-status.txt) with
dated outcomes. Application files change only through the specific failing item's
guide, not a blanket cleanup during validation.
**Files to create:** none required in the project. Build output and short-lived
fixtures belong in explicitly named temporary locations and are not source files.

**Steps**

1. Locate Hugo 0.136.5 Extended using the project's existing R/blogdown setup;
   verify its version. If unavailable, report the blocker or obtain that exact
   version when authorized; do not silently upgrade Hugo or the project.
2. Run a production-equivalent build and a separate `-F` preview build using a
   preview base URL. Direct output/cache to dedicated check locations where
   practical and use only flags supported by the pinned version.
3. Inspect Home, Progetto, privacy/confirmation, archive, article, all programming
   subsection types, an annual page, a source, genre/country pages, taxonomy
   indexes/terms, aliases and 404. Home/404 must not gain breadcrumbs.
4. Check internal destinations, relative assets, canonical/social metadata and
   expected future-dated-content differences between production and preview.
5. At representative widths such as 320, 375, 768 and desktop pixels, verify
   readable wrapping, galleries and form controls without horizontal overflow.
   Test keyboard focus/lightbox operation and screen-reader labels. If the
   five-column gallery is unusable, open a measured fix against the shortcode's
   CSS rather than assuming the layout is broken from source alone.
6. Verify that existing gallery validation errors remain path-specific using
   isolated fixtures, not invalid files left in production content. Record
   checks actually run and distinguish local tests from owner/deployed checks.

**Done when:** the relevant build/interaction matrix passes with recorded evidence.
Close only the checks actually completed; do not overwrite historical results or
claim a new Netlify submission test from a local build.

## V02: Sitemap lastmod

**Status:** DONE on 2026-11-18 with an explicit-editorial-date policy.
**Priority:** P2. **Depends on:** pinned Hugo available; accurate editorial dates.

**Files to modify:** none until the discrepancy is reproduced. If required,
modify [config.yaml](../config.yaml) and the affected content's front matter.
For fully generated annual metadata, modify [update-anni.R](../R/update-anni.R)
and regenerate rather than hand-edit pages.
**Files to create:** none expected. A custom `layouts\sitemap.xml` is a last-resort
proposal only if built-in configuration cannot express the agreed policy.

**Implemented policy:** [config.yaml](../config.yaml) now resolves the Hugo
`lastmod` field only from explicit `lastmod` front matter. Pages without an
explicit, trustworthy editorial modification date omit the sitemap value rather
than presenting a historical `date` as a modification. Twelve recently edited
editorial pages received dates verified from their latest meaningful commits.

When a generated annual page is meaningfully changed, pass an explicit value to
[update-anni.R](../R/update-anni.R), for example
`update_anni(years = 1960, lastmod = "2026-11-18")`. The generator validates
`YYYY-MM-DD` and writes that date to the generated front matter. Do not update
`lastmod` merely because the site or an unchanged data set was rebuilt.

**Verification:** Hugo 0.136.5 emitted the explicit date for the methodology
article and omitted `lastmod` for an annual page, a source page and Progetto,
none of which has an explicit modification date. A direct R test confirmed that
the generator writes a valid date and rejects an invalid calendar date.

**Steps**

1. Generate `sitemap.xml` and select representative dated archive/year pages,
   recently edited articles, undated pages and section indexes.
2. Compare each emitted lastmod with its front matter and actual meaningful
   content revisions. Distinguish a historical screening date, publication date
   and modification date; do not replace them all with today's build date.
3. Agree the lastmod policy and change configuration/metadata only where it
   gives inaccurate dates. Do not depend on Git-derived dates without verifying
   that the build checkout has the required history.
4. If generator metadata needs changes, preserve existing URLs and descriptions
   and ensure unchanged data do not spuriously refresh modification dates.
5. Rebuild, validate the XML and spot-check emitted dates again, including on a
   subsequent unchanged build.

**Done when:** sitemap dates reflect the agreed meaningful-change policy, or
the inspection establishes that existing output is correct with no code change.

## V03: Footer GitHub link

**Status:** DONE on 2026-11-18. [config.yaml](../config.yaml) no longer includes
`.git`; Hugo 0.136.5 emitted the normalized URL and GitHub returned HTTP 200.
**Priority:** P2, small ready check once external access works.
**Depends on:** working network and confirmation of the intended repository.

**Files to modify:** [config.yaml](../config.yaml) if normalization is needed.
[footer.html](../layouts/partials/footer.html) only if its construction is wrong;
it already builds the URL from configuration.
**Files to create:** none.

**Steps**

1. Inspect the rendered footer URL and open it in a browser; check the redirect
   chain and final destination. A DNS failure does not establish an HTTP 404.
2. Confirm that the intended destination is the public repository page, not a
   clone endpoint. If so, normalize the configured repository to
   `whatswrongintown/cinema-teatro-sestito` without `.git`.
3. Build and click the generated footer link. Avoid changing its markup if the
   configuration edit is sufficient.
4. Record the observed final URL/status or leave verification open if access
   remains unavailable.

**Done when:** the footer reaches the intended repository page, with no unrelated
social-link or navigation changes.

## P01: Short breadcrumb labels

**Status:** DONE on 2026-11-18.
**Priority:** P3. **Depends on:** agreement on the labels to shorten.

The four programming section indexes use standard `linkTitle` values:
`Anni`, `Fonti`, `Generi`, and `Paesi`. Full headings and URLs are unchanged.
Annual detail pages retain their existing labels; the R generator was not
modified. Hugo 0.136.5 verification covered representative landing and nested
pages, including full headings, short breadcrumbs and canonical URLs.

**Files to modify:** the four relevant programming subsection `_index.md` files
under [programmazione-storica](../content/programmazione-storica/) for section
`linkTitle` values. If year-only labels are chosen, modify
[update-anni.R](../R/update-anni.R) and regenerate annual front matter.
Other editorial pages change only if individually selected.
**Files to create:** none. No custom breadcrumb parameter/helper is required.

**Steps**

1. Agree a small label list, for example Anni/Fonti/Generi and year-only annual
   labels. Keep full headings and permalinks unchanged.
2. Use standard `linkTitle` metadata, which the current breadcrumb partial already
   reads. Review other uses of `.LinkTitle`, since the value is not breadcrumb-only.
3. For fully generated year pages, have the generator write the short label and
   regenerate; do not create a manual field that the next update will erase.
4. Verify nested/dated trails, long titles, missing overrides and other navigation
   that may use `.LinkTitle`. Existing ancestor logic should not need changes.

**Done when:** selected labels are short and stable across regeneration, while
full titles/routes and unaffected navigation remain correct.

## P02: Lightbox asset placement

**Status:** DONE on 2026-11-18. The stylesheet is loaded in the shared head,
the script remains at the end of the body, and both paths use Hugo's `relURL`.

**Priority:** P3, deferred. **Depends on:** none; coordinate with O05.

**Files to modify:** [head.html](../layouts/partials/head.html) and
[footer.html](../layouts/partials/footer.html).
**Files to create:** none.

**Steps**

1. Move the lightbox stylesheet link from the body/footer into the existing
   stylesheet area in the head; remove the original to avoid double loading.
2. Resolve lightbox CSS/JS URLs with the existing Hugo URL-helper pattern.
   Preserve script execution behavior; changing loading/defer strategy is not
   necessary just to normalize URLs.
3. Check stylesheet order so viewer controls and page styles do not regress.
4. Build for the production root and, if portability is a goal, a test base path.
   Verify that both assets load and the viewer still opens/closes/navigates.

**Done when:** there is one head stylesheet reference and one working script
reference, without introducing a site-wide base-path migration.

## M01: Form and privacy maintenance

**Priority:** P1 ongoing operations, not a new launch blocker.
**Depends on:** owner access to Netlify and the approved handling policy.

**Files to modify:** none routinely. Update [project status](project-status.txt)
when recording a meaningful check/incident. Change [privacy.md](../content/privacy.md)
only if actual practices change and the owner approves the new wording.
**Files to create:** none in the public project. Private messages, exports,
attachments and any operational records must stay outside the published project.

**Steps**

1. Review verified/spam submissions and notification delivery in Netlify without
   copying personal messages into issues, docs or source control.
2. Review active Legacy Starter/Forms levels and current submissions/upload usage
   in the dashboard. Act on usage alerts; do not assume a free hard stop or
   change plans/payment settings without authorization.
3. Respond privately, distinguish follow-up requests from publication permission,
   and obtain a separate agreement before publishing any memory/image.
4. Retain/delete submissions and any private exports according to the approved
   policy. Avoid unnecessary copies and check provider deletion/caching behavior.
5. After a form change, run an authorized minimal test and remove test data
   according to policy; do not send repeated test messages during routine docs work.
6. Log only the date, outcome and any non-sensitive action needed. If behavior
   changes, create a specific issue rather than reopen the whole launch checklist.

**Done when:** each maintenance pass has an outcome and any discovered problem
has an owner/action. The ongoing responsibility does not become permanently DONE
because one test passed; the current form's working status remains valid.

## F01: Cinema-image attachments

**Status:** Deferred 2026-11-17: the owner prefers visitors to use the existing
email link or arrange photo delivery after contact. No form uploads are enabled.
If revisited, this depends on agreed limits, access, privacy/rights handling and
acceptable Legacy Starter usage costs.

**Files to modify:** [contact-form.html](../layouts/shortcodes/contact-form.html),
[main.css](../static/css/main.css), [privacy.md](../content/privacy.md), and
conditionally [grazie.md](../content/grazie.md) if confirmation wording must
explain review/attachment handling.
**Files to create:** none for the minimal native-HTML upload. A proposed
`static\js\contact-form.js` is conditional progressive enhancement for useful
client-side feedback, not a substitute for server-side validation.
If enforceable file/content checks or restricted storage need backend services,
agree that architecture first; backend files/settings/costs cannot yet be fixed.

**Steps**

1. Read the current [feature requirements and provider sources](ideas/website-improvement-ideas.txt).
   Confirm the active account/Forms allowance. The published Level 0 has 100
   submissions and 10 MB uploads monthly; account-specific terms take precedence.
2. Agree image formats, number of fields and caps within the 8 MB total-request
   ceiling, allowing for text/encoding. Netlify documents one file per field
   and a 30-second upload timeout. Do not silently use a multiple-file field.
3. Establish what access/privacy protection and authoritative validation are
   required. Browser `accept`/size checks alone are not enforcement. If native
   Forms cannot meet the agreed needs, stop and choose an approved backend or
   restricted-storage approach before adding a misleading upload UI.
4. Review the privacy notice and metadata/location risks, owner moderation,
   retention/deletion, rights and separate publication permission. Uploaded URLs
   appear in notifications/exports and may remain accessible after deletion;
   do not promise private authenticated-only access or immediate erasure.
5. Add optional labelled upload field(s) and multipart encoding while preserving
   all existing form names, honeypot, message fields and confirmation behavior.
   Keep no-JavaScript and message-without-image submissions working.
6. Provide clear Italian instructions and accessible feedback. If progressive
   enhancement is chosen, preserve native submission as the fallback and handle
   non-success responses/timeouts explicitly, not just network failures.
7. On an authorized real deploy, test text only, valid image, invalid type,
   over-limit data and upload failure. Check notification/download links, spam,
   mobile behavior, deletion and usage accounting. Never publish test photos.

**Done when:** the existing text form still works, uploads meet the agreed
validation/access rules, errors are understandable, and privacy/billing behavior
has been verified rather than assumed. Do not enable the feature before that.

## F02: Poster collection pilot

**Priority:** P2, currently blocked on inputs. **Depends on:** external database,
representative images, stable identifiers and agreed public metadata.

**Files to modify:** eventually [home](../content/_index.md) and
[sitemap](../content/sitemap.md) to link the working catalogue. Existing
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

**Files to modify:** [main.css](../static/css/main.css),
[sitemap](../content/sitemap.md), and conditionally [home](../content/_index.md)
for a search link while retaining the Progetto-only top menu.
For the proposed R-index approach, modify
[update-programmazione-storica.R](../R/update-programmazione-storica.R)
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

## F04: Later editorial features

**Priority:** P3, deferred. **Depends on:** an explicit choice of feature and content.

**Files to modify:** [home](../content/_index.md) and
[sitemap](../content/sitemap.md) only when a new page is ready to link.
Reusing the contact form for identification may conditionally modify
[contact-form.html](../layouts/shortcodes/contact-form.html) to include clear
item context without changing existing submissions.
**Files to create:** no fixed set is approved. For a minimal editorial approach,
proposed `content\cronologia.md` (timeline), `content\aiuta-a-identificare.md`
(identification instructions) and/or `content\collezioni\_index.md` with curated
collection pages. Create only the selected branch, not all of them automatically.
Dedicated layouts/JS are conditional on separately agreed interaction requirements.

**Steps**

1. Choose one branch and its goal; do not combine all three into an undefined
   redesign. Identify the owner-reviewed source material and existing routes.
2. For a timeline, prepare dated events with source links and uncertainty notes;
   start with a readable chronological page before adding interaction.
3. For identification help, select a real item and invite private corrections
   with enough item context for review. Reuse the working contact path; depend
   on F01 only if uploads are essential. Never auto-publish visitors' claims.
4. For a curated collection, write the introduction and select existing items
   without copying their canonical records; use verified links and rights/credits.
5. Preview the chosen branch on mobile and keyboard, validate sources and links,
   then add its navigation entry and update the status with the actual scope.

**Done when:** the chosen branch is editorially reviewed, accessible and linked.
Keep the other branches DEFERRED; one published page does not finish all of F04.

## F05: Integrated programming dashboard

**Priority:** P2, proposed. **Depends on:** agreed pilot views, counting/filter
semantics, IMDb-ranking rules and performance targets. Does not require posters
or completion of F03. The owner selected documentation only on 2026-11-17.

**Detailed proposal and R starter:** section 1.5 of
[website improvement ideas](ideas/website-improvement-ideas.txt).
The recommended architecture is local R data preparation and browser-side
interaction within Hugo, not another hosted Shiny iframe.
That section now preserves the 2026-11-18 source inventory and CSV comparison
from the owner's temporary Shiny folder; it is the durable reference after that
folder is removed. Source inspection did not run Shiny or verify its deployment.
It also contains a fresh read-only analysis of all three website CSVs, an exact
native font/colour/layout contract, ranked additional chart ideas and archive
drill-through interactions. These remain proposals, not approved feature scope.

**Placement decided by the owner on 2026-11-18:** replace the iframe INSIDE the
existing article with the native dashboard shortcode. Preserve its historical
URL, date, slug and title; rewrite its body to guide exploration. The earlier
separate `/programmazione-storica/esplora/` proposal is superseded.

**Baseline file budget:** **4 created + 4 modified website files** (8 total).
Maintaining the three existing F05 docs makes that **4 created + 7 modified**
(11 total). This documentation-only turn changes those three docs, not the site.

**Four website files to modify when implementation is authorized:**
[programming introduction](../content/programmazione-storica/_index.md),
[editorial sitemap](../content/sitemap.md),
[original dashboard article](../content/articoli/2023-09-23-esplora-la-storia-cinematografica-di-san-vito-sullo-ionio/index.md),
[main.css](../static/css/main.css). Do not change generated annual tables or
legacy chart measures. The section/sitemap link to the article, not a new page.
**Four files to create:** proposed `R\update-dashboard.R`,
`static\data\dashboard.json`,
`layouts\shortcodes\programming-dashboard.html` and
`static\js\programming-dashboard.js`. The shortcode loads its deferred script
only where used; native HTML/SVG avoids additional library assets initially.
No head/footer/single template changes or separate content/CSS files are needed.
**Three docs to maintain:** [project status](project-status.txt), this guide and
[website improvement ideas](ideas/website-improvement-ideas.txt).
Optional full-updater integration adds one modified existing file,
[update-programmazione-storica.R](../R/update-programmazione-storica.R), making
5 website modifications (8 including docs). New tests, library assets and later
Hugo link lookups are scope-dependent additions, not hidden in the baseline.
Record the actual inventory when implementing; no implementation files are
created by this documentation update.

**Steps**

1. Use the recorded Shiny inventory to agree a minimal replacement. The source
   review is complete: year/chart controls, three charts, summaries/rankings,
   director frequency and a searchable table are documented. Do not port the
   first-entry-per-film reduction, distinct-genre-string counts, whole-string
   director grouping, regex filters or table-only director/genre filter scope.
   Define dated entries versus unique films, multi-value filter logic, missing
   metadata, coverage caveats and rating/vote/tie-break rules.
   Outline the article's Italian guidance before implementing: short introduction,
   "Come esplorare i dati", chart-specific instructions, "Come leggere i risultati"
   and "Fonti e aggiornamento". Follow the detailed editorial workflow in section
   1.5 of the ideas file. Do not write instructions for unbuilt features.
2. Validate CSV joins and prepare separate film/screening data with only needed
   public fields. Normalise multi-value relationships without multiplying entry
   counts. Reuse shared validated data with F03 where appropriate, not a second
   competing film catalogue. Use the website CSVs, not the older Shiny snapshots
   (5,055 entries, 4,359 films and one missing IMDb match). Export separate entry
   and film arrays, normalised relationship arrays, nullable numeric metadata
   and a schema version. Keep O03/O04's existing scope and decisions intact.
3. Generate JSON locally, commit it, and document refresh behavior for both full
   and partial updates. Start with an explicit standalone exporter after CSV
   changes, then agree full-updater integration; partial section generation must
   not silently leave a supposedly current JSON snapshot. Netlify remains
   Hugo-only; no R runtime or dependency on the temporary folder is deployed.
4. Build the Italian explorer within the existing layout. First slice: year
   selector, dated-entry and unique-film counts, reset and paginated entry
   table, with keyboard support and loading/empty/failure states. Next add
   shared title/director/genre/year-range filters and an entries-by-year chart.
   Monthly/genre/scatter charts, rankings and individual-director frequency are
   later slices if agreed. Keep browse links as the no-JavaScript fallback.
   Reuse the normal Hugo shell and local Merriweather/Lato fonts; mirror the
   existing mint/dark-green palette and form controls with dashboard-scoped
   styles. Keep the 700 px content column initially. Explicitly theme chart
   labels/tooltips as well as HTML; do not embed a separately themed app.
   Implement and review inside the existing article, not a separate page.
   Keep article date/reading time and its normal Home > Articoli breadcrumb.
   Replace the iframe with the shortcode in the candidate version and rewrite
   the article body to explain the delivered controls, measures and limitations.
   Keep UI labels/dynamic counts in the shortcode, editorial explanations in
   the article; avoid duplicated hard-coded totals. Preserve category/tag metadata
   and adjust description only if needed to match the delivered slice.
   Recommended next additions are a year/month coverage calendar and recurring-
   film/source detail expansion, followed by monthly/genre/country views. See
   the detailed proposal for measures, evidence, priorities and caveats.
5. Compare interactive results with R reference counts for repeated films,
   missing fields, combined filters and zero results. Verify mobile/keyboard
   use, data-load failure handling and the agreed size/load/interaction targets.
   Current all-data references: 5,290 entries / 4,567 films; the recorded starter
   gives 1,089 / 948 for 1950-1959. Recompute after data changes. Test that a film
   repeated across years stays visible in each relevant year, genre/director
   matches are exact and rating ties follow the agreed limit/order.
   Validate palette contrast, local fonts, responsive charts/tables, zero versus
   out-of-range calendar cells, any context-filter exception, and real Hugo
   destinations for archive drill-through links. Do not imply that pooled
   seasonality, IMDb votes or source counts measure attendance or confidence.
6. Build with Hugo 0.136.5 and verify the native dashboard and guidance at the
   unchanged article URL, with no Shiny iframe. Check article heading/anchor
   navigation, mobile reading order, keyboard use and no-JavaScript/data-error
   fallback; verify that instructions match the delivered controls and that
   methodology/archive links work. Check operation with Shiny requests blocked.
   Publish article and section/sitemap links together only after the agreed
   migration scope passes, not merely the first slice. Retire the old app
   separately, with the owner's approval; do not replace the iframe with a link
   to an unrequested second dashboard page.

**Done when:** the agreed explorer works without contacting Shiny, matches the
reference measures, fits the site, meets accessibility/performance checks and
can be refreshed reproducibly. A recorded idea or data starter is not completion.
