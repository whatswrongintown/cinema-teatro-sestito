# Poster collection

The poster generator is a local, manual R workflow. Hugo and Netlify use the
generated content, JSON and reduced images; they do not read `manifesti/` or
run R. Originals are private local files and must not be committed.

## Requirements and running

From the project root, install the R packages `magick`, `readr`, `jsonlite` and
`yaml`, and place the originals in the six category folders inside `manifesti/`.
Then run:

```r
source("R/update-posters.R")
build_posters()
```

Alternatively run `Rscript R/update-posters.R`. If `manifesti/` is missing the
command stops before changing generated files. Commit the generated pages,
`data/posters/films.json`, `static/images/manifesti/` derivatives and
`static/data/manifesti_report.csv`, along with any intentional source changes.
Do not commit the originals or `.cache/posters/`. Run the site with
`hugo server` to review it. This R workflow is planned to move to Hugo
(item H04 in [project status](project-status.md#6-migration-to-hugo-only)).

## Sources and overrides

The generator reads `static/data/programmazione_agende.csv`,
`programmazione_imdb.csv`, `programmazione_manifesti.csv` and
`posters_wiht_no_imdb_id.csv` without changing them. Identifiers are strings,
and `0` in the screening CSV means no internal code. The supplementary CSV
provides titles and production years. For title, genre and production year,
the generator prefers IMDb metadata, then poster metadata, then screenings.
For internal codes, the supplementary CSV fills missing values. Title
disagreements are reported.

`programmazione_manifesti.csv` is joined by `Const` (IMDb ID). It has no
cinema-screening dates: `Release Date`, `Created`, `Modified` and `Date Rated`
are not screening dates. Only dates from `programmazione_agende.csv` populate
the year and month views. The report counts IMDb posters with no screening
date and explicitly records that zero screening dates come from this
metadata-only file.

The poster metadata columns are handled as follows:

| Columns | Use |
| --- | --- |
| `Const` | Join key |
| `Title`, `Year`, `Genres` | Title, production year and genres, subject to precedence |
| `Position` | List position, in film details |
| `Created`, `Modified` | List creation and modification dates, in film details |
| `Description` | Description, in film details when present |
| `Original Title`, `Title Type` | Original title and work type, in film details |
| `URL` | IMDb URL, in film details |
| `IMDb Rating`, `Num Votes` | IMDb rating and votes, in film details |
| `Runtime (mins)`, `Directors` | Runtime and directors, in film details |
| `Release Date` | Release date, in film details; not a screening date |
| `Your Rating`, `Date Rated` | Personal rating and its date, in film details when present |

These remaining columns are stored under `extra` in the film JSON. The
current CSV has no poster-size or poster-number key.

Edit `static/data/poster_overrides.csv` to correct a scan or exclude a poster:
`film_id,category,size,number,rotate,exclude`. Rotation is clockwise and must
be 0, 90, 180 or 270; `exclude` is TRUE or FALSE. A film ID is an IMDb ID or
`internal-` followed by its code. Unmatched overrides are reported.

## Output and browsing

The local `.cache/posters/posters_index.rds` has one row per poster, with
film metadata, screening months, dimensions and derivative paths. Image
dimension and derivative caches use source paths, modification times and file
sizes. The Hugo data file contains one record per film with its posters and
dimensions. Front matter selects the data for year, category and size, genre,
title and film pages. Retro is separate from the printed collection.
Regeneration removes obsolete generated pages and empty managed scaffolds;
pages containing editorial text are retained.

## Editing section pages

The root, browse indexes, year, size and genre pages are editable. On first
generation the script scaffolds them and marks them `posters_managed: true`.
On later runs it updates only structural keys (`type`, `layout`, `browse`,
`collection`, `category`, `size`, `year`, `genre`, `letter`, `film_id` and
`weight`). The title, description, image key, other metadata and body are
yours. If an empty section still contains editorial text, its page is retained
and reported. Letter and film pages remain fully generated.

Add a hero using the historical-programming convention: set `image` in front
matter for social metadata and insert a Markdown image in the body where it
should appear. Add charts as Markdown or HTML images in the body. The root
and size index scaffolds contain `{{< poster-subsections >}}`; descriptions
come from the corresponding child pages' `description` fields. Year pages
show monthly galleries below their body; genre and year indexes append links.
Thumbnails open the existing keyboard-accessible lightbox; without JavaScript,
their links open the large derivative directly.

Format descriptions are based on
[Original Film Art](https://nz.originalfilmart.com/pages/sizes-italy),
[Art of the Movies](https://artofthemovies.co.uk/blogs/original-movie-posters/italian-movie-posters-names-and-sizes)
and [Mauvais Genres](https://www.mauvais-genres.com/en/content/45-movie-poster-size).
The sources differ on the dimensions of one foglio; physical sheet sizes can vary.

Web images are never enlarged: thumbnails are at most 400 pixels wide and
larger images are at most 1400 pixels on their longest side. The generator
applies EXIF orientation and manual rotation, converts to sRGB and strips
metadata. It uses WebP when available, otherwise progressive JPEG. Quality is
lowered to a floor of 60 if needed; remaining size exceptions and other
warnings are in `manifesti_report.csv`. Unsupported filenames are skipped and
reported rather than guessed. The local cache also records generated
derivatives so stale derivatives whose sources disappeared can be removed.

## Checks

Run `Rscript tests/test-posters-helpers.R` for synthetic parser, matching,
EXIF, rotation, caching, derivative and page-data checks. The command creates
and removes its own small files; it never reads the original collection.
