# CINEMA TEATRO SESTITO - PROJECT STATUS (single entry point)
Last review: 2026-11-23 (move to Claude Code, documentation cleanup, Hugo-only
migration goal)

Read this file first and update it whenever a decision is made.
See docs/README.md for the documentation index. Assistant instructions are in
CLAUDE.md at the repository root.
Documentation is in English; site content is in Italian. Use status words
TODO / DOING / DONE / DEFERRED and date findings and decisions.
Per-item steps are in docs/plans/implementation-guide.md; they do not change an
item's status.

## 1. PROJECT AT A GLANCE
- Hugo 0.136.5 Extended (pinned in netlify.toml). Local preview/build with
  `hugo server` / `hugo`; blogdown is no longer used. R scripts still hold the
  generators but are being phased out (section 6).
- Netlify runs Hugo only, not R or knitr. Commit generated Markdown and charts.
- Historical programming: 3 CSVs in static/data. Since 2026-11-23 Hugo builds
  the tables and SVG charts from them (H03).
- Poster collection: final since 2026-11-23. data/posters/films.json and the
  web images are committed; Hugo builds film and letter pages from the JSON (H04).
- Source-page counts checked 2026-11-17: 7 article bundles; 26 archive Markdown
  detail pages plus their index; 236 programming detail pages (57 years, 93
  sources, 23 genres, 63 countries) plus 5 programming indexes.
- CSV check 2026-11-17: 5,290 dated screening rows; 4,567 distinct screening film
  IDs and IMDb records; 4,568 country records. All screening IDs have IMDb rows.
- Never edit public/ or resources/ (regenerated). For generated output, change
  the data or generator; preserve editorial introductions.
- Tone for site content: welcoming, clear, professional Italian.

## 2. COMPLETED AND VERIFIED WORK
### DONE - R workflow
- 2026-11-16: update-anni/fonti/generi/paesi.R rewritten in base R, with yaml for
  metadata and showtext/sysfonts for the local Merriweather font. All 241
  Markdown pages were unchanged; full updates take about 20 s instead of 40 s.
- update-indici.R generates the six summary PNG charts for the four section
  indexes. Obsolete programming index _index.Rmd files were removed; the two
  article Rmd sources were removed in H02.
- 2026-11-17: full generator run in an isolated Git worktree: Markdown unchanged;
  three summary PNGs had small binary differences and were not copied back.

### DONE - Website features
- 2026-11-17: hierarchy-based breadcrumbs below the navigation header; home and
  404 excluded. The owner confirmed the styling works in production.
- O01 DONE 2026-11-17: Hugo's built-in robots.txt is enabled and live.
- 2026-11-17: gallery shortcode validates missing/invalid paths, empty or nested
  directories, unsupported files and resource lookup.
- 2026-11-17: homepage text form, honeypot, optional name/email, approved privacy
  notice and confirmation page. Owner confirmed it works on Netlify.
- O05 DONE 2026-11-18: lightbox keyboard accessibility (labelled Italian
  buttons, dialog semantics, focus containment/restoration, Escape). Links still
  work without JavaScript. Owner confirmed in a local preview.
- O06 closed 2026-11-17 by owner decision. The logo and main menu lack a
  distinct focus indicator; this is accepted, not a claim that all focus is
  visible.
- O07 DONE 2026-11-18: meaningful gallery alternatives. Logo alt is
  "Cinema Teatro Sestito - Home". Descriptions live in page front matter;
  individual descriptions take precedence over a page-level description and the
  filename fallback. A gallery without metadata emits a build warning.
- O08 DONE 2026-11-18: reading time in Italian ("min di lettura"); the owner
  kept the current ISO dates, labels and taxonomy year grouping.
- P01 DONE 2026-11-18: short breadcrumb labels Anni, Fonti, Generi, Paesi.
- P02 DONE 2026-11-18: lightbox.css in the shared head, lightbox.js in the
  footer, both through relURL.
- V02 DONE 2026-11-18: sitemap lastmod only from explicit front matter; the
  annual R generator accepts an optional validated date.
- V03 DONE 2026-11-18: footer GitHub URL normalized.
- F02 DONE 2026-11-23: poster collection. The local generator produced 1,787
  posters for 1,057 films and 3,574 derivatives, with no unsupported filenames
  or unmatched films (79 title conflicts and 14 ratio warnings are reported in
  static/data/manifesti_report.csv). Generated sources are committed and linked
  from Home and the site map; the owner confirmed it on 2026-11-23. The poster
  metadata CSV contains no cinema screening dates. See docs/posters.md.
- Programming section images/charts have descriptive alt text.

### DONE - Recorded build checks
- V01 2026-11-18: Hugo 0.136.5 production and -F preview builds passed at 404
  pages and 2,620 processed images (before the poster collection). Metadata,
  sitemap, robots, aliases, local assets and internal links passed, except the
  then-open O02 destination. No horizontal overflow at 320-1280 px on nine
  representative pages. No Netlify form-limit scenario was tested.
- O02 DONE (found 2026-11-23): the "Note sui manifesti" source page
  (content/programmazione-storica/fonti/1965-01-01-note-sui-manifesti/, added
  2026-11-20) exists with its category; /categories/note-sui-manifesti/ returns
  200 and the Fonti index links to the page. Its `description` is still an
  English placeholder ("Screenings from this source in the cinema archive.").

## 3. OPEN ITEMS

## 4. DECISIONS AND PROVIDER CONTEXT
- Keep params.anno and the generic root/static favicons.
- Keep goldmark unsafe: true (inline HTML, one iframe).
- Netlify stays Hugo-only;
- Keep Eventi available with its explicit "no events scheduled" message.
- Only Progetto stays in the top menu; no analytics (disabled, DNT respected).
- Only the owner maintains the site; visitors are mainly locals.
- Contact stays a homepage form plus visible email. Messages are private;
  publication requires a separate agreement. Poster scan rights: owner confirmed.
- Explain chart conventions in methodology; do not recalculate existing charts.
- Netlify plan: the owner identifies it as Legacy Starter (100 form submissions
  per site/month in the published legacy table; metered usage can cause
  charges). No plan change is proposed.
- Hugo upgrades are not planned. Later versions require excludeFiles -> files
  (deprecated >=0.153, removed 0.169) and languageCode -> locale (>=0.158).
  The migration (section 6) may justify an upgrade; agree it separately, test
  it, and update netlify.toml.
- 2026-11-23: the historical programming and the poster digitisation are
  final. The CSVs in static/data/ will not change and no new material will be
  added, so the programming and poster sections never need regenerating. The
  poster web images in static/images/manifesti/ (made with the R script) are
  accepted as they are; do not modify or regenerate them. Counts in this file
  dated before this decision (e.g. 5,290 screening rows) are older snapshots;
  the final screening CSV has 5,479 rows.
- 2026-11-23: the owner moved from GitHub Copilot to Claude Code. Assistant
  rules live in CLAUDE.md; .github/copilot-instructions.md was removed.

## 5. ROADMAP (future features are not current defects)

### TODO F03 - Film search (programming first, posters later)
  Define result granularity, scope and matching behaviour first. Build the
  index with Hugo, not R.

## 6. MIGRATION TO HUGO ONLY (decided 2026-11-23)
Goal: the owner wants to slowly leave R and the blogdown package and build the
site with Hugo only, to make the website easier to improve and evolve. R and
RStudio remain in use for exploratory analysis of the datasets, outside the
site build. Proceed gradually, one item at a time, with output comparison
before removing any R code. Steps: docs/plans/implementation-guide.md.

| ID | Item | Status |
| --- | --- | --- |
| H01 | Hugo (`hugo server` / `hugo`) as the local tool instead of blogdown | DONE 2026-11-23 |
| H02 | Convert the two article `index.Rmd` files to plain Markdown; remove blogdown leftovers | DONE 2026-11-23 |
| H03 | Historical programming tables and charts built by Hugo from the CSVs | DONE 2026-11-23 |
| H04 | Poster pages built by Hugo from `data/posters/films.json` (images and data stay as they are) | DONE 2026-11-23 |
| H05 | Hugo-native dashboard replacing the Shiny app and iframe | DOING 2026-11-23 (built; Shiny retired after publication) |
| H06 | Non-R tool (or retained utility) for source PDF conversion | DONE 2026-11-23 (tool retired, scans are final) |
| H07 | Remove replaced R scripts/tests/docs; keep analysis code outside the build | TODO |

H01/H02 (2026-11-23): a plain `hugo` build without blogdown produced 1,677
pages and 2,620 processed images with no warnings. Removed `.Rprofile`, the
root `index.Rmd`, the RStudio "Website" build type, the two article
`index.Rmd` files, the `blogdown/postref` shortcode and the Rmd exclusions in
the `config.yaml` content mount. The committed `index.md` files were kept (they
were newer than the Rmd sources). Their three charts moved to the bundles'
`images/` folders with descriptive names and were checked in `hugo server`.
The chart R code remains in Git history. `.claude/launch.json` defines the
`hugo server` preview. The RStudio project stays for exploratory analysis.

H03 tables (2026-11-23): the 238 year/source/genre/country pages no longer
contain tables (54,030 generated lines removed). The shortcode
`programmazione-tabelle` and the partial `programmazione/dati.html` render them
from the CSVs at build time. All 2,937 HTML/XML output files were compared with
the previous output: identical apart from the removed HTML comments and one
title the R tables had not picked up from a later CSV correction (1992,
"Chiamami… Bestial play best"). Year pages got `<!--more-->` so RSS summaries
stay as before. Existing pages are kept (no content adapter: the data are
final). The R table generators must no longer be run (they would rewrite the
pages); they go in H07. Details: docs/guides/historical-programming.md.

H03 charts (2026-11-23, owner chose SVG drawn by Hugo): the 114 annual charts
and 6 index charts are inline SVG from the `grafico` shortcode, reproducing the
R layout, including the IMDb title-label placement (glyph widths in
data/grafici/merriweather.json). All index aggregates and, for every year, the
monthly counts, axis values and rated-screening counts were compared with the
R functions: identical. Visual checks against the PNGs passed. 61 unused PNGs
were deleted; the 59 PNGs named in front matter `image:` stay as social preview
images. Full build: about 40 s (43 s before H03).

H04 (2026-11-23): the 1,057 film pages and the 26 title-letter pages are no
longer Markdown files: the content adapters
`content/posters/films/_content.gotmpl` and
`content/posters/by-title/_content.gotmpl` create them from
`data/posters/films.json` (same URLs, layouts and front matter keys; sitemap
priority omitted as before). The whole build output (HTML, XML, sitemap) was
compared with the previous build: identical, 1,677 pages. The year, size, genre
and root pages stay as editable Markdown. `data/posters/films.json` and the
images are final and kept; `R/update-posters.R` must no longer be run (it would
recreate the Markdown pages) and goes in H07. Details: docs/posters.md.

H05 (2026-11-23): the methodology article now embeds the `dashboard` shortcode
instead of the shinyapps.io iframe. The browser reads the public CSVs and
`static/js/dashboard.js` draws the filters, tables and SVG charts (no library);
the year filter affects all tabs and repeated dated entries stay separate from
distinct-film counts. Checked in `hugo server` (all tabs, filters, sorting, 320
to desktop widths, no console errors): 5,479 entries and 4,668 films for all
years. The CSVs hold 11 film IDs without an IMDb row and 55 screenings without
an ID; the Shiny app would have refused them, the Hugo page lists them without
rating or director. Open: the owner publishes the change, then retires the
shinyapps.io app (explicit approval); `R/shinyapp_dashboard` is removed in H07.
Details: docs/guides/historical-programming.md.

Because the data are final (section 4), the migration is about maintainability
and presentation, not a data pipeline.

Open question: whether a Hugo upgrade is part of the migration.

## 7. DOCUMENTATION MAINTENANCE
- 2026-11-23: documentation reviewed. Removed: the Phase 1/2 audit logs (their
  open items), the Copilot poster-section prompt, the
  superseded poster proposal/technical plan and the Netlify upload research.
  All remain in Git history.
- Use this file for current status, docs/proposals/ for feature proposals,
  docs/guides/historical-programming.md and docs/posters.md for the current
  generation workflows. Update the guides as migration items replace them.
- Keep content/sitemap.md up to date when sections change. Absolute-root URLs
  and the repeated public email are existing choices, not failures.
