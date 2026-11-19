# Cinema Teatro Sestito

The [Cinema Teatro Sestito website](https://cinemateatrosestito.com/) documents the history of the cinema in San Vito sullo Ionio and its historical film programming.

The site is built with:

- Hugo (Extended)
- R
- blogdown

using a customised theme derived from hugo-lithium-theme.

Netlify runs Hugo only. Generated files are committed to the repository because Netlify does not execute R scripts during deployment.

## Preview

Open the RStudio project and run:

```r
blogdown::serve_site()
```

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

For detailed information, see:

- `docs/historical-programming.md`

## Project Documentation

Detailed project documentation is maintained in the `docs/` directory.

Start here:

- `docs/project-status.txt`

Additional documentation:

- `docs/implementation-guide.md`
- `docs/historical-programming.md`
- `docs/ideas/website-improvement-ideas.txt`
- `docs/logs/`

Project decisions, implementation details, development history, workflows, and future plans should be documented in `docs/`, not in this README.

## Repository Structure

```text
content/    Site content and articles
layouts/    Hugo templates and layouts
static/     Static assets and source datasets
R/          R scripts used for content generation
docs/       Project documentation
public/     Generated Hugo output (do not edit)
resources/  Hugo cache and generated resources
```

## License

The archival documents and digitised materials in this collection are owned by Vito Sestito. All rights to original texts, photographs, and datasets are reserved.

Third-party materials, including IMDb data, remain subject to their respective terms.

The project's source code and technical documentation are licensed under the MIT License. See [LICENSE.md](LICENSE.md).
