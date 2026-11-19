# Historical programming: R scripts

How the "Programmazione storica" section is generated. Run everything from the
project root. Netlify only runs Hugo, so generated files (pages, tables, PNG
charts) must be committed.

## Requirements

Base R plus `yaml` (page metadata) and `showtext` / `sysfonts` (chart font).
Charts use Merriweather, always read from
`static/fonts/merriweather-v13-latin-regular.woff`: no download, and the scripts
stop with an error if the file is missing. `renv` is not used.

## Data

Three CSV files in `static/data/`:

| File | Content |
| --- | --- |
| `programmazione_agende.csv` | screenings (`date`, `const`, `title`, `source`, ...) |
| `programmazione_imdb.csv` | IMDb details, URLs and genres (`Const`, `Genres`, `URL`, ...) |
| `programmazione_paesi.csv` | production countries (`const`, `country`) |

The scripts check dates (`YYYY-MM-DD`), required columns and unique IDs, and stop
on errors. Several sources, genres or countries in one cell are separated by
commas; names are case-insensitive.

Read-only CSV check on 2026-11-17: 5,290 screening rows, 4,567 distinct screening
film IDs and IMDb records, and 4,568 country records. Every screening ID has an
IMDb row; the extra country ID `tt0052704` still needs reconciliation with the
poster data. It is deferred, not silently deleted or assigned a guessed match.

## Scripts

| Script | Function | What it writes |
| --- | --- | --- |
| `R/update-anni.R` | `update_anni(years = NULL)` | one page per year with two charts (monthly screenings, IMDb rating vs votes) |
| `R/update-fonti.R` | `update_fonti(sources = NULL)` | tables (by year and month) in every source page |
| `R/update-generi.R` | `update_generi(genres = NULL)` | genre pages (tables by year) |
| `R/update-paesi.R` | `update_paesi(countries = NULL)` | country pages (tables by year) |
| `R/update-indici.R` | `update_indici(sections)` | the summary charts shown in the section indexes |
| `R/update-programmazione-storica.R` | `update_programmazione_storica()` | everything above, checking all sections before writing |

```r
source("R/update-programmazione-storica.R")
update_programmazione_storica()            # after changing the CSV files

source("R/update-anni.R")
update_anni(years = c(1948, 1960))         # selected years only
update_anni(years = 1960, lastmod = "2026-11-18") # when data/content changed

source("R/update-fonti.R")
update_fonti(sources = "Calendario 1951")

source("R/update-indici.R")
update_indici(sections = "generi")         # anni, fonti, generi or paesi
```

Each section script can also be run with `Rscript R/update-<section>.R`.
Updating a section without a selection also regenerates its index charts; a
selection leaves them untouched.

The sitemap uses only explicit `lastmod` front matter. For a meaningful annual
page/data update, pass the editorial modification date through `update_anni()`.
Do not set it merely because Hugo or an unchanged data set was rebuilt.

## Shiny dashboard

The historical-programming article embeds a separately hosted Shiny app. From
the project root, install the R packages `shiny`, `DT`, `showtext`, and
`sysfonts`, then run it locally:

```r
shiny::runApp("R/shinyapp_dashboard")
```

The dashboard reads the authoritative programming and IMDb CSVs from
`static/data/` and local fonts from `static/fonts/`. The year selector affects
all tabs; director and genre filters affect only the table. Monthly counts
represent dated entries, while genre and director summaries count distinct films.
The IMDb chart shows recorded film titles where space permits, using the annual
charts' label-placement helper. Its values table lists all rated films with
positive vote counts, including those without a visible label.

To publish to the existing shinyapps.io app, configure the `rsconnect` account
first and, from the project root, explicitly run:

```r
source("R/shinyapp_dashboard/deploy.R")
deploy_dashboard()
```

This stages the app, current CSVs, fonts and shared annual-chart helper in a
temporary deployment bundle, using the existing deployment record. The bundle
is removed afterwards. Changes to `static/data/` require a new deployment;
a Hugo/Netlify build alone does not update the hosted app. Verify the app and
embedded iframe after deployment. Run the local data and staging checks with:

```r
source("R/shinyapp_dashboard/test-dashboard.R")
```

## Pages and metadata

- Generated tables, annual pages and charts are overwritten: change the data, not
  the pages. Old annual pages are never deleted automatically (a warning is shown).
- Annual pages get a year-specific description, `params.anno`, and their monthly
  chart as `image`.
- Source, genre and country pages keep their introduction and metadata. A source
  page needs front matter and the line `<!-- Tabelle generate automaticamente. -->`
  before the tables; its title must match the `source` value. A missing page makes
  `update_fonti()` stop with "Creare prima le schede delle fonti".
- Source pages take the first image of `static/images/<folder>/` as `image`.
- New genre and country pages are created from the database, with a title-specific
  description. Their URLs are section-based (`/programmazione-storica/generi/commedia/`);
  an older dated URL is kept as a Hugo alias.

## Note sui manifesti

The required future source page,
`content/programmazione-storica/fonti/<folder>/index.md`, titled
`Note sui manifesti` (or `Note su manifesti`), lists the screenings whose date is
written on the film poster, by year and month. The database value can be
`note_su_manifesti`, `Note sui manifesti` or `Note su manifesti` (also singular):
all fill that page. The annual pages link the source to it; until the page exists
they link to the sources index. Give the page the category `Note sui manifesti`
so that `/categories/note-sui-manifesti/` works.

That page/category has not yet been created in this copy. The Fonti index still
links to the category without backing content; do not describe the link as fixed.

## Section index charts

The index text lives only in each `_index.md`; the scripts never rewrite it. The
charts are PNG files in
`static/programmazione-storica/<section>/_index_files/figure-html/`:

| Section | File |
| --- | --- |
| anni | `film-per-anno-1.png` |
| fonti | `fonti-per-decennio-1.png` |
| generi | `generi-per-decennio-1.png`, `film-per-adulti-per-anno-1.png` |
| paesi-di-produzione | `italia-estero-per-decennio-1.png`, `paesi-per-decennio-1.png` |

The obsolete programming section `_index.Rmd` files have been removed. The two
article `index.Rmd` sources remain; this change does not replace their workflow.

Chart conventions: 1536 px wide (8 in at 192 dpi), the same text proportions as
the former knitr charts, and the same numbers as the original tidyverse code.
The sources chart classifies a source by name (Appunti, Rubriche, Calendari,
Note sui manifesti; everything else counts as Agende).

### Interpretation and remaining editorial work

Charts count dated database entries, not distinct films or a known count of
daily projections. Source charts count source-entry associations; country charts
count country-entry associations, including coproductions. The methodology
article already explains those distinctions.

The existing genre calculation removes `Drammatico` when a film has more than
one expanded row, so it also removes repeated Drammatico-only films, not just
films with several genres. Missing genres count as not adult in the adult-share
calculation. The methodology/index prose does not yet fully explain these two
behaviors; see O04 in [project status](../project-status.txt).

Earlier analysis recorded 62 films / 126 rows affected by the repeated
Drammatico-only exclusion, 104 missing-genre rows, and 7,126 country associations.
These detailed figures were not recalculated in the documentation review.
Decision: explain the conventions and review chart prose, not recalculate charts.
The scripts do not rewrite editorial introductions; do not edit generated tables
to try to fix explanatory text.

## Checks done on the rewrite (2026-11-16)

- Source, genre and country pages and the 57 annual pages are identical to the
  output of the previous tidyverse scripts; a full run on a copy of the project
  left all 241 pages unchanged.
- Chart data match the original R Markdown code; text sizes and positions match
  the published charts within a few pixels.
- A full update takes about 20 s, against about 40 s for the previous scripts
  (measured without the font download, which made them slower still).

## Recorded follow-up and review limits (2026-11-17)

The project status records a full generator run in an isolated Git worktree
using project data: generated Markdown was unchanged; three summary chart PNGs
had small binary differences and were not copied back. This is a previously
recorded check, not a generator run repeated for this documentation update.

The current review checked source documentation and CSV counts/ID coverage. It
did not regenerate pages/charts or run a fresh Hugo build. Old annual pages
intentionally remain with a warning if their data disappear; review them manually
when the warning occurs rather than treating retention as a new generator bug.
