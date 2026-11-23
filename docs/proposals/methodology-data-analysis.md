# METHODOLOGY ARTICLE: DATA ANALYSIS AND POSSIBLE IMPROVEMENTS
Working notes, 2026-11-17. Proposals and questions, not implementation decisions.
Current priorities are in docs/project-status.md.

## Scope
This note examines content/articoli/2026-11-11-metodologia-ricostruzione-programmazione/index.md
and all three CSV files in static/data. It proposes ways to make the article's
account of the resulting database more tangible. No changes to the article,
data, charts or R scripts are proposed as already implemented.

The figures below are a read-only snapshot of the current CSVs, calculated with
base R. They can change as the archive is corrected or expanded. Blank cells
were treated as missing; comma-separated values were split and trimmed for the
association counts. Counts describe the files, not the complete historical
activity of the cinema.

## 1. What the article already explains
The article describes the discovery and condition of the documents, the
different handwriting, scanning and working copies, transcription, comparison
of sources, IMDb identification and enrichment with IMDb and OMDb metadata.
It explains that some titles were excluded when identification was uncertain,
that dates can be reconstructed rather than directly transcribed, and that
1960-1961 has missing documentation.

Importantly, it already distinguishes dated database entries from actual
screenings, and explains that a multi-source entry and a coproduction can count
in multiple categories. The technical section could make these principles
concrete with the structure, measured coverage and examples of the resulting
data, without repeating the entire narrative or presenting it as complete.

The files do not themselves record a flag for directly attested versus
reconstructed dates, excluded titles, or the number of illegible/missing
documents. Their proportions cannot be calculated from these CSVs alone.

## 2. What is in the current data
* programmazione_agende.csv: 5,290 dated title entries, from 1948-01-06 to
  2004-05-02, covering all 57 calendar years in that range. There are 4,567
  distinct const values and 5,183 distinct dates. No date/const pair is
  duplicated; 107 dates have more than one entry. A date with multiple entries
  is not proof of a particular number of screenings.
* Each entry contains date, const, title, income, source and rating. All entries
  have date, const, title and source; income is blank on 638 entries, and
  rating is blank on 5,260. The latter is not the IMDb score: the nonblank
  values in this file are Approved (28) and 16+ (2). Confirm their meaning
  before using them.
* programmazione_imdb.csv: 4,567 rows, one per distinct Const. It supplies,
  among other fields, title, original title, URL, release year, genres, IMDb
  score and number of votes. All 4,567 entry IDs match an IMDb row. Blank
  genres affect 96 film records / 104 dated entries; blank IMDb scores affect
  278 films / 317 entries. IMDb Year is populated for every matched film.
* programmazione_paesi.csv: 4,568 rows, one per const. All entry IDs match a
  country row, and their country fields are nonblank. Other fields include
  rated, awards and is_adult, whose meaning and missingness require care.
* Source cells yield 93 distinct trimmed labels and 10,288 entry-source
  associations; 4,010 entries list more than one source. These are label
  counts, not necessarily independently verified counts of physical documents.
  At entry level, splitting country cells yields 7,126 entry-country
  associations, and splitting genres yields 11,877 entry-genre associations
  before any genre exclusion. Category totals are not exclusive.
* 1960 has 26 entries, all in October-December; 1961 has 18, all in
  November-December. This supports showing a clear documentation gap, not
  concluding that the cinema was closed during the other months. A year
  having entries does not establish that its documentation is complete.
* Comparing entry year with IMDb Year yields 17 entries involving 14 distinct
  film IDs where the entry predates that metadata year. For example,
  tt0041119 is dated 1949-10-21 in the entries and has IMDb Year 1950. These
  are review flags, not proven mistakes: release dates, identification,
  source transcription and metadata conventions must be checked individually.
* Income is populated in 4,652 entries, including 27 zero values; all nonblank
  values are digit strings. The author says a blank means the information was
  unavailable, while zero means there was no income for that movie. Presence
  is not verification of the amount, currency, unit or comparability through
  time. Do not equate missing with zero or add an income trend until the
  remaining meanings and historical context are agreed.

Method of counting: film counts use distinct const/Const, entry counts use CSV
rows, and metadata completeness at entry level follows the ID join. Source,
genre and country associations are obtained by splitting each entry's
comma-separated cell or joined metadata field. Comparisons with IMDb Year use
calendar years, not the exact release date. No sources outside the repository
were consulted to validate individual films or archival evidence.

## 3. Suggested article additions, in priority order
### A. Database structure and a compact summary
   Place after "Dalle fonti al database" or at the start of "Metadati, tabelle
   e grafici". Describe one dated entry, its possible multiple documentary
   sources, the shared film identifier and the separate IMDb and OMDb
   enrichment. A small diagram or table can show:

```text
archival documents -> dated entries (date, title, ID, sources)
                   -> ID links to IMDb metadata and OMDb country metadata
```

   Show the snapshot's entry count, distinct film-ID count and date range, with
   a date and a sentence that the figures describe identified, recorded
   material only. Source labels represent links in the data, not necessarily a
   separate table of documents. Do not suggest IMDb/OMDb are archival proof.

### B. Coverage and gaps by year or month
   A year-by-month heatmap of entry counts would make uneven coverage visible.
   Label the measure "voci datate nel database", show zero-entry months as
   "nessuna voce registrata" rather than "chiuso", and annotate 1960-1961.
   Counts per year or per month are evidence of recorded entries, not a
   measure of archive completeness or actual projections. If useful, add a
   simple annual series with the same caveat; do not assume the beginning and
   end years cover entire years.

   The site already has annual and monthly charts. In particular,
   R/update-indici.R excludes 1960 and 1961 from its annual index chart. A
   methodology graphic showing those years must be explicitly new or adapted,
   not described as an unchanged reuse. Decide whether to link to existing
   charts instead of duplicating them.

### C. How much source corroboration is recorded
   A small bar chart of entries with 1, 2, 3 or more listed source labels, or a
   table of entry-source associations by source type and decade, could
   illustrate cross-checking. State the denominator and count an entry once in
   each category it belongs to. Multiple sources are not automatically
   independent confirmations, and a single source is not proof of an error.
   The existing source chart already groups labels by naming rules; check
   whether that classification is suitable before reusing its output.

### D. Metadata completeness and join transparency
   A compact table can contrast total entries with entries having IMDb genres,
   scores, country and income, showing both numerator and denominator. Explain
   the entry-level join and optionally provide film-level completeness
   separately: the two denominators answer different questions. Mark missing
   metadata as unknown, not as a negative classification. Mention the
   unmatched country ID in technical notes rather than silently dropping it.
   Scores are IMDb users' ratings, not historical ratings by the local audience.

### E. One traceable example
   With the author's choice of a suitable source, illustrate a manuscript
   annotation -> interpreted title/date -> database row -> linked film
   metadata. Identify exactly which parts are transcribed, reconstructed or
   enriched, and link to the relevant source scan and film. Do not invent an
   example or assert that a date was reconstructed unless the evidence and
   editorial decision are known.

### Lower priority / needs a decision
* Release-to-programming delay: IMDb Year versus entry year can give a coarse
  year difference, not a precise elapsed time or necessarily the Italian
  release date. Review the 17 negative cases first, report exclusions and
  missing values, and avoid treating those flags as verified errors.
* Genre and country breakdowns already exist elsewhere on the site. They can
  explain enrichment but are less direct evidence of reconstruction quality.
  Genres and countries may be multiple; decide whether the denominator is
  entries, distinct films or associations. Percentages based on associations
  do not mean percentages of unique films or production shares.
* Before reusing the existing genre index, review its conventions documented in
  docs/guides/historical-programming.md: its Drammatico exclusion also affects
  repeated Drammatico-only films, and the adult-share calculation treats
  missing genres as not adult. A new methodology graphic should define its
  own intended missing-data and multi-genre handling rather than inherit these
  conventions unnoticed.
* Income analysis is potentially interesting but still needs clarification of
  monetary units, any currency transition, and whether values refer to a day,
  film or other period. Inflation,
  attendance and missing data limit comparisons; no conclusion about audience
  size or taste follows directly from raw income.

## 4. Possible future R workflow (not implemented)
Read the three local CSVs, validate required columns, dates, IDs and unique
metadata keys, then report unmatched IDs and missing values explicitly. Keep
the entry-level table intact when joining film metadata; expand multi-valued
fields only for analyses that need associations. Produce a small set of
reproducible tables and PNG charts, with clear units, denominators, missing-data
handling and an analysis date or input version. Reuse existing project R
helpers or conventions where appropriate, after checking their semantics.

If approved later, write chart files under an appropriate article asset
location and insert stable links and generated statistics into a clearly
delimited portion of the article Markdown, leaving the author's prose and
front matter intact. Decide the exact Hugo-compatible paths and output
ownership before implementation. R generation would run locally before the
site build; the documented Netlify deployment runs Hugo, not R, so generated
assets and Markdown would need to be persisted with the site. Do not overwrite
or silently resolve data discrepancies.

## 5. Questions for the author
1. Is the article primarily for general readers, researchers, or both? How
   much technical explanation should remain in the article versus a linked
   technical note?
2. Which two or three additions are most useful: database structure and
   summary, monthly coverage, source corroboration, metadata completeness, or
   an example traced to a scan? Should existing charts be linked or repeated?
3. Should 1960-1961 appear in a new coverage chart with explicit caveats,
   despite their exclusion from the current annual index chart?
4. Can you identify a specific entry and source scan that illustrate the
   identification process, ideally also a date adjustment? Are there records
   outside these CSVs documenting uncertain or excluded entries?
5. What do income values, blank income and zero mean, including their currency
   and period? What is the intended meaning of the agende rating field?
   Should these fields be discussed at all?
6. How should the 17 entry-year/IMDb-year flags and the extra country ID be
   reviewed? Are there source notes or poster records that can clarify them?
7. If a later R workflow is approved, should it generate only charts and a
   separate results file for editorial insertion, or update a marked section of
   the article automatically? How often should the figures be refreshed?

## 6. Author's initial answers
* The intended audience is both general readers and researchers. All proposed
  additions seem important; database structure may be a useful starting point.
* Include 1960-1961 in a new coverage chart with a clear warning.
* No particular example is remembered yet. The author recalls that adult films
  were particularly difficult to trace: they were often low-budget productions
  and information may no longer be available online. This is a useful possible
  illustration of identification limits, but a specific documented example
  still needs to be selected and checked.
* A blank income means the information was unavailable; zero means no income
  for that movie. Currency, recording period and the meaning of the separate
  rating field still need clarification.
* For a future R workflow, the author prefers charts and a separate results
  file for editorial insertion, not automatic modification of the article.

These answers guide a future proposal; they do not authorize implementing the
script or changing the article now. The other questions above remain open.

## 7. Proposed summary for the historical programming landing page
The author suggests putting a concise explanation of the database directly in
content/programmazione-storica/_index.md, rather than only in the methodology
article. The figures below are a snapshot and need refreshing when the data
change. Proposed Italian text, not yet published:

«Al 17 novembre 2026 la ricostruzione comprende 5.290 voci datate, relative a
4.567 film distinti, dal 6 gennaio 1948 al 2 maggio 2004. È presente almeno una
voce per ciascuno dei 57 anni del periodo, distribuita su 5.183 date.

Ogni voce associa un film a una data: non equivale necessariamente a una singola
proiezione. Un film poteva essere annotato una sola volta anche se proiettato
più volte; poteva inoltre essere proiettato in altre giornate non registrate.
Le date rappresentano quindi le giornate presenti nella ricostruzione, non
necessariamente tutte quelle in cui il cinema fu attivo. In 107 date sono
registrati più film, ma il numero effettivo delle proiezioni non è noto.

La documentazione è incompleta e alcune date sono state ricostruite confrontando
le fonti: i dati non rappresentano necessariamente tutti i film o tutte le
giornate di attività del cinema.»

The author's explanation is that a title might have been written once even
when shown multiple times or on other days. This supports describing the
figures as documented entries rather than screening totals. The CSVs do not
show how many screenings or active days are missing, so "only a small number"
cannot be established from them. The 107 dates have different film IDs; the
article notes that sources can disagree and that some dates were adjusted, so
the summary should not claim each film was definitely shown on that exact day.
The absence of duplicate date/ID pairs is a useful technical check but is not
necessary for a short public introduction.
