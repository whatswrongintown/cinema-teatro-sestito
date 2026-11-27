# To check before publishing (2026-11-27)

Every item that `decisioni-testi.md` marks *Check before publishing* or *To
check*, with what to look at. Section 1 lists the points where a decision and
the evidence (or the data, or a project rule) disagreed, and the owner's
answers (2026-11-27), now also in `decisioni-testi.md`. Evidence: `italian-text-evidence.md`. Status words per item: TODO /
DONE, with dates. A batch that depends on an item waits for it (see U33 in
`project-status.md`).

## 1. Contradictions (settled 2026-11-27)

| # | Decision | What disagrees | Look at | Status |
| --- | --- | --- | --- | --- |
| A1 | Fixed explanation: *un film in sala per più giorni nello stesso mese è registrato una sola volta* | The CSV has 20 cases of the same film twice in one month (20 extra records), for example tt0025493 in January 1950 and tt0031972 in March 1952; 188 dates carry two or more films | `static/data/programmazione_agende.csv`, and the agendas of those months, to see whether the sentence needs *di norma* or is wrong | DONE 2026-11-27 |
| A2 | *Gli anni d'oro*: 1966 as the high point; heading *Declino e trasformazione (dal 1977)* | Records: 1966 215, 1967 217 (distinct films: 214 in both). 1977 has 174 records, more than 1976 (156); the fall is 1978 (142) and 1979 (99). See the table in B9 | `static/data/programmazione_agende.csv`; whether *dal 1977* refers to the counts or to the first adult films (26 July 1977) | DONE 2026-11-27 |
| A3 | INCOM in the CSV (#6), *Calendario 1985 (2)* in the CSV (C5), keyboard slips corrected in the data (F6) | The same file says *The data stays unchanged* (titles); `CLAUDE.md` and `project-status.md` declare the datasets final since 2026-11-23 | An explicit owner exception to the data freeze, recorded in `project-status.md`, or display rules in the templates instead | DONE 2026-11-27 |
| A4 | Trailer reels (#2): the page keeps naming MGM, Titanus and Cineriz as the distributors who sent reels | No label reading MGM, Titanus or Cineriz was legible on the 35 reel photos (laboratories and once *UIP* were). Family answer 20 (`story-research.md`): the material was rented and passed from cinema to cinema, while the page says the cinema kept many reels. Answer 16 names Titanus and MGM among the agencies whose representatives visited, which supports them as distributors but not as senders of these reels | The reels and their boxes at full size; the bobine page `content/archivio/2025-10-27-bobine-dei-trailer-35mm/index.md` | DONE 2026-11-27 |
| A5 | Model passage 4 and the *Quanto incassavano* figures, counted per record | The same article says *Orgia libera* made *243.000 lire in una sola serata* (7 January 1990); a passaggio may stand for several days | The sources of that record: Rubrica 1984-92, Italautogamma 1989-90, Calendario 1990, Note sui manifesti | DONE 2026-11-27 |
| A6 | Agenda type page (#5) names three kinds of firm | Prevost 1977-78 (a rewinder maker, per the image file name) and Fincine 1948-49 (issuer not printed) fit none of them as far as the scans show; only Bruzia calls itself a rental agency (*Noleggio Films*). Rapidtransport's cover says transport and removals; family answer 16 says it carried the films | Covers of the Prevost and Fincine agendas | DONE 2026-11-27 |
| A7 | MGM envelope page | The page and its description say *9 novembre 1957*; the postmark was read as *Catania 9-IX-1957* (9 September) on a reduced scan | The envelope, `content/archivio/1957-11-09-busta-della-metro-goldwyn-mayer/` | DONE 2026-11-27 |

Answers (owner, 2026-11-27):

- **A1:** add *di norma*: *… un film in sala per più giorni nello stesso mese
  è di norma registrato una sola volta.*
- **A2:** *il massimo fu raggiunto tra il 1966 e il 1968*; *dal 1978 i
  film in cartellone calano* (142 in 1978, 99 in 1979); heading *Trasformazione e
  declino (dal 1977)*, because 1977 is when the adult films begin.
- **A3:** exception to the data freeze for three things only: *Incam* →
  *INCOM* in source names; *Calendario 1985 (2)*; obvious keyboard slips once
  checked against the agendas (C3.3, C3.4). Recorded in `project-status.md`.
- **A4:** the bobine page drops the sentence naming MGM, Titanus and Cineriz
  as senders of the reels; a distributor is named only where a label shows
  one. New wording: *I trailer arrivavano a noleggio insieme ai film e
  passavano da un cinema all'altro tramite corriere. Le bobine conservate al
  Cinema Sestito, trovate accanto al proiettore, sono probabilmente quelle che
  non fu necessario restituire. Risalgono per lo più al periodo 1993–2003.*
  Decision 2's MGM wording now applies only to the envelope page.
- **A5:** keep *in una sola serata* only if a source says so, otherwise *in un
  solo passaggio* (since 2026-11-27: *in una sola data di programmazione*). Sources checked 2026-11-27, none says so: Rubrica 1984-92
  (page O) has *Orgia libera 7/1/90*, a date only; Italautogamma 1989-90
  (*Gennaio 90*) lists it fourth of the month's eight films with *243*, no
  day; Calendario 1990 is not scanned; the poster (Note sui manifesti) shows
  no date on the front, and its back is not in the repository. So: *in una sola data di programmazione* (term changed 2026-11-27).
- **A6:** agenda type page: *Le agende cinematografiche provenivano da diverse
  ditte del settore: case di distribuzione, fornitori di apparecchiature e di
  carboni per le lampade ad arco, ditte che trasportavano le pellicole.*
  Fincine 1948-49 gets no type until the owner has seen its cover (B5).
- **A7:** the envelope is dated 9 September 1957. Correct the date shown and
  keep the old URL working.
- **Nascita, the letter's threat:** replace *minacciando di rivolgersi alle
  autorità* with *lasciando intendere un intervento più deciso; la lettera fu
  inviata per conoscenza anche alla stazione dei carabinieri.*
- Vito Sestito's dates, 1902–1985, are confirmed.

## 2. Facts and sources (*Check before publishing*)

| # | Item | Look at | Status |
| --- | --- | --- | --- |
| B1 | Other letters from the parish (for *non per la prima volta*) | Family papers; Drive `Scansione documenti` | TODO |
| B2 | What *Films S.A.I.* means on the 1957 envelope (*la filiale italiana della Metro-Goldwyn-Mayer* or *la statunitense Metro-Goldwyn-Mayer*); distributor names on the reel labels | The envelope (`content/archivio/1957-11-09-busta-della-metro-goldwyn-mayer/images/`); the reels | TODO |
| B3 | Every archive document has a date, a category and a digital reproduction | Repository check 2026-11-27: all 26 pages in `content/archivio/` have a date, a category and at least one image. Remains: whether every page shows the whole document | TODO |
| B4 | Italia Taglia data for a later classification chart | Permission from the Cineteca di Bologna, if needed | TODO |
| B5 | Who issued the agendas not scanned or unclear: Ceat 1966, Naonis 1966, Agenda 1968, Fincine 1948-49 | Covers and first pages of the physical agendas | TODO |
| B6 | Agenzia Fedi – Cosenza: projector maker or dealer | Fedi 1952-53, p. 3 (`static/images/programmazione_storica/` folder of that agenda); other Fedi agendas | TODO |
| B7 | Whether the membership card shows AGIS as well as ANEC | `content/archivio/1950-01-01-associazione-nazionale-esercenti-cinema/`, and the card | TODO |
| B8 | The 1947 and 1949 dates for the project page: nulla osta 19/5/1947 and Commissione's verbale 8/12/1947 (both cited only inside the 1949 decree), licence 19 March 1949 | The 1949 decree scan, `content/archivio/1949-03-19-abilitazione-cinema-in-piazza-mario-poler/`; the 1947 documents, if the family has them | TODO |
| B9 | Yearly counts 1957–1979 for *Gli anni d'oro* (counts settled by A2); the 1966 contract dates (Argos 16 February, Titanus 22 January, Paramount 26 March, Fox 18 May, W.B. 8 September) come from Stefano's diary, not scanned (family answer 18) | Table below; the diary | TODO |

Records and distinct films per year, from the CSV (2026-11-27):

| Year | 1957 | 1958 | 1959 | 1960 | 1961 | 1962 | 1963 | 1964 | 1965 | 1966 | 1967 | 1968 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Records | 129 | 121 | 134 | 26 | 18 | 110 | 110 | 105 | 154 | 215 | 217 | 203 |
| Films | 127 | 121 | 130 | 26 | 18 | 110 | 107 | 104 | 154 | 214 | 214 | 203 |

| Year | 1969 | 1970 | 1971 | 1972 | 1973 | 1974 | 1975 | 1976 | 1977 | 1978 | 1979 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Records | 189 | 150 | 185 | 167 | 157 | 134 | 155 | 156 | 174 | 142 | 99 |
| Films | 189 | 149 | 183 | 165 | 155 | 133 | 155 | 156 | 173 | 141 | 97 |

1960 and 1961 are incomplete (pages missing from the sources).

## 3. Film titles (settled 2026-11-27)

Owner's answer (2026-11-27): every film is shown under its programming title;
a film that never appears in the programming keeps the title printed on its
poster. This settles C1, C2 and C3; the CSV titles stay exactly as written (the
owner checked the agendas for C3.3 and C3.4, so no typing slip is corrected).

Look at the full poster (director, producer, production company, year) and, if
needed, IMDb under the printed director's name. Scans: the film page on the
site, `/posters/films/<IMDb ID>/`.

### C1. Possible wrong IMDb matches (20)

Start with *Corruption*, cited in *Le luci rosse*. Done: the article now names it
*Di dietro tutta, femmine corrotte dal piacere*.

| IMDb ID | Poster page title | Programming title | Director: poster / IMDb export | Status |
| --- | --- | --- | --- | --- |
| tt0085367 | Corruption | Di dietro tutta, femmine corrotte dal piacere | Richard Mahler / Roger Watkins | DONE 2026-11-27 (programming title) |
| tt0076235 | Jouir jusqu'au délire | Corpi d'amore porno | Thum Gerard / Gérard Vernier | DONE 2026-11-27 (programming title) |
| tt0078267 | Sette ragazze di classe | 7 ragazze di classe | Mario Bianchi / Pedro Lazaga (see C3) | DONE 2026-11-27 (programming title) |
| tt0081593 | Taboo | Lunghi e duri per i… turbamenti erotici di Pamela | Robert Mc Callun / Kirdy Stevens | DONE 2026-11-27 (programming title) |
| tt0124491 | Eruption | Sensual eruption (Eruption) | Stanley Kurlin / Sam Norvell | DONE 2026-11-27 (programming title) |
| tt0125296 | Justine, una minorenne deliziosa... | Justine, una minorenne deliziosa... | Robert R. Walters / Roberta Findlay, Cecil Howard, Walter E. Sear | DONE 2026-11-27 (programming title) |
| tt0127801 | A Scent of Heather | La moglie ingorda | Philip Drexler Jr. / Bill Milling | DONE 2026-11-27 (programming title) |
| tt0127824 | The Seduction of Lyn Carter | La seduzione di Lynne | Wess Brown / Anthony Spinelli | DONE 2026-11-27 (programming title) |
| tt0145174 | Oh Those Nurses! | Infermiere disposte a tutto | C.C. Williams / C.W. Cressler | DONE 2026-11-27 (programming title) |
| tt0165332 | Je t'offre mon corps | Quelle morbide calde labbra | Michel Leblanc / Michel Lemoine | DONE 2026-11-27 (programming title) |
| tt0180111 | Roxie | Mamma ho perso l'uccello | Buck Adams / Jack Remy | DONE 2026-11-27 (programming title) |
| tt0189511 | Shauna: Every Man's Fantasy | Gattine in amore | Henry Pachard / Roberta Findlay | DONE 2026-11-27 (programming title) |
| tt0195342 | Three Ripening Cherries | Hard confidential story | Troy Benny / Carlos Tobalina | DONE 2026-11-27 (programming title) |
| tt0202887 | Il grande momento | Il grande momento …bestiale | Richard Bennet / Antonio D'Agostino | DONE 2026-11-27 (programming title) |
| tt0204265 | Un desiderio bestiale | Un bestiale… triangolo erotico; Un desiderio bestiale | Richar Bennet / Antonio D'Agostino (two titles, one ID) | DONE 2026-11-27 (programming title) |
| tt0220139 | Vanessa | Le prestazioni di Vanessa | G. De Pasqual / Guy Bodart | DONE 2026-11-27 (programming title) |
| tt0336163 | Bruce Lee L'indistruttibile | Bruce Lee l'indistruttibile | Puo Chong Jan / Shi-hyeon Kim | DONE 2026-11-27 (programming title) |
| tt0390235 | Marina vedova viziosa | Marina la pornoviziosa | Alan W Cools / Luigi Grosso | DONE 2026-11-27 (programming title) |
| tt1180766 | La fureur sexuelle | Topo d'albergo; Sono una p… topo d'albergo | Jacques Dumoda / Daniel Daërt | DONE 2026-11-27 (programming title) |
| tt1839398 | Adolescentes pour satyres | Adolescenti vogliose | Myke Strong / Pierre B. Reinhard | DONE 2026-11-27 (programming title) |

### C2. Unclear films (11)

Any printed director, producer or year.

| IMDb ID | Poster page title | Programming title | Status |
| --- | --- | --- | --- |
| tt0068507 | Christine | Porno story di Christine | DONE 2026-11-27 (programming title) |
| tt0076020 | Fella | Pornoexhibition | DONE 2026-11-27 (programming title) |
| tt0080720 | Fascination | American porno story | DONE 2026-11-27 (programming title) |
| tt0080927 | Insatiable | Marilyn l'insaziabile | DONE 2026-11-27 (programming title) |
| tt0091058 | Flavia Schiava di Roma Regina d'amore | Flavia… Rome Bestial Luxury | DONE 2026-11-27 (programming title) |
| tt0126288 | Erotic Flash | Corpi bollenti d'amore | DONE 2026-11-27 (programming title) |
| tt0174076 | Nuits très chaudes aux Caraïbes | Porno erotic movie | DONE 2026-11-27 (programming title) |
| tt0186119 | Chu ba | Colpo per colpo | DONE 2026-11-27 (programming title) |
| tt0365091 | Les cuisses en chaleur | La moglie in calore | DONE 2026-11-27 (programming title) |
| tt0380594 | La grande ammucchiata | Le ninfomani | DONE 2026-11-27 (programming title) |
| tt0778869 | Tentações | Un mondo di tentazioni | DONE 2026-11-27 (programming title) |

### C3. Other title checks

| # | Item | Look at | Status |
| --- | --- | --- | --- |
| C3.1 | tt0078267: is the scan the poster of *Sette ragazze di classe*, or a collage for *Una storia ambigua* filed under the wrong film? | The physical poster | DONE 2026-11-27 (owner: names as in the programming) |
| C3.2 | Printed title on four illegible scans: tt0077520 (*Le evase*), tt0316886 (*Flash excitation blue*), tt1327719 (*Primizie pornografiche*), tt1404408 (*Anche i cinesi mangiano fagioli*) | The physical posters | DONE 2026-11-27 (owner: names as in the programming) |
| C3.3 | Agenda wording, to tell an agenda spelling from a typing slip: *I temibili 7* (poster: *I terribili 7*), *Assassino sulla Costa Azzurra* (*Assassinio*), *Viziose asolescenti* (*adolescenti*), *Più veloce del vento* (*Più veloci*) | The agenda named in each record's `source` cell (programming pages of those dates) | DONE 2026-11-27 (owner: names as in the programming) |
| C3.4 | *Le pioggie di Ranchipur*: what the agenda wrote (F6) | The agenda named in the record's `source` cell | DONE 2026-11-27 (owner: names as in the programming) |
| C3.5 | Sentence case for Italian titles (F3): the list of changed titles, prepared before the titles batch, for the owner to check | `titoli-maiuscole.md` (written 2026-11-27: 51 titles; checked by the owner the same day; 8 changes applied as display rules) | DONE 2026-11-27 |

## 4. Wording and settings

| # | Item | Look at | Status |
| --- | --- | --- | --- |
| D1 | The wording IMDb requires for its credit line, before changing *Information courtesy of IMDb* (V8) | IMDb's conditions of use for non-commercial sites | TODO |
| D2 | Hugo's option for first-letter-only title case of term names (C2), against Hugo 0.170.1 | Checked 2026-11-27: local `hugo version` and Netlify (`netlify.toml`, `HUGO_VERSION = '0.170.1'`) both run 0.170.1. `hugo config` lists `titlecasestyle = 'AP'` (the default) and `capitalizelisttitles = true`. Test builds outside the repository: `titleCaseStyle: firstupper` gives *Paesi di produzione*, *San Vito sullo Ionio*, *Storia locale* (first letter up, the rest as written); `capitalizeListTitles: false` leaves lower-case terms lower-case. Applied with the owner's OK: `titleCaseStyle: firstupper` in `config.yaml` | DONE 2026-11-27 |
