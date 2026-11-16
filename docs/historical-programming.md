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

source("R/update-fonti.R")
update_fonti(sources = "Calendario 1951")

source("R/update-indici.R")
update_indici(sections = "generi")         # anni, fonti, generi or paesi
```

Each section script can also be run with `Rscript R/update-<section>.R`.
Updating a section without a selection also regenerates its index charts; a
selection leaves them untouched.

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

One source page, `content/programmazione-storica/fonti/<folder>/index.md`, titled
`Note sui manifesti` (or `Note su manifesti`), lists the screenings whose date is
written on the film poster, by year and month. The database value can be
`note_su_manifesti`, `Note sui manifesti` or `Note su manifesti` (also singular):
all fill that page. The annual pages link the source to it; until the page exists
they link to the sources index. Give the page the category `Note sui manifesti`
so that `/categories/note-sui-manifesti/` works.

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

The `_index.Rmd` files of these indexes are no longer needed.

Chart conventions: 1536 px wide (8 in at 192 dpi), the same text proportions as
the former knitr charts, and the same numbers as the original tidyverse code.
The sources chart classifies a source by name (Appunti, Rubriche, Calendari,
Note sui manifesti; everything else counts as Agende).

## Checks done on the rewrite (2026-11-16)

- Source, genre and country pages and the 57 annual pages are identical to the
  output of the previous tidyverse scripts; a full run on a copy of the project
  left all 241 pages unchanged.
- Chart data match the original R Markdown code; text sizes and positions match
  the published charts within a few pixels.
- A full update takes about 20 s, against about 40 s for the previous scripts
  (measured without the font download, which made them slower still).
