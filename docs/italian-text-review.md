# Italian text review (2026-11-27)

A review of the Italian text visitors see on the site: page bodies, front
matter shown on the page (titles, descriptions, captions, alt text), Hugo
template strings, chart labels, JavaScript messages and the data that fills
the tables and poster pages. Nothing on the site was changed. Each issue gives
examples, where the text comes from, and options. The owner chooses; no option
is recommended.

Items already listed in U30 (`story-research.md`, section 3) are marked
**[U30]** and only summarised here. The calculations behind V1 and N2, the
classification of the F1 titles, and the sources for V6, V7 (Incom) and X1
(Mongiardo, MGM) are in `italian-text-evidence.md`.

## 1. Method and scope

- Read in full: every hand-written page in `content/` (home, project, archive,
  articles, reopening, posters and programming landing pages, privacy, thanks,
  sitemap), every archive document page, and the strings in `layouts/`,
  `static/js/` and `config.yaml`.
- Generated pages: built the site with `hugo` into `public/` (the normal build
  output) and extracted the visible text of all 1,885 HTML pages, then read one
  or more examples of every page type (home, film, letter, year, format, genre,
  country, source, retro, year of programming, source document, genre, country,
  archive list and single, article list and single, categories, tags, events,
  reopening, 404). Strings repeated across pages were counted, not read 1,885
  times.
- Film titles: compared by IMDb ID between `data/posters/films.json` and
  `static/data/programmazione_agende.csv` with a script (813 shared films).
- Historical transcriptions inside archive pages (the text of the 1944 deeds,
  the 1955 police report, the 1957 letter, etc.) reproduce the originals. Their
  old spelling and grammar are not reported as inconsistencies; only editorial
  text around them is.
- "R scripts": the generators were removed on 2026-11-23 (`42568359`). The
  pages they wrote are now static Markdown. Where a file was first written by a
  script, the origin column names the script; editing the file is now the only
  way to change it.

### How origins are labelled

| Label | Meaning | Where to change it |
| --- | --- | --- |
| Manual | Hand-written Markdown | the file |
| Ex-R (`script`) | Markdown first written by an R generator, now static | the file (all copies of the pattern) |
| Template | Hugo template or shortcode | the file in `layouts/` |
| JS | Browser script | `static/js/` |
| Data (CSV) / Data (films.json) | Dataset, declared final on 2026-11-23 | the dataset, or a display rule in a template |
| Hugo default | Hugo behaviour, no project text | `config.yaml` or term pages |

## 2. Summary

| # | Category | Issue | Origin |
| --- | --- | --- | --- |
| V1 | Vocabulary | "proiezioni", "voci", "film", "date" for the same count | Template, Manual, Ex-R |
| V2 | Vocabulary | "registro", "database", "archivio delle proiezioni" | Manual |
| V3 | Vocabulary | Names of the cinema | Manual, Template, Ex-R |
| V4 | Vocabulary | Section and navigation names | config, Template, Manual |
| V5 | Vocabulary | Poster terms and labels | Template, Manual |
| V6 | Vocabulary | Agendas called "delle case di distribuzione" | Manual (fonti pages), Template |
| V7 | Vocabulary | Proper names spelled two ways | Manual, Data (CSV) |
| V8 | Vocabulary | English words in Italian text | Template, JS, Manual |
| V9 | Vocabulary | Archive category names | Manual |
| R1 | Register | Academic, personal and promotional voices side by side | Manual |
| R2 | Register | 404 page tone | Template |
| R3 | Register | Moral judgement in a chart caption | Template |
| P1 | Person | tu / voi / noi / io | Manual, Template |
| P2 | Person | Author and founder share a name | Manual, Template |
| P3 | Person | Masculine generic forms | Template |
| T1 | Tenses | Historic present mixed with past tenses | Manual |
| T2 | Tenses | Isolated tense slips | Manual |
| C1 | Capitalisation | Title Case in page titles | Manual |
| C2 | Capitalisation | Category and tag names | Hugo default, Manual |
| C3 | Capitalisation | Descriptions starting lowercase | Manual, Template |
| C4 | Capitalisation | Genres, months, titles of office, "Cinema" | Manual, Template, Ex-R |
| C5 | Capitalisation | Source names | Data (CSV), Manual |
| D1 | Dates | Founding year 1946 vs 1948/1949 | Manual, Template [U30] |
| D2 | Dates | Wrong or contradictory dates in "Gli anni d'oro" | Manual [partly U30] |
| D3 | Dates | "Cinquant'anni di cartellone" | Manual, Template |
| D4 | Dates | Reopening chronology vs project page | Manual |
| D5 | Dates | Date and range formats | Manual, Template, Data |
| N1 | Numbers | English decimal and thousands separators | Template, JS |
| N2 | Numbers | Totals that do not match | Template, Manual |
| N3 | Numbers | Format sizes written four ways | Template, Manual |
| F1 | Film titles | One film, two titles (posters vs programming) | Data |
| F2 | Film titles | One film, several titles inside the CSV | Data (CSV) |
| F3 | Film titles | Capitalisation and punctuation inside titles | Data |
| F4 | Film titles | Straight vs curly apostrophes and ellipses | Template |
| F5 | Film titles | Titles in running text | Manual |
| F6 | Film titles | Possible misspellings in the data | Data |
| F7 | Film titles | Alphabetical sorting of "A ..." | Data (films.json) |
| G1 | Generic / AI-like | Stock academic phrasing | Manual |
| G2 | Generic / AI-like | Phrases repeated across pages | Manual |
| G3 | Generic / AI-like | Promotional or empty sentences | Manual, Template |
| X1 | Accuracy (seen in passing) | Misquotation, MGM, rating scale | Manual, Template |
| X2 | Punctuation (related) | Quotation marks, dashes, spacing | Manual |

## 3. Vocabulary

### V1. One count, four names: "proiezioni", "voci", "film", "date"

The methodology says the charts count database entries, not screenings:
"Le tabelle e i grafici presenti nel sito rappresentano le voci registrate nel
database, non il numero effettivo delle proiezioni." The rest of the site
mostly calls the same number "proiezioni", sometimes "film".

- The same yearly numbers (1948: 62, 1949: 112 ...) are labelled four ways:
  - "62 proiezioni" on the Anni index cards (`layouts/programmazione-storica/anni/list.html`, Template);
  - "Voci di programmazione registrate per anno dal 1948 al 1957" (chart alt in
    `content/articoli/2023-04-27-la-nascita-del-cinema-a-san-vito/index.md`, Manual);
  - "Numero di film proposti per anno" and axis "Numero di film"
    and "Frequenza dei film proposti dal 1948 al 2004"
    (`layouts/partials/grafici/articolo.html`, `film-per-anno.html`, Template);
  - "Numero di date registrate per mese" (`static/js/dashboard.js`, JS).
- Home: "5.479 proiezioni documentate" (`layouts/partials/home/numeri.html`, Template).
- Film pages: "1 proiezione documentata", "3 proiezioni documentate"
  (`layouts/posters/film.html`, Template, about 1,000 pages).
- Year pages: chart "Proiezioni documentate per mese", "Totale proiezioni: 215",
  axis "Numero di proiezioni", directly above the sentence "non il numero delle
  singole proiezioni" (`layouts/partials/grafici/anno-mensile.html` Template;
  sentence in `content/programmazione-storica/anni/*/index.md`, Ex-R `update-anni.R`).
- "Le luci rosse": "291 proiezioni di film classificati «per adulti»", table
  header "Proiezioni di film per adulti", "241 proiezioni con incasso noto",
  then "713 voci su 1.586" in the same article
  (`content/articoli/2026-11-24-le-luci-rosse-del-cinema-sestito/index.md`, Manual).
- Country index: "2.777 proiezioni" for Italy; the Italy page says "2.325 film"
  (`layouts/programmazione-storica/paesi-di-produzione/list.html`,
  `layouts/programmazione-storica/single.html`, Template). Both are right
  (entries vs distinct films) but the reader is not told.

Options:
- A. Keep "proiezioni" everywhere and change the methodology wording to say
  that a "proiezione" on this site means a dated entry.
- B. Use "voci" (or "date") wherever the number is a count of entries, and
  "film" only for distinct films; keep "proiezioni" for prose about real
  screenings.
- C. Keep labels short ("proiezioni") but add one fixed explanatory line under
  every chart and total that counts entries.

### V2. "registro", "database", "archivio delle proiezioni", "cartellone"

- "registro delle proiezioni", "il registro segna", "Il registro classifica
  ogni film con più generi" (luci rosse, Manual); "registro della programmazione"
  (`content/posters/retro/_index.md`, Manual); "I dati provenienti dal registro
  delle proiezioni" (`content/articoli/2025-11-05-gli-anni-d-oro-del-cinema-teatro-sestito/index.md`, Manual).
- Methodology: "non costituiscono un registro completo"; "ho costruito un
  database da zero" (Manual). There is no single original register: the data
  were built from 94 sources.
- "Archivio delle proiezioni del Cinema Teatro Sestito dal 1948 al 2004"
  (`content/programmazione-storica/_index.md`, description, Manual).
- "Il database interattivo è progettato per offrirvi un accesso senza
  precedenti al ricco database" vs description "Applicazione interattiva"
  (`content/articoli/2023-09-23-esplora-la-storia-cinematografica-di-san-vito-sullo-ionio/index.md`, Manual).
- "Fonti primarie - tra cui registri, appunti, e calendari"
  (`content/programmazione-storica/_index.md`, Manual), while the source types
  are agende, calendari, rubriche, appunti, note sui manifesti.

Options:
- A. "registro ricostruito" (or "registro") as the one name for the dataset,
  defined once in the methodology.
- B. "database" in technical text, "programmazione ricostruita" in prose; no
  "registro".
- C. Leave the words, add a glossary line to the methodology.

### V3. Names of the cinema

On-page forms: "Cinema Teatro Sestito", "Cinema Sestito", "cinema Sestito",
"il Sestito", "il Cinema" (common noun with capital), "Cinema di Piazza Mario
Polerà", "cinema “Sestito”" (transcriptions).

- "cinema Sestito" (lowercase) in `content/posters/_index.md` (description,
  "La raccolta del cinema Sestito", body), `content/posters/by-size/_index.md`,
  `content/posters/by-year/_index.md`, `content/programmazione-storica/_index.md`,
  `.../anni/_index.md`, `.../generi/_index.md`, `.../paesi-di-produzione/_index.md`
  (Manual). The posters landing has "Cinema Sestito" in `seoDescription` and
  "cinema Sestito" in `description` of the same file.
- "Il Sestito programmava anche molti film", "Il Sestito proiettò per l'ultima
  volta nel 2004" (luci rosse); "In sala al Sestito" (film pages, Template);
  "Accadde al Sestito" (home, Template).
- "la storia del Cinema", "del Cinema" as a common noun: metodologia ("La
  ricostruzione ... del Cinema", "storia del Cinema"), interview ("storia del
  Cinema"), `content/archivio/_index.md` ("archivio del Cinema",
  "patrimonio documentario del Cinema"), chart title "Le prime stagioni del
  Cinema (1948–1957)" (Template).
- The site is "Cinema Teatro Sestito" but the 1957–1959 decree, contracts and
  letters say "Cinema Sestito"; the articles say "Teatro" was added with the
  new hall ("Il nuovo *Cinema Teatro Sestito*", anni d'oro), while the home and
  footer use "Cinema Teatro Sestito" for 1946–2004.

Options:
- A. "Cinema Teatro Sestito" on first mention, then "il Cinema Sestito" /
  "la sala"; "cinema" lowercase when common noun.
- B. Historical name by period ("Cinema Sestito" before 1959, "Cinema Teatro
  Sestito" after), site name unchanged.
- C. Also allow the colloquial "il Sestito", but only in the personal-voice
  pages (see R1).

### V4. Section and navigation names

| Section | Names used | Where |
| --- | --- | --- |
| Articles | "Storie" (menu, footer), "Articoli e racconti" (page title, sitemap), "Racconti e memorie" (home card), "Racconti dalla sala" (home heading), "8 storie", "Tutte le storie →" | `config.yaml`, `content/articoli/_index.md`, `content/_index.md`, `layouts/articoli/list.html`, `layouts/partials/home/storie.html` |
| Programming | "Programmazione" (menu), "Programmazione storica", "Cinquant'anni di cartellone", "Quattro modi di leggere il cartellone" | `config.yaml`, `content/programmazione-storica/_index.md`, Template |
| Posters | "Manifesti" (menu), "Manifesti e locandine" (title), "La raccolta" | `config.yaml`, `content/posters/_index.md` |
| Project | "Il progetto" (menu), "Progetto" (sitemap) | `config.yaml`, `content/sitemap.md` |
| Home | "Home" (breadcrumb, sitemap, 404 button "Torna alla home"), "pagina iniziale" (`content/grazie.md`), "pagina principale" (404 text) | `layouts/partials/breadcrumbs.html`, `layouts/404.html` |
| Tags | "Argomenti" (page), "tag" in meta descriptions "Pagine del sito associate al tag %s", "Indice dei tag" | `content/tags/_index.md`, `layouts/partials/descrizione.html` |
| Archive | "Nove fondi per raccontare la sala" (list) but "Fondo: Archivio del Cinema Teatro Sestito" (one fondo, on every document) and "26 documenti · 9 categorie" | `layouts/archivio/list.html`, `layouts/archivio/single.html` |
| Home cards | "Quattro porte sulla sala" (home), "Cinque modi di entrare" (posters), "Quattro modi di leggere il cartellone" (programming) | Template, `content/posters/_index.md` |

Options:
- A. One name per section, used in menu, title, breadcrumb and links.
- B. Short names in the menu, full names in titles, but the same pair everywhere.
- C. Keep the variety as stylistic choice; fix only "Home", "tag" and "fondi".

### V5. Poster vocabulary and labels

- Umbrella term: "manifesti" counts fotobuste and locandine too: "Fotobuste
  50x70 · 835 manifesti", "Locandine 33x70 · 271 manifesti" (`layouts/partials/posters/page.html`, Template).
- Captions: "Manifesti 100x140, n. 1" (plural for one item, about 1,000 film
  pages) next to "Manifesto 100x140" on the same page
  (`layouts/partials/posters/film-images.html`: folder name "manifesti" passed through `title`, Template).
- Heatmap rows singular "Fotobusta 50×70", list headings plural "Fotobuste 50x70"
  (`layouts/partials/posters-format-heatmap.html`).
- Hand-written posters: "Retro" (menu, URL), "Scritti a mano" (card),
  "manifesti scritti a mano", "Manifesto scritto a mano 70x100", "Retro 70x100,
  n. 1", "manifesti realizzati a mano" (`content/posters/_index.md`, Template).
- Counts: "Fotobusta 50x70 · 2 pezzi in archivio" ("pezzi") vs "esemplari"
  in chart notes vs "copie conservate".
- Year page: bar labels "1966: 152 manifesti" and, below, decade cards "55 film"
  (`layouts/partials/posters-year-chart.html`, `posters/indice.html`).

Options:
- A. "manifesti" as umbrella, defined on the landing page; singular captions
  ("Manifesto 100x140, n. 1").
- B. "materiali" / "pezzi" as umbrella; "manifesti" only for the 70x100–140x200
  formats.
- C. One fixed name for hand-written posters ("manifesti scritti a mano") and
  "Retro" only as the menu label.

### V6. "Agende delle case di distribuzione"

- Fonti index: "le agende delle case di distribuzione" (`content/programmazione-storica/fonti/_index.md`, Manual).
- Agende type page: "Le agende cinematografiche erano distribuite dalle case di
  distribuzione" (`content/programmazione-storica/fonti/agende/_index.md`, Manual).
- All 30 agenda pages: "Agende cinematografiche fornite dalle case
  distributrici. Contengono ..." (plural, for a single document)
  (`content/programmazione-storica/fonti/agende/*/index.md`, front matter
  added 2025-10-15 in `b40e1a44`).
- Meta description: "agenda di distribuzione con date, titoli, distributore e
  incassi dei film" (`layouts/partials/descrizione.html`, Template).
- The methodology says the Fedi agendas came from a projector maker; most agenda
  titles (Fedi, Elettrocarbonium, Morganite, Lorraine, Prevost, Ceat, Naonis,
  Rapidtransport) are equipment, carbon or transport firms, not distributors.
- Image alt: "Copertina del calendario di programmazione Fedi 1954-1955" for an
  agenda (`content/programmazione-storica/fonti/_index.md`).

Options:
- A. "agende cinematografiche" (or "agende fornite da ditte del settore") without
  naming distributors; per-page description in the singular.
- B. Two wordings: distributors' agendas (Fincine, Incam, Bruzia ...) and
  suppliers' agendas (Fedi, Elettrocarbonium ...).
- C. Keep, if the owner knows they were all handed out by distributors.

### V7. Proper names spelled two ways

| Name | Variants | Files | Origin |
| --- | --- | --- | --- |
| Settimana Incom | "Incam 1948-49", "Incam 1949-50" (source titles on ~90 pages, home billboard) vs "La Settimana Incom", "Agenda cinematografica Incom" | `content/programmazione-storica/fonti/agende/1948-10-01-incam-1948-49/`, `.../1949-10-01-incam-1949-50/`, `static/data/programmazione_agende.csv` vs nascita article | Manual + Data (CSV) |
| Masceri | "Cinema Masceri" and "Teatro Masceri" in the same article | nascita article | Manual |
| Calzona / Calzone | "Vincenzo Calzone" (anni d'oro) vs "*ing.* Vincezo Calzona" (archive) **[U30]** | anni d'oro, `content/archivio/1957-01-01-1957-1959-progetto-sala-cinematografica-via-comm-doria/index.md` | Manual |
| ANEC / AGIS | Archive page "tessera ANEC", "Associazione Nazionale Esercenti Cinema"; nascita gallery alt "Tessera dell'Associazione Generale Italiana dello Spettacolo" for the same image | `content/archivio/1950-01-01-associazione-nazionale-esercenti-cinema/index.md`, nascita | Manual |
| Sansone e Dalila | "Sansone e Dalida" in the 1955 transcription vs "Sansone e Dalila" in its description and the article | `content/archivio/1955-09-12-processo-per-vendita-eccessiva-di-biglietti/index.md` | Manual (transcription) |
| Via Doria | "Via Comm. Doria" (titles, footnotes), "Via Doria" (anni d'oro), "via Doria" (archive title "Intonaci Cinema via Doria"), "Via V. Doria", "via Vito Doria" (transcriptions) | archive, anni d'oro | Manual |
| Piazza Mario Polerà | "Piazza Polerà" (alt of the 1961 certificate), "P.zza Mario Polera" (transcription) | `content/archivio/1961-08-01-attestato-d-eserzizio-ricambi-in-pizza-mario-poler/index.md` | Manual |
| San Vito sullo Ionio | editorial text "San Vito Jonio" (descriptions of the 1915 certificate and the MGM envelope), "Calabria jonica" (nascita), "S. Vito Jonio" (alt "Blocco di biglietti ... intestati a S. Vito Jonio", `layouts/articoli/list.html`) | archive, Template | Manual, Template |
| Footnote titles | "Acquisto fabbricato in Piazza Mario Polerà" (nascita fn 2) vs page "Acquisto palazzo ..."; "Acquisto terreni in Via Comm. Doria" vs "Acquisto terreno cinema ..."; "Autorizzazione all'apertura del locale cinematografico" vs "Abilitazione Cinema Via Comm. Doria"; "Diario di Vito" vs "Diario di Vito Sestito"; "Attestato terza elementare" vs "Attestato scuola elementare" | nascita, anni d'oro, storia di Vito | Manual |

Options:
- A. Editorial text uses one modern spelling; transcriptions stay as written
  (optionally with "[sic]").
- B. Editorial text follows the document it cites (so "Calzona", "Via Comm.
  Doria").
- C. Footnotes quote the archive page title exactly, or describe the document
  freely, but consistently in all articles.

### V8. English words in Italian text

- "Home" (breadcrumbs on 1,709 pages, sitemap, 404 button).
- "Information courtesy of IMDb (https://www.imdb.com)" (year pages, dashboard;
  `layouts/partials/grafici/anno-imdb.html`, `layouts/shortcodes/dashboard.html`,
  `static/js/dashboard.js`). This line may be required in English by IMDb's
  terms; check before changing.
- "Cinema italiano vs estero" (`layouts/partials/grafici/italia-estero-per-decennio.html`).
- "Distribuzione dei film per rating" (`layouts/partials/grafici/articolo.html`).
- "conserva la submission nel pannello del sito" (`content/privacy.md`).
- "Il team di Sonati Vicinu" (cinema e leggende); "circuiti mainstream"
  (progetto, programmazione); "grandi major americane" (bobine); "database"
  throughout.

Options:
- A. Italian everywhere a common word exists ("Pagina iniziale", "rispetto
  a", "classificazione", "invio", "gruppo").
- B. Keep established loanwords (database, team, major, mainstream), translate
  only interface words (Home, vs, submission, rating).
- C. Keep all.

### V9. Archive category names

"Corrispondenza, Autorizzazioni, Contratti, Progetti, Proprietà" (nouns) vs
"Giudiziario" (adjective, singular) and "Personali" (adjective, plural); text
"Questa sezione raccoglie e analizza i documenti e l'attrezzatura originali"
while the category is "Attrezzature" (`content/archivio/_index.md`, Manual;
categories also appear on every document and in `/categories/`).

Options:
- A. All nouns ("Atti giudiziari", "Documenti personali").
- B. Keep the labels, fix only "l'attrezzatura" / "Attrezzature".

## 4. Register

### R1. Three voices side by side

1. Academic, impersonal: `content/progetto.md`, `content/archivio/_index.md`,
   `content/programmazione-storica/_index.md`, `content/posters/_index.md`,
   interview intro, "Cinema e Leggende", "La storia di Vito Sestito",
   bobine. Example: "Questa trasformazione, lungi dall'essere marginale,
   riflette le pressioni del mercato ... in un contesto di progressiva
   periferizzazione culturale."
2. Personal, plain, first person: `content/riapertura/index.md`, methodology,
   `content/posters/retro/_index.md`, luci rosse, 404. Example: "Il bello di
   questi manifesti è proprio la scrittura a mano."
3. Promotional: "Qui trovate uno strumento per immergervi nell'affascinante
   mondo del Cinema Teatro Sestito" (esplora); "Un sogno che diventa realtà"
   (nascita heading); "Per oltre mezzo secolo un punto di incontro, di emozioni
   e di visioni condivise" (home).

The same subject changes voice between pages: the hand-written posters are
"testimonianze preziose di un artigianato locale che ha contribuito a dare un
volto alla programmazione" on the posters landing and "mio nonno ne preparava
uno da sé" on the Retro page.

Options:
- A. Bring the academic and promotional pages toward the plain personal voice
  of the newer pages.
- B. Two registers by page type: plain personal for narrative pages, neutral
  informative (not academic) for section introductions.
- C. Keep the academic register for analysis pages and reword only the
  promotional sentences.

### R2. 404 page

"Beh, questo è un problema. Sembra che tu sia finito su una pagina che non
esiste. Mi dispiace. ... Ti auguro una buona giornata, e spero che troverai
ciò che stavi cercando. Vito" (`layouts/404.html`, Template). Friendlier and
more colloquial than any other page; signed with a first name.

Options: A. keep (it matches the personal pages); B. shorten to two neutral
sentences; C. keep the tone, drop "Beh" and the signature.

### R3. Moral judgement in a chart

"Classificazioni sopra “PG” indicano film inadatti alla gioventù e alla morale
pubblica" (`layouts/partials/grafici/articolo.html`, chart in the nascita
article). The sentence reads as the site's own judgement, and uses a US rating
scale for 1948–1957 Italy (see X1).

Options: A. describe the classification neutrally ("film vietati ai minori
secondo la classificazione IMDb"); B. attribute the view to the period
("all'epoca considerati ..."); C. remove the note.

## 5. Grammatical person

### P1. tu / voi / noi / io

| Person | Examples | Files |
| --- | --- | --- |
| tu | "Scegli un anno", "Più sotto trovi i tipi di fonte", "consulta la nota metodologica", "Qui puoi consultare", "visita la sezione", "Approfondisci", "Il modulo raccoglie il messaggio che scegli di inviare" | `content/programmazione-storica/anni/_index.md`, `.../fonti/_index.md`, `content/posters/*`, `content/progetto.md`, `content/privacy.md` |
| voi | "Qui trovate uno strumento per immergervi ... offrirvi" | esplora article |
| noi | "raccontacelo nel messaggio" (form), "scrivici" (reopening), "ci aiutano a comprendere chi siamo e da dove veniamo" | `layouts/partials/contact-form.html`, `layouts/_default/single.html`, `layouts/riapertura/single.html`, cinema e leggende |
| io (owner) | "non esitare a contattarmi" (sitemap), "mandarmi una mail" (404), "Ho scansionato personalmente" (methodology), "fotografo", "comincio" (reopening), "mio nonno" (retro) | `content/sitemap.md`, `layouts/404.html`, methodology, reopening, retro |
| io (visitor) | Checkbox: "Puoi ricontattarmi per parlare di un'eventuale pubblicazione separata del mio ricordo" | `layouts/partials/contact-form.html` |
| impersonal | "si rimanda alla serie di articoli", "si veda la sezione", "per i criteri ... si veda la metodologia" | progetto, posters by-year, luci rosse |

The contact form moves from "Hai un ricordo" (tu) to "raccontacelo" (noi) to
"Puoi ricontattarmi ... del mio ricordo" (the visitor speaking) in four lines;
the privacy page then speaks of "il gestore del sito".

Options:
- A. Address the visitor as "tu" everywhere; the owner speaks as "io" in
  personal pages and the form; no "noi".
- B. "tu" for the visitor, "noi" for the project everywhere (also 404, sitemap).
- C. Impersonal instructions ("Scegliere un anno", "Per approfondire:"), "io"
  only in signed narrative pages.

### P2. Author and founder share a name

Every article and page is signed "Vito Sestito" ("Di Vito Sestito" on the
article template, `layouts/articoli/single.html`), and the founder is "Vito
Sestito" in the third person. "La storia di Vito Sestito ... Di Vito Sestito"
can read as an autobiography. The founder is also "Vito", "Sestito", "il
fondatore", "mio nonno", "nonno Vito" depending on the page.

Options:
- A. Byline with a qualifier ("Vito Sestito, nipote del fondatore") on article
  pages, or an "Autore" note on the project page.
- B. Refer to the founder as "Vito Sestito (1902–1985)" on first mention in
  each article.
- C. Leave the byline; use "mio nonno" consistently in first-person pages and
  "Vito Sestito" in third-person pages.

### P3. Masculine generic forms

"Sembra che tu sia finito su una pagina" (404); "Se desideri essere
ricontattato" (form). Options: A. neutral rewording ("Questa pagina non
esiste"; "Per una risposta, inserisci l'email"); B. keep.

## 6. Verb tenses

### T1. Historic present mixed with past tenses

- `content/progetto.md`, section "Programmazione": passato prossimo ("si è
  sempre contraddistinta", "ha privilegiato"), then historic present "A partire
  dagli anni Settanta, si assiste a una svolta significativa: la sala adotta",
  then passato prossimo again ("ha continuato").
- Anni d'oro: "Il periodo compreso tra il 1957 e il 1979 rappresenta",
  "I dati ... mostrano", "la curva inizia a scendere", "Nel 1979 il calo diventa
  significativo", then passato remoto for the narrative, and present again at
  the end: "la qualità della programmazione proiettano l'esperienza di San Vito
  oltre i confini locali".
- Nascita: "Particolarmente significativa è una lettera del 1957 in cui
  l'arciprete si lamenta ..." followed by "Mongiardo ammoniva".
- La storia di Vito Sestito: passato remoto narrative ("nacque", "fu
  arruolato") then "Vito Sestito ha lasciato una vasta produzione documentaria".
- Retro list: "106 dei 138 film ... sono stati prodotti prima del 1970" and, in
  the next bullet, "furono proiettati per la prima volta".

Options:
- A. Passato remoto for events, present only for what the data or documents
  show today ("il registro mostra").
- B. Passato prossimo throughout narrative pages (closer to spoken Italian, as
  in the reopening page).
- C. Allow the historic present, but not inside a paragraph that also uses past
  tenses.

### T2. Isolated slips

- "La loro esistenza mi era nota solo dopo aver iniziato a esplorare" (methodology):
  "solo dopo" needs an event ("ne sono venuto a conoscenza solo dopo").
- "Dal 2020 la sala è stata sgomberata" (progetto): "dal" suggests a state that
  lasts; see also D4.
- "Il cinema ... si configura come un archivio vivente" (cinema e leggende):
  present for a past event; also G1.

Options: A. correct each; B. leave until the page is rewritten for other reasons.

## 7. Capitalisation

### C1. Title Case in page titles

Most titles are sentence case ("La nascita del cinema a San Vito"), but:
"Cinema e Leggende" (article); "Attestato Operatore Cinematografico Guglielmo
Sestito", "Spettacolo Teatrale Quel Capoccione di Annibale", "Lettera di
Vettura Spedizione Sedie", "Autorizzazione Assemblea DC", "Lettera del
Sacerdote Gerardo Mongiardo", "1957-1959 Progetto sala Cinematografica Via
Comm. Doria", "Intonaci Cinema via Doria" (archive titles); headings "Indice
Analitico" (diary page); footnote "Foglio di Congedo Illimitato" (storia di
Vito). All Manual, in `content/archivio/*/index.md` and the articles.

Options: A. sentence case for all titles (Italian norm); B. Title Case only for
the names inside them (keep "DC", "Metro Goldwyn Mayer"); C. keep.

### C2. Category and tag names

Shown on `/categories/`, `/tags/`, breadcrumbs and article cards:
"Paesi Di Produzione", "Programmazione-per-Anni", "Note Sui Manifesti",
"Ricerca Storica", "San Vito Sullo Ionio", "Cinema Di Paese", "Storia Locale",
"Servizio Militare", "Documenti Scolastici", "· Note Sui Manifesti"
(breadcrumb on the Note sui manifesti source page). Origin: Hugo default (term
names are title-cased in English style because `config.yaml` sets no
`titleCaseStyle` and the terms have no `_index.md`). Hashtag-style tags
"CinemaTeatroSestito", "AutoricambiSestito", "SonatiVicinu" and lower-case
tags "storia locale", "cinema di paese" are Manual (front matter of the storia
di Vito, cinema e leggende and anni d'oro articles). Category slug
"programmazione-per-anni" on the 57 year pages is Ex-R (`update-anni.R`).

Options:
- A. Set Hugo's title case style to first-letter only (check the option name and
  values against Hugo 0.170.1) and fix the term names in front matter.
- B. Add an `_index.md` with an Italian title for each term shown.
- C. Fix only the front matter (hashtags, slug-like category); accept Hugo's
  casing.

### C3. Descriptions starting lowercase

`description: articolo dedicato al fondatore del cinema di San Vito sullo
Ionio` (storia di Vito), `articolo che trascrive il documento di abilitazione
del cinema nel 1949`, `progetto architettonico del 1957 per nuovo cinema`,
`contratto pubblicitario esclusivo per la Publi-Enic`, `trascrizione
dell'abilitazione ...`, `trascrizione del documento per la comunicazione
dell'assemblea ...` (archive, Manual). The articles list capitalises the first
letter (`strings.FirstUpper` in `layouts/articoli/list.html`); the home "Racconti
dalla sala" shows "articolo dedicato al fondatore ..." lowercase
(`layouts/partials/home/storie.html`). Alt texts also start lowercase: "foto
fatte per la patente", "progetto del 1957 sul cinema in Via Doria", "film
destinati alla programmazione".

Options: A. capitalise in the front matter; B. capitalise in every template
that prints descriptions; C. both.

### C4. Genres, months, offices, "Cinema"

- Genres: «Per adulti» (capital, `content/programmazione-storica/generi/_index.md`,
  `content/posters/by-genre/_index.md`) vs «per adulti» (luci rosse, retro);
  "Film di genere Per adulti nella programmazione" (meta description of
  `content/programmazione-storica/generi/per-adulti/index.md`, Ex-R
  `update-generi.R`, pattern repeated on 23 genre pages); "Il genere
  *Drammatico*" vs "commedia, avventura e azione" in the same paragraph.
- Months: "Gennaio 1966" as headings (poster year pages, Template) vs "26 luglio
  1977" in prose; standalone month headings ("Novembre") are fine either way.
- Offices: "il prefetto di Catanzaro" (nascita) vs "del **Prefetto della
  Provincia di Catanzaro**" (anni d'oro); "Lettera del Sacerdote"; "la Signora
  Maria De Luca", "del Notaio Menichini" in editorial descriptions (copied from
  the deeds).
- "Cinema" as common noun: see V3.

Options: A. lowercase genres in prose, capital only as labels; lowercase
offices and titles of courtesy in editorial text. B. keep labels as in the
data, prose free.

### C5. Source names

"Ceat 1966" vs "NAONIS 1966" vs "CIF 1985-86"; "Calendario 1985_2" with an
underscore (title of `content/programmazione-storica/fonti/calendari/1985-01-01-calendario-1985-2/index.md`,
and the source string in the CSV, so it appears in every "Fonte:" line).
Origin: Manual titles, Data (CSV) in tables.

Options: A. one style for brand names (as printed on the cover) and "Calendario
1985 (2)" or "Calendario 1985 bis"; B. change only the page titles, leave the
CSV (the "Fonte:" lines would still show the old form).

## 8. Dates

### D1. When did the cinema start? **[U30, open]**

"San Vito sullo Ionio · 1946–2004" (home), "In attività dal 1946 al 2004"
(footer on every page, `layouts/partials/footer.html`), "Fondato nel 1946"
(progetto), "fondata nel 1946" (cinema e leggende). The nascita article says
the passion "nacque nel 1946", the prefect's licence is 19 March 1949, the
nulla osta 19/5/1947, and the programming starts in 1948.

Options: A. "dal 1948" (first documented screening); B. "dal 1949" (licence);
C. keep 1946 and say on the project page what happened in 1946.

### D2. "Gli anni d'oro": dates **[partly U30]**

- Licence "6 giugno 1959" (text and footnote 6) vs the decree "Catanzaro, li
  30.6.1959" **[U30]**.
- "Il 3 marzo 1959 ... firmò il contratto ... Pochi giorni dopo si svolse il
  collaudo statico ... Il test, datato 26 aprile 1959": seven weeks, not a few
  days.
- 1966 contracts listed out of order: "16 febbraio 1966 — Argos" before "22
  gennaio 1966 — Titanus".
- Peak "fino al 1966, anno che segna l'apice" **[U30]**; decline "A partire
  dalla fine degli anni Settanta" (intro) vs "A partire dai primi anni
  Settanta" and heading "Declino e trasformazione (1970–1979)" **[U30]**.
- "mostrano un periodo costante del numero di film proposti fino al 1966, anno
  che segna l'apice": constant until a peak is self-contradictory wording.

Options: A. correct in the U30 pass; B. correct the order and "pochi giorni"
now, the rest with U30.

### D3. "Cinquant'anni di cartellone"

"Cinquant'anni di cartellone" (home card, programming landing occhiello)
against "dal 1948 al 2004" in the same block and "57 anni" on the Anni page
(`layouts/programmazione-storica/anni/list.html`). Home also says "Per oltre
mezzo secolo". `content/_index.md`, `content/programmazione-storica/_index.md`.

Options: A. "Oltre cinquant'anni di cartellone"; B. "Mezzo secolo di
cartellone"; C. "1948–2004" only.

### D4. Reopening chronology vs project page

Project: "Dal 2020 la sala è stata sgomberata, documenti e locandine sono stati
messi in salvo". Reopening: June 2020 photographs, August 2022 "Una sala piena
di cose", January 2023 "La sala si svuota". The 14 January 2023 step shows a
photo captioned "L'ingresso dopo la pulizia (luglio 2023)".

Options: A. project page: "Tra il 2020 e il 2023 la sala è stata sgomberata";
B. move the July 2023 photo to its own dated step; C. keep the caption, which is
accurate, and accept the gap.

### D5. Date and range formats

- First of the month: "1 febbraio 1953", "1 agosto 1961", "1 febbraio 1936",
  "1 agosto 2021" (editorial) vs "1° febbraio 1953" (transcription) and "ven 1
  nov" (tables).
- ISO dates in visible captions: "1957-08-10 Lettera del Sacerdote Gerardo
  Mongiardo", "1955-09-12 Processo per vendita eccessiva di biglietti 1"
  (archive image alt texts, shown as captions by `layouts/archivio/single.html`).
- Ranges: "1958-59", "1974-75" (two digits), "1969-1981", "1984-92",
  "1995-00" (source titles, Data + Manual); "1957-1979" (anni d'oro title,
  hyphen) vs "1957–1979" (link to it in nascita, en dash) vs "1946–1957"
  (nascita title, en dash) vs "1977-1994" (luci rosse title) vs "1960-1961"
  (methodology) vs "1948–2004" (templates).
- Decades: "anni Sessanta" in prose, "Anni 1960" on cards and "anni 1940" in
  chart tooltips (`layouts/programmazione-storica/list.html`, `partials/grafici/*`).

Options: A. "1° " for the first day in editorial text; en dash for all ranges;
four-digit years in titles; "anni Sessanta" in labels too. B. Keep source titles
as printed on the documents, normalise only editorial text. C. Replace ISO
captions by descriptive alt text (as on the newer archive pages).

## 9. Numbers

### N1. English separators in charts

- Percentages "0.1%", "55.3%" (genre and country charts, `layouts/partials/grafici/numeri.html`
  uses `printf "%.1f"`).
- Axis "1,000 / 10,000 / 100,000" and label "Numero di voti (log)"
  (`layouts/partials/grafici/anno-imdb.html`, `lang.FormatNumberCustom 0 ... "- . ,"`).
- Film pages: "Valutazione IMDb 6.6/10 (6.987 voti)": decimal point and
  Italian thousands separator on one line (`layouts/posters/film.html`).
- Elsewhere Italian: "5.479", "1.586", "74.900 lire".

Options: A. Italian format everywhere ("0,1%", "1.000", "6,6/10"); B. keep IMDb
ratings as IMDb writes them ("6.6/10"), Italian for everything else.

### N2. Totals that do not match

- Home: "1.787 manifesti e locandine", "Tutti i 1.787 manifesti →"; posters
  landing: "1.645 manifesti e locandine", "142 manifesti scritti a mano"
  (1,645 + 142 = 1,787) (`layouts/partials/home/numeri.html`,
  `layouts/partials/posters/landing.html`).
- Retro page: "106 dei 138 film con un manifesto scritto a mano" vs landing
  "142 manifesti scritti a mano" (films vs pieces, not explained).
- Note sui manifesti source page: "173 film" and "Tutti i 172 film con
  manifesto →".
- Year 1966: header "215 proiezioni · 214 film"
  (`layouts/programmazione-storica/single.html`) above a chart "Totale
  proiezioni: 215" (`layouts/partials/grafici/anno-mensile.html`); both are
  right (entries vs distinct films) but the difference is not explained.

Options: A. one base per number (pieces, films, entries) named in the label;
B. a short note where two bases appear on one page.

### N3. Format sizes

"50x70" (labels, URLs), "50×70" (heatmap rows), "50 × 70 cm" (format
descriptions), "140x200 centimetri" and "un 140x200" (luci rosse).

Options: A. "50×70 cm" in text, "50×70" in labels; B. "50x70" everywhere
(simplest, matches URLs and file names).

## 10. Film titles

### F1. One film, two titles

Of 813 films present in both datasets, 79 have a different title in
`data/posters/films.json` (poster pages, luci rosse article) and in
`static/data/programmazione_agende.csv` (programming tables, home billboard,
dashboard). The poster file often uses the original or IMDb title, the CSV the
Italian title written in the agenda.

| IMDb ID | Poster pages | Programming tables |
| --- | --- | --- |
| tt0122903 | American Pie | Belle erotiche e maliziose (American Pie); Belle, erotiche e maliziose |
| tt0191448 | Showgirls | Perversioni sessuali a Las Vegas |
| tt0127095 | Peaches and Cream | Voluttuose deviazioni carnali |
| tt0178877 | Satisfactions | Femmine sfrenate |
| tt0085367 | Corruption | Di dietro tutta, femmine corrotte dal piacere |
| tt0079599 | Incontri proibiti | L'altro vizio della porno bocca (Incontri proibiti) |
| tt0058567 | Sei donne per l'assassino | 6 donne per l'assassino |
| tt0074102 | L'impero dei sensi | Ecco l'impero dei sensi |
| tt0186119 | Chu ba | Colpo per colpo |
| tt0095863 | Phantasm II | Fantasmi II (Phantasm II) |

The luci rosse article cites poster titles ("*Showgirls* (1986) il 7 maggio
1989", "*Peaches and Cream*, *Satisfactions*", "*Corruption* (1983)"), so a
reader who opens that date in the programming finds another title.

Options:
- A. Keep both and show the other title on each side ("in cartellone come ...",
  "titolo originale ...") through a template that looks up the IMDb ID.
- B. Choose one source as the display title for both sections (template only,
  data unchanged).
- C. Edit one dataset (the datasets are declared final; this would be an
  owner's exception).
- D. Keep as is; in articles, give the title as it appears in the programming.

### F2. One film, several titles inside the CSV

30 IMDb IDs carry more than one title string in `programmazione_agende.csv`,
for example: "Il ratto delle sabine" / "Il ratto delle Sabine (professor
trombone)"; "Fiesta (La matadora)" / "La Matadora (Fiesta)"; "Il falco rosso" /
"Il falco rosso " (trailing space); "Mezzogiorno di... fifa" / "Mezzogiorno
di... Fifa"; "Il Ritorno di Palma d'Acciaio (Jing wu men xu ji )" / "Il ritorno
di palma d'acciaio"; "Justine una minorenne deliziosa…" / "Justine, una
minorenne deliziosa...". Some differences reflect different agendas (that is a
historical fact); others are typing variants.

Options: A. leave all (they record what each source wrote); B. normalise only
case, spacing and punctuation variants; C. normalise in display only.

### F3. Capitalisation and punctuation inside titles

- Title Case in the data: "La più Grande Avventura di Tarzan", "La Bestia del
  Castello Maledetto", "Perversioni Internazionali", "Quella Porno-Erotica di
  Mia Moglie", "Attenti a Quei Due… Chiamate Londra", "Flavia Schiava di Roma
  Regina d'amore".
- Lowercase proper names: "I cavalieri dalle maschere nere (I beati paoli)".
- Subtitle separators: "Agente 007 - L'uomo dalla pistola d'oro" (capital
  after dash) vs "Bestia del Sud - voglia di godere" (lowercase); "2+5:
  Missione Hydra" vs "F.B.I. operazione Baalbeck"; "Fbi contro gangsters" vs
  "F.B.I."; "El gringo" vs "7 pistole per El Gringo".
- Missing punctuation: "Bluff storia di truffe e di imbroglioni", "Cina
  violenza e furore", "Grizzly l'orso che uccide" (other titles use a comma or
  dash in the same position).

Options: A. Italian sentence case for Italian titles, original case for
foreign ones (display rule or data edit); B. keep titles exactly as recorded.

### F4. Straight vs curly apostrophes and ellipses

The same title is printed differently by section: "L'implacabile cordobes"
(poster year page) vs "L’implacabile cordobes" (1966 programming table);
"Carambola, filotto... tutti in buca" (posters) vs "Vivendo cantando… che male
ti fò?" (programming). The programming tables pass titles through Markdown
typography (`{{% programmazione-tabelle %}}` renders Markdown), poster
templates print them raw. The same happens with page titles and timeline titles
("Le locandine all'ingresso", straight) under body text with curly
apostrophes. Origin: Template.

Options: A. typographic apostrophes and "…" everywhere (convert in the poster
templates); B. straight characters everywhere (disable typography in the
tables); C. keep.

### F5. Titles in running text

- Italic: "*Re vagabondo*", "*Porno Holocaust*" (anni d'oro, luci rosse).
- Link without italics: "[Sansone e Dalila](...)", "[Schiavitù](...)" (nascita).
- Guillemets: "Fotobusta di «Guardiamola nuda e… poi decidiamo»" (luci rosse
  caption).
- No marking: "proiezione di Sansone e Dalila" (archive description);
  "Quel capoccione di Annibale" (archive).
- Year and director: "(Cecil B. DeMille, 1949)" (nascita), "(1987)" only (luci
  rosse).

Options: A. italic for every title in editorial text (also in captions and
descriptions where Markdown is not rendered, use «»); B. «» everywhere; C.
italic in articles only.

### F6. Possible misspellings in the data

"Le pioggie di Ranchipur" (the usual Italian title is "Le piogge di
Ranchipur"; check the agenda, it may itself say "pioggie"); "Viziose
asolescenti" (adolescenti); "Maciste contro Ercole nella valle dei guai ( I due
pretoriani)" (space after the parenthesis); "Il Ritorno di Palma d'Acciaio
(Jing wu men xu ji )". Data (CSV).

Options: A. correct the typing errors (owner's exception to the data freeze);
B. keep, as records of what was written; C. correct only obvious keyboard slips.

### F7. Sorting of "A ..."

"A 30 secondi dalla fine" is listed under "#" between "I 3 dell'Operazione
Drago" and "I 4 di Chicago" (`/posters/by-title/`), because its `sort_key` in
`films.json` drops "A" as if it were an article. In Italian "A" here is a
preposition. Origin: Data (films.json, `sort_key`).

Options: A. sort it under "A"; B. accept.

## 11. Generic or AI-sounding phrases

### G1. Stock academic phrasing

These read as generated or generic: abstract nouns in chains, no concrete
detail, words such as "configurarsi", "dinamiche", "identitario",
"restituire", "intrecciare".

| File | Examples |
| --- | --- |
| `content/progetto.md` | "configurandosi come spazio di aggregazione e di fruizione culturale"; "ha incarnato una visione del cinema come strumento di crescita culturale e coesione sociale"; "rappresenta un esempio significativo di imprenditoria culturale"; "lungi dall'essere marginale"; "in un contesto di progressiva periferizzazione culturale"; "offrendo uno spazio di osservazione delle trasformazioni sociali attraverso il medium cinematografico"; "un luogo di socializzazione, di formazione culturale e di costruzione identitaria"; "alle generazioni presenti e future" |
| `content/_index.md` | "Per oltre mezzo secolo un punto di incontro, di emozioni e di visioni condivise"; "In questo equilibrio irregolare risiede gran parte del suo fascino e del suo valore storico"; "un'esperienza che ha intrecciato arte, comunità e quotidianità" |
| `content/archivio/_index.md` | "raccoglie e analizza"; "le dinamiche gestionali, le relazioni istituzionali e le trasformazioni urbanistiche"; "al fine di garantire la conservazione e la fruibilità pubblica del patrimonio documentario"; "Ogni documento è corredato da una scheda descrittiva contenente datazione, contesto di produzione" (most pages have no such context) |
| `content/programmazione-storica/_index.md` | "costituisce una delle componenti centrali dell'archivio documentario"; "l'evoluzione del gusto del pubblico locale, le strategie distributive adottate"; "inteso come specchio delle pratiche culturali quotidiane" |
| `content/posters/_index.md` | "costituiscono la componente visiva dell'archivio documentario"; "ne offrono un controcanto grafico, fatto di colori, caratteri tipografici e immaginario promozionale"; "testimonianze preziose di un artigianato locale" |
| `content/articoli/2015-04-15-.../index.md` | "Il racconto si configura come una fonte orale di rilievo"; "la dimensione affettiva e identitaria che il cinema ha assunto" |
| `content/articoli/2023-09-10-cinema-e-leggende/index.md` | "come dispositivo narrativo capace di mediare tra passato e presente"; "uno spazio di costruzione identitaria, di trasmissione simbolica e di aggregazione sociale"; "si configura come un archivio vivente"; "ci aiutano a comprendere chi siamo e da dove veniamo" |
| `content/articoli/2023-04-20-la-storia-di-vito-sestito/index.md` | "Figura di grande disciplina e precisione"; "uno spaccato dettagliato"; "emerge come emblematica di una generazione"; "una storia locale che merita di essere conosciuta, studiata e tramandata" |
| `content/articoli/2023-04-27-la-nascita-del-cinema-a-san-vito/index.md` | "Un sogno che diventa realtà"; "la passione per la settima arte"; "il segno tangibile di questa rinascita"; "un sistema ingegnoso che dimostra la straordinaria partecipazione popolare"; "con una capienza ridotta ma ingegnosa"; "Tali episodi rivelano il delicato equilibrio tra iniziativa culturale, controllo morale e autorità ecclesiastica" |
| `content/articoli/2025-11-05-gli-anni-d-oro-.../index.md` | "cuore pulsante della vita comunitaria" and "cuore pulsante della storia"; "simbolo di progresso e di coesione sociale" (twice); "segno tangibile del rinnovamento culturale"; "un piccolo prodigio ingegneristico"; "L'inaugurazione e l'inizio di una nuova era"; "rendendola parte integrante della più ampia storia del cinema popolare italiano del Novecento" |
| `content/archivio/2025-10-27-bobine-dei-trailer-35mm/index.md` | "rappresentano una testimonianza di grande valore storico e materiale"; "costituiscono un importante documento in sé"; "un raro esempio di archivio tecnico-cinematografico" |
| `content/articoli/2023-09-23-esplora-.../index.md` | "immergervi nell'affascinante mondo"; "un accesso senza precedenti al ricco database" |
| `content/eventi/_index.md` | "Un punto di contatto tra il lavoro d'archivio e la vita culturale contemporanea del paese." (sentence without a verb) |

The newer pages (reopening, methodology, luci rosse, retro, section intros of
posters and programming written in 2026) are concrete and do not show this
pattern.

### G2. Phrases repeated across pages

- "Questa raccolta nasce dall'intento di ..." closes both
  `content/posters/_index.md` and `content/programmazione-storica/_index.md`,
  each followed by "la memoria ... di un cinema di provincia".
- "punto di riferimento" (progetto, storia di Vito, nascita, anni d'oro);
  "spazio di aggregazione" / "aggregazione sociale" (progetto, interview,
  leggende, anni d'oro); "continua a vivere" (home, progetto, leggende);
  "segno tangibile" (nascita, anni d'oro); "coesione sociale" (progetto, anni
  d'oro); "costruzione identitaria" / "identitaria" (progetto, interview,
  leggende).

### G3. Promotional or empty template sentences

"Un viaggio nella sala buia" (Anni chart heading,
`layouts/partials/grafici/film-per-anno.html`); "Quando il grande schermo
illuminava San Vito (1957–1979)" (chart title, `layouts/partials/grafici/articolo.html`);
"Dominanza dei generi per decennio" (chart title) against the alt "Percentuale
dei generi cinematografici per decennio"; site description "i ricordi di una
cara istituzione del paese" (`config.yaml`, shown as meta on the 404 page).

Options for G1–G3:
- A. Rewrite the older pages in the plain style of the 2026 pages: concrete
  facts, names and dates, fewer abstract nouns.
- B. Cut the sentences that carry no fact, keep the rest as written.
- C. Replace only the repeated phrases (G2) and the empty headings (G3).
- D. Keep.

## 12. Accuracy and punctuation noticed in passing

These are outside the requested categories but surfaced while reading.

### X1. Accuracy

- Nascita: Mongiardo "ammoniva Sestito a evitare in futuro pellicole “contrarie
  alla moralità pubblica”": the letter, transcribed on the archive page, says
  "evitare proiezioni contro la moralità"; the words in quotation marks are not
  in it.
- Bobine page: "spesso corrispondenti delle grandi major americane o di
  società italiane come la Metro-Goldwyn-Mayer, la Titanus o la Cineriz" reads
  as if MGM were Italian. The page also says "seconda metà del Novecento" for
  reels that are mostly 1993–2003 **[U30]**.
- Nascita chart: a US rating scale ("PG") for 1948–1957 Italian screenings;
  Italian classification at the time was "vietato ai minori di 16 anni".
- "Ogni documento è corredato da una scheda descrittiva contenente datazione,
  contesto di produzione e riproduzione digitale" (archive intro): most archive
  pages have only a date, a category and the images.

Options: A. correct with U30; B. add to U30's list for later.

### X2. Punctuation (related)

- Quotation marks: «» (luci rosse, retro, genre pages), “ ” (nascita,
  transcriptions), " " (nascita: "[La Settimana Incom]").
- Dashes: " - " hyphen as a dash (interview, storia di Vito, programming
  landing, home "*- sempre aperta -*"), "—" em dash (anni d'oro list), "–" en
  dash elsewhere.
- Comma splices: "La galleria fotografica testimonia questa consuetudine, gli
  invitati posano ..."; "le persone poi prendevano posto tra le sedie, gli sposi
  venivano messi sul palco" (anni d'oro).
- Comma before "con": "capace di mescolare i grandi titoli della storia del
  cinema, con titoli di nicchia" (home).
- Serial comma (not Italian usage): "attestati, diari, e documenti militari"
  (archive categories), "registri, appunti, e calendari", "le strategie
  distributive adottate, e le modalità" (programming landing).
- Spacing: "altoparlanti,  e stabilizzatori" (methodology), "il cinema  si
  configura" (leggende), "Soverato,3 marzo 1959" (anni d'oro footnote 5),
  "“Schiavitù” ," (transcription).
- Accent written as apostrophe in front matter and generated text:
  "comunita'" (descriptions of the interview, anni d'oro and leggende, shown on
  the home and article list), "localita'", "Societa'", "validita'", "idoneita'",
  "attivita'", "martedi'" (archive descriptions and alts); "puo'" and "e'" on
  all 57 year pages (Ex-R `update-anni.R`).
- Captions without a full stop next to captions with one (methodology).

Options: A. one convention per mark (for example «» for quotations, "–" for
ranges, "—" or "–" with spaces for asides) applied in a single pass; B. fix only
the accent apostrophes and spacing errors.

## 13. Files reviewed

Built output: all 1,885 `index.html` pages in `public/` after `hugo` on
2026-11-27 (text extracted and deduplicated; one or more of each page type read
in full).

Hand-written and generated Markdown, templates, scripts and data:

<details>
<summary>Full list (click to open)</summary>

605 files.

- `content/_index.md`
- `content/archivio/1915-08-20-attestato-scuola-elementare-vito-sestito/index.md`
- `content/archivio/1923-10-09-congedo-fine-leva-vito-sestito/index.md`
- `content/archivio/1936-02-01-diario-vito-sestito-dal-1936-al-1949/index.md`
- `content/archivio/1944-03-02-acquisto-palazzo-in-piazza-mario-poler-parte-1/index.md`
- `content/archivio/1944-03-06-acquisto-palazzo-in-piazza-mario-poler-parte-2/index.md`
- `content/archivio/1944-03-15-acquisto-palazzo-in-piazza-mario-poler-parte-3/index.md`
- `content/archivio/1949-03-19-abilitazione-cinema-in-piazza-mario-poler/index.md`
- `content/archivio/1950-01-01-associazione-nazionale-esercenti-cinema/index.md`
- `content/archivio/1953-02-01-espansione-cinema-in-piazza-mario-poler/index.md`
- `content/archivio/1955-09-12-processo-per-vendita-eccessiva-di-biglietti/index.md`
- `content/archivio/1955-12-26-acquisto-terreno-cinema-in-via-comm-doria/index.md`
- `content/archivio/1956-03-01-acquisto-terreno-cinema-in-via-comm-doria-parte-2/index.md`
- `content/archivio/1956-04-07-acquisto-orto-cinema-in-via-comm-doria/index.md`
- `content/archivio/1957-01-01-1957-1959-progetto-sala-cinematografica-via-comm-doria/index.md`
- `content/archivio/1957-03-15-contratto-pubblicit-publi-enic/index.md`
- `content/archivio/1957-08-10-lettera-del-sacerdote-gerardo-mongiardo/index.md`
- `content/archivio/1957-11-09-busta-della-metro-goldwyn-mayer/index.md`
- `content/archivio/1958-09-03-intonaci-cinema-via-doria/index.md`
- `content/archivio/1959-03-03-contratto-con-societ-elettrica-delle-calabrie/index.md`
- `content/archivio/1959-06-30-abilitazione-cinema-via-comm-doria/index.md`
- `content/archivio/1961-08-01-attestato-d-eserzizio-ricambi-in-pizza-mario-poler/index.md`
- `content/archivio/1962-04-08-attestato-operatore-cinematografico-guglielmo-sestito/index.md`
- `content/archivio/1968-02-10-autorizzazione-assemblea-dc/index.md`
- `content/archivio/1970-12-29-spettacolo-teatrale-quel-capoccione-di-annibale/index.md`
- `content/archivio/1987-03-30-lettera-di-vettura-spedizione-sedie/index.md`
- `content/archivio/2025-10-27-bobine-dei-trailer-35mm/index.md`
- `content/archivio/_index.md`
- `content/articoli/2015-04-15-intervista-sulla-storia-del-cinema-a-stefano-sestito/index.md`
- `content/articoli/2023-04-20-la-storia-di-vito-sestito/index.md`
- `content/articoli/2023-04-27-la-nascita-del-cinema-a-san-vito/index.md`
- `content/articoli/2023-09-10-cinema-e-leggende/index.md`
- `content/articoli/2023-09-23-esplora-la-storia-cinematografica-di-san-vito-sullo-ionio/index.md`
- `content/articoli/2025-11-05-gli-anni-d-oro-del-cinema-teatro-sestito/index.md`
- `content/articoli/2026-11-11-metodologia-ricostruzione-programmazione/index.md`
- `content/articoli/2026-11-24-le-luci-rosse-del-cinema-sestito/index.md`
- `content/articoli/_index.md`
- `content/categories/_index.md`
- `content/eventi/_index.md`
- `content/grazie.md`
- `content/posters/_index.md`
- `content/posters/by-country/_index.md`
- `content/posters/by-country/afghanistan/_index.md`
- `content/posters/by-country/argentina/_index.md`
- `content/posters/by-country/australia/_index.md`
- `content/posters/by-country/belgium/_index.md`
- `content/posters/by-country/brazil/_index.md`
- `content/posters/by-country/canada/_index.md`
- `content/posters/by-country/china/_index.md`
- `content/posters/by-country/colombia/_index.md`
- `content/posters/by-country/denmark/_index.md`
- `content/posters/by-country/dominican-republic/_index.md`
- `content/posters/by-country/egypt/_index.md`
- `content/posters/by-country/france/_index.md`
- `content/posters/by-country/germany/_index.md`
- `content/posters/by-country/greece/_index.md`
- `content/posters/by-country/hong-kong/_index.md`
- `content/posters/by-country/indonesia/_index.md`
- `content/posters/by-country/italy/_index.md`
- `content/posters/by-country/japan/_index.md`
- `content/posters/by-country/lebanon/_index.md`
- `content/posters/by-country/liechtenstein/_index.md`
- `content/posters/by-country/mexico/_index.md`
- `content/posters/by-country/netherlands/_index.md`
- `content/posters/by-country/new-zealand/_index.md`
- `content/posters/by-country/philippines/_index.md`
- `content/posters/by-country/south-africa/_index.md`
- `content/posters/by-country/south-korea/_index.md`
- `content/posters/by-country/soviet-union/_index.md`
- `content/posters/by-country/spain/_index.md`
- `content/posters/by-country/sweden/_index.md`
- `content/posters/by-country/switzerland/_index.md`
- `content/posters/by-country/taiwan/_index.md`
- `content/posters/by-country/thailand/_index.md`
- `content/posters/by-country/trinidad-and-tobago/_index.md`
- `content/posters/by-country/turkey/_index.md`
- `content/posters/by-country/united-kingdom/_index.md`
- `content/posters/by-country/united-states/_index.md`
- `content/posters/by-country/west-germany/_index.md`
- `content/posters/by-country/yugoslavia/_index.md`
- `content/posters/by-genre/_index.md`
- `content/posters/by-genre/animazione/_index.md`
- `content/posters/by-genre/avventura/_index.md`
- `content/posters/by-genre/azione/_index.md`
- `content/posters/by-genre/biografico/_index.md`
- `content/posters/by-genre/commedia/_index.md`
- `content/posters/by-genre/documentario/_index.md`
- `content/posters/by-genre/drammatico/_index.md`
- `content/posters/by-genre/fantascienza/_index.md`
- `content/posters/by-genre/fantastico/_index.md`
- `content/posters/by-genre/giallo/_index.md`
- `content/posters/by-genre/guerra/_index.md`
- `content/posters/by-genre/horror/_index.md`
- `content/posters/by-genre/musica/_index.md`
- `content/posters/by-genre/musical/_index.md`
- `content/posters/by-genre/noir/_index.md`
- `content/posters/by-genre/per-adulti/_index.md`
- `content/posters/by-genre/per-famiglie/_index.md`
- `content/posters/by-genre/poliziesco/_index.md`
- `content/posters/by-genre/sentimentale/_index.md`
- `content/posters/by-genre/sportivo/_index.md`
- `content/posters/by-genre/storico/_index.md`
- `content/posters/by-genre/thriller/_index.md`
- `content/posters/by-genre/western/_index.md`
- `content/posters/by-size/_index.md`
- `content/posters/by-size/fotobuste-50x70/_index.md`
- `content/posters/by-size/locandine-33x70/_index.md`
- `content/posters/by-size/manifesti-100x140/_index.md`
- `content/posters/by-size/manifesti-140x200/_index.md`
- `content/posters/by-size/manifesti-70x100/_index.md`
- `content/posters/by-source/_index.md`
- `content/posters/by-source/agenda-1968/_index.md`
- `content/posters/by-source/appunti-cif-1985-86/_index.md`
- `content/posters/by-source/appunti-cif-1986-87/_index.md`
- `content/posters/by-source/appunti-cif-1987-88/_index.md`
- `content/posters/by-source/appunti-italautogamma-1988-89/_index.md`
- `content/posters/by-source/appunti-italautogamma-1989-90/_index.md`
- `content/posters/by-source/appunti-italautogamma-1990-91/_index.md`
- `content/posters/by-source/appunti-italautogamma-1991-92/_index.md`
- `content/posters/by-source/appunti-italautogamma-1992-93/_index.md`
- `content/posters/by-source/appunti-new-europe-1993-94/_index.md`
- `content/posters/by-source/appunti-new-europe-1994-95/_index.md`
- `content/posters/by-source/appunti-new-europe-1995-00/_index.md`
- `content/posters/by-source/appunti-victory-2000/_index.md`
- `content/posters/by-source/bruzia-1952-53/_index.md`
- `content/posters/by-source/bruzia-1955-56/_index.md`
- `content/posters/by-source/bruzia-1956-57/_index.md`
- `content/posters/by-source/bruzia-1958-59/_index.md`
- `content/posters/by-source/calendario-1962/_index.md`
- `content/posters/by-source/calendario-1963/_index.md`
- `content/posters/by-source/calendario-1966/_index.md`
- `content/posters/by-source/calendario-1967/_index.md`
- `content/posters/by-source/calendario-1968/_index.md`
- `content/posters/by-source/calendario-1972/_index.md`
- `content/posters/by-source/calendario-1973/_index.md`
- `content/posters/by-source/calendario-1974/_index.md`
- `content/posters/by-source/calendario-1975/_index.md`
- `content/posters/by-source/calendario-1979/_index.md`
- `content/posters/by-source/calendario-1980/_index.md`
- `content/posters/by-source/calendario-1981/_index.md`
- `content/posters/by-source/calendario-1982/_index.md`
- `content/posters/by-source/calendario-1983/_index.md`
- `content/posters/by-source/calendario-1984/_index.md`
- `content/posters/by-source/calendario-1985-2/_index.md`
- `content/posters/by-source/calendario-1985/_index.md`
- `content/posters/by-source/calendario-1986/_index.md`
- `content/posters/by-source/calendario-1987/_index.md`
- `content/posters/by-source/calendario-1988/_index.md`
- `content/posters/by-source/calendario-1989/_index.md`
- `content/posters/by-source/calendario-1990/_index.md`
- `content/posters/by-source/calendario-1991/_index.md`
- `content/posters/by-source/calendario-1992/_index.md`
- `content/posters/by-source/calendario-1993/_index.md`
- `content/posters/by-source/calendario-1994/_index.md`
- `content/posters/by-source/calendario-1995/_index.md`
- `content/posters/by-source/calendario-1996/_index.md`
- `content/posters/by-source/calendario-1999/_index.md`
- `content/posters/by-source/calendario-2002/_index.md`
- `content/posters/by-source/calendario-2003/_index.md`
- `content/posters/by-source/calendario-2004/_index.md`
- `content/posters/by-source/ceat-1966/_index.md`
- `content/posters/by-source/elettrocarbonium-1976-77/_index.md`
- `content/posters/by-source/fedi-1952-53/_index.md`
- `content/posters/by-source/fedi-1954-55/_index.md`
- `content/posters/by-source/fedi-1957-58/_index.md`
- `content/posters/by-source/fedi-1958-59/_index.md`
- `content/posters/by-source/fedi-1960-61/_index.md`
- `content/posters/by-source/fedi-1961-62/_index.md`
- `content/posters/by-source/fedi-1962-63/_index.md`
- `content/posters/by-source/fedi-1975-76/_index.md`
- `content/posters/by-source/lorraine-1969-70/_index.md`
- `content/posters/by-source/lorraine-1970-71/_index.md`
- `content/posters/by-source/morganite-1968-69/_index.md`
- `content/posters/by-source/naonis-1966/_index.md`
- `content/posters/by-source/note-sui-manifesti/_index.md`
- `content/posters/by-source/prevost-1977-78/_index.md`
- `content/posters/by-source/rapidtransport-1964/_index.md`
- `content/posters/by-source/rapidtransport-1965/_index.md`
- `content/posters/by-source/rubrica-1967/_index.md`
- `content/posters/by-source/rubrica-1968/_index.md`
- `content/posters/by-source/rubrica-1969-1981/_index.md`
- `content/posters/by-source/rubrica-1970-1980/_index.md`
- `content/posters/by-source/rubrica-1971/_index.md`
- `content/posters/by-source/rubrica-1972/_index.md`
- `content/posters/by-source/rubrica-1973/_index.md`
- `content/posters/by-source/rubrica-1974-75/_index.md`
- `content/posters/by-source/rubrica-1976-77/_index.md`
- `content/posters/by-source/rubrica-1978-79/_index.md`
- `content/posters/by-source/rubrica-1982-83/_index.md`
- `content/posters/by-source/rubrica-1984-92/_index.md`
- `content/posters/by-title/_content.gotmpl`
- `content/posters/by-title/_index.md`
- `content/posters/by-year/1953/_index.md`
- `content/posters/by-year/1955/_index.md`
- `content/posters/by-year/1956/_index.md`
- `content/posters/by-year/1957/_index.md`
- `content/posters/by-year/1959/_index.md`
- `content/posters/by-year/1960/_index.md`
- `content/posters/by-year/1961/_index.md`
- `content/posters/by-year/1962/_index.md`
- `content/posters/by-year/1963/_index.md`
- `content/posters/by-year/1964/_index.md`
- `content/posters/by-year/1965/_index.md`
- `content/posters/by-year/1966/_index.md`
- `content/posters/by-year/1967/_index.md`
- `content/posters/by-year/1968/_index.md`
- `content/posters/by-year/1969/_index.md`
- `content/posters/by-year/1970/_index.md`
- `content/posters/by-year/1971/_index.md`
- `content/posters/by-year/1972/_index.md`
- `content/posters/by-year/1973/_index.md`
- `content/posters/by-year/1974/_index.md`
- `content/posters/by-year/1975/_index.md`
- `content/posters/by-year/1976/_index.md`
- `content/posters/by-year/1977/_index.md`
- `content/posters/by-year/1978/_index.md`
- `content/posters/by-year/1979/_index.md`
- `content/posters/by-year/1980/_index.md`
- `content/posters/by-year/1981/_index.md`
- `content/posters/by-year/1982/_index.md`
- `content/posters/by-year/1983/_index.md`
- `content/posters/by-year/1984/_index.md`
- `content/posters/by-year/1985/_index.md`
- `content/posters/by-year/1986/_index.md`
- `content/posters/by-year/1987/_index.md`
- `content/posters/by-year/1988/_index.md`
- `content/posters/by-year/1989/_index.md`
- `content/posters/by-year/1990/_index.md`
- `content/posters/by-year/1991/_index.md`
- `content/posters/by-year/1992/_index.md`
- `content/posters/by-year/1993/_index.md`
- `content/posters/by-year/1994/_index.md`
- `content/posters/by-year/1995/_index.md`
- `content/posters/by-year/1996/_index.md`
- `content/posters/by-year/1999/_index.md`
- `content/posters/by-year/2002/_index.md`
- `content/posters/by-year/2003/_index.md`
- `content/posters/by-year/2004/_index.md`
- `content/posters/by-year/_index.md`
- `content/posters/films/_content.gotmpl`
- `content/posters/retro/_index.md`
- `content/privacy.md`
- `content/progetto.md`
- `content/programmazione-storica/_index.md`
- `content/programmazione-storica/anni/1948-01-01-programmazione-1948/index.md`
- `content/programmazione-storica/anni/1949-01-01-programmazione-1949/index.md`
- `content/programmazione-storica/anni/1950-01-01-programmazione-1950/index.md`
- `content/programmazione-storica/anni/1951-01-01-programmazione-1951/index.md`
- `content/programmazione-storica/anni/1952-01-01-programmazione-1952/index.md`
- `content/programmazione-storica/anni/1953-01-01-programmazione-1953/index.md`
- `content/programmazione-storica/anni/1954-01-01-programmazione-1954/index.md`
- `content/programmazione-storica/anni/1955-01-01-programmazione-1955/index.md`
- `content/programmazione-storica/anni/1956-01-01-programmazione-1956/index.md`
- `content/programmazione-storica/anni/1957-01-01-programmazione-1957/index.md`
- `content/programmazione-storica/anni/1958-01-01-programmazione-1958/index.md`
- `content/programmazione-storica/anni/1959-01-01-programmazione-1959/index.md`
- `content/programmazione-storica/anni/1960-01-01-programmazione-1960/index.md`
- `content/programmazione-storica/anni/1961-01-01-programmazione-1961/index.md`
- `content/programmazione-storica/anni/1962-01-01-programmazione-1962/index.md`
- `content/programmazione-storica/anni/1963-01-01-programmazione-1963/index.md`
- `content/programmazione-storica/anni/1964-01-01-programmazione-1964/index.md`
- `content/programmazione-storica/anni/1965-01-01-programmazione-1965/index.md`
- `content/programmazione-storica/anni/1966-01-01-programmazione-1966/index.md`
- `content/programmazione-storica/anni/1967-01-01-programmazione-1967/index.md`
- `content/programmazione-storica/anni/1968-01-01-programmazione-1968/index.md`
- `content/programmazione-storica/anni/1969-01-01-programmazione-1969/index.md`
- `content/programmazione-storica/anni/1970-01-01-programmazione-1970/index.md`
- `content/programmazione-storica/anni/1971-01-01-programmazione-1971/index.md`
- `content/programmazione-storica/anni/1972-01-01-programmazione-1972/index.md`
- `content/programmazione-storica/anni/1973-01-01-programmazione-1973/index.md`
- `content/programmazione-storica/anni/1974-01-01-programmazione-1974/index.md`
- `content/programmazione-storica/anni/1975-01-01-programmazione-1975/index.md`
- `content/programmazione-storica/anni/1976-01-01-programmazione-1976/index.md`
- `content/programmazione-storica/anni/1977-01-01-programmazione-1977/index.md`
- `content/programmazione-storica/anni/1978-01-01-programmazione-1978/index.md`
- `content/programmazione-storica/anni/1979-01-01-programmazione-1979/index.md`
- `content/programmazione-storica/anni/1980-01-01-programmazione-1980/index.md`
- `content/programmazione-storica/anni/1981-01-01-programmazione-1981/index.md`
- `content/programmazione-storica/anni/1982-01-01-programmazione-1982/index.md`
- `content/programmazione-storica/anni/1983-01-01-programmazione-1983/index.md`
- `content/programmazione-storica/anni/1984-01-01-programmazione-1984/index.md`
- `content/programmazione-storica/anni/1985-01-01-programmazione-1985/index.md`
- `content/programmazione-storica/anni/1986-01-01-programmazione-1986/index.md`
- `content/programmazione-storica/anni/1987-01-01-programmazione-1987/index.md`
- `content/programmazione-storica/anni/1988-01-01-programmazione-1988/index.md`
- `content/programmazione-storica/anni/1989-01-01-programmazione-1989/index.md`
- `content/programmazione-storica/anni/1990-01-01-programmazione-1990/index.md`
- `content/programmazione-storica/anni/1991-01-01-programmazione-1991/index.md`
- `content/programmazione-storica/anni/1992-01-01-programmazione-1992/index.md`
- `content/programmazione-storica/anni/1993-01-01-programmazione-1993/index.md`
- `content/programmazione-storica/anni/1994-01-01-programmazione-1994/index.md`
- `content/programmazione-storica/anni/1995-01-01-programmazione-1995/index.md`
- `content/programmazione-storica/anni/1996-01-01-programmazione-1996/index.md`
- `content/programmazione-storica/anni/1997-01-01-programmazione-1997/index.md`
- `content/programmazione-storica/anni/1998-01-01-programmazione-1998/index.md`
- `content/programmazione-storica/anni/1999-01-01-programmazione-1999/index.md`
- `content/programmazione-storica/anni/2000-01-01-programmazione-2000/index.md`
- `content/programmazione-storica/anni/2001-01-01-programmazione-2001/index.md`
- `content/programmazione-storica/anni/2002-01-01-programmazione-2002/index.md`
- `content/programmazione-storica/anni/2003-01-01-programmazione-2003/index.md`
- `content/programmazione-storica/anni/2004-01-01-programmazione-2004/index.md`
- `content/programmazione-storica/anni/_index.md`
- `content/programmazione-storica/fonti/1965-01-01-note-sui-manifesti/index.md`
- `content/programmazione-storica/fonti/_index.md`
- `content/programmazione-storica/fonti/agende/1948-10-01-fincine-1948-49/index.md`
- `content/programmazione-storica/fonti/agende/1948-10-01-incam-1948-49/index.md`
- `content/programmazione-storica/fonti/agende/1949-10-01-elettrocarbonium-1949-50/index.md`
- `content/programmazione-storica/fonti/agende/1949-10-01-incam-1949-50/index.md`
- `content/programmazione-storica/fonti/agende/1950-12-01-elettrocarbonium-1950-51/index.md`
- `content/programmazione-storica/fonti/agende/1951-11-01-bruzia-1951-52/index.md`
- `content/programmazione-storica/fonti/agende/1952-12-01-bruzia-1952-53/index.md`
- `content/programmazione-storica/fonti/agende/1952-12-01-fedi-1952-53/index.md`
- `content/programmazione-storica/fonti/agende/1953-12-01-fedi-1953-54/index.md`
- `content/programmazione-storica/fonti/agende/1954-12-01-bruzia-1954-55/index.md`
- `content/programmazione-storica/fonti/agende/1954-12-01-fedi-1954-55/index.md`
- `content/programmazione-storica/fonti/agende/1955-12-01-bruzia-1955-56/index.md`
- `content/programmazione-storica/fonti/agende/1956-10-01-bruzia-1956-57/index.md`
- `content/programmazione-storica/fonti/agende/1957-12-01-fedi-1957-58/index.md`
- `content/programmazione-storica/fonti/agende/1958-11-01-fedi-1958-59/index.md`
- `content/programmazione-storica/fonti/agende/1959-02-01-bruzia-1958-59/index.md`
- `content/programmazione-storica/fonti/agende/1960-10-01-fedi-1960-61/index.md`
- `content/programmazione-storica/fonti/agende/1961-11-01-fedi-1961-62/index.md`
- `content/programmazione-storica/fonti/agende/1962-11-01-fedi-1962-63/index.md`
- `content/programmazione-storica/fonti/agende/1964-01-01-rapidtransport-1964/index.md`
- `content/programmazione-storica/fonti/agende/1965-01-01-rapidtransport-1965/index.md`
- `content/programmazione-storica/fonti/agende/1966-01-01-ceat-1966/index.md`
- `content/programmazione-storica/fonti/agende/1966-01-01-naonis-1966/index.md`
- `content/programmazione-storica/fonti/agende/1968-01-01-agenda-1968/index.md`
- `content/programmazione-storica/fonti/agende/1968-11-01-morganite-1968-69/index.md`
- `content/programmazione-storica/fonti/agende/1969-11-01-lorraine-1969-70/index.md`
- `content/programmazione-storica/fonti/agende/1970-12-01-lorraine-1970-71/index.md`
- `content/programmazione-storica/fonti/agende/1975-11-01-fedi-1975-76/index.md`
- `content/programmazione-storica/fonti/agende/1976-12-01-elettrocarbonium-1976-77/index.md`
- `content/programmazione-storica/fonti/agende/1977-11-01-prevost-1977-78/index.md`
- `content/programmazione-storica/fonti/agende/_index.md`
- `content/programmazione-storica/fonti/appunti/1985-10-01-appunti-cif-1985-86/index.md`
- `content/programmazione-storica/fonti/appunti/1986-09-01-appunti-cif-1986-87/index.md`
- `content/programmazione-storica/fonti/appunti/1987-06-01-appunti-cif-1987-88/index.md`
- `content/programmazione-storica/fonti/appunti/1988-09-01-appunti-italautogamma-1988-89/index.md`
- `content/programmazione-storica/fonti/appunti/1989-09-01-appunti-italautogamma-1989-90/index.md`
- `content/programmazione-storica/fonti/appunti/1990-09-01-appunti-italautogamma-1990-91/index.md`
- `content/programmazione-storica/fonti/appunti/1991-09-01-appunti-italautogamma-1991-92/index.md`
- `content/programmazione-storica/fonti/appunti/1992-10-01-appunti-italautogamma-1992-93/index.md`
- `content/programmazione-storica/fonti/appunti/1993-10-01-appunti-new-europe-1993-94/index.md`
- `content/programmazione-storica/fonti/appunti/1994-10-01-appunti-new-europe-1994-95/index.md`
- `content/programmazione-storica/fonti/appunti/1995-10-01-appunti-new-europe-1995-00/index.md`
- `content/programmazione-storica/fonti/appunti/2000-09-01-appunti-victory-2000/index.md`
- `content/programmazione-storica/fonti/appunti/_index.md`
- `content/programmazione-storica/fonti/calendari/1948-01-01-calendario-1948/index.md`
- `content/programmazione-storica/fonti/calendari/1951-04-01-calendario-1951/index.md`
- `content/programmazione-storica/fonti/calendari/1952-01-01-calendario-1952/index.md`
- `content/programmazione-storica/fonti/calendari/1962-01-01-calendario-1962/index.md`
- `content/programmazione-storica/fonti/calendari/1962-12-01-calendario-1963/index.md`
- `content/programmazione-storica/fonti/calendari/1966-01-01-calendario-1966/index.md`
- `content/programmazione-storica/fonti/calendari/1967-01-01-calendario-1967/index.md`
- `content/programmazione-storica/fonti/calendari/1968-01-01-calendario-1968/index.md`
- `content/programmazione-storica/fonti/calendari/1971-12-01-calendario-1972/index.md`
- `content/programmazione-storica/fonti/calendari/1973-01-01-calendario-1973/index.md`
- `content/programmazione-storica/fonti/calendari/1974-01-01-calendario-1974/index.md`
- `content/programmazione-storica/fonti/calendari/1975-01-01-calendario-1975/index.md`
- `content/programmazione-storica/fonti/calendari/1979-01-01-calendario-1979/index.md`
- `content/programmazione-storica/fonti/calendari/1980-01-01-calendario-1980/index.md`
- `content/programmazione-storica/fonti/calendari/1981-01-01-calendario-1981/index.md`
- `content/programmazione-storica/fonti/calendari/1982-01-01-calendario-1982/index.md`
- `content/programmazione-storica/fonti/calendari/1983-01-01-calendario-1983/index.md`
- `content/programmazione-storica/fonti/calendari/1984-01-01-calendario-1984/index.md`
- `content/programmazione-storica/fonti/calendari/1985-01-01-calendario-1985-2/index.md`
- `content/programmazione-storica/fonti/calendari/1985-01-01-calendario-1985/index.md`
- `content/programmazione-storica/fonti/calendari/1986-01-01-calendario-1986/index.md`
- `content/programmazione-storica/fonti/calendari/1987-01-01-calendario-1987/index.md`
- `content/programmazione-storica/fonti/calendari/1988-01-01-calendario-1988/index.md`
- `content/programmazione-storica/fonti/calendari/1989-01-01-calendario-1989/index.md`
- `content/programmazione-storica/fonti/calendari/1990-01-01-calendario-1990/index.md`
- `content/programmazione-storica/fonti/calendari/1991-01-01-calendario-1991/index.md`
- `content/programmazione-storica/fonti/calendari/1992-01-01-calendario-1992/index.md`
- `content/programmazione-storica/fonti/calendari/1993-01-01-calendario-1993/index.md`
- `content/programmazione-storica/fonti/calendari/1994-01-01-calendario-1994/index.md`
- `content/programmazione-storica/fonti/calendari/1995-01-01-calendario-1995/index.md`
- `content/programmazione-storica/fonti/calendari/1996-01-01-calendario-1996/index.md`
- `content/programmazione-storica/fonti/calendari/1996-02-01-calendario-1997/index.md`
- `content/programmazione-storica/fonti/calendari/1998-01-01-calendario-1998/index.md`
- `content/programmazione-storica/fonti/calendari/1999-01-01-calendario-1999/index.md`
- `content/programmazione-storica/fonti/calendari/2000-01-01-calendario-2000/index.md`
- `content/programmazione-storica/fonti/calendari/2001-01-01-calendario-2001/index.md`
- `content/programmazione-storica/fonti/calendari/2002-01-01-calendario-2002/index.md`
- `content/programmazione-storica/fonti/calendari/2003-01-01-calendario-2003/index.md`
- `content/programmazione-storica/fonti/calendari/2004-01-01-calendario-2004/index.md`
- `content/programmazione-storica/fonti/calendari/_index.md`
- `content/programmazione-storica/fonti/rubriche/1967-01-01-rubrica-1967/index.md`
- `content/programmazione-storica/fonti/rubriche/1968-01-01-rubrica-1968/index.md`
- `content/programmazione-storica/fonti/rubriche/1968-12-01-rubrica-1969-1981/index.md`
- `content/programmazione-storica/fonti/rubriche/1969-12-01-rubrica-1970-1980/index.md`
- `content/programmazione-storica/fonti/rubriche/1970-12-01-rubrica-1971/index.md`
- `content/programmazione-storica/fonti/rubriche/1971-12-01-rubrica-1972/index.md`
- `content/programmazione-storica/fonti/rubriche/1973-01-01-rubrica-1973/index.md`
- `content/programmazione-storica/fonti/rubriche/1974-01-01-rubrica-1974-75/index.md`
- `content/programmazione-storica/fonti/rubriche/1976-01-01-rubrica-1976-77/index.md`
- `content/programmazione-storica/fonti/rubriche/1977-12-01-rubrica-1978-79/index.md`
- `content/programmazione-storica/fonti/rubriche/1982-01-01-rubrica-1982-83/index.md`
- `content/programmazione-storica/fonti/rubriche/1984-01-01-rubrica-1984-92/index.md`
- `content/programmazione-storica/fonti/rubriche/_index.md`
- `content/programmazione-storica/generi/_index.md`
- `content/programmazione-storica/generi/animazione/index.md`
- `content/programmazione-storica/generi/avventura/index.md`
- `content/programmazione-storica/generi/azione/index.md`
- `content/programmazione-storica/generi/biografico/index.md`
- `content/programmazione-storica/generi/commedia/index.md`
- `content/programmazione-storica/generi/documentario/index.md`
- `content/programmazione-storica/generi/drammatico/index.md`
- `content/programmazione-storica/generi/fantascienza/index.md`
- `content/programmazione-storica/generi/fantastico/index.md`
- `content/programmazione-storica/generi/giallo/index.md`
- `content/programmazione-storica/generi/guerra/index.md`
- `content/programmazione-storica/generi/horror/index.md`
- `content/programmazione-storica/generi/musica/index.md`
- `content/programmazione-storica/generi/musical/index.md`
- `content/programmazione-storica/generi/noir/index.md`
- `content/programmazione-storica/generi/per-adulti/index.md`
- `content/programmazione-storica/generi/per-famiglie/index.md`
- `content/programmazione-storica/generi/poliziesco/index.md`
- `content/programmazione-storica/generi/sentimentale/index.md`
- `content/programmazione-storica/generi/sportivo/index.md`
- `content/programmazione-storica/generi/storico/index.md`
- `content/programmazione-storica/generi/thriller/index.md`
- `content/programmazione-storica/generi/western/index.md`
- `content/programmazione-storica/paesi-di-produzione/_index.md`
- `content/programmazione-storica/paesi-di-produzione/afghanistan/index.md`
- `content/programmazione-storica/paesi-di-produzione/algeria/index.md`
- `content/programmazione-storica/paesi-di-produzione/argentina/index.md`
- `content/programmazione-storica/paesi-di-produzione/australia/index.md`
- `content/programmazione-storica/paesi-di-produzione/austria/index.md`
- `content/programmazione-storica/paesi-di-produzione/belgium/index.md`
- `content/programmazione-storica/paesi-di-produzione/brazil/index.md`
- `content/programmazione-storica/paesi-di-produzione/bulgaria/index.md`
- `content/programmazione-storica/paesi-di-produzione/canada/index.md`
- `content/programmazione-storica/paesi-di-produzione/china/index.md`
- `content/programmazione-storica/paesi-di-produzione/colombia/index.md`
- `content/programmazione-storica/paesi-di-produzione/czech-republic/index.md`
- `content/programmazione-storica/paesi-di-produzione/czechoslovakia/index.md`
- `content/programmazione-storica/paesi-di-produzione/denmark/index.md`
- `content/programmazione-storica/paesi-di-produzione/dominican-republic/index.md`
- `content/programmazione-storica/paesi-di-produzione/east-germany/index.md`
- `content/programmazione-storica/paesi-di-produzione/egypt/index.md`
- `content/programmazione-storica/paesi-di-produzione/france/index.md`
- `content/programmazione-storica/paesi-di-produzione/germany/index.md`
- `content/programmazione-storica/paesi-di-produzione/greece/index.md`
- `content/programmazione-storica/paesi-di-produzione/hong-kong/index.md`
- `content/programmazione-storica/paesi-di-produzione/hungary/index.md`
- `content/programmazione-storica/paesi-di-produzione/india/index.md`
- `content/programmazione-storica/paesi-di-produzione/indonesia/index.md`
- `content/programmazione-storica/paesi-di-produzione/iran/index.md`
- `content/programmazione-storica/paesi-di-produzione/ireland/index.md`
- `content/programmazione-storica/paesi-di-produzione/israel/index.md`
- `content/programmazione-storica/paesi-di-produzione/italy/index.md`
- `content/programmazione-storica/paesi-di-produzione/jamaica/index.md`
- `content/programmazione-storica/paesi-di-produzione/japan/index.md`
- `content/programmazione-storica/paesi-di-produzione/jordan/index.md`
- `content/programmazione-storica/paesi-di-produzione/lebanon/index.md`
- `content/programmazione-storica/paesi-di-produzione/liechtenstein/index.md`
- `content/programmazione-storica/paesi-di-produzione/malaysia/index.md`
- `content/programmazione-storica/paesi-di-produzione/mexico/index.md`
- `content/programmazione-storica/paesi-di-produzione/monaco/index.md`
- `content/programmazione-storica/paesi-di-produzione/morocco/index.md`
- `content/programmazione-storica/paesi-di-produzione/netherlands-antilles/index.md`
- `content/programmazione-storica/paesi-di-produzione/netherlands/index.md`
- `content/programmazione-storica/paesi-di-produzione/new-zealand/index.md`
- `content/programmazione-storica/paesi-di-produzione/peru/index.md`
- `content/programmazione-storica/paesi-di-produzione/philippines/index.md`
- `content/programmazione-storica/paesi-di-produzione/poland/index.md`
- `content/programmazione-storica/paesi-di-produzione/portugal/index.md`
- `content/programmazione-storica/paesi-di-produzione/puerto-rico/index.md`
- `content/programmazione-storica/paesi-di-produzione/romania/index.md`
- `content/programmazione-storica/paesi-di-produzione/singapore/index.md`
- `content/programmazione-storica/paesi-di-produzione/south-africa/index.md`
- `content/programmazione-storica/paesi-di-produzione/south-korea/index.md`
- `content/programmazione-storica/paesi-di-produzione/soviet-union/index.md`
- `content/programmazione-storica/paesi-di-produzione/spain/index.md`
- `content/programmazione-storica/paesi-di-produzione/sweden/index.md`
- `content/programmazione-storica/paesi-di-produzione/switzerland/index.md`
- `content/programmazione-storica/paesi-di-produzione/taiwan/index.md`
- `content/programmazione-storica/paesi-di-produzione/thailand/index.md`
- `content/programmazione-storica/paesi-di-produzione/trinidad-and-tobago/index.md`
- `content/programmazione-storica/paesi-di-produzione/tunisia/index.md`
- `content/programmazione-storica/paesi-di-produzione/turkey/index.md`
- `content/programmazione-storica/paesi-di-produzione/united-kingdom/index.md`
- `content/programmazione-storica/paesi-di-produzione/united-states/index.md`
- `content/programmazione-storica/paesi-di-produzione/venezuela/index.md`
- `content/programmazione-storica/paesi-di-produzione/west-germany/index.md`
- `content/programmazione-storica/paesi-di-produzione/yugoslavia/index.md`
- `content/riapertura/index.md`
- `content/sitemap.md`
- `content/tags/_index.md`
- `layouts/404.html`
- `layouts/_default/list.html`
- `layouts/_default/single.html`
- `layouts/_default/term.html`
- `layouts/archivio/list.html`
- `layouts/archivio/single.html`
- `layouts/articoli/list.html`
- `layouts/articoli/single.html`
- `layouts/eventi/list.html`
- `layouts/eventi/single.html`
- `layouts/index.html`
- `layouts/partials/archivio/scansioni.html`
- `layouts/partials/articoli/apertura.html`
- `layouts/partials/asset.html`
- `layouts/partials/breadcrumbs.html`
- `layouts/partials/contact-form.html`
- `layouts/partials/css-bundle.html`
- `layouts/partials/descrizione.html`
- `layouts/partials/eventi/inizio.html`
- `layouts/partials/eventi/riga.html`
- `layouts/partials/footer.html`
- `layouts/partials/grafici/anno-imdb.html`
- `layouts/partials/grafici/anno-mensile.html`
- `layouts/partials/grafici/articolo.html`
- `layouts/partials/grafici/colore.html`
- `layouts/partials/grafici/espandi.html`
- `layouts/partials/grafici/extended.html`
- `layouts/partials/grafici/film-per-adulti-per-anno.html`
- `layouts/partials/grafici/film-per-anno.html`
- `layouts/partials/grafici/fonti-per-decennio.html`
- `layouts/partials/grafici/generi-per-decennio.html`
- `layouts/partials/grafici/indice-assi.html`
- `layouts/partials/grafici/indice-legenda.html`
- `layouts/partials/grafici/indice-pannello.html`
- `layouts/partials/grafici/indice-xy.html`
- `layouts/partials/grafici/italia-estero-per-decennio.html`
- `layouts/partials/grafici/larghezza.html`
- `layouts/partials/grafici/numeri.html`
- `layouts/partials/grafici/paesi-per-decennio.html`
- `layouts/partials/grafici/pretty.html`
- `layouts/partials/head.html`
- `layouts/partials/header.html`
- `layouts/partials/home/cartellone-dati.html`
- `layouts/partials/home/cartellone.html`
- `layouts/partials/home/collezione.html`
- `layouts/partials/home/hero.html`
- `layouts/partials/home/immagine.html`
- `layouts/partials/home/ingressi.html`
- `layouts/partials/home/manifesto.html`
- `layouts/partials/home/numeri.html`
- `layouts/partials/home/riapertura.html`
- `layouts/partials/home/storie.html`
- `layouts/partials/nav.html`
- `layouts/partials/posters-format-heatmap.html`
- `layouts/partials/posters-genre-heatmap.html`
- `layouts/partials/posters-heatmap.html`
- `layouts/partials/posters-year-chart.html`
- `layouts/partials/posters/cards.html`
- `layouts/partials/posters/copertina.html`
- `layouts/partials/posters/count.html`
- `layouts/partials/posters/descrizione.html`
- `layouts/partials/posters/film-images.html`
- `layouts/partials/posters/film-map.html`
- `layouts/partials/posters/fonti.html`
- `layouts/partials/posters/gallery.html`
- `layouts/partials/posters/indice.html`
- `layouts/partials/posters/landing.html`
- `layouts/partials/posters/paesi.html`
- `layouts/partials/posters/page.html`
- `layouts/partials/posters/paginator.html`
- `layouts/partials/posters/proiezioni.html`
- `layouts/partials/posters/sheet-size.html`
- `layouts/partials/programmazione/collage-manifesti.html`
- `layouts/partials/programmazione/dati.html`
- `layouts/partials/programmazione/indici.html`
- `layouts/partials/programmazione/manifesti.html`
- `layouts/partials/programmazione/paesi-cella.html`
- `layouts/partials/programmazione/righe.html`
- `layouts/partials/programmazione/sezione.html`
- `layouts/partials/programmazione/striscia.html`
- `layouts/partials/riapertura/ultima.html`
- `layouts/partials/scheda.html`
- `layouts/partials/social-card.html`
- `layouts/partials/social-image.html`
- `layouts/posters/browse.html`
- `layouts/posters/country.html`
- `layouts/posters/film.html`
- `layouts/posters/genre.html`
- `layouts/posters/letter.html`
- `layouts/posters/retro.html`
- `layouts/posters/size.html`
- `layouts/posters/source.html`
- `layouts/posters/year.html`
- `layouts/programmazione-storica/anni/list.html`
- `layouts/programmazione-storica/generi/list.html`
- `layouts/programmazione-storica/list.html`
- `layouts/programmazione-storica/paesi-di-produzione/list.html`
- `layouts/programmazione-storica/single.html`
- `layouts/riapertura/single.html`
- `layouts/robots.txt`
- `layouts/shortcodes/dashboard.html`
- `layouts/shortcodes/grafico.html`
- `layouts/shortcodes/image-gallery.html`
- `layouts/shortcodes/manifesto.html`
- `layouts/shortcodes/poster-charts.html`
- `layouts/shortcodes/programmazione-tabelle.html`
- `static/js/cartellone.js`
- `static/js/dashboard.js`
- `static/js/lightbox.js`
- `static/js/manifesti.js`
- `config.yaml`
- `data/posters/films.json`
- `static/data/programmazione_agende.csv`

</details>
