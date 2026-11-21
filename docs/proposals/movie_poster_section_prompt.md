# Task: Add a "Posters (Manifesti)" section to the Cinema Teatro Sestito website

## Context
This repo is the Cinema Teatro Sestito website (R blogdown + Hugo). The
"Historical Programming" section is already generated automatically by R. Build a
new, similarly generated Posters section.

Before writing code, explore the repo and find:
- how Historical Programming is generated (script, content folder, layouts/partials,
  data files, how it is triggered). Reuse its conventions (naming, front matter
  style, helper functions).
- how static assets are served, how CSS is organised, how R dependencies are
  managed (renv / DESCRIPTION), and whether the site uses i18n.

Summarise findings in 10 lines or fewer (path + one line each) at the start of your work.

Maintainer hints (verify, don't trust blindly):
- Historical Programming script: `[PATH]`
- Screening dates CSV: `static/data/programmazione_agende.csv`. It has one row per
  screening and also an `internal_poster_code` column (see "Posters without an IMDb ID").
- Film metadata CSV: `static/data/programmazione_imdb.csv` (genres, production year,
  other metadata, keyed by IMDb ID).
- Field names: IMDb ID `[NAME]` (present in both CSVs; EMPTY in the screening CSV for
  films that are not on IMDb), title `[NAME]`, genres `[NAME]`, production year `[NAME]`,
  screening date(s) `[NAME]`, title for films without an IMDb ID `[NAME, in the screening CSV]`
- UI labels / URL slugs / month names in: `[Italian | English]`. The category names
  Fotobuste, Locandine, Manifesti and Retro always stay in Italian.
- Sample rows from each CSV (include at least one film without an IMDb ID):
  `[PASTE 3 ROWS EACH]`

## CRITICAL: the original images are NOT in git
- `manifesti/` is in `.gitignore`; originals exist only on the maintainer's machine.
  Never `git add` anything from it, never change that `.gitignore` entry, never copy
  originals into a tracked folder.
- The R script is therefore a LOCAL, manual step. Everything it produces that the
  site needs (derivative images, JSON, content pages) is committed. The Hugo/blogdown
  build must never need `manifesti/` or the poster R script.
- If `manifesti/` is missing (fresh clone, CI), the script must exit with a clear
  message and change nothing. It must never delete existing generated files.
- `posters_index.rds` and the dimension cache are local build artefacts: keep them in
  a gitignored location (e.g. `.cache/posters/`) and add it to `.gitignore`.
- Tests must use small synthetic images created at test time, never the real originals.
- If you cannot see `manifesti/` in your environment, implement and test with
  synthetic fixtures and tell me clearly that the full run must be done locally.

## Input: poster files
```text
manifesti/
  fotobuste 50x70/     category fotobuste,  size 50x70
  locandine 33x70/     category locandine,  size 33x70
  manifesti 70x100/    category manifesti,  size 70x100
  manifesti 100x140/   category manifesti,  size 100x140
  manifesti 140x200/   category manifesti,  size 140x200
  retro/               category retro: hand-made posters used when the official
                       poster was not available; sizes are mixed (all of the above)
```
Dimensions are in cm. Folder names contain spaces: handle them safely.

Files are `.jpeg`. Match the extension case-insensitively and also tolerate `.jpg` and
`.png`; ignore non-image files.

Filename patterns:
```text
printed:  {FilmID}_{WxH}_{NN}.jpeg    e.g. tt0034167_50x70_01.jpeg, 892_50x70_01.jpeg  (then _02, _03 ...)
retro:    {FilmID}_{WxH}_r.jpeg       e.g. tt0041917_70x100_r.jpeg, 892_70x100_r.jpeg  (single retro poster)
          {FilmID}_{WxH}_r{NN}.jpeg   e.g. tt0041917_70x100_r01.jpeg, _r02.jpeg        (several)
```
- FilmID is one of:
  - an IMDb ID: `tt` + 7–8 digits (e.g. `tt0034167`);
  - an internal poster code: digits only (e.g. `892`), used for films that are not on
    IMDb (see "Posters without an IMDb ID").
  The two can never be confused, because IMDb IDs always start with `tt`.
- Always treat the FilmID as a string.
- size: `{width}x{height}`; NN: poster number (01, 02, ...).
- Parse each filename stem with one anchored regex, not by splitting on `_`. The third
  part is either digits only (printed poster) or `r` optionally followed by a number
  (retro). The exact separator for numbered retro posters is not certain: accept `r`,
  `r1`, `r01`, `r_01`, `r-01`. The retro number is the digits, or 1 if there are none.
- Category comes from the FOLDER. The nominal size comes from the FILENAME, normalised
  to the canonical `short x long` form (so `70x50` becomes `50x70`), so that one
  physical size never splits into two size pages. This size is only a label for
  grouping. It says nothing about orientation: a horizontal poster may be named `50x70`.
  Never use it for layout or orientation (see Rule 3).
- Cross-check: files in `retro/` must use the `r` token and files elsewhere must use a
  number. For the five non-retro folders, also warn if the normalised filename size
  differs from the folder size. Report every mismatch in `manifesti_report.csv`; the
  folder still decides the category.
- If two files resolve to the same FilmID + category + size + number (e.g. both `_r` and
  `_r01`), warn and keep the first alphabetically.
- Files not matching any pattern: skip, record in `manifesti_report.csv` with the
  reason, never crash.

## Posters without an IMDb ID (internal poster codes)
Some films are not on IMDb. Their posters are named with an internal numeric code
instead of an IMDb ID (e.g. `892_50x70_01.jpeg`). In `programmazione_agende.csv` these
films are recognisable because the IMDb ID column is empty and the `internal_poster_code`
column holds the code.
- Read every ID / code column as CHARACTER, trimmed (e.g. via `readr` `col_types`).
  Never let a code be parsed as a number (leading zeros, `892.0`).
- Matching: `tt...` files match the IMDb ID column; numeric files match
  `internal_poster_code` in the screening CSV.
- Metadata for these films: title and screenings come from the screening CSV (the field
  named in the hints). Genres and production year only if the screening CSV provides
  them; `programmazione_imdb.csv` has no row for them. Missing values here are normal,
  not an error.
- Canonical film id `film_id` (used in the index, JSON, front matter and URLs): the
  IMDb ID when the film has one, otherwise `internal-{code}` (e.g. `internal-892`).
  If an internal code belongs to a row that also has an IMDb ID, use the IMDb ID, so
  that posters named either way merge into one film.
- Report in `manifesti_report.csv`: internal codes with no match in the screening CSV;
  internal codes mapped to more than one distinct title (warn, use the first); and the
  number of internal-code films without genre.
- Also store `id_type` (`imdb` or `internal`) for each film.

## Input: metadata (read-only; never modify these CSVs, existing pages use them)
- Detect delimiter, encoding, decimal mark and date format (Italian CSVs often use
  `;`, Windows-1252, dd/mm/yyyy). Print what you detected.
- Screening dates give year and month. If a screening covers a date range spanning
  several months, the film counts in each month. Several screenings give several months.
- Genres may be several values in one cell: split using the separator actually used.
- Duplicate IMDb IDs in `programmazione_imdb.csv`: use the first and warn. (The screening
  CSV legitimately has several rows per film, one per screening.)
- Poster film IDs with no metadata match at all go to `manifesti_report.csv`; they still
  get indexed (title falls back to `film_id`) but are excluded from year/genre pages.

## Optional input: manual overrides
Pixel dimensions cannot tell whether an image was scanned sideways. Support a small,
committed, hand-edited file `data-raw/poster_overrides.csv` (or another path matching
repo conventions; create it with headers only if missing). Columns:
`film_id, category, size, number, rotate, exclude`.
- `rotate`: 0, 90, 180 or 270 degrees clockwise, applied to the pixels before the
  derivatives are made. Orientation is then computed after the rotation.
- `exclude`: TRUE skips the file.
- Rows that match no file are listed in `manifesti_report.csv`.

## Rules
1. Year/month = when the film was SCREENED at the cinema (screening CSV), never the
   production year. Films with no screening date are omitted from year/month browsing
   but appear in size, genre and title browsing.
2. Representative poster = the lowest poster number available (normally 01).
   - On a category+size page: the lowest number within that category+size.
   - On pages that mix sizes (year, month, genre, title), use the first size in
     `SIZE_PRIORITY` that the film has, then its lowest number.
     Default `SIZE_PRIORITY <- c("100x140","70x100","140x200","50x70","33x70")`.
   - Listings show exactly one image per film. Other posters appear only on the film page.
   - On Retro pages, apply the same logic to the film's retro posters only
     (`SIZE_PRIORITY`, then the lowest retro number).
3. Orientation comes ONLY from the real pixel dimensions of the original, never from
   the filename or folder (the filename size is a nominal `short x long` label).
   - Read width and height with `magick::image_info()`.
   - Check for an EXIF Orientation tag (e.g. the `exif:Orientation` property from
     `magick::image_attributes()`, or the `exifr` package if already available). If the
     value is 5–8, swap width and height. Verify the approach on a test image with an
     EXIF rotation tag before relying on it.
   - ratio = w/h: square 0.95–1.05, portrait < 0.95, landscape > 1.05 (constants).
   - Sanity check: compare the pixel ratio (shorter/longer side) with the nominal
     short/long ratio of the size. If they differ by more than 12% (constant), list the
     file in `manifesti_report.csv` (possible wrong folder, crop or scan margins). This
     is a warning only.
4. A film with several genres appears on every genre page. Slugify genres and titles
   for URLs (accents, case); display the original text.
5. Sorting is case- and accent-insensitive and ignores leading articles
   (`[Il, Lo, La, I, Gli, Le, L', Un, Uno, Una, The, A, An]`). Title pages are A–Z plus
   `#` for digits/other.
6. Create only pages that have content (no empty year, month, size, genre, letter).
7. RETRO is a separate collection. Retro posters appear only in the Retro section and
   in a separate "Retro" block on the film page. They do not appear in By Year / By
   Size / By Genre / By Title. A film with only retro posters therefore appears only
   in Retro.
8. Films with no genre (typically the internal-code films) are simply not listed on
   By Genre pages; they still appear in Year, Size and Title browsing. Do not create an
   "unclassified" genre page; just report how many films are affected.

## Image attributes (alt text)
- `alt` = the film title. Compute it once in R and store it per poster in the JSON
  (field `alt`), so templates never rebuild it. If the title is missing, fall back to
  `film_id`.
- In gallery cards, `alt` is simply the title.
- On the film page, where several posters of one film appear together, make each `alt`
  distinguishable by appending category and size in parentheses, e.g.
  "Title (Manifesti 100x140)" or "Title (Retro 70x100)".
- Every `<img>` also has `width` and `height` (the derivative's dimensions),
  `loading="lazy"` and `decoding="async"`.

## Web image optimisation (derivatives)
The originals are far too large for the web. The site only ever uses reduced
derivatives; originals are never modified or published. Goal: a balanced trade-off,
so images look clean at normal viewing sizes while files stay small.
- Thumbnail (galleries): 400px wide, height proportional, WebP quality ~75. Target
  roughly 15–40 KB. (400px covers 2x displays for ~200px cards.)
- Large (film page): longest side at most 1400px, WebP quality ~80. Target roughly
  100–300 KB.
- Never upscale: if an original is smaller than the target, keep its size.
- Downscale with a high-quality filter (Lanczos), convert to sRGB, strip metadata
  (EXIF/ICC) after conversion. Apply any EXIF orientation (and any manual `rotate`
  override) to the pixels BEFORE stripping metadata, otherwise browsers will show the
  derivative rotated wrongly.
- Use WebP when `magick::magick_config()` reports WebP support; otherwise JPEG
  (progressive, quality ~80, 4:2:0 chroma subsampling).
- Adaptive quality: if a derivative exceeds its ceiling (thumbnail 60 KB, large 400 KB),
  re-encode lowering quality in steps of 5 down to a floor of 60, never lower. Report
  the files that hit the floor.
- All sizes, qualities and ceilings are named constants at the top of the script.
- Originals can be very large: process one image at a time, free memory between
  images, show progress, and log (don't abort on) a file that fails to read.
- Record the derivatives' width/height in the index and JSON. The `<img>` width/height
  attributes and aspect-ratio must use the derivative's dimensions.
- Print a summary: file counts, total size, and median / 95th percentile / maximum size
  per derivative type, plus the 10 largest files.

## Output: files to create

**R pipeline** (`[path matching existing convention]`, one entry point,
e.g. `build_posters()`), using magick, dplyr, stringr, purrr, fs, yaml, glue (plus
readr and jsonlite if needed; add to renv/DESCRIPTION only what you use):
1. Scan `manifesti/`, parse filenames, read image dimensions.
2. Cache dimensions keyed by path + mtime + size. A re-run with no changes must not
   read any image.
3. Join to the metadata CSVs as described above (IMDb IDs and internal codes).
4. Write `posters_index.rds`: one row per poster (film_id, id_type, imdb_id,
   internal_poster_code, title, category, size, poster_number as an integer, is_retro,
   orientation, original width/height, derivative width/height, alt, path,
   is_representative) with list-columns `genres` and `screenings` (year, month).
   Leave imdb_id or internal_poster_code empty when not applicable. All later steps read
   this index, never the image folders.
5. Write `data/posters/films.json` (the Hugo data dir at repo root, NOT `static/data`):
   one record per film with film_id, id_type, metadata, screenings, and a `posters`
   array (category, size, number, is_retro, orientation, alt, thumb path and dimensions,
   large path and dimensions).
6. Generate the derivatives described above, committed to the repo. Names mirror the
   source filename, e.g. `tt0034167_50x70_01.webp`, `892_50x70_01.webp` and
   `tt0041917_70x100_r01.webp`. Create only if missing or the source is newer. Put them
   under the existing static image convention (e.g. `static/img/manifesti/thumbs|large/`).
7. Generate the Hugo pages below.

**Hugo content** (minimal and data-driven; no per-poster pages):
```text
content/posters/_index.md
content/posters/by-year/_index.md
content/posters/by-year/1953/_index.md
content/posters/by-year/1953/03/_index.md
content/posters/by-size/_index.md                      # grouped by category
content/posters/by-size/manifesti-100x140/_index.md    # one per category+size
content/posters/by-genre/drama/_index.md
content/posters/by-title/a/_index.md
content/posters/retro/_index.md                        # all retro films, by title
content/posters/retro/by-year/1953/03/_index.md        # same layouts, collection: retro
content/posters/films/tt0034583/index.md               # film with an IMDb ID
content/posters/films/internal-892/index.md            # film with an internal code
```
Front matter (only the keys that apply to the node):
```yaml
title: "Manifesti 100x140"
type: posters
layout: size            # year | month | size | genre | letter | film | retro
collection: printed     # printed | retro
browse: size
year: null
month: null
category: manifesti     # fotobuste | locandine | manifesti
size: 100x140
genre: null
letter: null
film_id: null           # IMDb ID, or internal-{code}
weight: 1
generated: true
```
Pages contain no film lists. Layouts filter `data/posters/films.json` using the front
matter keys, and the same layouts serve both collections. Do not use Hugo taxonomies
for these axes (they can't express year-to-month nesting or A–Z and would need a page
per poster), unless Historical Programming already uses them for genre; in that case
follow it.

**Film page**: all printed posters (thumbnails linking to the large version), the retro
posters in their own block, metadata (title, production year and genres when known,
screening dates), and a link to its Historical Programming page if one exists (use
whichever key that section uses to identify a film). Originals are not published.

**Templates and CSS** (`layouts/posters/...`, one shared gallery partial):
- Card = thumbnail + title, linking to the film page. Classes `poster-portrait`,
  `poster-landscape`, `poster-square` plus a category class (`poster-cat-locandine`...).
  Retro cards show a size badge, because sizes are mixed.
- Responsive CSS grid (`auto-fill` + `minmax`), `align-items: start`, no stretching,
  `object-fit: contain`, `width`/`height` attributes and a real-ratio `aspect-ratio`
  (locandine 33x70 are very tall and must not distort), landscape cards may span 2
  columns, `alt` text as described in "Image attributes", no JS required.
- Paginate any listing over ~60 films with Hugo's pager.
- Put the CSS where the site's existing CSS lives.

## Constraints
- Idempotent and incremental. On regeneration delete only files with
  `generated: true` under `content/posters/` and `data/posters/` (and stale
  derivatives that no longer have a source, only when the originals are present).
  Never touch hand-written content, `manifesti/`, `static/data/*.csv` or the
  Historical Programming code.
- Scale target: thousands of posters, minimal duplicated content.
- If something is ambiguous, use the default stated here and list the assumption in
  the PR description. Don't stop to ask unless truly blocked.

## Work in phases (commit after each)
1. Scanner, parser, metadata join, cache, index, report.
2. Derivatives + JSON + Hugo content generation.
3. Templates, CSS, navigation (including Retro).
4. Short `docs/posters.md`: how to run locally, what gets committed, data structures,
   how each section is built.

## Done when
- A clean local run succeeds; a second run with no changes reads no images.
- `git status` shows nothing from `manifesti/`, and `.cache/` (or equivalent) is ignored.
- The site builds with `manifesti/` temporarily renamed (proves no build dependency).
- Running the script with `manifesti/` missing changes no generated file.
- The script prints counts: scanned, parsed, skipped, films with IMDb ID, films with
  internal code, matched, unmatched, films without genre, retro films, pages per type,
  and the derivative size summary.
- Derivatives respect their size ceilings, or the exceptions are listed.
- No empty galleries. Every listing shows one image per film, correctly sorted. Every
  image has an `alt` equal to the film title (with the film-page suffix described above).
- Tests (synthetic images) for the filename parser, orientation classifier,
  metadata join and representative-poster selection.
  - Parser cases: printed `01`/`02`; retro `r`, `r1`, `r01`, `r_02`; internal-code files
    such as `892_50x70_01` and `892_70x100_r`; an internal code with leading zeros
    (`007_50x70_01`, which must stay `"007"`); a retro file outside `retro/`; a numbered
    file inside `retro/`; wrong IMDb ID length; upper-case `.JPEG`; a non-matching name;
    duplicate `_r` and `_r01`; size `70x50` normalised to `50x70`.
  - Image cases: a landscape image named `50x70` classified as landscape; an image with
    an EXIF rotation tag; a `rotate` override.
  - Join cases: an internal code matching the screening CSV; an internal code that
    matches nothing; an internal code whose row also has an IMDb ID (posters merge into
    one film).
- Spot-check five films (screened in several months, several sizes, no screening date,
  retro-only, internal-code) and report their generated paths.
