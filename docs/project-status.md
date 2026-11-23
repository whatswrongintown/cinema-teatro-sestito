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
- Hugo 0.136.5 Extended (pinned in netlify.toml and .Rprofile). R/blogdown is
  still used for content generation but is being phased out (section 6).
- Netlify runs Hugo only, not R or knitr. Commit generated Markdown and charts.
- Historical programming: 3 CSVs in static/data -> local R scripts -> pages,
  tables and PNG charts -> commit -> Netlify publishes.
- Poster collection: private local originals in manifesti/ -> local R script ->
  pages, data/posters/films.json and web images -> commit (docs/posters.md).
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
  article Rmd sources remain (see H02).
- update-fonti.R accepts "Note sui manifesti"; the source page is still pending.
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
  known O02 destination. No horizontal overflow at 320-1280 px on nine
  representative pages. No Netlify form-limit scenario was tested.

## 3. OPEN ITEMS
### DEFERRED O02 - "Note sui manifesti" source/category
  The Fonti index links to /categories/note-sui-manifesti/ without backing
  content. Create the source page when verified data exist; do not invent the
  historical source.
### DEFERRED O03 - Country-only film ID
  programmazione_paesi.csv has one ID, tt0052704, with no screening or IMDb row.
  Reconcile it with verified evidence; do not delete it or guess a match.
### DEFERRED O04 - Chart convention explanations
  The genre chart drops "Drammatico" from films with several expanded rows
  (also repeated Drammatico-only films), and missing genres count as not adult.
  The methodology prose does not fully explain this. Decision: explain the
  conventions, do not recalculate charts. Resume after the database is final.
### DOING M01 - Routine form/privacy operations
  Monitor spam and usage; retain/delete messages according to the approved
  notice. The optional publication follow-up is not permission to publish.
  The form is not feature-flagged: deploying its shortcode publishes it.

## 4. DECISIONS AND PROVIDER CONTEXT
- Keep params.anno and the generic root/static favicons.
- Keep goldmark unsafe: true (inline HTML, one iframe).
- Netlify stays Hugo-only; renv is not used.
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
  it, and align netlify.toml and .Rprofile.
- 2026-11-23: the owner moved from GitHub Copilot to Claude Code. Assistant
  rules live in CLAUDE.md; .github/copilot-instructions.md was removed.

## 5. ROADMAP (future features are not current defects)
### DEFERRED F01 - Photo attachments to the contact form
  Owner chose on 2026-11-17 to receive photos by email or after contact. Not
  implemented. If revisited, keep text-only and no-JavaScript use working.
### TODO F03 - Film search (programming first, posters later)
  Define result granularity, scope and matching behaviour first. Build the
  index with Hugo, not R.
### DEFERRED F04 - Timeline, identification help and curated collections.
### Superseded F05 - Shiny dashboard
  The 2026-11-18 decision to keep Shiny is superseded by H05 (2026-11-23). The
  revised app in R/shinyapp_dashboard stays live and maintained until its Hugo
  replacement is published.

## 6. MIGRATION TO HUGO ONLY (decided 2026-11-23)
Goal: the owner wants to slowly leave R and the blogdown package and build the
site with Hugo only, to make the website easier to improve and evolve. R and
RStudio remain in use for exploratory analysis of the datasets, outside the
site build. Proceed gradually, one item at a time, with output comparison
before removing any R code. Steps: docs/plans/implementation-guide.md.

| ID | Item | Status |
| --- | --- | --- |
| H01 | Hugo (`hugo server` / `hugo`) as the local tool instead of blogdown | TODO |
| H02 | Convert the two article `index.Rmd` files to plain Markdown; remove blogdown leftovers | TODO |
| H03 | Historical programming pages, tables and charts built by Hugo from the CSVs | TODO |
| H04 | Poster pages and data built by Hugo; non-R image derivative step | TODO |
| H05 | Hugo-native dashboard replacing the Shiny app and iframe | TODO |
| H06 | Non-R tool (or retained utility) for source PDF conversion | TODO |
| H07 | Remove replaced R scripts/tests/docs; keep analysis code outside the build | TODO |

Open questions: charts as Hugo-generated SVG or a small JavaScript library;
whether new programming pages are created by a Hugo content adapter; whether a
Hugo upgrade is part of the migration.

## 7. DOCUMENTATION MAINTENANCE
- 2026-11-23: documentation reviewed. Removed: the Phase 1/2 audit logs (their
  open items are O02 and O03 above), the Copilot poster-section prompt, the
  superseded poster proposal/technical plan and the Netlify upload research.
  All remain in Git history.
- Use this file for current status, docs/proposals/ for feature proposals,
  docs/guides/historical-programming.md and docs/posters.md for the current
  generation workflows. Update the guides as migration items replace them.
- Keep content/sitemap.md up to date when sections change. Absolute-root URLs
  and the repeated public email are existing choices, not failures.
