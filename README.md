# Cinema Teatro Sestito

The [Cinema Teatro Sestito website](https://cinemateatrosestito.com/) documents the history of the cinema in San Vito sullo Ionio and its historical film programming.

The site uses [Hugo](https://gohugo.io/), [R](https://www.r-project.org/) and [blogdown](https://github.com/rstudio/blogdown). It uses Hugo 0.136.5 and a theme derived from [hugo-lithium-theme](https://github.com/jrutheiser/hugo-lithium-theme), modified by Yihui Xie.

## Preview

Open the RStudio project and run:

```r
blogdown::serve_site()
```

## Update Historical Programming

The database consists of three CSV files in [static/data/](static/data/): screenings and sources (`programmazione_agende.csv`), IMDb film details and genres (`programmazione_imdb.csv`), and production countries (`programmazione_paesi.csv`).

After updating the CSV files, run the following from the project root:

```r
source("R/update-programmazione-storica.R")
update_programmazione_storica()
```

This updates the year pages and charts, source tables, genre and country pages, and section indexes. New sources need an existing source page with a title matching the `source` value in the database, except for `note_su_manifesti`. Add that value to the same `source` column, separated by commas when there are multiple sources. Its screenings appear directly on the sources index, grouped by year and month, without a separate source page.

To update just one section, run the corresponding file from the project root:

```text
Rscript R/update-anni.R
Rscript R/update-fonti.R
Rscript R/update-generi.R
Rscript R/update-paesi.R
```

Each section script is independent and updates only its section and index. The full-update script calls all four. In R, source the relevant file and call `update_anni()`, `update_fonti()`, `update_generi()`, or `update_paesi()`. Pass `render_index = FALSE` to skip that section's index; `update_anni(years = c(1948, 1960))` limits the annual pages to selected years.

To update specific pages, use their titles or database values. Names are case-insensitive, and multiple names can be supplied:

```r
source("R/update-fonti.R")
update_fonti(sources = "Calendario 1951", render_index = FALSE)
update_fonti(sources = c("Incam 1948-49", "Calendario 1951"), render_index = FALSE)

source("R/update-generi.R")
update_generi(genres = "Commedia", render_index = FALSE)
source("R/update-paesi.R")
update_paesi(countries = "Italy", render_index = FALSE)
source("R/update-anni.R")
update_anni(years = c(1948, 1960), render_index = FALSE)
```

With `render_index = FALSE`, only the selected pages are updated. By default, the entire section index and its charts are also regenerated from all the data. To update the poster-note table, which is part of the sources index rather than a separate page, use `update_fonti(sources = "note_su_manifesti")` with index rendering enabled.

Generated pages, tables, charts and indexes are overwritten. Edit index text in the corresponding `_index.Rmd` files, and review it when the data changes: the script does not rewrite the interpretation. Old year pages and charts are not deleted automatically.

Annual pages receive a year-specific description. Source pages without a description receive one based on the source title; existing source descriptions are preserved. New genre and country pages receive title-specific descriptions, and the previous generic generated descriptions are replaced during updates. Custom descriptions are preserved.

Genre and country pages use stable, section-based URLs (for example, `/programmazione-storica/generi/commedia/`) instead of deriving their URLs from a placeholder date. When an existing page is migrated, its previous dated URL is retained as a Hugo alias.

To regenerate all annual pages and their charts without updating other sections:

```r
source("R/update-anni.R")
update_anni()
```

To check the generators, run from the project root:

```text
Rscript R/test-generate-anni.R
Rscript R/test-update-programmazione-storica.R
```

## License

The archival documents and digitized materials in this collection are owned by Vito Sestito. All rights to his original content, including texts, photographs and datasets, are reserved. Third-party materials, including IMDb data, remain subject to their respective terms.

The project's original code and technical documentation are licensed under the [MIT License](LICENSE.md).