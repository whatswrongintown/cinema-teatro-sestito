# Style guide for the Italian text (2026-11-27)

How to write and change the text visitors see: page bodies, front matter shown
on the page, captions, alt text, template strings, chart labels and JavaScript
messages. It applies the owner's decisions in `decisioni-testi.md`; the issue
codes in brackets (V1, R1 ...) point to `italian-text-review.md`, where the
original examples are. Where a decision and the evidence disagree, the point
is listed in `da-verificare.md`, not settled here.

Transcriptions of documents (deeds, letters, reports) are never restyled:
they reproduce the original, spelling and punctuation included. The 2015
interview keeps what was said and originally published; only an introduction
added later follows this guide.

## 1. Two registers (R1)

| Register | Pages | How it sounds |
| --- | --- | --- |
| Personal | Articles, reopening, Retro, 404 | Plain, first person (*io*, *mio padre*, *mio nonno*), concrete events, names and dates |
| Neutral | Section introductions, data pages, chart notes, methodology | Short sentences, facts, names, dates, numbers; no *io* |

Neither register uses academic abstractions (*si configura come*,
*dinamiche*, *costruzione identitaria*, *lungi dall'essere*) or promotional
language (*affascinante mondo*, *un sogno che diventa realtà*, *cuore
pulsante*). A sentence that carries no fact is cut, not reworded (G1–G3).

## 2. Grammatical person (P1–P3)

- **Visitors: *voi*.** Instructions written as full sentences, forms
  included: *Avete un ricordo…*, *raccontatelo nel messaggio*, *Scegliete un
  anno*. Never *tu*.
- **Buttons and link labels: nouns, not imperatives,** with an arrow when they
  lead somewhere: *I manifesti →*, *Il progetto →*, *Verso la riapertura →*,
  *I dati →*, *La riapertura →*; buttons to the memories form: *Il vostro
  ricordo →*. Exceptions: *Home* (404 button), items in a list of links
  (*Ricordi*, *Email*), *Precedente* / *Successiva*, and the menu button,
  labelled *Menu* in both states (its `aria-expanded` says whether it is
  open).
- **The owner: *io*, only on personal pages** (articles, reopening, Retro).
  Neutral pages (site map, privacy, section introductions, 404) never say
  *io*: *Se non trovate quello che cercate, scrivete dal modulo contatti.*
- **Data and method: impersonal.** *Per i criteri si veda la metodologia.*
- ***noi*** only for a real group of people.
- **Visitor speaking in a form:** *Autorizzo il gestore del sito a ricontattarmi
  per un'eventuale pubblicazione separata del ricordo.*
- **No author reference:** no *Di Vito Sestito* on articles. The founder is
  *Vito Sestito (1902–1985)* on first mention in third-person text; in
  personal pages he is *mio nonno*.
- **Neutral forms, not the masculine generic:** *Questa pagina non esiste*;
  *Per ricevere una risposta, inserite l'email*.

## 3. Tenses (T1, T2)

- **Articles and introductions: past tenses.** Passato remoto for distant
  history (*Vito Sestito nacque nel 1902*, *il Cinema Sestito proiettò per
  l'ultima volta nel 2004*), passato prossimo for
  recent events (*ha chiuso nel 2004*, *ho scansionato*).
- **Present:** in timeline steps (*fotografo l'ingresso*, *comincio*), and for
  what sources show today (*le fonti mostrano*, *la lettera dice*).
- No historic present inside a past-tense paragraph.
- *solo dopo* needs an event: *Ne ho scoperto l'esistenza solo dopo…*

## 4. Vocabulary and glossary

### Counts (V1, N2)

A record in the database is one title on one date. In busy years it may stand
for several days and many shows. (Decided 2026-11-27; replaces *passaggio*.)

| Term | Use for | Example |
| --- | --- | --- |
| *film* | Every count of records in charts, axes and cards | *Film per anno*, *Film per mese*, *Film per adulti (% dell'anno)*; axis *Film*; *Totale: 215 film* |
| *film in cartellone* | Headline totals and page headers counting records | *5.479 film in cartellone*; *215 film in cartellone · 214 titoli* |
| *In cartellone N volte* | Film pages | *In cartellone 3 volte*; *In cartellone 1 volta* |
| *titoli* | Distinct films, each counted once | *214 titoli*; country cards *2.777 film in cartellone · 2.325 titoli*; poster pages: *138 titoli* (Retro) |
| *date in cartellone* | Records seen as dates, where *film* would not read | *74.900 lire per ogni data in cartellone (241 date con incasso noto)* |
| *proiezione* | Only a real, specific event, in prose | *l'ultima proiezione nel 2004* |
| *citazione* | A record × a source naming it (sources chart) | *Citazioni nelle fonti per decennio* |
| *manifesti e locandine* | Physical pieces in the poster collection | *1.787 manifesti e locandine, di cui 142 scritti a mano* |

Every label names its unit, so two numbers on one page never look
contradictory: *215 film in cartellone · 214 titoli*; *Tutti i 172 titoli con
manifesto stampato*.

Fixed explanation, near the charts and in the methodology:

> Ogni film in cartellone corrisponde a un titolo registrato dalle fonti in una
> data. Un titolo programmato più volte è contato una volta per ciascuna; un
> film in sala per più giorni nello stesso mese è di norma registrato una sola
> volta.

A record's income or event is never stretched to *una serata* unless a source
says so: write *in una sola data di programmazione*.

### The dataset (V2)

*programmazione ricostruita* in prose; *database* only in technical text
(methodology); never *registro*. Sources are *le fonti*: *agende*,
*calendari*, *rubriche*, *appunti*, *note sui manifesti*.

### The cinema and the sections (V3, V4)

- *Cinema Teatro Sestito* on first mention, then *il Cinema Sestito* or *la
  sala*. *cinema* is lowercase as a common noun (*la storia del cinema*).
  Template strings: *In sala al Cinema Sestito*, *Accadde al Cinema Sestito*.
- Sections (menu / title): Storie / Storie; Programmazione / Programmazione
  storica; Manifesti / Manifesti e locandine; Il progetto; Archivio;
  Argomenti; Home. URLs do not change.

### Posters (V5, N3)

- The collection is *manifesti e locandine*; *manifesti* is the defined
  shorthand. Counts by format name the format: *835 fotobuste*, *271
  locandine*.
- Captions in the singular: *Fotobusta 50x70, n. 1*; *Manifesto 100x140, n. 1*.
- Hand-written pieces are *manifesti scritti a mano*; *Retro* only as the menu
  label and in the URL.
- Sizes *50x70* everywhere; *cm* only in descriptive prose (*un manifesto di
  140x200 cm*).

### Agendas, archive, names (V6, V7, V9)

- *agende cinematografiche*; one agenda page speaks of one agenda. Name the
  issuing firm only where the cover shows it. The firms, in general: *case di
  distribuzione, fornitori di apparecchiature e di carboni per le lampade ad
  arco, ditte che trasportavano le pellicole*.
- Name a distributor (of a reel, a poster, a letter) only where the object
  shows it.
- Archive categories are nouns: *Atti giudiziari*, *Documenti personali*,
  *Attrezzature* (*le attrezzature*). The archive has *nove categorie*, not
  *fondi*.
- One modern spelling in editorial text: *INCOM* (agendas and sources; *Incom* only in *La Settimana Incom*), *Vincenzo
  Calzone*, *Cinema Masceri* (*di Catanzaro* on first mention), *San Vito
  sullo Ionio*, *Piazza Mario Polerà*.

### English words (V8)

Keep *database*, *major*, *Home*. Otherwise Italian: *vs* → *e* / *rispetto
a*; *submission* → *invio*; *il team di* → *gli organizzatori di*; *rating* →
*classificazione*. The IMDb credit line stays as it is.

## 5. Film titles (F1–F7)

- **The title the film was shown under in San Vito leads**, taken from the
  programming. When the original differs, a second line: *Titolo originale:
  …*. Poster and film pages use the most frequent programming variant;
  programming tables keep each source's wording.
- **In running text:** italics, linked titles included; «» only where italics
  cannot show (alt text, front matter shown raw). Year on first mention,
  director when it helps; the original in brackets when useful:
  *Perversioni sessuali a Las Vegas* (*Showgirls*, 1986).
- **Display:** Italian titles in sentence case, proper names kept (*I cavalieri
  dalle maschere nere (I Beati Paoli)*); foreign titles unchanged. Typographic ’ and … everywhere.
- **Sorting:** skip the articles *il, lo, la, i, gli, le, l’, un, uno, una,
  un’* and English *the, an*; Italian *a* is a preposition, so *A 30 secondi
  dalla fine* and *A letto con il nemico* sort under A (*A Beautiful Mind*,
  English, under B).
- **Original title:** on film pages, *Titolo originale: …* (in italics) only
  when it differs from the title shown in San Vito.

## 6. Capitals (C1–C5)

- Titles in sentence case, proper names and acronyms kept: *Lettera del
  sacerdote Gerardo Mongiardo*, *Autorizzazione assemblea DC*.
- Descriptions start with a capital, in front matter and in templates.
- Lowercase in prose: genres (*un film per adulti*, *il genere drammatico*;
  capitals only as labels: *Per adulti*), months (*26 luglio 1977*; capital
  only at the start of a heading), offices and courtesy titles (*il prefetto*,
  *il notaio*, *la signora*).
- Source names as printed on the cover (*Ceat 1966*, *NAONIS 1966*);
  *Calendario 1985 (2)*.

## 7. Dates and numbers (D3, D5, N1)

- First of the month *1° febbraio 1953*; other days *26 luglio 1977*.
- Ranges in editorial text: en dash and full years, *1957–1979*. Source
  season names stay as printed: *Fedi 1958-59*.
- Decades: *anni Sessanta*, in labels and tooltips too (not *Anni 1960*).
- Span of the programming: *Oltre cinquant'anni di cartellone*; the cinema:
  *1946–2004*.
- Italian number format everywhere, IMDb ratings included: *5.479*, *0,1%*,
  *6,6/10*, *1.000*.
- Alt text describes the image; no ISO dates as captions.

## 8. Punctuation (X2)

- «» for quotations in editorial text; transcriptions keep their marks.
- En dash for ranges (*1957–1979*); spaced en dash for asides (*… – un inciso –
  …*); no hyphen or em dash as a dash.
- No serial comma (*agende, calendari e appunti*).
- Accents, not apostrophes: *comunità*, *può*, *è*, *martedì*.
- Captions end with a full stop only when they are sentences.

## 9. Model passages

Copy their tone, not their words. Passages 1–3 are copied exactly as published;
passage 4 is adjusted as decided (*registro* → *le fonti*; the counts as
*date in cartellone*). The methodology is not a model yet (see T2).

**1. Personal.** `content/posters/retro/_index.md`, section *Perché «Retro»*

> Quando per un film non c'era il manifesto, mio nonno ne preparava uno da sé: prendeva il manifesto di un altro film, lo girava e sul **retro** scriveva a mano il titolo, spesso con l'orario dello spettacolo e qualche nome del cast. Ogni volta usava colori diversi, così non ce ne sono due uguali. Il bello di questi manifesti è proprio la scrittura a mano.

**2. Personal (timeline step).** `content/riapertura/index.md`, step *L'ultimo
documento*

> Dopo quasi due anni di pratiche legali resta da registrare un ultimo atto all'Agenzia delle Entrate. Ci torno per la seconda volta e resto in ufficio dalle 11 alle 13: scopro che il file andava consegnato in formato XML, non in PDF, e alla fine un impiegato, vista la mia pazienza, mi aiuta a prepararlo. Le carte sono in ordine.

**3. Neutral (introduction).** `content/riapertura/index.md`, page body

> Il Cinema Teatro Sestito ha chiuso nel 2004. Riaprirlo significa, prima di tutto, liberare la sala, ricostruirne la storia e mettere in regola l'edificio: un lavoro fatto di carte, attese e piccoli passi. Questa pagina li racconta in ordine e viene aggiornata a ogni novità.

**4. Neutral (data).** *Le luci rosse*, section *Quanto incassavano*, adjusted

> Per una parte delle date in cartellone le fonti riportano anche l'incasso, in lire correnti. Tra il 1977 e il 1994 un film per adulti incassava in media 74.900 lire per ogni data in cartellone (241 date con incasso noto), contro le 53.800 degli altri film (1.221 date). Il confronto va però fatto anno per anno, perché le lire del 1990 non valgono quelle del 1981: a parità di anno, i film per adulti incassavano in media circa il 20% in più, con eccezioni (nel 1981 e nel 1992 incassavano meno).

## 10. Write this, not this

Pairs from `italian-text-review.md`; the right-hand forms are on the site
today.

| Write this | Not this | Issue |
| --- | --- | --- |
| *5.479 film in cartellone* | *5.479 proiezioni documentate* | V1 |
| *Film per anno*, axis *Film* | *Numero di film* (axis counting records) | V1 |
| *le fonti mostrano che…* | *il registro segna…* | V2 |
| *Agende cinematografiche* | *Agende cinematografiche fornite dalle case distributrici* | V6 |
| *INCOM 1948-49* | *Incam 1948-49*, *Incom 1948-49* | V7 |
| *Fotobusta 50x70, n. 1* | *Fotobuste 50x70, n. 1* | V5 |
| *Avete un ricordo del cinema? Raccontatelo nel messaggio.* | *Hai un ricordo … raccontacelo* | P1 |
| *Questa pagina non esiste o è stata spostata.* | *Sembra che tu sia finito su una pagina che non esiste.* | P3, R2 |
| *Ne ho scoperto l'esistenza solo dopo…* | *La loro esistenza mi era nota solo dopo…* | T2 |
| *Tra il 2020 e il 2023 la sala è stata sgomberata* | *Dal 2020 la sala è stata sgomberata* | T2, D4 |
| *Mongiardo ammoniva Sestito a fare «di tutto per evitare proiezioni contro la moralità»* | *… pellicole “contrarie alla moralità pubblica”* (not in the letter) | X1 |
| *Lettera del sacerdote Gerardo Mongiardo* | *Lettera del Sacerdote Gerardo Mongiardo* | C1 |
| *1° febbraio 1953* | *1 febbraio 1953* | D5 |
| *1957–1979* | *1957-1979* | D5 |
| *Valutazione IMDb 6,6/10* | *6.6/10* | N1 |
| *la comunità*, *può* | *la comunita'*, *puo'* | X2 |
| *agende, calendari e appunti* | *registri, appunti, e calendari* | X2 |
| *Quando per un film non c'era il manifesto, mio nonno ne preparava uno da sé* (Retro) | *testimonianze preziose di un artigianato locale che ha contribuito a dare un volto alla programmazione* (posters landing, same subject) | R1, G1 |

## 11. Before changing a text

1. Find where the text comes from: Markdown in `content/`, a Hugo template or
   shortcode in `layouts/`, JavaScript in `static/js/`, data in `static/data/`
   or `data/`, or `config.yaml`. A page first written by an old R script is
   now ordinary Markdown; the scripts no longer exist.
2. Change it at that source, in every copy of the pattern.
3. Check that the facts still hold against `da-verificare.md`.
