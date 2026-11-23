# Poster collection

The collection is final (2026-11-23). Hugo builds all poster pages from
`data/posters/films.json` and the committed web images in
`static/images/manifesti/`; neither changes and the R generator that produced
them was removed in H07 (it stays in Git history). The private originals in
`manifesti/` are never committed.

## How the pages are built

- Film pages (`/posters/films/<id>/`) and title-letter pages
  (`/posters/by-title/<letter>/`) are created by the content adapters
  `content/posters/films/_content.gotmpl` and
  `content/posters/by-title/_content.gotmpl` (H04). Letter `#` becomes `0-9`.
- The root, year, size, genre and browse-index pages are editable Markdown in
  `content/posters/`. Front matter selects the data (`layouts/posters/`,
  `layouts/partials/posters/`): `collection` (`printed` or `retro`), `category`,
  `size`, `year`, `genre`, `letter`, `browse`.
- The root and size indexes use the shortcode `poster-subsections`, which lists
  the child pages with their `description` and counts. Year pages show monthly
  galleries below their text; genre and year indexes list their children.
- Add a hero as in the historical programming pages: `image` in front matter
  for social metadata and a Markdown image in the body. Thumbnails open the
  keyboard-accessible lightbox; without JavaScript they link to the large image.

## Data (`data/posters/films.json`)

One record per film: IMDb or internal ID, title, production year, genres,
screening dates, sort key, letter, `extra` IMDb details and its posters
(category, size, number, orientation, alt text, thumbnail and large image with
dimensions). Retro posters are kept separate from the printed collection.

Sources used to build it: `static/data/programmazione_agende.csv`,
`programmazione_imdb.csv`, `programmazione_manifesti.csv` and
`posters_wiht_no_imdb_id.csv` (title, genre and production year come from IMDb,
then poster metadata, then screenings; 79 title conflicts and 14 ratio warnings
are listed in `static/data/manifesti_report.csv`). Only dates from
`programmazione_agende.csv` populate the year and month views: the poster
metadata file has no cinema screening dates (`Release Date`, `Created`,
`Modified` and `Date Rated` are not screening dates).

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
