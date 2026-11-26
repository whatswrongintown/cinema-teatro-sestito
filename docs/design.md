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
| Reopening | `riapertura.html` | `riapertura`: `occhiello`, `titolo`, `testo`, `pagina`, `etichetta`; below the text, the latest step of the reopening timeline (see "Reopening timeline") |
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

### Reopening timeline (U15)

`/riapertura/` (`content/riapertura/index.md`, `type: riapertura`,
layout `layouts/riapertura/single.html`) tells the path to the reopening.
The owner updates only that file: its front matter `params.fasi` lists the
phases in order (`titolo`, `periodo`, `stato`: `fatto`, `in-corso` or
`prossimo`, `testo`, `voci`), and each step (`voci`) has `data`
(YYYY-MM-DD, left out for future steps), `titolo`, `testo` (Markdown),
optional `foto` (a file in `images/` of the bundle, or in the bundle of
`pagina`, resized to 900 px WebP) with `alt` and `didascalia`, and optional
`pagina` (a site page, linked). Layout: dark header with the
latest update and the phases as a progress strip (`aria-current="step"` on
the phase in progress), the opening photo (`image:`, also the share card),
the page text, then one band per phase with its steps on a vertical line
(filled dot done, red ring for the latest step with
`id="ultimo-aggiornamento"`, empty dot and dashed line for future steps;
the phase in progress is the dark band), and a "Vuoi dare una mano?" band.
`partials/riapertura/ultima.html` finds the latest dated step; the home
reopening band shows it with a link. Only photos chosen by the owner
(Drive "Foto"), resized to at most 1600 px before they are added; HEIC files
are converted with ImageMagick (`magick in.HEIC -auto-orient -resize
"1600x1600>" -strip -quality 84 out.jpg`; Windows has no HEVC codec here).
Styles: end of
`editorial.css`. Private people are named by first name only. Keep family
details general and publish only what the owner has approved (2026-11-26).

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
  dedicato al fondatore…"). Above 160 characters, add a short
  `seoDescription:` for search engines (the build warns; see `posters.md`,
  "Page metadata").

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

## Share cards (U17, U18)

What a link to the site shows on social networks and in chat apps (Open
Graph and Twitter metadata, `layouts/partials/head.html`). Every page shares
one 1200x630 JPEG card, with its width, height, type and alt text declared,
and `og:locale` `it_IT`.

Rule for every page, old and new (first match wins):

1. **A section card.** The main pages of Posters (landing, Per anno, Per
   formato, Per genere, Per paese, Per fonte, Per titolo, Retro) and of the
   historical programming (landing, Anni, Generi, Paesi, Fonti) have a
   ready-made collage, `share-card.jpg` in their bundle, named by front
   matter `shareImage:`. Each has the section name on the left (site fonts
   and colours) and six cropped tiles on the right, labelled with what the
   section is organised by (years, formats, genres, countries, sources,
   letters). Posters are picked at random among the better-known films (top
   40% by IMDb votes), without repeats; the Fonti card uses source scans.
2. **Its own image.** A page with front matter `image:` shares that image:
   articles (their hero), archive documents (their scan), historical sources
   (their first scan) and the other section pages with a hero. `image:` is a
   file in the page bundle or an absolute path under `static/` (for example
   `/images/manifesti/large/...`). **Every article must have `image:`**: it
   is both its hero and its share card, and the build warns about an article
   without one, or with an `image:` that does not exist. `imageCaption` (else
   the title) becomes the card's alt text.
3. **A poster, for pages that list films.** Posters list pages share the
   poster of their card (`posters/copertina.html`; letter pages the
   best-known film of that letter); year, genre, country and source pages of
   the historical programming share the first poster of their strip
   (`programmazione/manifesti.html`). Film pages have their first poster as
   `image:` (content adapter).
4. **The house card** for everything else (home, Il progetto, Eventi, the
   archive and taxonomy lists, small pages, and programme pages without any
   poster): `content/social-card.png`, `params.defaultImage`, with
   `params.defaultImageAlt`.

The logic is in `layouts/partials/social-image.html` (choice of image) and
`layouts/partials/social-card.html` (format). Every image is **cropped to
fill the card** (owner's choice, 2026-11-26, over whole images on a dark
background). An image taller than the card keeps the band 30% of the way
down, like CSS `object-position: center 30%`: on posters, documents and
photos this usually holds the title, the heading or the faces (Hugo's smart
crop picked worse areas). Wider images are cropped at the centre. A JPEG
that is already 1200x630 (the section cards) is used as it is.

Do not add other preview images (such as chart PNGs): give a page an
`image:`, or, for a new main section page, a section card.

**Making the cards.** Section cards: `docs/share-card/make-cards.ps1`, run
from the repository root (`& .\docs\share-card\make-cards.ps1`); it reads
`data/posters/films.json`, the programme CSVs and the source scans, renders
each card with Edge (headless) and writes the 13 `share-card.jpg` files. The
same `-Seed` gives the same cards (1956 is the published set); another seed
draws new posters. To add a section, add a card to the script and
`shareImage: "share-card.jpg"` to the section's `_index.md`. House card:
`docs/share-card/house-card.html` mirrors the home hero (kicker, wordmark
with "Sestito" in italic curtain red, the address and the three posters of
`params.manifestiHero`); the command to render it is in that file. Render
it again if the hero posters change.

The cards are about 1,200 processed images. Locally the first build after a
change to `social-card.html` takes over 10 minutes, then they come from the
image cache (on Netlify the cache is kept between deploys, see U01).

Platforms cache previews per URL: after a change, re-scrape a page in
Facebook's Sharing Debugger (also used by WhatsApp and Instagram) or LinkedIn's
Post Inspector; old previews in existing chats do not change.

## Next steps

The redesign (U07) is closed: merged, deployed and checked with Lighthouse
(U03). Still open elsewhere: search (U09, U11) and the owner's answers for
the article on adult and exploitation films (U12).
