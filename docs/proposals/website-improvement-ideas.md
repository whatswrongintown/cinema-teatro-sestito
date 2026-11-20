# WEBSITE IMPROVEMENT IDEAS AND TECHNICAL PLAN
Working notes, 2026-11-15, reviewed and reorganised 2026-11-17
Dashboard source, website design and current-data reviews: 2026-11-18

Nothing here is an implementation decision unless it appears in
docs/project-status.md. Current issues and priorities live there; this file
holds feature details, provider references and future proposals. Historical
audits remain in docs/logs/. DONE / TODO / DEFERRED describe current feature state.

## FOUNDATION
- Hugo 0.136.5 + R/blogdown, deployed with Netlify (Hugo only, no R). Static is
  mounted both as assets and as static, so anything placed in static/ is public.
- Historical programming is organised by year, source, genre and country; the
  screening CSV links films through `const`, the IMDb CSV through `Const`.
  Links between datasets must be verified, not assumed.
- The home page describes the poster section as under construction. The existing
  image-gallery shortcode makes square 300x300 thumbnails and filename captions,
  which do not suit a poster catalogue.

## 1. CURRENT FEATURES AND PLANNED ENHANCEMENTS

### 1.1 Memories and contact - DONE, owner-verified working 2026-11-17
- The homepage Hugo shortcode layouts/shortcodes/contact-form.html accepts a
  private message (required), optional name and optional reply email. It works
  without JavaScript and includes Netlify metadata, a hidden form-name field,
  a honeypot, a privacy link and a confirmation-page action.
- The optional follow-up request about publication is not publication permission.
  Agree publication, credit or anonymity separately with the author. A reply
  email is needed if the visitor wishes to be contacted.
- content/privacy.md was approved by the owner on 2026-11-17;
  content/grazie.md is the confirmation page.
- On 2026-11-17 the owner confirmed Netlify was checked and everything works.
  This supersedes the earlier local-preview/launch-blocker status. It is not
  evidence of an assistant-run test of every notification, spam or error case.
- Monitor submissions/spam and account usage as routine maintenance; follow the
  approved retention/deletion practices. Messages are not automatically published
  or committed. The shortcode is unconditional, not preview-gated.
Docs: https://docs.netlify.com/manage/forms/setup/
      https://docs.netlify.com/manage/forms/submissions/
      https://docs.netlify.com/manage/forms/spam-filters/

#### 1.1.1 Legacy Starter context - official references checked 2026-11-17
The owner identifies the account as Legacy Starter. Do not substitute newer
credit-based plan terms, including their unlimited Forms offering.
- Legacy plans apply to accounts predating September 4, 2025. The published
  table lists 100 form submissions per site/month; the FAQ describes Forms
  Level 0 as 100 submissions plus 10 MB of uploaded files per month. Forms usage
  counts verified submissions and the files uploaded through them.
- Monthly uploads are a separate metered allowance, not a per-file size limit
  or an unlimited lifetime storage promise. The dashboard is authoritative for
  older grandfathered terms and the active Forms level; it was not inspected by
  the assistant. Do not assume the account must still be on Level 0.
- Legacy Starter metered usage can trigger automatic add-on upgrades/extra
  charges. Legacy Free has different hard-limit behavior. Do not promise that
  reaching an allowance merely rejects the next submission or cannot cost money.
- For deployment context, the published Starter table lists 100 GB monthly
  bandwidth and 300 monthly build minutes, with overages. These are not upload
  limits or evidence of a current problem.
- No migration is proposed: moving a team to credit-based pricing is documented
  as irreversible. Keep account settings and billing unchanged for this task.
Sources:
https://docs.netlify.com/manage/accounts-and-billing/billing/billing-for-legacy-plans/legacy-pricing-plans/
https://docs.netlify.com/manage/accounts-and-billing/billing/billing-for-legacy-plans/billing-faq-for-legacy-plans/
https://docs.netlify.com/manage/forms/usage-and-billing/

#### 1.1.2 Cinema-image attachments - DEFERRED 2026-11-17, not implemented
Goal: visitors can optionally attach cinema-related images to their message.
The existing text form must keep working, including without JavaScript.
- The owner chose to use the existing email link for photos, or arrange their
  delivery after contact, instead of implementing uploads for now. If revisited,
  formats, limits and security need agreement. Other document types are not in
  the initial scope. Phone photos may need preparation.
- The form invitation now mentions cinema visits, theatrical shows, anecdotes
  and photos, without promising an attachment field.
- The owner identified Netlify's VGS plugin. Netlify recommends VGS for uploads
  containing personal information; its plugin configures VGS vault routes rather
  than securing uploads by merely installing it. Its GitHub repository was
  archived on 2026-02-24, and current photo-upload support, maintenance and
  applicable terms need confirmation. VGS's pricing page lists plans starting
  at $1,000/month and says users can get started free; the actual terms for this
  use are unknown. Do not install or activate it without a separate decision.
  https://www.netlify.com/integrations/very-good-security/build-plugin/
  https://github.com/verygoodsecurity/netlify-plugin-vgs
  https://www.verygoodsecurity.com/pricing
- Consider native HTML file inputs and multipart/form-data encoding. Netlify
  currently supports one file per upload field; several files require several
  fields, not reliance on a single multiple-file field.
- Netlify's documented ceiling is 8 MB for the whole form request, not per
  image, and uploads time out after 30 seconds. The monthly Forms upload
  allowance is separate; allow for form fields/encoding in any chosen file cap.
- Give accessible labels and clear size/format instructions. Plan reliable file
  validation and visible oversized/unsupported/failed/timeout feedback; a browser
  accept hint alone does not validate uploaded content. Test mobile use too.
- Review upload abuse/spam handling, personal data and image metadata/location
  information. Keep owner review before any publication: do not automatically
  copy submissions into static/, the repository or a public gallery.
- Review the privacy notice and actual storage/access/retention/deletion behavior
  before enabling uploads. Receiving an image is not permission to publish it;
  separately agree rights, attribution and publication.
- Netlify supplies file links in submission details, email notifications, CSV
  exports and the API. Do not promise authenticated-only access without checking.
  Its docs say uploads can remain accessible by direct URL for 24 hours after
  deleting a form; do not promise immediate erasure.
- When separately authorized, test success/failure, notification links, deletion
  behavior and monthly accounting on a real deploy. No upload field, processing,
  account change or submission test is part of this documentation-only update.
Sources:
https://docs.netlify.com/manage/forms/setup/#file-uploads
https://docs.netlify.com/manage/forms/submissions/#file-uploads

### 1.2 Search - TODO, not implemented
Make films in the programming (later posters) easy to find: search box, useful
results, a no-results state.
- Fields: Italian and original titles, film ID, screening year, genre, country;
  for posters also title, size and handmade status. Decide on case, accents,
  partial matches and typos.
- Decide whether a result is a film, a screening, a poster or a mix, and avoid
  one result per screening unless intended. Do not confuse release year with
  screening year.
- Approach: a build-time JSON index (from R or a Hugo output template) with only
  public fields, record type and labels; a small client-side script normalises
  case and accents. Measure index size and load time. Typo tolerance needs an
  extra library. Render results safely, handle empty/loading/error states, give
  keyboard and label support, and keep the browse pages as the no-JavaScript
  fallback. A hosted search service only if scale justifies its privacy and cost.

### 1.3 Breadcrumbs - DONE 2026-11-18
layouts/partials/breadcrumbs.html is called once from the shared header, just
below and outside the navigation header. It uses Hugo ancestors and .RelPermalink
rather than dated URL segments, starts with Home, and excludes home and 404.
Markup has a labelled nav, ordered list and aria-current on the non-linked
current item. static/css/main.css provides wrapping, a thin green link underline
and the same green hover/focus highlight as page content.
- Labels use .LinkTitle: existing titles by default, standard linkTitle front
 matter when supplied. P01 added Anni, Fonti, Generi and Paesi as short labels
 on the four programming indexes. No special breadcrumbTitle parameter or
 year-only label for annual pages was implemented.
- Nested and dated routes were checked in the earlier recorded full build.
  Fresh taxonomy/alias, mobile and assistive-technology checks were not repeated
  in the documentation review; keep them separate from a known implementation bug.
Docs: https://gohugo.io/methods/page/ancestors/

### 1.4 Vintage poster collection - TODO, proposal
Known: 1,797 images, 3.88 GB, photographed with an iPhone SE (2nd generation),
no copies. Folders by poster size, e.g. folder "fotobuste 50x70" with file
"tt0038338_50x70_01": film code, size, number (different numbers are different
posters of the same film). Some films use local codes instead of IMDb codes.
"tt0047517_70x100_r_01" has "r" for a poster handmade by the owner's grandfather.
Paths in these notes omit extensions; keep real ones.

The owner's poster database is manifesti_archivio.csv (not in the project; inspect
it first). Columns: position, const, title, original_title, year, directos,
location, archivio, locandina_33x70, fotobusta_70x50, manifesto_70x100,
manifesto_100x140, manifesto_140x200, pieghevole, comment, retro. It has one
column per poster format, not one row per image: reshape it into one row per
poster item. Check "retro" (back of the poster) and the "const" values that are
local codes.

Five views of the same collection (no separate copies of the data):
1. By screening year: films screened that year, with all screening dates and
   sources when a film was shown more than once; link to the existing year and
   source pages with real Hugo links. Posters without a matched screening are
   reachable elsewhere and labelled.
2. By film name: alphabetical index with a defined Italian sorting rule; equal
   titles with different film IDs stay separate.
3. By genre: one list per genre, grouped by film; a film may appear in several
   genres; unknown genres are not invented. Keep it separate from the existing
   programming genre pages and link the two where useful.
4. By poster size: an editorial explanation of the physical formats, then a page
   for each format present; keep format and dimensions in separate fields and
   handle unknown sizes explicitly.
5. By film, all versions: every poster image of the film, grouped by size and
   variant, with a handmade label and documented screening dates. A page per
   poster can follow if items need richer notes or shareable links.

Visitor experience: browsable gallery with uncropped thumbnails, title, size and
handmade marker; filters only on reliable metadata; a detail view with a larger
image, description or transcription, real dimensions, attribution and provenance
(unknown kept distinct from confirmed), useful alt text; links to related
screenings and other posters of the same film when the match is verified; a
curated introduction to the grandfather's handmade work.

Catalogue model (validate against the real files):
- Film: film key, titles, optional IMDb ID, release year, genres. Keep local
  codes as they are; never treat them as IMDb IDs.
- Poster item: stable local ID, film link if known, size, variant, handmade
  status, notes, rights status. One film can have several different posters; the
  sequence number is not a count of copies.
- Image: scan linked to its item, with the real relative path and the view
  (front/back); an item can have several scans. Screening dates written on a
  poster are sourced evidence, not confirmed dates.
- Screening: date, film key, recorded title and source from
  programmazione_agende.csv, with the existing methodology caveats.
Keep IDs and file names stable; do not rename, move or overwrite originals
before agreeing a convention; if files are renamed, keep an old-to-new mapping.
Check rights for digitised artwork before publication (ownership of the physical
poster alone may not be enough; the owner confirms all scans can be published).

### 1.5 Shiny dashboard maintenance - TODO F05, current direction 2026-11-18
The owner chose to retain the existing Shiny app and its article iframe. The
proposed native Hugo replacement is superseded and is no longer an active plan.

The revised app lives in R/shinyapp_dashboard. It reads the website CSVs, keeps
repeated dated entries, and derives distinct-film counts separately. The year
filter affects all tabs; director and genre filters affect the table. Local
changes do not update shinyapps.io automatically. Run, test and deploy using the
[historical programming guide](../guides/historical-programming.md). Deployment
requires explicit approval and verification of the hosted app and iframe.

Agree a specific improvement and its expected behavior before changing the app.
Record implementation and verification under F05 in
[project status](../project-status.md). Do not restore the superseded native
Hugo design or make the website depend on a second dashboard implementation.
### 1.6 Other ideas
- Interactive timeline linking screenings, stories and archive items.
- "Help identify this item": corrections reviewed before publication.
- Curated collections: handmade posters, a decade, a genre, a local story.
- Accessibility follow-up: O05 lightbox keyboard behavior and O07 gallery
 alternatives are complete. O06 remains closed by owner decision: other
 navigation focus styles are retained, while breadcrumbs use the content-link
 focus treatment. See docs/project-status.md for completed checks and remaining
 follow-up.

## 2. POSTER TECHNICAL PLAN (proposal, poster pipeline not built or tested)

### 2.1 Responsibilities
- The poster database and the CSVs stay the authoritative inputs. A local R step
  (run when data change) validates and joins them and writes Hugo-ready data,
  pages and web images; Markdown holds editorial text; Hugo layouts and partials
  render lists, film pages and a shared poster card; an optional shortcode embeds
  a few posters in articles (unknown ID or missing image = build error).
- The collection must work without JavaScript. If generation ever has to run on
  Netlify, an R environment and build step must be added explicitly.

### 2.2 Proposed files (illustrative; do not create before the model and URLs are agreed)
```text
  R/update-manifesti.R          validation, joins, page and data generation
  data/manifesti.json           optional Hugo-ready lookup
  content/manifesti/_index.md   introduction and links to the five views
  content/manifesti/film/<film-id>/index.md   generated film pages
  content/manifesti/anni|generi|formati/...   generated or editorial indexes
  layouts/manifesti/..., layouts/partials/..., layouts/shortcodes/...
  static/ or assets/            web images, depending on the image choice
```
Keep manually written introductions apart from generated files, document what an
updater may overwrite, and never edit generated pages by hand.

### 2.3 Matching and validation
- Join the poster film code to `const` (screenings) and `Const` (IMDb) only after
  checking that each code is the same film. Multiple posters and screenings per
  film multiply rows in a naive join: group by film, keep individual posters and
  screenings, deduplicate only where justified. Split genres like the existing
  genre script. Report unmatched and ambiguous records; never assign a plausible
  match silently.
- Before writing anything: required fields, unique poster keys, duplicate image
  paths, valid dimensions and dates, conflicting film IDs, local code mapping,
  missing files, safe relative paths. Produce a reviewable summary (totals,
  unmatched IDs, missing genres, errors) and stop on errors that would give wrong
  links or broken images. Test on a small sample first.

### 2.4 Hugo data and layouts
- Prototype: R generates one Markdown page per film plus the year, genre and size
  pages; front matter has the film key; a JSON lookup holds the larger
  relationships (.Site.Data reads JSON, not CSV, in Hugo 0.136.5). Alternative:
  read CSV with resources.Get and transform.Unmarshal (rows as strings; no
  targetType option in 0.136.5; static/data CSVs are already global resources).
  Data files alone do not create pages.
- Stable URLs built on film or item IDs, with aliases if a URL changes; use
  .RelPermalink for links. Split long lists by year, letter, genre or size and
  consider pagination (it works on page collections). Static filters on separate
  pages keep working without JavaScript.
  Docs: https://gohugo.io/content-management/data-sources/
        https://gohugo.io/functions/transform/unmarshal/
        https://gohugo.io/templates/pagination/

### 2.5 Image pipeline and deployment
- Originals stay outside the website, backed up separately. Check file types,
  EXIF orientation, dimensions and quality first.
- Web derivatives without cropping: thumbnails and larger views, aspect ratio
  preserved, no enlargement, no private EXIF/location data; give width/height and
  lazy loading, and link to the large view, not the master. Hugo can resize at
  build time (the gallery uses Fit and square Fill), but test time and memory
  before processing 1,797 photos; use the same derivative URL everywhere.
- Do not put masters in static/ (it is published); consider an assets-only
  location or prebuilt web copies. Measure repository size, deploy size, build
  time and page weight on Netlify, with a sample and then in full. Committed
  files are simple but make Git larger; external object storage or image hosting
  adds cost, configuration and backups. Check real account limits.
  Docs: https://gohugo.io/content-management/image-processing/

### 2.6 Converting the JPEGs in a separate R project
The owner prefers to convert the photos in a separate R project and copy only
web-ready images into the site. This keeps the 3.88 GB out of the repository and
avoids reconverting on each Hugo build.
Starting derivatives (to be confirmed on samples):
- Gallery: fit within 400 x 400 px, WebP quality 75-80.
- Large view: fit within 1600 x 1600 px, WebP quality 80-85.
- 50x70 and 70x100 in the names are physical sizes, not pixels: keep them. WebP
  is a candidate, not a requirement: compare with JPEG for legibility of printed
  and handwritten text, colour and size.
Workflow:
1. New RStudio project; originals in a separate read-only, backed-up location;
   a new empty output folder outside both the originals and the site.
2. Install magick and check that its ImageMagick build writes WebP (otherwise
   fix it or use JPEG).
3. Inventory recursively (paths, extensions, pixel sizes, byte sizes, count);
   report non-JPEG files, unreadable images and name collisions after the
   extension change, including case-insensitive ones on Windows. Never skip a
   file silently.
4. Test representative photos (portrait/landscape, faded, small print, the "r"
   example, EXIF rotation): apply orientation before stripping metadata, check
   colour and readability in a browser, confirm location data is gone, and check
   the effect of dropping colour profiles.
5. Process the whole collection one source at a time from the oriented original
   (not the thumbnail from the large WebP), keeping folder structure and file
   stem; only the extension changes:
   ```text
   originals\fotobuste 50x70\tt0038338_50x70_01.jpg
   web-output\gallery\fotobuste 50x70\tt0038338_50x70_01.webp
   web-output\large\fotobuste 50x70\tt0038338_50x70_01.webp
   ```
   (an example, not a decision on URLs; handle spaces in folder names when
   building links).
6. Save a manifest outside the public site: original path, derivative paths,
   dimensions, byte sizes, settings; reconcile it with the poster database.
7. Check that the count matches (currently 1,797, to verify) and every image has
   exactly one readable derivative per size; report failures, duplicates, wrong
   orientation and odd sizes; stop on errors.
8. Copy only approved derivatives and public data into the site; check every
   image URL in a Hugo preview and a Netlify deploy preview.

One-image experiment (illustrative, not a batch converter):

```r
install.packages("magick")   # once, if needed
library(magick)
input <- file.choose()
output_dir <- choose.dir(caption = "Choose an empty sample output folder")
if (is.na(output_dir) || !nzchar(output_dir)) stop("No output folder chosen")
gallery <- file.path(output_dir, "sample-gallery.webp")
large <- file.path(output_dir, "sample-large.webp")
if (file.exists(gallery) || file.exists(large)) {
  stop("Sample output already exists; choose an empty folder")
}
original <- image_orient(image_read(input))
image_write(image_strip(image_resize(original, "400x400>")),
            path = gallery, format = "webp", quality = 78)
image_write(image_strip(image_resize(original, "1600x1600>")),
            path = large, format = "webp", quality = 82)
print(image_info(image_read(gallery)))
print(image_info(image_read(large)))
```

">" prevents enlargement; orientation is applied before metadata removal. Open
both files and compare with the original, and inspect the metadata separately.
The real batch script needs a dry-run inventory and collision report, must never
overwrite originals or existing outputs, stops with the affected path on error,
keeps a progress/error report, and uses a new output folder per full run.
Docs: https://docs.ropensci.org/magick/reference/editing.html
      https://docs.ropensci.org/magick/reference/transform.html
      https://docs.ropensci.org/magick/reference/geometry.html

### 2.7 Implementation order
1. Inspect a sample of the poster database and file names (a local ID, a handmade
   item, a film with several sizes); agree labels, rights, identifiers and public
   metadata.
2. Proof of concept: validate the joins in R, generate a few film and browse
   pages, render uncropped thumbnails. Test films with several dates, no matching
   screening, missing genre, several variants; compare counts with the source.
3. Measure image and build costs; choose storage, derivatives, navigation and
   pagination; check direct URLs, missing-file diagnostics, mobile and keyboard
   use, alt text and no-JavaScript browsing.
4. Scale to the full collection, review the mismatch report, build with Hugo
   0.136.5, verify a Netlify deploy preview, document the update and backup flow.
5. Breadcrumbs are implemented and build-tested. The text form is implemented,
   its privacy notice is approved, and the owner confirmed Netlify works on
   2026-11-17. Image attachments (section 1.1.2) and search remain separate future
   enhancements; their priority is in docs/project-status.md. Check any Hugo API
   against 0.136.5 before adopting it.

## OPEN QUESTIONS
1. What do the local codes look like, and is there a list mapping each to a film?
2. Are sizes always in centimetres, and does each image show one whole poster, a
   detail or the back?
3. Should search start with screenings, posters or both, and what would visitors
   type or filter by?
Answered so far: the owner would like to publish selected memories later, with
permission. The current text form works per the owner's Netlify check; the next
requested form enhancement is optional cinema-image attachments, not other
document types initially. Formats, count and site-specific limits remain open.
