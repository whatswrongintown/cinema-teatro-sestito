# Visual design

The redesign (U07) gives the site the look of a working cinema and cultural
venue instead of a blog and statistics archive. Status: DOING 2026-11-24, home
page prototype on the branch `redesign/home-prototype`; the inner pages still
use the old styles under the new header and footer.

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

- Fraunces (roman and italic, weight 300-900): titles and home page text. The
  roman file is preloaded in `head.html`.
- Archivo (weight 400-800, width 62-125%): labels, dates, menu, buttons.

Merriweather and Lato stay: the old pages still use them, and the SVG charts
place their labels with Merriweather widths (`data/grafici/merriweather.json`),
so the chart font must not change.

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
- Films tagged "Per adulti" are left out of the home selection only; they stay
  in the programme pages. TODO 2026-11-24: owner to confirm.

## Next steps

See U07 in `project-status.md`: article, archive, poster and programme
templates in the new style, then CSS fingerprinting with Hugo Pipes (browsers
kept stale CSS during the prototype).
