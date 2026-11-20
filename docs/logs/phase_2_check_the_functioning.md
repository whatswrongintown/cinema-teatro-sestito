# PHASE 2 - CHECKING HOW THE SITE WORKS (condensed log)
Four technical audits started on 2026-11-13, read-only; later corrections are
marked as such. Current status and decisions: docs/project-status.md.

## PROMPT 1 - TAXONOMIES AND SECTIONS
- Default taxonomies (categories, tags): 19 categories (269 assignments) and 34
  tags (132). Terms live under /categories/ and /tags/, without a dedicated
  layout (generic list grouped by year).
- 9 _index.md files: home, four sections and four sub-sections of historical
  programming. The _index.Rmd files are excluded from the Hugo mount. /sitemap/
  is the editorial map (a Markdown page), distinct from sitemap.xml.
- Structure: Home > Progetto, Editorial map, Archivio (nine categories),
  Articoli (7), Eventi (empty), Programmazione storica > Fonti (93 pages: 30
  Agende, 39 Calendari, 12 Rubriche, 12 Appunti), Anni (57), Generi (23), Paesi
  di produzione (63).
- sitemap.xml: 335 unique URLs, no collisions; on 2026-11-13 all returned 200
  without redirects. The lastmod values were not checked.
- Redundancy: /categories/{generi,paesi-di-produzione,programmazione-per-anni} and
  /tags/programmazione repeat the sub-section lists and group undated pages under
  year 0001. /categories/ and /tags/ are in English.
- Category links: 16 links, 15 destinations, 14 returning 200;
  /categories/note-sui-manifesti/ returns 404 (Phase 1, item 22). The /sitemap/
  page has a link without a destination for "Locandine d'epoca" (item 7).

## PROMPT 2 - TEMPLATES AND SHORTCODES
- 15 local templates, no themes/ folder: the layouts derive from Hugo Lithium and
  are adapted. Own shortcodes: image-gallery and blogdown/postref (relref and
  youtube are built in). No duplicated or unused templates.
- Build with Hugo 0.136.5: 77 galleries and 1,310 images with valid URLs. In a
  temporary fixture a valid gallery works; a missing parameter, a missing folder
  or a non-image file stop the build (generic message for a missing parameter
  and a non-image file).
- Fixed after the audit: Anni list with ul/li and h2; head.html with meta
  descriptions for taxonomies, canonical, Twitter Card and og:type; descriptive
  alt text on the home page, Archivio and Articoli.
- Remaining: Lightbox CSS in the body; alt text of the Programmazione storica
  section; logo alt ("avatar"); image-gallery inputs not validated;
  .Site.LanguageCode deprecated in recent versions; root-relative URLs in the
  footer and 404 page (fine for a root deploy).

## PROMPT 3 - HISTORICAL PROGRAMMING AND CSV
- Data: 5,290 valid dates (YYYY-MM-DD), no fully duplicated rows or date+const
  duplicates; 4,567 distinct const values, all with an IMDb record and URL; 606
  films recur on several dates (723 entries beyond the first). The CSVs are UTF-8
  (agende with BOM). The `rating` column is not used; `income` is ignored (638
  empty, 27 zeros). All 93 source values, 23 genres and 63 countries find their
  page.
- The 57 year pages match the CSV and have both charts; 1960 and 1961 carry the
  partial-documentation note. Netlify does not read the CSVs: after every change
  the scripts must be run and the output committed.
- Cautions on the charts (decision: explain them in the methodology article, no
  recalculation). The charts count dated entries, not distinct films; the genre
  heat-map uses genre-entry associations and drops "Drammatico" when n() > 1 per
  const (62 films, 126 entries); 104 entries without a genre count as "not
  adult"; Italy/abroad counts 7,126 country associations (1,490 entries with
  several countries); the Sources chart counts source-entry associations ("N°
  film") and unrecognised sources fall into "Agende".
- programmazione_paesi.csv has one extra row (tt0052704). The generator warns
  but does not delete pages of years removed from the CSV; it must be run from
  the project root.
- Update 2026-11-16: the scripts were rewritten in base R with identical results;
  the index charts are produced by R/update-indici.R
  (docs/guides/historical-programming.md). The scripts were re-run on a copy.

## PROMPT 4 - IMAGES AND SEO
- 209 image references (14 image front matter fields) with no missing files; 80
  image-gallery calls on 77 existing folders. 1,357 images in static (about
  386.5 MiB: 1,246 PNG, 91 JPG, 15 WebP, 4 SVG, 1 ICO), none above 1 MiB.
- Open Graph: og:image absolute and reachable, defaultImage fallback correct.
  287 files with title and description. The gallery makes 300x300 q50 thumbnails
  and large images up to 1600x1600 q50; images placed in Markdown stay original.
  The home page uses "/./_index_files/..." (redundant but working).
- Fixed after the audit (head.html): canonical, Twitter Card, descriptions for
  taxonomies, og:type. robots.txt was 404 and was added on 2026-11-16.
- Remaining: alt text of the Programmazione storica section and of the galleries
  (derived from file names); the Hugo build has not been re-run to check the
  <head>.
