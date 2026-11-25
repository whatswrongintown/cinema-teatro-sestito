# Visual design

The redesign (U07) gives the site the look of a working cinema and cultural
venue instead of a blog and statistics archive. Status: DOING; merged to `main` and deployed 2026-11-25: every page is in the new style (home,
posters, articles, archive, historical programming, Eventi, Progetto,
category and tag pages, the small pages and the 404). The Lighthouse check
runs on the deployed site (see Next steps).

Mockup (private, owner only): the "Cinema Sestito redesign" design canvas on
claude.ai, with the desktop home page, the visual system and the phone home
page with the menu open.

## Idea: the auditorium and the foyer

- Dark like the auditorium (`.tone-dark`) for what visitors look at: posters,
  the programme, the reopening, the header and the footer.
- Warm paper like the foyer (`.tone-light`) for what they read: stories,
  documents and the contact form.

## Tokens (`static/css/tokens.css`)

| Token | Light | Dark | Use |
| --- | --- | --- | --- |
| `--ink` | `#1A1512` | `#F3EBDD` | text |
| `--paper` | `#F4EDE1` | `#14100E` | background |
| `--paper-2` | `#EAE0CF` | `#1F1915` | cards, highlighted rows |
| `--muted` | `#6B5F55` | `#A89B8C` | meta text (AA on its own background) |
| `--curtain` | `#9E2A1F` | `#E0503F` | accent, calls to action, current state |
| `--brass` | `#A8823F` | `#C9A45C` | rules, figures, secondary buttons |
| `--rule` | `#D6C9B4` | `#3A2F27` | dividers |

`.tone-dark` redefines the tokens, so a component written with the variables
works on either surface. The reopening band on the home page overrides them
locally for its red background. Shared pieces in `tokens.css`: `.wrap` (1280 px
column with a fluid gutter), `.label` (condensed uppercase labels),
`.button` and `.button-ghost`, focus outlines and `prefers-reduced-motion`.

## Typefaces

Self-hosted variable WOFF2 files, Latin subset, in `static/fonts/`, declared in
`static/css/fonts.css` (SIL Open Font License, licence files beside them):

- Fraunces (roman and italic, weight 300-900): titles and text, the default
  for `body` and headings. The roman file is preloaded in `head.html`.
- Archivo (weight 400-800, width 62-125%): labels, dates, menu, buttons.

The charts use the same two typefaces: Archivo for labels and values, Fraunces
for chart titles. Merriweather was removed (2026-11-25) with the old chart
style; Lato was removed (2026-11-24) once no page used it.

## Charts (U14)

The SVG charts of the historical programming (`layouts/partials/grafici/`), the
poster charts (`poster-charts.css`) and the dashboard (`dashboard.css`) use the
design tokens: they sit on the paper of the page, with no background of their
own, and follow the light or dark tone. The SVG chart styles are in
`static/css/grafici.css` (classes `g-*`, part of the site bundle): curtain red
for bars, lines, areas and dots; brass for the second series and the 50% line;
heat-map tiles mix `--paper-2` into `--curtain` by a per-tile `--t` value; axes
in `--muted`; text in Archivo and titles in Fraunces. Keep colours out of the
SVG partials.

## Stylesheets

The site stylesheet is one file, built by Hugo Pipes in
`layouts/partials/css-bundle.html` (called from `head.html`): `fonts.css`,
`tokens.css`, `main.css` (base, header, menu, breadcrumbs, footer, poster grid
and contact form), `lightbox.css` and `editorial.css` (all page layouts),
joined in that order, minified and fingerprinted, for example
`/css/site.min.<hash>.css`. To add a stylesheet to the site, add its name to
the list in that partial. `poster-charts.css`, `dashboard.css` and every
script (`lightbox.js` in the footer, `cartellone.js`, `manifesti.js`,
`dashboard.js`) go through `layouts/partials/asset.html`, which minifies and
fingerprints one file and returns its URL.

The hash in the file name changes whenever the content changes, so browsers
never keep a stale copy after a deploy (during the prototype they did). Keep
the output in `css/`: the relative font paths in `fonts.css` (`../fonts/…`)
depend on it. The original files in `static/css` and `static/js` are still
copied unchanged to the build, so a page cached by a visitor from before the
deploy keeps working. Edit the sources in `static/`, never the generated
files. The old blog styles (`.content`, `.article-*`, `.archive*`) were
removed with the last old templates. Breadcrumbs are a dark strip that
continues the header.

## Header and footer (U09, U10)

- `layouts/partials/nav.html`: the wordmark "Cinema Teatro *Sestito*"
  (replaces the round avatar) and the `menu.main` entries from `config.yaml`;
  an entry with `params.cta: true` is drawn as a button. The current section
  gets `aria-current`. Below 900 px the menu is a native `popover` opened by a
  button: full screen, large tap targets, no JavaScript. Browsers without
  popover support show the list inline.
- `layouts/partials/footer.html`: venue line, the menu, the Posters
  subsections (`/posters` sections), contacts, credits and links to privacy,
  site map and source code.

## Home page (U08)

`layouts/index.html` calls one partial per section in
`layouts/partials/home/`; the content comes from the `params` of
`content/_index.md`, so the owner changes the selection without touching
templates:

| Section | Partial | Front matter |
| --- | --- | --- |
| Hero with three posters | `hero.html` | `occhiello`, `sottotitolo`, `manifestiHero` (film IDs) |
| Figures | `numeri.html` | none: counted from the datasets |
| In questi giorni | `cartellone.html` | none (see below) |
| Intro | in `index.html` | the page body |
| Section cards | `ingressi.html` | `ingressi`: `pagina`, `occhiello`, `titolo`, `testo`, `immagine`, optional `inquadratura` (CSS object-position) and `disegno` |
| Poster strip | `collezione.html` | `manifestiInEvidenza` (film IDs) |
| Stories | `storie.html` | `storie`: `pagina`, optional `immagine` |
| Reopening | `riapertura.html` | `riapertura`: `occhiello`, `titolo`, `testo`, `pagina`, `etichetta` |
| Contact form | `partials/contact-form.html` | none |

Helpers: `home/manifesto.html` returns a film's first printed poster from
`films.json` with its format label; `home/immagine.html` finds an image in the
page bundle, the home bundle or `static/` and resizes bundle images wider than
800 px to WebP (poster files are used as they are). The contact form moved
from a shortcode to a partial; it stays on the home page (decision in
`project-status.md`).

### "In questi giorni"

The screenings documented in the seven days around today, in every year: one
per year (a screening with a poster preferred), at most six spread over the
years, with the first one that has a poster shown large beside the list.

- `home/cartellone-dati.html` reads the screenings once and publishes
  `/cartellone/01.json` to `12.json` (30-85 KB each, arrays of date, title, two
  genres, source, film page, poster thumb, poster large, format).
- `home/cartellone.html` renders the selection for the build date, so the
  section works without JavaScript.
- `static/js/cartellone.js` (home page only) redoes the selection for the
  visitor's date from the monthly files. The rules are written twice, in the
  template and in the script: change both together.
- Every screening can appear, adult and erotic films included: the posters
  were public in the town square and are not explicit (owner, 2026-11-24).

## Pages in the new style

Every template wraps its content in `<main class="home">` and builds it from
the shared components of `editorial.css`: bands (`<section>`, `<article>`
or `<nav>` with `.tone-dark` / `.tone-light`), `.home-h2`, `.home-kicker`,
`.home-sub`, `.home-more`, `.home-numbers`, cards, chips, tiles, the
programme rows (`.shows`, `.show`) and the reading column (`.prose`).

### Generic pages, Eventi, indexes and 404

- `layouts/_default/single.html`: Progetto, privacy, site map, thank-you page
  and any page without its own template. Dark header (section, title,
  description, "Aggiornato il …" from `lastmod`), the text in the reading
  column; with three or more `##` headings (or `toc: true`) a sticky "In
  questa pagina" index sits beside the text. `ricordi: true` (Progetto) adds
  a red "Condividi un ricordo" band linking to the form on the home page.
- Eventi (`layouts/eventi/list.html`, `single.html`, partials in
  `layouts/partials/eventi/`): an event is a page in `content/eventi/` with
  `date` (publication, today or earlier, as Hugo does not build future
  pages) and in `params`: `inizio` ("2027-03-12T21:00", seconds optional),
  `tipo`, `luogo`, `ingresso`; optional `image`. Events still to come at the
  last build are listed as "I prossimi appuntamenti" in the programme style,
  the others under "Eventi passati"; with none to come the page shows
  "Sipario chiuso, per ora." The field list is also in the comment of
  `content/eventi/_index.md`. Since the list is decided at build time, an
  event moves to "passati" at the next deploy after it happens.
- `layouts/_default/list.html`: the category and tag indexes (terms as tiles
  with their counts) and the fallback for any other section (cards).
  Term pages use `layouts/_default/term.html`; do not add a
  `_default/taxonomy.html`, which Hugo would also use for the term pages.
- `layouts/404.html`: "Fuori programma", the owner's message and links to
  the sections; the page title is "Pagina non trovata".

### Cinema per adulti ed exploitation (U12)

The dedicated page (`/programmazione-storica/cinema-per-adulti/`) was removed
on 2026-11-25 at the owner's request (U16): the article "Le luci rosse del
Cinema Sestito" tells this chapter, and its front matter `aliases` keeps the
old URL working as a redirect. The posters are in the Posters genre page
"Per adulti"; the yearly share chart stays on the Generi index. These films
are not hidden anywhere on the site.

### Articles (Storie)

Templates `layouts/articoli/list.html` and `layouts/articoli/single.html`.

- List: dark header with the section text and its `image` (the ticket book,
  no longer repeated in the body), the newest story as the lead with a large
  image, then cards (image when the story has `image`, else a text card).
- Article: dark header with category, date, reading time, title, the
  `description` as summary (first letter capitalised) and author, plus
  "Aggiornato il …" when `lastmod` differs from `date`. The opening image is
  the bundle file named in `image`: `layouts/partials/articoli/apertura.html`
  resizes it (PNG to WebP, at most 1600 px) and, when the body starts with
  the same image, removes it from the body and uses its alt text as caption.
  So keep writing the hero as the first line of the body, as before.
  `image` may also be a file under `static/` (an absolute path such as
  `/images/manifesti/large/...`, e.g. a poster), and `imageCaption` sets the
  caption directly; the list page uses the same image. The
  text sits in a 700 px reading column (`.prose`) on paper: headings,
  footnotes, galleries (the shortcode's inline float layout is overridden),
  YouTube and the dashboard. Tags as links, then the older and newer stories.
- Posters inside an article: the shortcode `manifesto`
  (`layouts/shortcodes/manifesto.html`), for example
  `{{< manifesto id="tt0235686" lato="destra" didascalia="..." >}}`. `id` is
  the film ID of `data/posters/films.json`; the figure shows the film's first
  printed poster (opens in the image viewer) with an automatic caption (title
  linked to the film page, year, format, first screening). `lato="sinistra"`
  or `"destra"` floats a portrait poster beside the text from 1,100 px wide
  (it is centred below that and always for landscape posters);
  `didascalia` adds a sentence. The build fails if the film has no printed
  poster.
- The descriptions double as the summary under the title, so write them as
  a sentence for readers (some are short notes today, e.g. "articolo
  dedicato al fondatore…").

### Historical programming

Templates and data are described in `historical-programming.md` ("Page
templates"). In short: the landing page leads with figures, section cards
and a band per decade with its best-known posters (four section cards since
the adult films page was removed, U16); the indexes open with a short text
and its charts, then list the years, genres, countries or source types,
each source type with its own page of sources (U16, 2026-11-25); the detail pages show a poster strip, on year pages the charts,
then the tables as programme listings (dates as "dom 2 gen"). Charts and
dashboard use the site palette (see Charts, U14).

### Archive, categories and tags

- Archive page (`layouts/archivio/list.html`): dark header with the section
  text, the number of documents and three documents fanned out
  (`documentiHero` in `content/archivio/_index.md`, page paths); the
  categories as cards in the order and with the text of `categorie` (each
  links to its category page and counts its archive documents); then every
  document as a card (`partials/scheda.html`) in a timeline by decade.
- Document page (`layouts/archivio/single.html`): dark header with section
  and category, title, `description` and the document date (a date on
  1 January shows only the year, as the day is not known). The scans are the
  images that open the body: `partials/archivio/scansioni.html` takes that
  block out of the body and shows the images large, with their alt text as
  caption and the image viewer (bundle files, resized to 1,100 px for the
  page, original in the viewer; accented file names are matched through
  their URL-escaped form). Images later in the text, or after an opening
  line of text, stay in the text. Then a record card (date, category,
  topics, number of reproductions, fund) beside the rest of the body, and
  the previous and next documents by date. So keep writing a document as
  before: scan images first, then the transcription.
- Category and tag pages (`layouts/_default/term.html`): dark header with
  "Categoria" or "Argomento", the term and its number of pages, then every
  page as a card, oldest first. `content/categories/_index.md` and
  `content/tags/_index.md` give the indexes Italian titles (Categorie,
  Argomenti) for the breadcrumbs.

### Posters section (U11)

Landing page, list pages and film pages are described in
`posters.md`; shared pieces: `.chips` / `.chip` (neighbour links, current
page in curtain red), `.years` (year index), `.cards-posters` (genre and format
cards), `.posters-page .poster-grid` (larger thumbnails with titles) and the
film page classes `.film-*`.

## Next steps

See U07 in `project-status.md`: the redesign is merged and deployed, and the
Lighthouse check is done (U03). Still open: search, and the owner's texts
(reopening status, the article on adult and exploitation films).
