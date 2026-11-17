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
- [docs/implementation-guide.md](docs/implementation-guide.md): priorities, dependencies, resolution steps, affected/new files and acceptance checks for every open status item.
- [docs/historical-programming.md](docs/historical-programming.md): the R scripts, the data and the generated pages.
- [docs/ideas/website-improvement-ideas.txt](docs/ideas/website-improvement-ideas.txt): implemented feature notes, future image attachments, Legacy Starter references, and poster/search proposals.
- [docs/logs/](docs/logs/): dated historical audits, not the current backlog.

Hierarchy-based breadcrumbs and explicit gallery-input validation are implemented.
The homepage contact form is working according to the owner's Netlify check on
2026-11-17. Cinema-image attachments are requested but not implemented; the poster
catalogue and film search also remain future work. The status document separates
confirmed issues from pending checks and optional enhancements.

## License

The archival documents and digitized materials in this collection are owned by Vito Sestito. All rights to his original content, including texts, photographs and datasets, are reserved. Third-party materials, including IMDb data, remain subject to their respective terms.

The project's original code and technical documentation are licensed under the [MIT License](LICENSE.md).
