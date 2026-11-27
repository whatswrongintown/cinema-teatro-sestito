# Italian text review: decisions

27 November 2026

Decisions on the 42 issues in Claude Code's report (`docs/italian-text-review.md`), with the evidence in `docs/italian-text-evidence.md`. All decision batches are done; the page-by-page rewriting (G1–G3) remains.

## Check these first

- **Changed files:** Claude Code reports no changes to website content, and nothing committed. Your repo includes generated files, so run `git status` after its `hugo` build. Review any changes in `public/` separately from the documentation changes.
- **The earlier skill draft:** it told Claude to fix generated pages through their R scripts. The report says those scripts were removed. Replace step 3 with: *"Find where the text currently comes from (Markdown, Hugo template, JavaScript, data or configuration) and propose the change there. A page's origin in an old R script doesn't mean the script still exists."*

## Decided: facts and sources

Agreed in chat on 27 November 2026. Your own text uses one modern spelling; transcriptions stay as written.

| # | Issue | Decision | Check before publishing |
| --- | --- | --- | --- |
| 1 | Mongiardo's letter (X1) | Keep *ammoniva*: *Mongiardo ammoniva Sestito a fare «di tutto per evitare proiezioni contro la moralità»*. Correct the transcription to the scan (*e farete di tutto*, *in iscritto*). Replace *In numerose occasioni* with *non per la prima volta* (the letter says *ancora una volta*). Replace *minacciando di rivolgersi alle autorità* with *lasciando intendere un intervento più deciso; la lettera fu inviata per conoscenza anche alla stazione dei carabinieri.* (2026-11-27) | Other parish letters, if the family has any |
| 2 | Trailer reels (X1) | Revised 2026-11-27 (A4): drop the sentence naming MGM, Titanus and Cineriz as senders of the reels; name a distributor only where a label shows one. New wording: *I trailer arrivavano a noleggio insieme ai film e passavano da un cinema all'altro tramite corriere. Le bobine conservate al Cinema Sestito, trovate accanto al proiettore, sono probabilmente quelle che non fu necessario restituire. Risalgono per lo più al periodo 1993–2003.* The MGM wording (*la filiale italiana della Metro-Goldwyn-Mayer* if *S.A.I.* confirms it, otherwise *la statunitense Metro-Goldwyn-Mayer*) applies only to the envelope page, whose date is 9 September 1957 (A7: correct the date shown, keep the old URL working) | Meaning of *Films S.A.I.* on the 1957 envelope; distributor names on the reel labels |
| 3 | Archive introduction (X1) | *Ogni documento è presentato con la data, la categoria e la riproduzione digitale.* | Every document has all three |
| 4 | Classification chart (R3, X1) | Remove the chart and its moral note from the article on the cinema's beginnings; keep your data and classification | Italia Taglia data later, with permission from the Cineteca di Bologna if needed |
| 5 | Agendas (V6) | *agende cinematografiche*, singular on each agenda page. Type page: *Le agende cinematografiche provenivano da diverse ditte del settore: case di distribuzione, fornitori di apparecchiature e di carboni per le lampade ad arco, ditte che trasportavano le pellicole.* (revised 2026-11-27, A6). Name a supplier only where the cover shows it; Fincine 1948-49 gets no type until its cover is seen | Covers of Ceat 1966, Naonis 1966, Agenda 1968 and the issuer of Fincine 1948-49; whether Agenzia Fedi – Cosenza was the maker or a dealer |
| 6 | Names (V7) | *INCOM* for the agendas and source names, as printed on the covers (*INCOM 1948-49*, *INCOM 1949-50*, like *NAONIS*), the CSV included; *Incom* only inside *La Settimana Incom* (2026-11-27) (exception to the data freeze, 2026-11-27, A3; the covers read INCOM; *Incam* was a repository error); *Vincenzo Calzone*; *Cinema Masceri* (*di Catanzaro* on first mention); membership card described as printed | Whether the card shows AGIS as well as ANEC |
| 7 | Founding year (D1) | Keep *1946–2004* in footer and home; the project page separates family memory (1946) from documents (1947 nulla osta, 1949 licence) and records (from 1948) | The 1947 and 1949 dates against the documents |
| 8 | *Gli anni d'oro* (D2) | Licence 30 June 1959; replace *pochi giorni dopo*; 1966 contracts in date order; *il massimo fu raggiunto tra il 1966 e il 1968*; *dal 1978 i film in cartellone calano* (142 in 1978, 99 in 1979); heading *Trasformazione e declino (dal 1977)*, 1977 being the year the adult films begin (2026-11-27, A2) | Yearly counts checked 2026-11-27 (`da-verificare.md`, B9) |
| 9 | Fifty years (D3) | *Oltre cinquant'anni di cartellone* | — |
| 10 | Clearing the hall (D4) | *Tra il 2020 e il 2023 la sala è stata sgomberata, mentre documenti e manifesti venivano messi in salvo.* July 2023 photo stays in its step | — |

## Decided: counts

A record in the database is one title on one date. In busy years it may stand for several days and many shows; a film shown on several days in the same month is as a rule recorded once (20 films appear twice in one month). The site therefore counts *film in cartellone*, not screenings (V1, N2). On 2026-11-27 this term replaced *passaggi*, chosen earlier the same day.

| Term | Use for | Examples |
| --- | --- | --- |
| film | Every count of records in charts, axes and cards | Chart titles *Film per anno*, *Film per mese*, *Film per adulti (% dell'anno)*; axes *Film*; monthly total *Totale: 215 film* |
| film in cartellone | Headline totals and headers counting records | *5.479 film in cartellone*; *215 film in cartellone · 214 titoli* |
| In cartellone N volte | Film pages | *In cartellone 3 volte*, *In cartellone 1 volta* |
| titoli | Distinct films, each counted once | *214 titoli*; country and decade cards *film in cartellone · titoli*; on the poster pages too (*138 titoli* on Retro, decade cards); physical pieces stay *manifesti e locandine* |
| citazioni | Sources chart | *Citazioni nelle fonti per decennio* |
| proiezione | Only real, specific events in prose | *l'ultima proiezione nel 2004* |
| manifesti e locandine | Physical pieces in the collection | *1.787 manifesti e locandine, di cui 142 scritti a mano* |

Every label names its unit, so two numbers on one page never look contradictory: *215 film in cartellone · 214 titoli* for 1966.

Fixed explanation, near the charts and in the methodology: *Ogni film in cartellone corrisponde a un titolo registrato dalle fonti in una data. Un titolo programmato più volte è contato una volta per ciascuna; un film in sala per più giorni nello stesso mese è di norma registrato una sola volta.* (2026-11-27.)

*Le luci rosse*: *Orgia libera* made 243.000 lire *in una sola data di programmazione*, not *in una sola serata*: no source gives the evening (2026-11-27, A5; sources in `da-verificare.md`). Its income figures read *74.900 lire per ogni data in cartellone (241 date con incasso noto)* and *(1.221 date)*.

From the evidence check (`docs/italian-text-evidence.md`):

- The three charts labelled *Numero di film* count records: relabel them *Film per anno*, axis *Film*.
- The sources chart counts citations (10,671 against 5,479 records, since a record can cite up to four sources): label it *Citazioni nelle fonti per decennio*, with one explanatory line.
- The *Drammatico* rule is a bug: fix the code to drop *Drammatico* only when a film has a more specific genre, as the genres page says (135 records now vanish); the posters genre heatmap stays as it is; its caption already says Drammatico is excluded (owner, 2026-11-27; recomputing it from `films.json` is a later item, U34).
- Records without a country (55): left out of both country charts, with the note *Sono esclusi 55 film in cartellone senza paese di produzione noto.* (2026-11-27).
- *173 film* versus *172 film* is not an error: 173 films in the source, 172 of them with a printed poster. Label the link *Tutti i 172 titoli con manifesto stampato*.

## Decided: film titles

The title a film was shown under in San Vito leads everywhere. The data stays unchanged, except as granted on 2026-11-27 (A3): obvious keyboard slips, once checked against the agendas; templates decide what is displayed.

| Issue | Decision |
| --- | --- |
| F1, two titles | Main title from the programming data; second line *Titolo originale: …* only when it differs |
| F2, several Italian variants | Programming tables keep each source's title; poster and film pages use the most frequent variant |
| F3, capitals inside titles | Data as recorded; Italian titles displayed in sentence case, proper names kept; Claude Code prepares the list for you to check. Foreign titles unchanged |
| F4, apostrophes and ellipses | Typographic (’ and …) in every section |
| F5, titles in your text | Italics everywhere, linked titles included; «» only where italics can't show (alt texts); year on first mention, director when it helps |
| F6, typing errors in the data | Checked against the agendas by the owner (2026-11-27, C3.3, C3.4): the titles are as the sources wrote them, so none is corrected; the CSV stays as written |
| F7, sorting | *A 30 secondi dalla fine* under A |

In articles: the cartellone title first, the original in brackets when useful, for example *Perversioni sessuali a Las Vegas* (*Showgirls*). The evidence supports the rule: in 56 of the 79 cases the poster in the archive prints the programming title.

Settled 2026-11-27 (C1–C3 in `da-verificare.md`): always use the programming title; a film that never appears in the programming keeps the title printed on its poster. The 20 possible wrong IMDb matches and the 11 unclear films are shown under their programming titles (*Corruption* is *Di dietro tutta, femmine corrotte dal piacere* in *Le luci rosse*). The owner checked the agendas: *I temibili 7*, *Assassino sulla Costa Azzurra*, *Viziose asolescenti*, *Più veloce del vento* and *Le pioggie di Ranchipur* stay as written.

## Decided: voice and vocabulary

| Issue | Decision |
| --- | --- |
| R1, register | Narrative pages (articles, reopening, Retro, 404): plain personal voice, *io* and *mio nonno*. Section introductions and data pages: neutral and informative, short sentences with facts, names and dates. No academic abstractions, no promotional language |
| P1, grammatical person | *voi* for visitors, forms and instructions included; *io* in personal pages; impersonal for data and method; *noi* only for a real group. Form: *Avete un ricordo…*, *raccontatelo nel messaggio*; checkbox *Autorizzo il gestore del sito a ricontattarmi per un'eventuale pubblicazione separata del ricordo.* |
| P2, author | No author reference anywhere: remove *Di Vito Sestito* from articles. The founder is *Vito Sestito*, with his dates on first mention: *Vito Sestito (1902–1985)*, confirmed 2026-11-27 |
| P3, masculine forms | Neutral wording: *Questa pagina non esiste*; *Per ricevere una risposta, inserite l'email* |
| T1, tenses | Present allowed in timeline steps; past tenses in articles and introductions (passato remoto for distant history, passato prossimo for recent events); present only for what sources show today |
| V2, the dataset | *programmazione ricostruita* in prose, *database* only in technical text, no *registro* |
| V3, the cinema's name | *Cinema Teatro Sestito* on first mention, then *il Cinema Sestito* or *la sala*; lowercase *cinema* as a common noun; templates *In sala al Cinema Sestito*, *Accadde al Cinema Sestito* |
| V4, section names | Storie / Storie; Programmazione / Programmazione storica; Manifesti / Manifesti e locandine; Il progetto; Archivio (*Nove categorie*, not *Nove fondi*); Argomenti; Home. URLs unchanged |
| V5, posters | Collection: *manifesti e locandine*; *manifesti* as defined shorthand; counts by format (*835 fotobuste*); singular captions (*Fotobusta 50x70, n. 1*); *manifesti scritti a mano*, *Retro* only as menu label and URL |
| V8, English words | Keep *database*, *major*, *Home*; *vs* → *e* or *rispetto a*; *submission* → *invio*; *gli organizzatori di Sonati Vicinu*. IMDb credit unchanged until its required wording is checked |
| V9, archive categories | Nouns: *Atti giudiziari*, *Documenti personali*; *le attrezzature* |
| R2, 404 page | *Questa pagina non esiste o è stata spostata. Potete tornare alla Home o cercare tra le sezioni del sito. Se pensate che manchi qualcosa, scrivete dal modulo contatti.* |

### Model passages for the style guide

- **Personal:** the Retro page, section *Perché «Retro»* (`content/posters/retro/_index.md`), and the reopening step *L'ultimo documento* (`content/riapertura/index.md`).
- **Neutral:** the reopening introduction (`content/riapertura/index.md`), and *Quanto incassavano* in *Le luci rosse*, once *registro* becomes *le fonti* and the counts become *date in cartellone* (see `guida-di-stile.md`).
- **Not models yet:** the methodology passages; one has the T2 slip *mi era nota solo dopo* (better: *Ne ho scoperto l'esistenza solo dopo…*).

For the 2015 interview, separate the original interview from any introduction added later, and don't restyle what was said or originally published.

## Decided: conventions

| Issue | Decision |
| --- | --- |
| T2, slips | *Ne ho scoperto l'esistenza solo dopo…*; *Tra il 2020 e il 2023…*; the *Cinema e leggende* sentence when that page is rewritten |
| C1, titles | Sentence case, proper names and acronyms kept: *Lettera del sacerdote Gerardo Mongiardo*, *Autorizzazione assemblea DC* |
| C2, categories and tags | Hugo capitalises only the first letter; proper names get their own term page (*San Vito sullo Ionio*); hashtag-style tags replaced. Confirm the Hugo version first |
| C3, descriptions | Capital first letter in front matter and in templates |
| C4, lowercase | Genres lowercase in prose, capitals as labels; months lowercase except at the start of a heading; *il prefetto*, *il notaio*, *la signora* in your text |
| C5, source names | Brand names as printed; *Calendario 1985 (2)*, in the CSV too |
| D5, dates | *1° febbraio 1953*; en dash and full years in your text (*1957–1979*); source season names unchanged (*Fedi 1958-59*); *anni Sessanta* in labels too; descriptive alt text instead of ISO-date captions |
| N1, numbers | Italian format everywhere: *6,6/10*, *0,1%*, *1.000* |
| N3, sizes | *50x70* everywhere, *cm* in descriptive prose |
| X2, punctuation | «» in your text, transcriptions unchanged; en dash for ranges, spaced en dash for asides; no serial comma; accents not apostrophes (*comunità*, *può*, *è*); full stop on captions only when they are sentences |

## What happens next

1. Save this file in the repository as `docs/decisioni-testi.md`.
2. Claude Code writes the style guide and the to-check list from it, and proposes batches (prompt below).
3. You check the items marked *Check before publishing* against documents and data.
4. Claude Code applies the decisions one batch at a time, each on its own branch; you review the changes and the preview, then commit.
5. Page-by-page rewriting of the older pages (G1–G3), using the model passages.
6. Final pass with the review skill, its step 3 updated as in *Check these first*.

## Next prompt for Claude Code

For step 2. Opus is the right model for this: it involves judgement across many files.

```text
Read docs/decisioni-testi.md: my decisions on docs/italian-text-review.md. Also read docs/italian-text-evidence.md; where it contradicts a decision, list the contradiction instead of choosing. Don't change website content, data or templates yet.
(1) Write docs/guida-di-stile.md: a style guide in English with Italian examples, covering the two registers, grammatical person, tenses, vocabulary and glossary (passaggi, film, manifesti e locandine, programmazione ricostruita, names), titles, dates, numbers and punctuation. Include the four model passages exactly as written (with passage 5 adjusted as noted) and a few "write this / not this" pairs taken from the report. Keep it to a few pages.
(2) Write docs/da-verificare.md: every item marked "Check before publishing" and every "To check" item, with the document, data or page I need to look at.
(3) Propose implementation batches (facts, counts, titles, voice, conventions), listing the files each touches and which changes are templates, data or Markdown. Wait for my approval before editing.
Add to CLAUDE.md the line: "Before writing or changing any text visitors see, read docs/guida-di-stile.md." Follow the project's documentation rules.
```
