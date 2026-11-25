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
- Look (2026-11-24, branch `redesign/home-prototype`, see `design.md`): every
  Posters page loads `static/css/editorial.css`. `layouts/partials/posters/page.html`
  renders the landing page (`posters/landing.html`) or, for list pages, a dark
  header (title, description, count from `posters/count.html`, links to the
  neighbouring pages), the page text when there is any (the
  `<!-- Write your text here -->` placeholder counts as empty), then:
  - `browse: year`: years by decade, each with its number of films;
  - `browse: genre` and `browse: size`: cards with a representative poster
    from `posters/copertina.html` (the film with most IMDb votes, portrait
    first, no film twice on a page);
  - `browse: title`: letter links and the paginated gallery;
  - year pages: month links and one gallery per month, plus a link to that
    year's programme; other pages: the paginated gallery (60 per page).
  Gallery cards (`posters/gallery.html`) show the title (a link to the film
  page) and the production year (in a fixed-height block when drawn to scale).
- Posters to scale (U05, 2026-11-25): when a gallery (`posters/gallery.html`,
  one per month on year pages) or a film page's posters
  (`posters/film-images.html`) mix formats, the grid gets the class
  `is-to-scale` and every thumbnail is drawn at the real size of its sheet.
  `posters/sheet-size.html` turns the format (`size`, "AxB") into width and
  height in cm, oriented like the scan (sheet area from the format, aspect
  ratio from the thumbnail, so a landscape 50x70 fotobusta is 70 wide). The
  templates set `--w`/`--h` on each card and `--max-w`/`--max-h` on the grid;
  `editorial.css` ("Posters to scale") picks one px-per-cm scale per gallery so
  the largest sheet is at most 400 px wide, 440 px tall and fits the row
  (container query units), lays the cards out as a wrapping row with image
  bottoms aligned, and keeps cards at least 7rem wide for the titles (clamped
  to two lines). The scale is per gallery, so two month galleries on one year
  page can use different scales. Single-format galleries (the format pages)
  keep the uniform grid.
- Landing page: front matter `occhiello`, `sottotitolo`, `introTitolo`,
  `ingressiOcchiello`, `ingressiTitolo` and `ingressi` (the cards, same
  fields as on the home page). "Manifesto del giorno": `posters/indice.html`
  picks a film by day number modulo the pool (all films with a printed
  poster) for the build date and publishes `/posters/indice.json`; `static/js/manifesti.js`
  redoes it for the visitor's date and drives "Un manifesto a caso".
- Film pages (`layouts/posters/film.html`): main poster large (lightbox),
  original title, director, year, runtime, genres (linked to the genre pages),
  IMDb rating and link; the screenings from the programming data
  (`posters/proiezioni.html`, by IMDb ID, with source and a link to the year's
  programme; films without IMDb ID fall back to `screening_dates`); every
  printed and handwritten poster; previous and next film by title
  (`posters/indice.html`). The internal IMDb list fields (position, created,
  modified, personal rating) are no longer shown.
- Retro (`content/posters/retro/_index.md`, rewritten 2026-11-25, U06): what
  these posters are, in the owner's words: when a film had no poster, the
  owner's grandfather took a poster of another film, turned it over and wrote
  the title by hand on the back (hence "Retro"), often with the show time and
  some cast names, each time in different colours; the handwriting is what
  makes them special. They are called "scritti a mano" (not "dipinti") on the
  landing card, the landing figures and the film page. Then the figures, as a
  short list: of the 138 films with one, 106 were produced before 1970; of the
  130 with a screening date, 124 were first shown between 1956 and 1979 and
  none in the 1980s; none is an adult film (the median production years, 1967
  against 1974 for printed posters only, were dropped as hard to follow).
  Update the figures only if `films.json` changes (it is final). The gallery
  has no size labels: it is drawn to scale (U05).
- `image` in front matter is used for social metadata. Thumbnails open the
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

Count check (DONE 2026-11-25, explained and confirmed by the owner, data not
changed): the chart CSVs add up to
1,960 dated posters + 527 undated, while the recording file
(`programmazione_manifesti.csv`, 1,064 poster records) holds 2,038 posters and
`films.json` 1,787. The 1,960 is not a number of posters: `poster_section.R`
builds `film_years` as one row per poster and *screening year*, so a poster of a
film shown in several years is counted in each of them (200 of 859 dated poster
records, up to 5 years; 449 extra counts). Counted once, 1,511 posters have a
screening date (1,511 + 527 = 2,038). The same inflation affects the format and
genre decade totals (1,712 distinct poster-decade counts instead of 1,960; e.g.
1970s 762 against 869 published). The year chart is still a valid "posters in use
that year"; the captions state that repeats are counted each year. The owner
confirmed the data is correct (2026-11-25): the CSVs stay as they are and are
not regenerated to count each poster once per decade.

Genre chart (changed 2026-11-24): posters without a screening date are included
in a "Senza data" column (CSV decade `senza_data`), because a film's genre does
not depend on when it was screened; this adds Noir (6 undated posters). The
genre Drammatico is excluded (almost every film carries it; the filter in
`poster_section.R` now says `"Drammatico"`, it used to be lowercase and removed
nothing). `posters_genre_by_decade.csv` was regenerated with a Python port of
the script, checked to reproduce the previous published CSV before the two
changes. Still not in the chart: 15 titles (23 posters) whose IMDb entry has no genres
(or, for Speed and the space-prefixed const of poster 954, is missing from
`manifesti_imdb.csv`). The owner checked IMDb: they have no genre information, so
they stay out of the genre chart on purpose (decision 2026-11-24), together with
52 posters (45 records) that have no `const`. The Drammatico page under
`posters/by-genre/` stays, since a film may have Drammatico as its only genre.

About the source files: the repository's `static/data/programmazione_manifesti.csv`
is the IMDb export with extra metadata. The poster recording file used by
`poster_section.R` (also named `programmazione_manifesti.csv`, not in this
repository) was built from an IMDb export plus one column per format holding the
number of posters; its `data` column is not used (the same dates are already in
`programmazione_agende.csv`, which provides all screening dates). In that file,
poster 943 had a space-only cell in `manifesto_100x140` and poster 954 a leading
space in `const`; both were cleaned in the owner's copy. Some titles in it also
have mojibake (for example `TrinitÃ `), not changed. The 251 difference between the recording file (2,038) and `films.json` (1,787)
(analysed 2026-11-24): 895 of the 1,065 recording records match `films.json`
exactly; for 120 films the recording has more posters than there are images, by
up to 9 (for example `tt0112883`: 9 recorded 100x140 copies, 1 image), and
never fewer. By format the extra recorded posters are 100x140: 131, 33x70: 82,
50x70: 23, 140x200: 6, mostly 1990s films. This is duplicate copies of the
same poster (one image per distinct poster in `films.json`, every physical copy
in the recording file). Confirmed by the owner 2026-11-24: duplicates were
recorded but photographed once. So the charts count recorded copies, while the
gallery shows distinct images; the three chart captions say so.

The 1966 peak (152 posters against 15 in 1965): it is not a programming effect,
`programmazione_agende.csv` has 154 screenings in 1965 and 215 in 1966. What
changes is how many screenings are linked to a poster: 6 films in 1965, 61 in
1966, 50 in 1967, 31 in 1968. Confirmed by the owner (2026-11-25): the data is
correct; the 1966 posters were, probably by chance, saved and stored
correctly, while fewer from the earlier years survived.
Owner's oral testimony (2026-11-24): the owner's father tried to keep most posters, and
the grandfather had at first given many away, especially to children in the
1950s and 1960s. The year intro (`by-year/_index.md`) cites it as "racconto di
famiglia"; the exact year is unknown, so it is not tied to 1966.

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
