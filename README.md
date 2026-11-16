# Cinema Teatro Sestito

The [Cinema Teatro Sestito website](https://cinemateatrosestito.com/) documents the history of the cinema in San Vito sullo Ionio and its historical film programming.

It is built with [Hugo](https://gohugo.io/) 0.136.5 (Extended), [R](https://www.r-project.org/) and [blogdown](https://github.com/rstudio/blogdown), using a theme derived from [hugo-lithium-theme](https://github.com/jrutheiser/hugo-lithium-theme). Netlify runs Hugo only: it does not run R, so generated files are committed.

## Preview

Open the RStudio project and run:

```r
blogdown::serve_site()
```

## Update the historical programming

After changing the CSV files in [static/data/](static/data/), run from the project root:

```r
source("R/update-programmazione-storica.R")
update_programmazione_storica()
```

This regenerates the annual pages, the tables in source, genre and country pages, and the charts of the section indexes. Single sections or pages can be updated too; see [docs/historical-programming.md](docs/historical-programming.md).

## Documentation

- [docs/project-status.txt](docs/project-status.txt): current status, open items, decisions and roadmap (start here).
- [docs/historical-programming.md](docs/historical-programming.md): the R scripts, the data and the generated pages.
- [docs/ideas/](docs/ideas/): ideas and technical plan (poster collection, search, contact form, breadcrumbs).
- [docs/log/](docs/log/): condensed audit logs.

## License

The archival documents and digitized materials in this collection are owned by Vito Sestito. All rights to his original content, including texts, photographs and datasets, are reserved. Third-party materials, including IMDb data, remain subject to their respective terms.

The project's original code and technical documentation are licensed under the [MIT License](LICENSE.md).
