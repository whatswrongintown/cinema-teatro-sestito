# Cinema Teatro Sestito

The [Cinema Teatro Sestito website](https://cinemateatrosestito.com/) documents the history of the cinema in San Vito sullo Ionio and its historical film programming.

The site is built with Hugo (Extended), using a customised theme derived from
hugo-lithium-theme. Tables, charts, poster pages and the dashboard are all built
by Hugo from the datasets in `static/data/` and `data/`; no R is needed.

Netlify runs Hugo only.

## Local Setup and Build

Install Hugo 0.136.5 Extended (the version pinned in `netlify.toml`), then
preview or build the site from the project root:

```sh
hugo server
hugo
```

See the [project status](docs/project-status.md) for current decisions and the
[historical programming guide](docs/guides/historical-programming.md) for how the
data pages work.

## Project Documentation

The [documentation index](docs/README.md) links to current status, guides,
plans and proposals.

Project decisions, implementation details, development history, workflows, and future plans should be documented in `docs/`, not in this README.

## Repository Structure

```text
content/    Site content and articles
layouts/    Hugo templates and layouts
static/     Static assets, scripts and source datasets
data/       Hugo data files
docs/       Project documentation
public/     Generated Hugo output
resources/  Hugo cache and generated resources
```

## License

The archival documents and digitised materials in this collection are owned by Vito Sestito. All rights to original texts, photographs, and datasets are reserved.

Third-party materials, including IMDb data, remain subject to their respective terms.

The project's source code and technical documentation are licensed under the MIT License. See [LICENSE.md](LICENSE.md).
