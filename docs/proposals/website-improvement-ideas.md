# WEBSITE IMPROVEMENT IDEAS
Working notes, 2026-11-15; reorganised 2026-11-17 and 2026-11-23.

Nothing here is an implementation decision unless it appears in
docs/project-status.md. Current issues, priorities and the Hugo-only migration
plan live there; this file holds feature details, provider references and
future proposals. The poster collection is built and documented in
docs/posters.md.

## FOUNDATION
- Hugo 0.136.5, deployed with Netlify (Hugo only, no R). R/blogdown generators
  are being phased out in favour of Hugo (see project status, section 6).
  `static/` is mounted both as assets and as static, so anything placed in
  `static/` is public.
- Historical programming is organised by year, source, genre and country; the
  screening CSV links films through `const`, the IMDb CSV through `Const`.
  Links between datasets must be verified, not assumed.

## 1. CURRENT FEATURES AND PLANNED ENHANCEMENTS

### 1.1 Memories and contact - DONE, owner-verified working 2026-11-17
- The homepage shortcode `layouts/shortcodes/contact-form.html` accepts a private
  message (required), optional name and optional reply email. It works without
  JavaScript and includes Netlify metadata, a hidden form-name field, a
  honeypot, a privacy link and a confirmation-page action.
- The optional follow-up request about publication is not publication
  permission. Agree publication, credit or anonymity separately with the author.
- `content/privacy.md` was approved by the owner on 2026-11-17;
  `content/grazie.md` is the confirmation page.
- Monitor submissions/spam and account usage as routine maintenance; follow the
  approved retention/deletion practices. Messages are not automatically
  published or committed. The shortcode is unconditional, not preview-gated.
- Plan context: the owner identifies the account as Netlify Legacy Starter. The
  published legacy table lists 100 form submissions per site/month; metered
  usage can trigger add-on charges. The account dashboard is authoritative.
- Photo attachments were not implemented: on 2026-11-17 the owner chose to
  receive photos by email or after contact. If revisited, review Netlify's
  current upload limits, privacy, retention and rights before starting.
Docs: https://docs.netlify.com/manage/forms/setup/
      https://docs.netlify.com/manage/forms/usage-and-billing/
      https://docs.netlify.com/manage/accounts-and-billing/billing/billing-for-legacy-plans/legacy-pricing-plans/

### 1.2 Search - TODO, not implemented
Make films in the programming (later posters) easy to find: search box, useful
results, a no-results state.
- Fields: Italian and original titles, film ID, screening year, genre, country;
  for posters also title, size and handmade status. Decide on case, accents,
  partial matches and typos.
- Decide whether a result is a film, a screening, a poster or a mix, and avoid
  one result per screening unless intended. Do not confuse release year with
  screening year.
- Approach: a Hugo-built JSON index (output format or `resources.Get` +
  `transform.Unmarshal` of the CSVs) with only public fields, record type and
  labels; a small client-side script normalises case and accents. This fits the
  Hugo-only direction better than an R-generated index. Measure index size and
  load time. Render results safely, handle empty/loading/error states, give
  keyboard and label support, and keep the browse pages as the no-JavaScript
  fallback.

### 1.3 Breadcrumbs - DONE 2026-11-18
`layouts/partials/breadcrumbs.html` is called once from the shared header, below
and outside the navigation header. It uses Hugo ancestors and `.RelPermalink`,
starts with Home, excludes home and 404, and uses `.LinkTitle` (short
`linkTitle` values on the four programming indexes).
Docs: https://gohugo.io/methods/page/ancestors/

### 1.4 Historical programming dashboard - see project status H05
The Shiny app in `R/shinyapp_dashboard` (hosted on shinyapps.io, embedded by
iframe in the methodology article) is still the live dashboard. On 2026-11-23
the owner decided to replace it with a Hugo-native page as part of the
migration. Until the replacement is published, maintain and deploy the Shiny
app as described in docs/guides/historical-programming.md; deployment requires
explicit approval. The replacement must keep the current behaviour: the year
filter affects all views, repeated dated entries are kept, and distinct-film
counts are derived separately.

### 1.5 Other ideas
- Interactive timeline linking screenings, stories and archive items.
- "Help identify this item": corrections reviewed before publication.
- Curated collections: handmade posters, a decade, a genre, a local story.

## OPEN QUESTIONS
1. Should search start with screenings, posters or both, and what would visitors
   type or filter by?
2. For the Hugo-native dashboard (H05): its filters need JavaScript; can it
   reuse the SVG chart partials (decided for the static charts on 2026-11-23),
   or does it need a small chart library?
