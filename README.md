# Cinema Teatro Sestito

The [Cinema Teatro Sestito website](https://cinemateatrosestito.com/) documents the history of the cinema in San Vito sullo Ionio and its historical film programming.

The site uses [Hugo](https://gohugo.io/), [R](https://www.r-project.org/) and [blogdown](https://github.com/rstudio/blogdown). It uses Hugo 0.136.5 and a theme derived from [hugo-lithium-theme](https://github.com/jrutheiser/hugo-lithium-theme), modified by Yihui Xie.

## R Environment

The project uses `renv` to record R package versions in `renv.lock`. Open the
project with R 4.6.2; `.Rprofile` activates the project library. On a new
machine, restore the packages with:

```r
renv::restore()
```

After the first setup, restart the R session so the project library is active.
On a new machine, the first restore may require an internet connection if the
packages are not already cached. `renv` does not install R itself. Netlify
builds the existing Markdown files and assets with Hugo; it does not restore R
packages or knit `.Rmd` files.

## Preview

Open the RStudio project and run:

```r
blogdown::serve_site()
```

## Update Historical Programming

The database consists of three CSV files in [static/data/](static/data/):

- `programmazione_agende.csv`: screenings and sources.
- `programmazione_imdb.csv`: IMDb film details and genres.
- `programmazione_paesi.csv`: production countries.

### Update all sections

After updating the CSV files, run this from the project root:

```r
source("R/update-programmazione-storica.R")
update_programmazione_storica()
```

This updates annual pages and charts, source tables, and genre and country pages.

### Update individual sections or pages

From the project root, source the relevant script and call its function. With no selection, it updates all pages in that section. Alternatively, supply years or page titles/database values to update only those pages:

```r
source("R/update-anni.R")
update_anni()                              # All years
update_anni(years = c(1948, 1960))         # Selected years

source("R/update-fonti.R")
update_fonti()                             # All sources
update_fonti(sources = c("Incam 1948-49", "Calendario 1951"))

source("R/update-generi.R")
update_generi()                            # All genres
update_generi(genres = "Commedia")

source("R/update-paesi.R")
update_paesi()                             # All countries
update_paesi(countries = "Italy")
```

Names are case-insensitive, and multiple names can be supplied. The annual, genre and country scripts can also be run directly with `Rscript R/update-anni.R`, `Rscript R/update-generi.R` or `Rscript R/update-paesi.R`.

### Sources and section indexes

New sources need an existing source page whose title matches the database's `source` value. Separate multiple sources in that column with commas. The exception is `note_su_manifesti`: its screenings appear in the sources index, grouped by year and month, rather than on a separate page.

The update scripts do not render section indexes. To update an index and its charts, knit its `_index.Rmd` separately in RStudio. Edit and review the index text there when data changes; the scripts do not rewrite its interpretation.

### Generated content and metadata

Generated pages, tables and annual charts are overwritten; old annual pages and charts are not deleted automatically.

- Annual pages receive year-specific descriptions and use their monthly chart as the YAML `image`.
- Source descriptions are preserved. When available, the first image in the corresponding static folder is used as the YAML `image`.
- New genre and country pages receive title-specific descriptions; previous generic descriptions are replaced, while custom descriptions are preserved. Their YAML `image` points to the first chart of the corresponding section.
- Genre and country pages use stable, section-based URLs (for example, `/programmazione-storica/generi/commedia/`). When an existing page is migrated, its previous dated URL is retained as a Hugo alias.

## License

The archival documents and digitized materials in this collection are owned by Vito Sestito. All rights to his original content, including texts, photographs and datasets, are reserved. Third-party materials, including IMDb data, remain subject to their respective terms.

The project's original code and technical documentation are licensed under the [MIT License](LICENSE.md).