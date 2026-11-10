library(tidyverse)

# Carica i CSV
imdb <- read_csv("../cinema-teatro-sestito/static/data/programmazione_imdb.csv") %>%
          select(const = Const, url = URL)

proiezioni <- read_csv("../cinema-teatro-sestito/static/data/programmazione_agende.csv")

# Estrai l'anno dalla colonna date
proiezioni <- proiezioni %>%
          mutate(anno = year(ymd(date))) %>%
          left_join(imdb, by = "const") %>%
          mutate(title = paste0("[",title,"]","(",url,")"))

# Estrai anni unici ordinati
anni <- sort(unique(proiezioni$anno))

# Cartella base di output
cartella_base <- "content/programmazione-storica/anni"

# Ciclo sugli anni
for (a in anni) {
          
          # Filtra le proiezioni per l'anno corrente
          proiezioni_anno <- proiezioni %>%
                    filter(anno == a)
          
          # Nome cartella nel formato richiesto
          nome_cartella <- paste0(a, "-01-01-programmazione-", a)
          cartella_anno <- file.path(cartella_base, nome_cartella)
          
          if (!dir.exists(cartella_anno)) dir.create(cartella_anno, recursive = TRUE)
          
          # Nome file .Rmd
          file_path <- file.path(cartella_anno, "index.Rmd")
          
          # Data di inizio anno
          data_inizio <- paste0("'", a, "-01-01'")
          
          # Front matter YAML
          front_matter <- paste0(
                    "---\n",
                    "title: Programmazione ", a, "\n",
                    "author: Vito Sestito\n",
                    "date: ", data_inizio, "\n",
                    "slug: programmazione-", a, "\n",
                    "categories:\n",
                    "  - programmazione-per-anni\n",
                    "params:\n",
                    "  anno: ", a, "\n",
                    "---\n\n"
          )
          
          # Chunk setup: librerie + dati già filtrati
          chunk_setup <- paste0(
                    "```{r setup, include=FALSE}\n",
                    "library(tidyverse)\n",
                    "library(knitr)\n",
                    "library(here)\n",
                    "library(ggrepel)\n",
                    "library(scales)\n",
                    "library(showtext)\n",
                    "\n",
                    "# Impostazioni grafiche: font Merriweather\n",
                    "font_add_google(\"Merriweather\", \"merriweather\")\n",
                    "showtext_auto()\n",
                    "\n",
                    "theme_set(\n",
                    "theme_classic(base_family = \"merriweather\") +\n",
                              "theme(\n",
                                        "plot.subtitle = element_text(size = 18),\n",
                                        "axis.title = element_text(size = 18),\n",
                                        "axis.text = element_text(size = 16),\n",
                                        "panel.grid.major = element_blank(),\n",
                                        "panel.grid.minor = element_blank()\n",
                    "                   )\n",
                    ")\n",
                    "\n",
                    "# Imposta la lingua italiana per i nomi dei mesi\n",
                    "Sys.setlocale(\"LC_TIME\", \"it_IT.UTF-8\")\n",
                    "\n",
                    "# Dati filtrati per l'anno ", a, "\n",
                    "imdb <- read_csv(here(\"static/data/programmazione_imdb.csv\")) %>% \n",
                    "  select(const = Const, year = Year, directors = Directors, genres = Genres, imdb_rating = `IMDb Rating`, imdb_votes = `Num Votes`, runtime = `Runtime (mins)`, url = URL) \n",
                    "\n",
                    "Sys.setlocale(\"LC_TIME\", \"it_IT.UTF-8\") \n",
                    "\n",
                    "proiezioni_anno <- read_csv(here(\"static/data/programmazione_agende.csv\")) %>% \n",
                    "  mutate(anno = year(ymd(date))) %>% \n",
                    "  left_join(imdb, by = \"const\") %>% \n",
                    "  mutate(Titolo = paste0(\"[\", title, \"](\", url, \")\")) %>% \n",
                    "  filter(anno == params$anno) %>% \n",
                    "  rename(Data = date) %>% \n",
                    "  arrange(Data)\n",
                    "```\n\n"
          )
          
          # Chunk grafici
          chunk_grafici <- paste0(
                    "```{r echo=FALSE, warning=FALSE, fig.width=8, fig.height=3}\n",
                    "\n",
                    "totale <- nrow(proiezioni_anno) \n",
                    "\n",
                    "proiezioni_anno %>%\n",
                    "  mutate(mese = month(Data, label = TRUE, abbr = FALSE), mese = str_to_title(as.character(mese)), mese = factor(mese, levels = unique(mese[order(month(Data))]))) %>%\n",
                    "  count(mese) %>%\n",
                    "  ggplot(aes(x = mese, y = n)) +\n",
                    "  geom_col(fill = \"#CBF8DF\") +\n",
                    "  geom_text(aes(label = n), vjust = -0.5, size = 6) +\n",
                    "  labs(y = \"Numero di film proiettati\", x = \"\", subtitle = paste(\"Totale proiezioni:\", totale)) +\n",
                    "  theme(strip.placement = \"outside\",\n",
                    "        strip.background = element_blank(),\n",
                    "        panel.spacing=unit(0,\"cm\"),\n",
                    "        plot.margin = margin(t = 20, r = 10, b = 10, l = 10)) +\n",
                    "  coord_cartesian(clip = \"off\")\n",
                    "\n",
                    "proiezioni_anno %>%\n",
                    "  drop_na(imdb_rating, imdb_votes) %>%\n",
                    "  ggplot(aes(imdb_votes, imdb_rating)) +\n",
                    "  geom_point(colour = \"#CBF8DF\", size = 2) +\n",
                    "  geom_text_repel(aes(label = title), size = 6) +\n",
                    "  scale_x_log10(labels = comma) +\n",
                    "  scale_y_continuous(breaks = 1:10) +\n",
                    "  labs(y = \"Valutazioni medie IMDb\", x = \"Numero di voti (log)\", caption = \"Information courtesy of IMDb (https://www.imdb.com)\") +\n",
                    "  theme(strip.placement = \"outside\",\n",
                    "        strip.background = element_blank(),\n",
                    "        panel.spacing=unit(0,\"cm\"),\n",
                    "        plot.margin = margin(t = 20, r = 10, b = 10, l = 10)) +\n",
                    "  coord_cartesian(clip = \"off\")\n",
                    "\n",
                    "```\n\n"
          )
          
          # Chunk tabella suddivisa per mese
          chunk_tabella <- ""
          
          # 1. Leggi tutte le cartelle disponibili nella directory delle fonti
          cartelle_fonti <- list.dirs("content/programmazione-storica/fonti/", recursive = FALSE, full.names = FALSE)
          
          # 2. Rimuovi la parola "appunti" dai nomi delle cartelle per facilitare il matching
          cartelle_pulite <- cartelle_fonti %>%
                    str_replace_all("appunti", "") %>%
                    str_replace_all("-", "") %>%
                    str_to_lower()
          
          # 2. Estrai e pulisci i nomi delle fonti dal database
          fonti_anno <- proiezioni_anno %>%
                    filter(!is.na(source)) %>%
                    pull(source) %>%
                    str_split(",") %>%
                    unlist() %>%
                    str_trim() %>%
                    unique() %>%
                    sort()
          
          fonti_pulite <- fonti_anno %>%
                    str_replace_all("[^a-zA-Z0-9]", "") %>%
                    str_to_lower()
          
          # 4. Mappa ogni fonte alla prima cartella che contiene il nome pulito
          mappa_fonti <- tibble(
                    fonte = fonti_anno,
                    fonte_pulita = fonti_pulite,
                    cartella = map_chr(fonte_pulita, function(f) {
                              match_index <- which(str_detect(cartelle_pulite, f))
                              if (length(match_index) > 0) cartelle_fonti[match_index[1]] else NA
                    })
          ) %>%
                    filter(!is.na(cartella)) %>%
                    mutate(
                              # Estrai la data dal nome della cartella (formato: YYYY-MM-DD)
                              data_slug = str_extract(cartella, "^\\d{4}-\\d{2}-\\d{2}"),
                              # Rimuovi la data dal nome per ottenere lo slug finale
                              nome_slug = str_remove(cartella, "^\\d{4}-\\d{2}-\\d{2}-"),
                              # Costruisci il link corretto
                              link = paste0("/", str_replace_all(data_slug, "-", "/"), "/", nome_slug, "/")
                    )
          
          
          # 5. Crea i link Markdown
          link_markdown <- paste0("[", mappa_fonti$fonte, "](", mappa_fonti$link, ")")
          
          # 6. Nota a piè di pagina
          nota_fonti <- paste0("[^1]: Fonti: ", paste(link_markdown, collapse = ", "), "\n")
          
          # Nomi dei mesi in italiano
          mesi_italiani <- c("Gennaio", "Febbraio", "Marzo", "Aprile", "Maggio", "Giugno",
                             "Luglio", "Agosto", "Settembre", "Ottobre", "Novembre", "Dicembre")
          
          # Trova il primo mese con proiezioni
          primo_mese <- proiezioni_anno %>%
                    mutate(mese = month(date)) %>%
                    filter(!is.na(mese)) %>%
                    summarise(min_mese = min(mese)) %>%
                    pull(min_mese)
          
          for (m in 1:12) {
                    proiezioni_mese <- proiezioni_anno %>% filter(month(date) == m)
                    
                    if (nrow(proiezioni_mese) > 0) {
                              intestazione_mese <- paste0("### ", mesi_italiani[m])
                              if (m == primo_mese) intestazione_mese <- paste0(intestazione_mese, "[^1]")
                              intestazione_mese <- paste0(intestazione_mese, "\n\n")
                              
                              tabella_mese <- paste0(
                                        "```{r echo=FALSE}\n",
                                        "proiezioni_anno %>% \n",
                                        "  filter(month(Data) == ", m, ") %>% \n",
                                        "  select(Data, Titolo) %>% \n",
                                        "  arrange(Data) %>% \n",
                                        "  kable(col.names = c(\"\", \"\"))\n",
                                        "```\n\n"
                              )
                              
                              chunk_tabella <- paste0(chunk_tabella, intestazione_mese, tabella_mese)
                    }
          }
          # Aggiungi la nota a piè di pagina in fondo
          chunk_tabella <- paste0(chunk_tabella, nota_fonti)
          
          # Scrivi il file
          writeLines(c(front_matter, chunk_setup, chunk_grafici, chunk_tabella), file_path)
}
