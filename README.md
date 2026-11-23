# Cinema Teatro Sestito

The [Cinema Teatro Sestito website](https://cinemateatrosestito.com/) documents the history of the cinema in San Vito sullo Ionio and its historical film programming.

The site is built with:

- Hugo (Extended)
- R scripts for content generation (being phased out in favour of Hugo)

using a customised theme derived from hugo-lithium-theme.

Netlify runs Hugo only. Generated files are committed to the repository because Netlify does not execute R scripts during deployment.

## Local Setup and Build

Install Hugo 0.136.5 Extended (the version pinned in `netlify.toml`), then
preview or build the site from the project root:

```sh
hugo server
hugo
```

R with blogdown (`blogdown::serve_site()`) still works, but the project is
moving to Hugo only; see the [project status](docs/project-status.md). R is
currently still needed to regenerate the historical programming and poster
pages. Regenerate any required Markdown and charts locally and commit them
before deployment.

## Update Historical Programming

After modifying the datasets in `static/data/`, run:

```r
source("R/update-programmazione-storica.R")
update_programmazione_storica()
```

This regenerates:

- yearly programming pages
- source pages
- genre pages
- country pages
- index charts

See the [historical programming guide](docs/guides/historical-programming.md)
for requirements, partial updates, and dashboard deployment.

## Project Documentation

The [documentation index](docs/README.md) links to current status, guides,
plans, proposals, and historical audit logs.

Project decisions, implementation details, development history, workflows, and future plans should be documented in `docs/`, not in this README.

## Repository Structure

```text
content/    Site content and articles
layouts/    Hugo templates and layouts
static/     Static assets and source datasets
R/          R scripts used for content generation
docs/       Project documentation
public/     Generated Hugo output
resources/  Hugo cache and generated resources
```

## License

The archival documents and digitised materials in this collection are owned by Vito Sestito. All rights to original texts, photographs, and datasets are reserved.

Third-party materials, including IMDb data, remain subject to their respective terms.

The project's source code and technical documentation are licensed under the MIT License. See [LICENSE.md](LICENSE.md).
