# Italian text review: evidence check (2026-11-27)

Follow-up to `italian-text-review.md` (U32). It answers three questions
with what the repository holds: templates, the three programming CSVs,
`data/posters/films.json` and the scans published on the site. Nothing on the
site, in the data or in the code was changed. Where the repository cannot
settle a point, the last part of each section lists what to check on the
physical documents.

Evidence labels used below:

- **Template**: read from the file in `layouts/` or `static/js/`.
- **Data**: recomputed from the CSV or `films.json` with a script (the numbers
  match the built site, `hugo` 2026-11-27).
- **Scan**: read on an image in the repository (poster, agenda, letter,
  envelope, reel photo). Small print was read on reduced copies; anything
  marked "not legible" was not guessed.

## 1. What the counts measure

### Units

| Unit | Definition | Total |
| --- | --- | --- |
| Entry | One row of `static/data/programmazione_agende.csv`: one title on one date. No two rows share date, IMDb ID and title. | 5,479 rows on 5,273 distinct dates (188 dates have two or more rows) |
| Distinct film | Distinct non-empty IMDb ID among the entries. Entries without an ID (55) are never counted as films. | 4,626 |
| Source association | One entry × one source named in its `source` cell. An entry names 1 source (1,394 rows), 2 (3,042), 3 (979) or 4 (64). | 10,671 |
| Genre association | One entry × one IMDb genre of its film (`programmazione_imdb.csv`). 172 entries have no genre. | — |
| Country association | One entry × one country of its film (`programmazione_paesi.csv`). 55 entries have no country. | — |

Every number labelled "proiezioni" on the site counts **entries**, not
screenings. "Date registrate" (dashboard) also counts entries, not distinct
dates. "Film" means distinct IMDb IDs, except in the charts listed under
"Numero di film" below, which count entries.

### Each label, its calculation and what it counts

| Label on the site | Where | Calculation (template) | Counts | Example |
| --- | --- | --- | --- | --- |
| "5.479 proiezioni documentate" | Home strip | `len` of all rows (`partials/home/numeri.html`) | entries | 5,479 |
| "proiezioni documentate", "film con scheda IMDb", "fonti originali", "decenni di cartellone" | Programming landing, header | rows; distinct IDs; number of source pages; distinct decades (`programmazione-storica/list.html`) | entries; distinct films; pages; decades | 5,479; 4,626; 94; 7 |
| "1.347 proiezioni · 1.286 film" | Programming landing, decade bands | rows and distinct IDs of the decade (same file, line 75) | entries; distinct films | 1960s |
| "215 proiezioni" | Anni index cards | rows of the year (`partials/programmazione/sezione.html`, line 65) | entries | 1966 |
| "Un viaggio nella sala buia" / "Frequenza dei film proposti dal 1948 al 2004", axis "Numero di film", alt "Numero di film proposti per anno ... esclusi il 1960 e il 1961" | Anni index chart | rows per year, 1960 and 1961 left out (`partials/programmazione/indici.html`, `anni`; `partials/grafici/film-per-anno.html`) | **entries**, labelled films | 1966: 215 entries, 214 distinct films |
| "215 proiezioni", "214 film" | Year page header | rows; distinct IDs (`programmazione-storica/single.html`, lines 38–39) | entries; distinct films | 1966 |
| "Proiezioni documentate per mese", "Totale proiezioni: 215", axis "Numero di proiezioni" | Year page chart | rows per month (`partials/grafici/anno-mensile.html`) | entries | 1966 |
| "Valutazioni medie IMDb e numero di voti" | Year page chart | one point per entry with rating and votes, repeats kept (`partials/grafici/anno-imdb.html`) | entries of rated films | — |
| "Le prime stagioni del Cinema (1948–1957)", "Numero di film proposti per anno", axis "Numero di film", alt "Voci di programmazione registrate per anno" | Nascita article | rows per year (`partials/grafici/articolo.html`, `articolo-prime-stagioni`) | **entries**, labelled films and voci | 1948: 62 |
| "Distribuzione dei film per rating (1948–1957)", alt "Voci ... suddivise per classificazione" | Nascita article | rows per year whose film has a `rated` value that maps to one of four groups; other and missing values are left out (same file, `articolo-rating`) | entries with a mapped rating only: **350 of the 1,008 entries** of 1948–1957 | — |
| "Quando il grande schermo illuminava San Vito (1957–1979)", axis "Numero di film" | Anni d'oro article | rows per year, 1948–2004 (`articolo-grande-schermo`) | **entries**, labelled films | — |
| "Presenza delle fonti per decennio", legend "N° film", tooltip "Calendari, anni 1960: 823" | Fonti index chart | source associations per type and decade; the type comes from the source name (`cif`, `italautogamma`, `europe`, `victory` → Appunti; `manifest` → Note sui manifesti; `calendario` → Calendari; `rubric` → Rubriche; anything else → Agende) (`indici.html`, `fonti`) | **source associations**, labelled films | total 10,671, against 5,479 entries |
| "30 fonti"; "N proiezioni" | Fonti index cards | source pages per type; rows citing the source (`sezione.html`, lines 108–110) | pages; entries | "251 proiezioni" (Note sui manifesti) |
| "148 proiezioni", "144 film" | Source page header | rows citing the source; distinct IDs (`single.html`) | entries; distinct films | Fedi 1958-59 |
| "173 film" and "Tutti i 172 film con manifesto →" | Note sui manifesti page | distinct IDs among its 251 rows (36 further titles have no ID and are not counted); films of those rows that have a printed poster (`partials/programmazione/manifesti.html`) | distinct films; films with a poster | — |
| "Percentuale dei generi cinematografici per decennio" (alt), "Dominanza dei generi per decennio" (title) | Generi index chart | genre associations of the decade divided by all genre associations of the decade; "Drammatico" dropped by the rule below (`indici.html`, `generi`) | share of **genre associations** | — |
| "Percentuale annuale di film per adulti nella programmazione" | Generi index chart | rows of the year whose genres include "Per adulti" ÷ rows of the year (`indici.html`, `adulti`) | share of **entries** | 1983: 36 of 110 = 32.7 % |
| "Percentuale di film italiani ed esteri per decennio" | Paesi index chart | country associations naming Italy ÷ all country associations of the decade; an entry without a country counts once as foreign (`indici.html`, `italia`) | share of **country associations** | — |
| "Numero di paesi rappresentati nella programmazione per decennio" | Paesi index chart | distinct country names per decade; a missing country counts as one extra "country" (`indici.html`, `paesi`) | distinct countries, +1 in the 1960s, 1970s, 1980s and 1990s (entries without a country: 2, 1, 24, 28) | — |
| "2.777 proiezioni" (Italia) | Paesi index cards | rows whose country list contains the country, co-productions included | entries | Italy page header: "2.325 film" (distinct IDs) |
| "3 proiezioni documentate" | Film pages | rows with the film's IMDb ID; for films without an ID, the number of `screening_dates` in `films.json` (`posters/film.html`, line 65) | entries, or poster dates from another dataset | *Ulisse*: 3 |
| "Le proiezioni documentate dal 24 al 30 novembre" | Home billboard | rows falling on those calendar days in any year (`partials/home/cartellone-dati.html`, `static/js/cartellone.js`) | entries | — |
| "Totale proiezioni: N", "Proiezioni mensili", axis "Numero di proiezioni", note "Numero di date registrate per mese" | Dashboard | rows in the selection (`static/js/dashboard.js`, `monthChart`) | **entries** (not distinct dates) | — |
| "Film distinti per genere", "Valutazione IMDb in relazione al numero di voti, N film" | Dashboard | distinct films (key: IMDb ID, or title when there is no ID) | distinct films; one point per film (the year page chart keeps repeats) | — |
| "291 proiezioni", "713 voci su 1.586", weekday table, "74.900 lire ... (241 proiezioni con incasso noto)", "53.800 ... (1.221 proiezioni)" | Luci rosse article (hand-written) | Data: all recomputed and exact (rows 1977-07-26 to 1994-10-16 with genre "Per adulti"; `income` cells with a number) | entries | — |
| "1.787 manifesti e locandine"; "1.645 manifesti e locandine", "142 manifesti scritti a mano" | Home; posters landing | every poster image in `films.json` (835 fotobuste, 271 locandine, 539 manifesti, 142 retro); printed vs `is_retro` (`partials/home/numeri.html`, `partials/posters/landing.html`) | poster pieces | — |
| "106 dei 138 film ...", "124 dei 130 film ..." | Retro page (hand-written) | Data: 138 films have a hand-written poster; 106 produced before 1970; 130 have a screening date (the 124 was not recomputed) | films | — |
| "1966: 152 manifesti" | Posters by year chart | poster pieces counted once per screening year (`docs/posters.md`, U04) | poster-years | — |

### Findings on the calculations

- **"Numero di film" counts entries** in three charts (Anni index, both
  article bar charts). Over all years the entries exceed the distinct films of
  the same year by 184; the largest gaps are 1950 (+19), 1953 (+16), 1952 and
  1988 (+13). In 1966 the gap is one.
- **The fonti chart legend "N° film" counts source associations**, almost twice
  the number of entries.
- **The rating chart shows about a third of the entries** (350 of 1,008 for
  1948–1957): entries without a mapped rating are dropped, but the alt text
  presents the bars as all entries by classification.
- **The Drammatico rule does not do what the Generi page says.** The page:
  "la categoria «Drammatico» è esclusa quando accompagna un genere più
  specifico". The code counts, for each film, its number of genres summed
  over all its screenings, and drops "Drammatico" when that sum is above one.
  So a film whose only genre is "Drammatico" loses it when it was screened
  twice or more: 135 entries of 66 such films vanish from the chart, while the
  same films screened once stay. (The rule is documented in `indici.html` as
  inherited from the R code; the posters genre heatmap drops "Drammatico"
  altogether, a third rule.)
- **Missing data changes two country charts:** 55 entries without a country
  count as "Estero" in the Italy/foreign shares and as one extra country in
  the distinct-country count.
- The luci rosse and retro figures written by hand reproduce exactly from the
  data.

Nothing here needs a physical document; the choices are about labels and
rules (see V1 in the review).

## 2. The 79 title differences

### Sources of the two titles

- **Poster pages** show `title` from `films.json`. For every one of the 79 films
  that has a row in `programmazione_imdb.csv`, this title equals that row's
  `Title` (IMDb's display title). Nine of the 79 have no row in the IMDb export
  in the repository.
- **Programming tables** show the `title` written for each entry in
  `programmazione_agende.csv` (the agenda's wording, sometimes with another
  title in brackets).
- **Scan**: the first printed poster of each film (or the hand-written one if
  there is no printed one), read for the printed Italian title and, where
  printed, the director. The director was compared with `Directors` in the
  IMDb export.

### Classes and the rule used

Applied in this order:

1. **Possible wrong match**: the poster scan shows a different film's title,
   or its printed director differs from the IMDb export's director and the
   scan does not print the IMDb title. Adult films of the period were often
   signed with pseudonyms; the repository cannot tell a pseudonym from a
   different film, so this class means "check", not "wrong".
2. **Spelling or punctuation**: same words after ignoring case, punctuation,
   a leading article, digits vs number words, or a single-letter slip.
3. **Alternative title**: both titles are Italian titles of the film (the CSV
   pairs them as "A (B)", one is a short form of the other, or the scan shows
   both).
4. **Original versus Italian**: the poster page shows the original
   (non-Italian) IMDb title; the programming shows the Italian release title;
   the scan supports the link (it prints the original title in brackets, or
   its director matches the IMDb export, or the CSV itself pairs the two).
5. **Unclear**: nothing in the repository links the two titles beyond the ID
   (no director printed, no IMDb row, no bracketed original).

| Class | Films |
| --- | --- |
| Spelling or punctuation | 7 |
| Alternative title | 13 |
| Original versus Italian | 28 |
| Possible wrong match | 20 |
| Unclear | 11 |
| **Total** | **79** |

### Full list

"Dir." = director printed on the scan / director in the IMDb export. "—" =
none printed, or no IMDb row.

| IMDb ID | Poster page | Programming (CSV) | Scan shows | Dir. scan / IMDb | Class |
| --- | --- | --- | --- | --- | --- |
| tt0039377 | Fiesta | Fiesta (La matadora); La Matadora (Fiesta) | "La matadora" (fotobusta) | Richard Thorpe / Richard Thorpe | Original vs Italian |
| tt0045992 | Il diario di un condannato | Sotto il Sole Rovente (Il diario di un condannato) | "Sotto il sole rovente (Il diario di un condannato)" | Raoul Walsh / Raoul Walsh | Alternative title |
| tt0053780 | I dolci inganni | Dolci inganni | "I dolci inganni" | Alberto Lattuada / Alberto Lattuada | Spelling |
| tt0055169 | Messalina: Venere imperatrice | Messalina Venere imperatrice | "Messalina Venere imperatrice" | Vittorio Cottafavi / same | Punctuation |
| tt0058567 | Sei donne per l'assassino | 6 donne per l'assassino | "Sei donne per l'assassino" | Mario Bava / Mario Bava | Spelling (IMDb original title is "6 donne ...") |
| tt0061981 | Il mio corpo per un poker | The belle starr story (Il mio corpo per un poker) | hand-written "The Belle Starr story" | — / Piero Cristofani, Lina Wertmüller | Alternative title |
| tt0062408 | Tatuaggio | Il tatuaggio | hand-written "Tatuaggio" | — / Johannes Schaaf | Spelling (article) |
| tt0063754 | Vado, vedo e sparo | I tre che sconvolsero il West (Vado, vedo e sparo); Vado, vedo e sparo | hand-written "I tre che sconvolsero il West (Vado, vedo e sparo)" | — / Enzo G. Castellari | Alternative title |
| tt0067941 | Il vero e il falso | Il vero e il falso; L'uomo della verità (Il vero e il falso) | "L'uomo della verità" and "Il vero e il falso" | Eriprando Visconti / same | Alternative title |
| tt0068507 | Christine | Porno story di Christine | "the Porno Story of Christine" | — / Ernst Hofbauer | Unclear |
| tt0071836 | Squadra speciale antirapina | Squadra speciale antirapina; Quelli antirapina (Squadra speciale antirapina) | "Squadra speciale antirapina" | — / José Antonio de la Loma | Alternative title |
| tt0074102 | L'impero dei sensi | Ecco l'impero dei sensi | "Ecco l'impero dei sensi (L'empire des sens)" | Nagisa Oshima / same | Alternative title |
| tt0074313 | Jing wu men xu ji | Il ritorno di palma d'acciaio; Il Ritorno di Palma d'Acciaio (Jing wu men xu ji) (twice, one with a trailing space) | "Il ritorno di palma d'acciaio" | Jimmy Shaw / Iksan Lahardi, Tso Nam Lee, Jimmy Shaw | Original vs Italian |
| tt0076020 | Fella | Pornoexhibition | "Pornoexhibition" | Francis Leroi / — | Unclear |
| tt0076235 | Jouir jusqu'au délire | Corpi d'amore porno | "Corpi d'amore porno" | Thum Gerard / Gérard Vernier | Possible wrong match |
| tt0077520 | Le evase - Storie di sesso e di violenze | Le evase; Le evase - Storie di sesso e di violenze | title not legible | — / Giovanni Brusadori | Alternative title (short form) |
| tt0077777 | Jouir! | Porno libido | "Porno libido" | Gerard Kikoine / Gérard Kikoïne | Original vs Italian |
| tt0078267 | Sette ragazze di classe | 7 ragazze di classe | press-cutting collage printed "Una storia ambigua", regia Mario Bianchi | Mario Bianchi / Pedro Lazaga | Possible wrong match (the poster image; the title difference itself is digits vs words) |
| tt0079599 | Incontri proibiti | L'altro vizio della porno bocca (Incontri proibiti); ..., incontri proibiti | "L'altro vizio della porno bocca" with banner "Mistique" (IMDb original: "Mystique") | — / Roberta Findlay | Alternative title |
| tt0079903 | I 12 colpi segreti del Kung Fu di Bruce Lee l'invincibile | that title; Bruce Lee l'invincibile del kung fu | "Bruce Le l'invincibile ed i suoi 12 colpi segreti del kung-fu" | Tu Lu Po / Lu-Po Tu | Alternative title (the printed title matches neither) |
| tt0080720 | Fascination | American porno story | "American porno story" | Chuck Vincent / — | Unclear |
| tt0080927 | Insatiable | Marilyn l'insaziabile | "Marilyn l'insaziabile, Marilyn l'ingorda e una Marilyn da Supertilt" | — / Stu Segall | Unclear |
| tt0081593 | Taboo | Lunghi e duri per i… turbamenti erotici di Pamela | same | Robert Mc Callun / Kirdy Stevens | Possible wrong match |
| tt0085367 | Corruption | Di dietro tutta, femmine corrotte dal piacere | same | Richard Mahler / Roger Watkins | Possible wrong match |
| tt0089071 | Educating Mandy | I peccati della notte | same | Royce Shepard / Royce Shepard | Original vs Italian |
| tt0091058 | Flavia Schiava di Roma Regina d'amore | Flavia… Rome Bestial Luxury | "Flavia... Rome Bestial Luxury", "Production 1989" | L. Webber / — | Unclear |
| tt0095863 | Phantasm II | Fantasmi II (Phantasm II) | "Phantasm II" | Don Coscarelli / same | Original vs Italian (the Italian poster used the original title) |
| tt0122903 | American Pie | Belle erotiche e maliziose (American Pie); Belle, erotiche e maliziose | "Belle, erotiche e maliziose" | Jeffrey Fairbanks / Jeffrey Fairbanks, Damon Christian | Original vs Italian |
| tt0123638 | The New Erotic Adventures of Casanova | Casanova 82 | "Casanova 82" | John Holmes / John Holmes, Carlos Tobalina | Original vs Italian |
| tt0124491 | Eruption | Sensual eruption (Eruption) | "Sensual eruption" | Stanley Kurlin / Sam Norvell | Possible wrong match |
| tt0124693 | Great Sexpectations | Conturbanti esperienze di una ragazzina in calore | same, "(Great Deypeltations)" | Henri Pachard / same | Original vs Italian |
| tt0125175 | Hot Teenage Assets | Viziose asolescenti | "Viziose adolescenti (Hot Teenage Assets)" | Zachary Youngblood, Daemian Lee / Damian Lee, Zachary Strong | Original vs Italian; the CSV's "asolescenti" is a typing slip |
| tt0125296 | Justine, una minorenne deliziosa... | Justine, una minorenne deliziosa...; Justine una minorenne deliziosa… | "Justine una minorenne deliziosa..." | Robert R. Walters / Roberta Findlay, Cecil Howard, Walter E. Sear | Possible wrong match (the title difference itself is punctuation) |
| tt0125914 | Quella Porno-Erotica di Mia Moglie | Quella porno erotica di mia moglie | "Quella Porno-Erotica di Mia Moglie" | — / Carlos Tobalina | Spelling (case, hyphen) |
| tt0126288 | Erotic Flash | Corpi bollenti d'amore | "Corpi bollenti d'amore" (Moana Pozzi, Marina Lotar) | — / Roberto Bianchi Montero | Unclear |
| tt0127095 | Peaches and Cream | Voluttuose deviazioni carnali | same, "(Peaches and Cream)" | Robert Mc Callum / — | Original vs Italian |
| tt0127113 | Hot & Saucy Pizza Girls | Voglie erotiche di una porno pizzaiola (Hot & Saucy Pizza Girls) | "Voglie erotiche di una porno pizzaiola" | Robert C. Chinn / Bob Chinn | Original vs Italian |
| tt0127801 | A Scent of Heather | La moglie ingorda (A Scent of Heather); La moglie ingorda | "La moglie ingorda" | Philip Drexler Jr. / Bill Milling | Possible wrong match |
| tt0127824 | The Seduction of Lyn Carter | La seduzione di Lynne | same | Wess Brown / Anthony Spinelli | Possible wrong match |
| tt0127854 | Langues cochonnes | Pornoshow a Montecarlo (Langues cochonnes); Pornoshow a Montecarlo | "Pornoshow a Montecarlo" | Alan Vydra / Claude Pierson, Alan Vydra | Original vs Italian |
| tt0127875 | Sexcapades | Le super bocche | "Sharon e Dominique – Le super bocche" | Henri Pachard / same | Original vs Italian |
| tt0134562 | Cherry Cheese Cake | Folli desideri erotici | same | Briam McLaren / Brian McLaren | Original vs Italian |
| tt0137551 | For Services Rendered | Perversioni Internazionali | "Perversioni internazionali" | Tim MacDonald / Tim McDonald | Original vs Italian |
| tt0139593 | Scoundrels | Febbre di lingue viziose | same, "(Scoundrels)" | Cecil Howard / Cecil Howard, Fred J. Lincoln | Original vs Italian |
| tt0145174 | Oh Those Nurses! | Infermiere disposte a tutto | same | C.C. Williams / C.W. Cressler | Possible wrong match |
| tt0159150 | Zum zum zum - La canzone che mi passa per la testa | Zum zum zum | "Zum zum zum (La canzone che mi passa per la testa)" | — / Bruno and Sergio Corbucci | Alternative title (short form) |
| tt0165332 | Je t'offre mon corps | Quelle morbide calde labbra | same | Michel Leblanc / Michel Lemoine | Possible wrong match |
| tt0174076 | Nuits très chaudes aux Caraïbes | Porno erotic movie | "Porno super super super erotic movie" | F. Leroi / — | Unclear |
| tt0178877 | Satisfactions | Femmine sfrenate | same, "(Satisfaction)" | Robert Mc Callum / Gary Graver | Original vs Italian (director name differs; the luci rosse article cites Wikipedia for Graver's pseudonym "Robert McCallum") |
| tt0180111 | Roxie | Mamma ho perso l'uccello | same | Buck Adams / Jack Remy | Possible wrong match |
| tt0186119 | Chu ba | Colpo per colpo | same | Jimmy L. Pascual / — | Unclear |
| tt0189511 | Shauna: Every Man's Fantasy | Gattine in amore | same | Henry Pachard / Roberta Findlay | Possible wrong match |
| tt0189799 | Never Sleep Alone | Provocazione carnale | same, "(Never sleep alone)" | Kemal Horulu / same | Original vs Italian |
| tt0191448 | Showgirls | Perversioni sessuali a Las Vegas | same, "(Showgirls)" | Robert Mc Callum / Gary Graver | Original vs Italian (director as for tt0178877) |
| tt0195025 | The Life and Times of Xaviera Hollander | La professionista del piacere | same | Larry G. Spangler / same | Original vs Italian |
| tt0195293 | Sorority Sweethearts | Avide lingue | same, "(Sorority Sweethearts)" | Paul G. Vatelli / Paul Vatelli | Original vs Italian |
| tt0195342 | Three Ripening Cherries | Hard confidential story | same | Troy Benny / Carlos Tobalina | Possible wrong match |
| tt0196779 | Nackt und keß am Königssee | Corpi viziosi (Nackt und keß am Königssee) | "Corpi viziosi" | Jurgen Enz / Jürgen Enz | Original vs Italian |
| tt0200115 | Der Sexbaron von St. Pauli | Pornoereditiere cercasi (Der Sexbaron von St. Pauli); Pornoereditiere cercasi | "Pornoereditiere cercasi" | Jurgen Enz / Jürgen Enz | Original vs Italian |
| tt0202887 | Il grande momento | Il grande momento …bestiale | "Il grande momento ...bestiale" | Richard Bennet / Antonio D'Agostino | Possible wrong match |
| tt0204265 | Un desiderio bestiale | Un bestiale… triangolo erotico (1991); Un desiderio bestiale (1992) | "Un bestiale.... triangolo erotico" | Richar Bennet / Antonio D'Agostino | Possible wrong match (two different Italian titles share the ID) |
| tt0210354 | I terribili 7 | I temibili 7 | "I terribili 7" | Raffaello Matarazzo / same | Spelling (the CSV word differs from the poster) |
| tt0220139 | Vanessa | Le prestazioni di Vanessa | same | G. De Pasqual / Guy Bodart | Possible wrong match |
| tt0316886 | Sette femmine per un sadico | Flash excitation blue (Sette femmine per un sadico); Flash excitation blue | title not legible | — / Michel Lemoine | Alternative title |
| tt0336163 | Bruce Lee L'indistruttibile | Bruce Lee l'indistruttibile | "Bruce Lee l'indistruttibile", "prodotto da Star Light Co. (Taiwan)" | Puo Chong Jan / Shi-hyeon Kim | Possible wrong match (the title difference itself is case) |
| tt0353260 | Assassinio sulla Costa Azzurra | Assassino sulla Costa Azzurra | hand-written "Assassinio sulla Costa Azzurra" | — / Jacques Guymont | Spelling (one letter) |
| tt0365091 | Les cuisses en chaleur | La moglie in calore | "La moglie in calore" | Patrick Aubin / — | Unclear |
| tt0380594 | La grande ammucchiata | Le ninfomani | "Le ninfomani" | Burd Tranbaree / — | Unclear (the poster page's Italian title is not on the scan) |
| tt0390235 | Marina vedova viziosa | Marina la pornoviziosa | "Marina la pornoviziosa – Chiamate 6969 taxi per signora" | Alan W Cools / Luigi Grosso | Possible wrong match |
| tt0444336 | Penetrações Profundas | Il miele dell'amante regina | same | Juan Bajon / Juan Bajon | Original vs Italian |
| tt0459021 | A Vingança de Uma Mulher | Solange la calda bocca | same | Mario Vaz Filho / Mário Vaz Filho | Original vs Italian |
| tt0778869 | Tentações | Un mondo di tentazioni | same | — / Nilton Nascimento | Unclear |
| tt1180766 | La fureur sexuelle | Topo d'albergo (La fureur sexuelle); Sono una p… topo d'albergo | "Sono una p... topo d'albergo" | Jacques Dumoda / Daniel Daërt | Possible wrong match |
| tt1327719 | Fais-m'en plus | Primizie pornografiche (Fais-m'en plus) | "Primizie ..." (rest torn) | — / Alain Payet | Original vs Italian (CSV pairing only) |
| tt13852490 | Bonanza: Ride the Wind | Più veloce del vento (Bonanza: Ride the Wind) | "Più veloci del vento (Gli uomini di Bonanza)" | William Witney / same | Original vs Italian; the CSV has "veloce", the poster "veloci" |
| tt1404408 | Il segreto della palma d'acciaio | Anche i cinesi mangiano fagioli (Il segreto della palma d'acciaio) | title not legible | Wu Ming Shun / Min-Hsiung Wu | Alternative title |
| tt1839398 | Adolescentes pour satyres | Adolescenti vogliose | "Adolescenti vogliose" | Myke Strong / Pierre B. Reinhard | Possible wrong match |
| tt2173762 | Bruce Lee | Bruce Lee, un cuore d'oro, due mani d'acciaio | "Bruce Lee" with "un cuore d'oro due mani d'acciaio" (fotobusta) | — / Ti Shih | Alternative title (short form) |
| tt5508022 | Hardcore Super Girls | Le ragazze super particolari | same | Wolf Rademaker / Wolf Rademacher and others | Original vs Italian |

### Other things the scans show

- In 56 of the 79 cases the scan prints the programming title (or one of its
  CSV variants, ignoring case and punctuation), not the poster page title. For
  these films the poster page shows a title that is not on the poster held in
  the archive.
- The poster page title is sometimes Italian but absent from the scan:
  "Flavia Schiava di Roma Regina d'amore" (scan: "Flavia... Rome Bestial
  Luxury"), "La grande ammucchiata" (scan: "Le ninfomani"), "Marina vedova
  viziosa" (scan: "Marina la pornoviziosa").
- The luci rosse article cites six of these films by their poster page title:
  *Corruption* (tt0085367) is a possible wrong match (scan: regia Richard
  Mahler; IMDb export: Roger Watkins); *Incontri proibiti* is supported by the
  "Mistique" banner; *Showgirls*, *Satisfactions* and *Peaches and Cream* print
  the original title in brackets; *American Pie* has the IMDb director on the
  scan. In the programming these films appear under their Italian titles.

### What to check on the physical posters and agendas

- The 20 "possible wrong match" films: the director and production company on
  the full poster (and any IMDb entry under the printed director's name).
- tt0078267: whether the scan is the poster of *Sette ragazze di classe* or a
  collage for *Una storia ambigua* filed under the wrong film.
- The 11 "unclear" films: any printed director, producer or year.
- The four illegible scans (tt0077520, tt0316886, tt1327719, tt1404408): the
  printed title.
- The agenda wording for "I temibili 7", "Assassino sulla Costa Azzurra",
  "Viziose asolescenti" and "Più veloce del vento" (agenda slip or typing
  slip).

## 3. Four statements and their sources

### 3.1 The Mongiardo quotation

| Site | Repository source |
| --- | --- |
| Nascita article: "Mongiardo ammoniva Sestito a evitare in futuro pellicole “contrarie alla moralità pubblica”, minacciando di rivolgersi alle autorità in caso contrario" | Transcription (`content/archivio/1957-08-10-lettera-del-sacerdote-gerardo-mongiardo/index.md`): "eviterete per l'avvenire il ripetersi di simili abusi e fare di tutto per evitare proiezioni contro la moralità" |
| — | Scan (`images/19570810letteraSacMongiardo.jpg`, typed letter): "...e fa-/rete di tutto per evitare proiezioni contro la moralità ." The words "contrarie alla moralità pubblica" are not in the letter. |
| "minacciando di rivolgersi alle autorità" | Scan: "Un Vostro ostinato atteggiamento mi spingerebbe (presso lo Ufficio cui la presente è solo inviata per privata conoscenza) a una presa di posizione diversa ..."; the letter is copied "e p.c. Comando Stazione CC". A paraphrase of this, not a quotation. |
| "In numerose occasioni, l'arciprete Gerardo Mongiardo intervenne" | Only this letter is in the repository; it says "ancora una volta" about admitting minors. |

Also seen: the transcription has "garantirmi per iscritto" and "e fare di
tutto"; the scan reads "garantirmi in iscritto" and "e farete di tutto".

To check physically: nothing for the quotation (the scan is legible). Other
letters from the parish, if the family has any, for "in numerose occasioni".

### 3.2 The agenda description

| Site | Repository source |
| --- | --- |
| Fonti index: "le agende delle case di distribuzione"; Agende page: "Le agende cinematografiche erano distribuite dalle case di distribuzione"; 30 agenda pages: "Agende cinematografiche fornite dalle case distributrici"; meta: "agenda di distribuzione" | Covers in `static/images/programmazione_storica/<folder>/..._01.webp`, below. |
| Methodology: the Fedi agendas are "riconducibili all'azienda italiana che produceva proiettori cinematografici" | Fedi 1952-53, p. 3: "Esercenti! per i vostri fabbisogni rivolgetevi all' Agenzia Fedi - Cosenza, Via Milelli ... accessori e qualsiasi pezzo di ricambio per la cinematografia ... Officina attrezzata per la riparazione di qualsiasi tipo di proiettore". The methodology's own images (`materiale_promozionale.png`) show projector models "Fedi XI/T", "Fedi XI/TS", "XII/TS". |

What each scanned cover says:

| Agenda | Printed on the cover | Kind of firm, as printed |
| --- | --- | --- |
| Fincine 1948-49 | "“Fincine” Agenda 1948-49 ... Direzione generale: Roma – Via Romagna, 3" | not stated |
| Incam 1948-49, 1949-50 | "INCOM Agenda cinematografica, Stagione 1948-49 / 1949-50"; inside: "INCOM Industria Corti Metraggi s.p.a. ... “La Settimana Incom” cine-giornale", list of "Concessionari INCOM" (Milan: "Distribuzione e noleggio") | newsreel producer with distributors |
| Elettrocarbonium 1949-50 | "Calendario per programmazioni films 1949-1950 ... Elettrocarbonium ... Carboni per lampade ad arco" | arc-lamp carbon maker |
| Bruzia 1951-52 | "Omaggio della “Bruzia” Noleggio Films, Cosenza ... Rappresentante per la Calabria: Lux, Indipendenti, Manenti, Meridional, Roma, Vigor Films ... Fornitura di carboni per cinema" | film rental (distribution) agent |
| Fedi 1952-53 | "Agenzia Fedi - Cosenza" (accessories, spare parts, repairs) | equipment agency |
| Rapidtransport 1964 | "Rapidtrasport di Domenico Posca ... Servizio celere bisettimanale da e per Napoli ... traslochi" | transport firm |
| Morganite 1968-69 | "Agendina di programmazione ... offerta dalla Società Morganite Exports Limited Londra ... Carboni Morganite ... agente esclusivo per l'Italia Mole-Richardson (Italia)" | carbon maker |
| Lorraine 1969-70 | "Carboni Lorraine ... Société Le Carbone-Lorraine, Paris" | carbon maker |
| Elettrocarbonium 1976-77 | "Programmazione films 1976-1977 ... elettrocarbonium S.p.A. Milano" | (carbon maker, per the 1949 cover) |
| Prevost 1977-78 | "Agenda di programmazione anno 1978 ... Prevost Milano" | not stated (the site's image file `avvolgitore_prevost.jpg` names a Prevost rewinder) |
| Ceat 1966, Naonis 1966, Agenda 1968 | not scanned | — |

Of the scanned agendas, only Bruzia describes itself as a film rental agency,
and Incom lists film distributors; the others are equipment, carbon or
transport firms. Image folder names already say so ("carboni_morganite",
"carboni_lorraine").

To check physically: the covers and first pages of Ceat 1966, Naonis 1966,
Agenda 1968 and Fincine 1948-49 (who issued them); whether "Agenzia Fedi –
Cosenza" is the projector maker or a local dealer of Fedi products.

### 3.3 Incam or Incom

| Site | Repository source |
| --- | --- |
| Source titles "Incam 1948-49", "Incam 1949-50" (pages, tables on about 90 pages, home billboard); CSV source strings "Incam 1948-49" (75 entries), "Incam 1949-50" (87) | Covers of both agendas: "INCOM ... Agenda cinematografica". Inside 1948-49: "INCOM Industria Corti Metraggi s.p.a., Roma, Via Bellini 27 ... “La Settimana Incom”". |
| Nascita article: "La Settimana Incom"; gallery folder and files `2023_04_27_la_settimana_incam` / `la_settimana_incam_0N` (file names only, not shown) | Same four images (they are pages of the 1948-49 agenda). The gallery alt texts already say "Incom". |

The scans read "Incom" everywhere; "Incam" occurs only in names given in the
repository (CSV, page titles, folders).

To check physically: nothing (the covers are legible).

### 3.4 MGM in the trailer-reels page

| Site | Repository source |
| --- | --- |
| Bobine page: "I distributori, spesso corrispondenti delle grandi major americane o di società italiane come la **Metro-Goldwyn-Mayer**, la **Titanus** o la **Cineriz**, inviavano ai gestori di sala le copie promozionali tramite posta o corriere." | MGM envelope scan (`content/archivio/1957-11-09-busta-della-metro-goldwyn-mayer/images/`): printed sender "Metro-Goldwyn-Mayer Films S.A.I.", addressed "Spett. Direzione Cinema Sestito, S. Vito Jonio, Catanzaro", postmark "Catania 9-IX-1957". The repository does not say what "S.A.I." stands for. |
| "Queste venivano poi restituite o riutilizzate ... conservate a discrezione dell'esercente. Il Cinema Sestito ne ha mantenuto un numero significativo" | Family answer 20 (`story-research.md`): the names on the trailer boxes are other cinemas of the area; the material was only rented and passed from cinema to cinema by courier. Reel photos show hand-written "Soverato" and "Diamante – Vittoria". |
| "Durante la seconda metà del Novecento" | Reel photos (35 in the gallery): labels of 1990s–2000s titles (*Fight Club*, *Notting Hill*, *Charlie's Angels*, *Scary Movie* ...) **[U30]** |
| Titanus, Cineriz | Titanus appears in the agendas (methodology) and on two poster scans (*I dolci inganni*, *Zum zum zum*). On the 35 reel photos, at the size checked, the legible labels name laboratories (Technicolor, Telecolor, Cinecittà, "Sviluppo e stampa" Roma) and once "UIP"; no label reading MGM, Titanus or Cineriz was legible. |

To check physically: the reel boxes, at full size, for the distributor named
on each label; what "Films S.A.I." stands for (MGM's Italian company or not),
which decides whether "società italiane come la Metro-Goldwyn-Mayer" is
defensible.

## 4. Summary of physical checks

| # | Check | Section |
| --- | --- | --- |
| 1 | Director and producer on the full posters of the 20 possible wrong matches and the 11 unclear films | 2 |
| 2 | Poster filed under *Sette ragazze di classe* (tt0078267) | 2 |
| 3 | Titles on four illegible poster scans | 2 |
| 4 | Agenda wording of four suspect titles | 2 |
| 5 | Covers of Ceat 1966, Naonis 1966, Agenda 1968; issuer of Fincine 1948-49 | 3.2 |
| 6 | Agenzia Fedi – Cosenza: maker or dealer | 3.2 |
| 7 | Further parish letters, if any | 3.1 |
| 8 | Distributor names on the trailer reel labels; meaning of "Films S.A.I." on the MGM envelope | 3.4 |
