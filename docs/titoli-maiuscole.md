# Sentence case for film titles: proposed changes (2026-11-27)

Decision F3 (`decisioni-testi.md`): Italian titles are displayed in sentence
case, proper names kept; foreign titles unchanged; the data stays as recorded.
The owner checked this list on 2026-11-27; its 8 changes are applied as
display rules in `layouts/partials/posters/titoli.html`. `films.json` and the
CSV do not change.

What it covers: the display title of every poster film (the title the film was
shown under in San Vito, batch 4), as built on the film pages. The
programming tables keep each source's own wording (F2) and are not in the list.

How the proposal was made (a script, so every row needs a human look):

- A capital inside a title is proposed in lower case only when the same word
  appears in lower case in another title (the 5,479 programming titles, the
  poster titles and the IMDb titles), so it is a common word.
- Kept: the first word, the first word after " - ", ":", "(", "!", "?" or "…"
  (a subtitle or a new sentence), *Dio*, words never seen in lower case
  (column "Kept (probable names)"), and capitalised words next to another
  capital (column "Kept as part of a name (check)": *Rio Grande*, *Kung Fu*,
  *Sole Rovente*).
- Skipped: foreign films whose display title is their original title, and
  English segments (*Blue Erotic Movie*, *Sweet savage*).

Rows where "Proposed" equals "Current" change nothing: they are listed so the
kept capitals can be checked too (for example *Sotto il Sole Rovente* and
*Momenti Porno Vogliosi*, which may need lower case after all, or *Kung Fu*).
Doubtful proposals: *Le occasioni di rosa* (Rosa is probably a name), *West* in
*pazzo West* and *brutos del West* (the Far West is usually capitalised),
*apaches*, *drago* in *La rivolta del Drago* (a title or a nickname?).

Proposed changes after the owner's check: 8 of 51 rows (the other rows only list kept capitals). The owner kept the capital in *Winchester* (three titles), *Rosa* and *Gringo* (2026-11-27).

| IMDb ID | Current | Proposed | Kept (probable names) | Kept as part of a name (check) |
| --- | --- | --- | --- | --- |
| tt0060926 | 009 Joe Tempesta | 009 Joe Tempesta | Joe | Tempesta |
| tt0057891 | 1000 dollari per un Winchester | 1000 dollari per un Winchester |  |  |
| tt0058861 | 3 colpi di Winchester per Ringo | 3 colpi di Winchester per Ringo | Ringo |  |
| tt0058862 | 30 Winchester per El Diablo | 30 Winchester per El Diablo | Diablo | El |
| tt0060923 | 7 pistole per El Gringo | 7 pistole per El Gringo |  | El, Gringo |
| tt0268576 | A 117 colpo grosso a Los Angeles | A 117 colpo grosso a Los Angeles | Angeles | Los |
| tt0353260 | Assassino sulla Costa Azzurra | Assassino sulla Costa Azzurra |  | Costa, Azzurra |
| tt0285452 | Bestia del Sud - voglia di godere | Bestia del sud - voglia di godere |  |  |
| tt0165117 | Bruce Lee: l’ira del drago colpisce anche l’Occidente | Bruce Lee: l’ira del drago colpisce anche l’occidente | Lee |  |
| tt0080488 | Café Express | Café Express |  | Express |
| tt0150011 | C’era una volta questo pazzo, pazzo, pazzo West | C’era una volta questo pazzo, pazzo, pazzo west |  |  |
| tt0072886 | Doc Savage, l’uomo di bronzo | Doc Savage, l’uomo di bronzo |  | Savage |
| tt0112883 | Don Juan DeMarco - Maestro d’amore | Don Juan DeMarco - Maestro d’amore | DeMarco | Juan |
| tt0051612 | Duello a Forte Smith | Duello a Forte Smith | Smith | Forte |
| tt0050970 | Furia a Rio Apache | Furia a Rio Apache | Apache | Rio |
| tt0079903 | I 12 colpi segreti del Kung Fu di Bruce Lee l’invincibile | I 12 colpi segreti del Kung Fu di Bruce Lee l’invincibile | Bruce, Lee | Kung, Fu |
| tt0070034 | I 3 dell’Operazione Drago | I 3 dell’Operazione Drago |  | Operazione, Drago |
| tt0062713 | I cannoni di San Sebastian | I cannoni di San Sebastian | Sebastian | San |
| tt0058995 | I magnifici brutos del West | I magnifici brutos del west |  |  |
| tt0057122 | I pistoleros di Casa Grande | I pistoleros di Casa Grande |  | Casa, Grande |
| tt0196886 | I quattro pistoleri di Santa Trinità | I quattro pistoleri di Santa Trinità | Trinità | Santa |
| tt0067750 | Il solitario di Rio Grande | Il solitario di Rio Grande |  | Rio, Grande |
| tt0059337 | Johnny West il mancino | Johnny West il mancino |  | West |
| tt0059773 | La doppia vita di Sylvia West | La doppia vita di Sylvia West | Sylvia | West |
| tt0063696 | La grande rapina di Long Island | La grande rapina di Long Island | Island | Long |
| tt0345561 | La leggenda di Al, John e Jack | La leggenda di Al, John e Jack | John, Jack | Al |
| tt0164455 | La rivolta del Drago | La rivolta del drago |  |  |
| tt0049933 | La terra degli Apaches | La terra degli apaches |  |  |
| tt0059429 | Le meravigliose avventure di Marco Polo (Lo scacchiere di Dio) | Le meravigliose avventure di Marco Polo (Lo scacchiere di Dio) | Dio | Marco, Polo |
| tt0082834 | Le occasioni di Rosa | Le occasioni di Rosa |  |  |
| internal-1272 | L’appel Gloria e Paul | L’appel Gloria e Paul | Paul | Gloria |
| tt0074569 | L’ultima orgia del III Reich | L’ultima orgia del III Reich |  | Reich |
| tt0200888 | L’uomo del Kung Fu | L’uomo del Kung Fu |  | Kung, Fu |
| tt0055114 | Maciste alla corte del Gran Khan | Maciste alla corte del Gran Khan | Khan | Gran |
| tt0056208 | Madame Sans Gêne | Madame Sans Gêne | Gêne | Sans |
| tt0102382 | Malibù Gorilla | Malibù Gorilla |  | Gorilla |
| internal-1009 | Momenti Porno Vogliosi | Momenti Porno Vogliosi | Vogliosi | Porno |
| tt0191448 | Perversioni sessuali a Las Vegas | Perversioni sessuali a Las Vegas | Vegas | Las |
| tt0061799 | Ringo e Gringo contro tutti | Ringo e Gringo contro tutti |  |  |
| tt0114287 | Rob Roy | Rob Roy |  | Roy |
| tt0065367 | Sei già cadavere Amigo… ti cerca Garringo | Sei già cadavere amigo… ti cerca Garringo | Garringo |  |
| tt0203105 | Seminò morte… lo chiamavano il Castigo di Dio! | Seminò morte… lo chiamavano il castigo di Dio! | Dio |  |
| tt0059098 | Sfida a Rio Bravo | Sfida a Rio Bravo |  | Rio, Bravo |
| tt0045992 | Sotto il Sole Rovente | Sotto il Sole Rovente |  | Sole, Rovente |
| tt0059134 | Sparate a vista su Killer Kid | Sparate a vista su Killer Kid | Kid | Killer |
| tt0100758 | Tartarughe Ninja alla riscossa | Tartarughe Ninja alla riscossa |  | Ninja |
| tt0061333 | Un maggiordomo nel Far West | Un maggiordomo nel Far West |  | Far, West |
| tt0064818 | Uno straniero a Paso Bravo | Uno straniero a Paso Bravo | Paso | Bravo |
| tt0042901 | Viva Robin Hood! | Viva Robin Hood! |  | Robin, Hood |
| tt0114862 | Viva San Isidro | Viva San Isidro | Isidro | San |
| tt0063775 | Viva! Viva Villa! | Viva! Viva Villa! |  | Villa |

Status: DONE 2026-11-27. Checked by the owner; the 8 changes are applied as display rules in `layouts/partials/posters/titoli.html` (a warning appears if a rule no longer matches its title).
