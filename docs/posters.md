# Poster collection

The collection is final (2026-11-23). Hugo builds all poster pages from
`data/posters/films.json` and the committed web images in
`static/images/manifesti/`; neither changes and the R generator that produced
them was removed (it stays in Git history). The private originals are not part
of the repository.

## How the pages are built

- Film pages (`/posters/films/<id>/`) and title-letter pages
  (`/posters/by-title/<letter>/`) are created by the content adapters
  `content/posters/films/_content.gotmpl` and
  `content/posters/by-title/_content.gotmpl`. Letter `#` becomes `0-9`.
- The root, year, size, genre and browse-index pages are editable Markdown in
  `content/posters/`. Front matter selects the data (`layouts/posters/`,
  `layouts/partials/posters/`): `collection` (`printed` or `retro`), `category`,
  `size`, `year`, `genre`, `letter`, `browse`. The root and the four browse
  indexes use `layout: browse`; do not name a layout `index`, which Hugo
  (0.146+) reserves, so those pages would fall back to the generic list.
- The root and size indexes use the shortcode `poster-subsections`, which lists
  the child pages with their `description` and counts. Year pages show monthly
  galleries below their text; genre and year indexes list their children.
- Add a hero as in the historical programming pages: `image` in front matter
  for social metadata and a Markdown image in the body. Thumbnails open the
  keyboard-accessible lightbox; without JavaScript they link to the large image.
  Index pages with `image: ''` share the nearest parent's image (in the end the
  Posters hero). Film pages get `image:` from the adapter: the large image of
  the first printed poster, or of the first poster if there are only retros.

## Data (`data/posters/films.json`)

One record per film: IMDb or internal ID, title, production year, genres,
screening dates, sort key, letter, `extra` IMDb details and its posters
(category, size, number, orientation, alt text, thumbnail and large image with
dimensions). Retro posters are kept separate from the printed collection.

Sources used to build it: `static/data/programmazione_agende.csv`,
`programmazione_imdb.csv` and `programmazione_manifesti.csv` (title, genre and
production year come from IMDb, then poster metadata, then screenings). The
build reports, the list of posters without an IMDb ID and the empty overrides
file were deleted on 2026-11-23 as no longer needed. Only dates from
`programmazione_agende.csv` populate the year and month views: the poster
metadata file has no cinema screening dates (`Release Date`, `Created`,
`Modified` and `Date Rated` are not screening dates).

## Charts in the Posters subsections (DONE 2026-11-24)

Each subsection index page shows one chart, through the shortcode
`{{< poster-charts "<name>" >}}` (`layouts/shortcodes/poster-charts.html`, which
also links `static/css/poster-charts.css`):

- `content/posters/by-year/_index.md` ("anni"): `layouts/partials/posters-year-chart.html`,
  inline SVG bar chart of posters per screening year (every year from first to
  last, 0 where empty); the caption gives the posters without a screening date.
- `content/posters/by-size/_index.md` ("formati"): `posters-format-heatmap.html`,
  decades by format.
- `content/posters/by-genre/_index.md` ("generi"): `posters-genre-heatmap.html`,
  decades by genre, sorted by total.

The two heat maps are HTML tables built by the shared
`layouts/partials/posters-heatmap.html`. Colours follow the historical
programming charts: grey `#E5E5E5` to mint `#CBF8DF` (CSS `color-mix`, square-root
scale), mint bars with the `#7fbf9f` edge of `dashboard.css`; empty cells show no
number.

Each of these `_index.md` files also holds the Italian introduction that
explains its chart. As in the historical programming pages, the year index lists
the years grouped by decade (links only) and the genre and size lists show no
counts (the Posters root list still does).

Data (aggregates of the poster database, final): `static/data/posters_year_counts.csv`,
`posters_no_year.csv`, `posters_format_by_decade.csv`, `posters_genre_by_decade.csv`.
They are read with `resources.Get | transform.Unmarshal` (`getCSV` no longer
exists in Hugo 0.170.1); combinations missing from the CSVs count as 0. The
site has no global CSS variables, so `poster-charts.css` declares its own,
copied from `main.css` and `dashboard.css`.

Open check (2026-11-24, explained, data not changed): the chart CSVs add up to
1,960 dated posters + 527 undated, while the recording file
(`programmazione_manifesti.csv`, 1,064 poster records) holds 2,038 posters and
`films.json` 1,787. The 1,960 is not a number of posters: `poster_section.R`
builds `film_years` as one row per poster and *screening year*, so a poster of a
film shown in several years is counted in each of them (200 of 859 dated poster
records, up to 5 years; 449 extra counts). Counted once, 1,511 posters have a
screening date (1,511 + 527 = 2,038). The same inflation affects the format and
genre decade totals (1,712 distinct poster-decade counts instead of 1,960; e.g.
1970s 762 against 869 published). The year chart is still a valid "posters in use
that year"; the captions state that repeats are counted each year. To count each
poster once per decade, use `distinct(internal_code, decade)` in the decade
charts.

Genre chart (changed 2026-11-24): posters without a screening date are included
in a "Senza data" column (CSV decade `senza_data`), because a film's genre does
not depend on when it was screened; this adds Noir (6 undated posters). The
genre Drammatico is excluded (almost every film carries it; the filter in
`poster_section.R` now says `"Drammatico"`, it used to be lowercase and removed
nothing). `posters_genre_by_decade.csv` was regenerated with a Python port of
the script, checked to reproduce the previous published CSV before the two
changes. Still not in the chart: 15 titles (23 posters) whose IMDb entry has no
genres in `manifesti_imdb.csv` or is absent from it (poster codes 26, 125, 390,
830, 855, 890, 954, 963, 1057, 1060, 1068, 1072, 1251, 1257, 1289; Speed, 1068,
has genres in `programmazione_imdb.csv`), plus 52 posters (45 records) with no
`const`. In the recording file, poster 943 had a space-only cell in
`manifesto_100x140` and poster 954 a leading space in `const`; both were cleaned
in the owner's copy (that file is not in this repository; the repo's
`static/data/programmazione_manifesti.csv` is a different, IMDb-style file).
The recording file also has mojibake in some titles (for example `TrinitÃ `)
and two dates in one cell for posters such as 1009 (not changed). The 251 difference between the
recording file (2,038) and `films.json` (1,787) is unexplained. The 1966 peak
(152 against 15 in 1965) is still to be checked.

## Images

Thumbnails are at most 400 px wide and large images at most 1400 px on their
longest side, never enlarged, in sRGB with metadata stripped, as WebP. The
collection holds 1,787 posters for 1,057 films. Do not modify or regenerate
`static/images/manifesti/`.

Format descriptions on the size pages are based on
[Original Film Art](https://nz.originalfilmart.com/pages/sizes-italy),
[Art of the Movies](https://artofthemovies.co.uk/blogs/original-movie-posters/italian-movie-posters-names-and-sizes)
and [Mauvais Genres](https://www.mauvais-genres.com/en/content/45-movie-poster-size).
The sources differ on the dimensions of one foglio; physical sheet sizes can vary.
