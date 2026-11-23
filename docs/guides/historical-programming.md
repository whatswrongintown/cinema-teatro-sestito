# Historical programming

How the "Programmazione storica" section is built. The data are final
(2026-11-23), so nothing here needs to run for new data; this guide explains
how the pages work and how to change their presentation.

Status of the Hugo-only migration
([project status, section 6](../project-status.md#6-migration-to-hugo-only)):

- **Tables and charts:** built by Hugo from the CSVs since 2026-11-23 (H03).
- **Dashboard:** Hugo page and browser script (H05). **Source PDF images:** R script (H06).

## Data

Three CSV files in `static/data/`:

| File | Content |
| --- | --- |
| `programmazione_agende.csv` | screenings (`date`, `const`, `title`, `source`, ...), sorted by date |
| `programmazione_imdb.csv` | IMDb details, URLs and genres (`Const`, `Genres`, `URL`, ...) |
| `programmazione_paesi.csv` | production countries (`const`, `country`) |

Several sources, genres or countries in one cell are separated by commas;
values are trimmed and matched case-insensitively. 55 screenings have no IMDb ID
and are shown without a link.

## Tables (Hugo)

Every year, source, genre and country page ends with the shortcode

```text
{{% programmazione-tabelle "anni" %}}    (or "fonti", "generi", "paesi")
```

which renders the tables at build time:

| Mode | Page filter | Layout |
| --- | --- | --- |
| `anni` | rows whose year equals the page's `params.anno` | one table per month; first month carries footnote `[^1]` listing the year's sources |
| `fonti` | rows whose `source` list contains the page title | one table per month, under `## <year>` headings when the source spans several years |
| `generi` | rows whose IMDb `Genres` contain the page title | one table per year |
| `paesi` | rows whose country list contains the page title | one table per year |

Files:

- `layouts/partials/programmazione/dati.html` reads the three CSVs once per
  build (`partialCached`), joins IMDb URLs/genres and countries by film ID,
  escapes titles for Markdown tables, and maps source titles to their pages.
  The poster-date source can be written `Note sui manifesti`, `note_su_manifesti`
  and similar variants; all link to the "Note sui manifesti" source page.
- `layouts/shortcodes/programmazione-tabelle.html` filters and formats the rows.
  It must be called with `{{% %}}` so the output is processed as Markdown.

Rules for editing pages:

- Edit front matter, introductions and galleries freely; keep the shortcode as
  the last line. Never paste tables into the Markdown.
- Year pages have `<!--more-->` before the tables (before the partial-year note
  on 1960 and 1961) so RSS summaries contain only the introduction.
- A page's title is its matching key: renaming a source, genre or country page
  title breaks its table (the build warns when a page has no rows, and fails
  when a year page has no rows or a source has no page).

Verification (2026-11-23): all 2,937 HTML/XML files were compared with the
previous R-generated output. Apart from the removed HTML comments, the only
difference was one title the R tables had not picked up from a later CSV
correction (`Chiamami… Bestial play best`, 1992).

## Charts (Hugo, inline SVG)

Charts are drawn by Hugo as inline SVG with the shortcode

```text
{{< grafico nome="<name>" alt="<accessible description>" >}}
```

| Name | Page | Chart |
| --- | --- | --- |
| `anno-mensile` | every year page | screenings per month (bars), total in the title |
| `anno-imdb` | every year page | IMDb rating vs votes (log scale) with film titles where there is room |
| `film-per-anno` | Anni index | screenings per year (line), 1960 and 1961 excluded |
| `fonti-per-decennio` | Fonti index | source-entry associations per source type and decade (heat map) |
| `generi-per-decennio` | Generi index | share of each genre per decade (heat map) |
| `film-per-adulti-per-anno` | Generi index | yearly share of "Per adulti" screenings (area, 50% line) |
| `italia-estero-per-decennio` | Paesi index | Italian vs foreign share per decade (stacked bars) |
| `paesi-per-decennio` | Paesi index | distinct production countries per decade (line) |

Files in `layouts/`:

- `shortcodes/grafico.html` picks the rows (year pages) or the aggregates
  (index pages) and calls the chart partial of the same name in
  `partials/grafici/`.
- `partials/programmazione/indici.html` computes the index aggregates once per
  build (rules below).
- Helpers in `partials/grafici/`: `pretty.html` (R's `pretty()`, monthly axis),
  `extended.html` (ggplot2's "extended" axis algorithm), `espandi.html` (5%
  range expansion), `numeri.html` (common decimals, like R's `format()`),
  `larghezza.html` (text width), `indice-pannello.html`, `indice-xy.html`,
  `indice-assi.html`, `indice-legenda.html`, `colore.html`.
- `data/grafici/merriweather.json`: glyph widths (em) of Merriweather Regular,
  measured once from `static/fonts/merriweather-v13-latin-regular.woff`. Hugo
  cannot measure text, so the IMDb chart uses them to place title labels without
  overlaps (most isolated points first, 8 positions on 3 rings; titles without
  room are omitted, as in R). Characters missing from the file use an average
  width.

Layout, sizes, colours (`#CBF8DF` mint, `#E5E5E5` grey) and text positions
reproduce the former R charts (8 inches wide; annual charts in points, index
charts in 192-dpi pixels). Heat-map colours are interpolated in RGB instead of
CIELAB; with these two close colours the difference is barely visible. Heat-map
tiles and stacked bars carry a tooltip (`<title>`) with their value. The SVG
scales with the page (`max-width: 100%`).

Verification (2026-11-23): all index aggregates (years, source tiles, genre
counts, shares and order, adult and Italian shares, distinct countries) and,
for all 57 years, the monthly counts, axis values and number of rated
screenings were compared with the R functions: all identical. The charts were
checked visually against the PNGs; the IMDb labels chosen are almost the same
as R's. A full `hugo` build takes about 40 s.

Social previews: SVG cannot be used as an Open Graph image, so the PNGs still
named in front matter `image:` are kept as static files: the 57 annual
`proiezioni-mensili.png`, `generi-per-decennio-1.png` (genre pages) and
`italia-estero-per-decennio-1.png` (country pages and index). The other R chart
PNGs were deleted. The data are final, so these images do not go stale.

**Do not run the old R generators** (`update_anni()`, `update_fonti()`,
`update_generi()`, `update_paesi()`, `update_indici()`,
`update_programmazione_storica()`): they would write tables and PNG references
back into the pages. They are removed in H07.

Index aggregation rules (from the former `R/update-indici.R`):

- Sources are typed by name, in this order: Appunti (`cif`, `italautogamma`,
  `europe`, `victory`), Note sui manifesti (`manifest`), Calendari
  (`calendario`), Rubriche (`rubric`); everything else counts as Agende.
- Genres: one association per genre of the screening; `Drammatico` is dropped
  for films with more than one genre row across all their screenings; shares
  are per decade; rows are ordered by total, then name.
- Italian share: country associations containing "Italy" over all associations
  of the decade; screenings without countries count once as foreign.
- Distinct countries per decade count a missing country as one value.

### Interpretation and remaining editorial work

Charts count dated database entries, not distinct films or a known count of
daily projections. Source charts count source-entry associations; country charts
count country-entry associations, including coproductions. The methodology
article already explains those distinctions.

The genre calculation removes `Drammatico` when a film has more than one
expanded row, so it also removes repeated Drammatico-only films, not just films
with several genres. Missing genres count as not adult in the adult-share
calculation. The methodology/index prose does not yet fully explain these two
behaviours. Decision: explain
the conventions, do not recalculate the charts. The Hugo charts reproduce these
conventions; if one is ever changed, update the prose at the same time.

## Source PDF images (R, H06)

From the project root, install `pdftools` and `magick`, then run
`source("R/fonti_pdf_to_images.R"); fonti_pdf_to_images()` (or
`Rscript R/fonti_pdf_to_images.R`). Each PDF in `programmazione_storica_pdf/`
is rendered at 200 dpi and saved as WebP (quality 85, maximum width 1800 px,
no metadata) in `static/images/programmazione_storica/<pdf-name>/`; existing
images in that folder are deleted first. Checks:
`Rscript tests/test-fonti-pdf-to-images.R`. Since the sources are final, this is
only needed to replace a scan; update the source page's `image`, gallery path
and `galleryDescriptions` key by hand afterwards.

## Dashboard (Hugo, H05)

The methodology article
(`content/articoli/2023-09-23-esplora-la-storia-cinematografica-di-san-vito-sullo-ionio/`)
embeds the dashboard with the `dashboard` shortcode
(`layouts/shortcodes/dashboard.html`), which replaced the Shiny iframe on
2026-11-23. The browser reads the two public CSVs `static/data/programmazione_agende.csv`
and `programmazione_imdb.csv` and `static/js/dashboard.js` (no library) draws
everything; `static/css/dashboard.css` styles it. Nothing is generated at build
time, so there is nothing to regenerate.

Behaviour kept from the Shiny app: the year selector affects all tabs;
director and genre filters affect only the table; monthly counts are dated
entries, while genre, ranking and director summaries count distinct films. Charts
are inline SVG (monthly, genre, IMDb rating against votes) with a values table
under each. Differences: IMDb titles are shown on hover instead of placed as
labels, and the director filter is a text box that matches part of a name. The
CSVs contain 55 screenings without an IMDb ID and 11 IDs without an IMDb row (a
few adult films); they appear as films of their own with no rating or director
(a screening without an ID is one film per title).

The `R/shinyapp_dashboard` app and its shinyapps.io deployment are retired once
the Hugo page is published (owner approval; code removal is H07).
