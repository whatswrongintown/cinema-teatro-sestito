library(tidyverse)


# Percorsi
imdb_path <- "static/data/programmazione_imdb.csv"
data_path <- "static/data/programmazione_agende.csv"
output_dir <- "content/programmazione-storica/fonti"
image_dir <- "static/images"

# Carica i dati
imdb <- read_csv(imdb_path) %>%
          select(const = Const, url = URL)

programmazione <- read_csv(data_path) %>%
          select(const, date, title, source) %>%
          mutate(date = as.Date(date)) %>%
          left_join(imdb, by = "const") %>%
          mutate(
                    # Se const manca o è vuoto: niente link
                    title_link = if_else(!is.na(const) & const != "" & !is.na(url) & url != "",
                                         paste0("[", title, "](", url, ")"),
                                         title)
          )

# Funzione per determinare categoria e descrizione
get_metadata <- function(source_name) {
          if (str_detect(source_name, regex("calendario", ignore_case = TRUE))) {
                    list(cat = "Calendari", desc = "Calendari murali o da tavolo legati all’attività del cinema. Indicano la data di proiezione e il titolo dei film, insieme agli incassi registrati.")
          } else if (str_detect(source_name, regex("rubrica", ignore_case = TRUE))) {
                    list(cat = "Rubriche", desc = "Rubriche dove i film venivano annotati in ordine alfabetico, con data di proiezione e distributore.")
          } else if (str_detect(source_name, regex("italautogamma|cif|new|victory", ignore_case = TRUE))) {
                    list(cat = "Appunti", desc = "Appunti su blocchi o fogli, con i film registrati per mese. Riportano gli incassi dei film quando disponibili.")
          } else {
                    list(cat = "Agende", desc = "Agende cinematografiche fornite dalle case distributrici. Contengono informazioni dettagliate sulla data di proiezione, titolo del film, distributore e l’ammontare degli incassi.")
          }
}

# Helper: escape per pipe in Markdown
escape_md <- function(x) {
          x <- replace_na(x, "")
          str_replace_all(x, "\\|", "\\\\|")
}

# Helper: crea tabella markdown semplice con due colonne
make_md_table <- function(df, col1_name = "", col2_name = "") {
          if (nrow(df) == 0) return("")
          header <- paste0("| ", col1_name, " | ", col2_name, " |")
          sep <- "|---|---|"
          rows <- pmap_chr(
                    list(df[[1]], df[[2]]),
                    ~ paste0("| ", escape_md(as.character(..1)), " | ", escape_md(as.character(..2)), " |")
          )
          paste(c(header, sep, rows), collapse = "\n")
}

# Estrai tutte le fonti uniche
fonti <- programmazione %>%
          separate_rows(source, sep = ",") %>%
          mutate(source = str_trim(source)) %>%
          distinct(source) %>%
          pull(source)

# Genera file .md per ogni fonte
for (fonte in fonti) {
          fonte_data <- programmazione %>%
                    filter(str_detect(source, fixed(fonte)))
          
          if (nrow(fonte_data) == 0) next
          
          meta <- get_metadata(fonte)
          first_date <- floor_date(min(fonte_data$date, na.rm = TRUE), unit = "month")
          
          # Slug base
          slug <- str_replace_all(tolower(fonte), "[^a-z0-9]+", "-")
          slug_gallery <- str_replace_all(tolower(fonte), "[^a-z0-9]+", "_")
          
          if (!is.null(meta$cat) && meta$cat == "Appunti") {
                    slug <- paste0("appunti-", slug)
                    slug_gallery <- paste0("appunti_", slug_gallery)
          }
          
          # Path galleria immagini
          gallery_path <- paste0("/images/", format(first_date, "%Y_%m_%d"), "_", slug_gallery)
          
          # Front matter YAML
          front_matter <- paste0(
                    "---\n",
                    "title: ", fonte, "\n",
                    "author: Vito Sestito\n",
                    "date: '", first_date, "'\n",
                    "slug: ", slug, "\n",
                    "categories:\n",
                    "  - ", meta$cat, "\n",
                    "description: ", meta$desc, "\n",
                    "---\n\n"
          )
          
          # Verifica se la cartella immagini esiste
          gallery_folder <- file.path("static/images", paste0(format(first_date, "%Y_%m_%d"), "_", slug_gallery))
          gallery_exists <- dir.exists(gallery_folder)
          
          chunk_gallery <- if (gallery_exists) {
                    paste0("{{< image-gallery gallery_dir=\"", gallery_path, "\" >}}\n\n")
          } else {
                    "> ⚠️ Questa fonte non è stata scansionata.\n\n"
          }
          
          # Mesi in italiano
          mesi_italiani <- c("Gennaio", "Febbraio", "Marzo", "Aprile", "Maggio", "Giugno",
                             "Luglio", "Agosto", "Settembre", "Ottobre", "Novembre", "Dicembre")
          
          anni_presenti <- fonte_data %>%
                    mutate(anno = year(date)) %>%
                    pull(anno) %>%
                    unique() %>%
                    sort()
          
          chunk_tabella <- ""
          
          if (length(anni_presenti) == 1) {
                    proiezioni_anno <- fonte_data
                    mesi_presenti <- proiezioni_anno %>%
                              mutate(mese = month(date)) %>%
                              pull(mese) %>%
                              unique() %>%
                              sort()
                    
                    for (m in mesi_presenti) {
                              proiezioni_mese <- proiezioni_anno %>% filter(month(date) == m)
                              
                              if (nrow(proiezioni_mese) > 0) {
                                        intestazione_mese <- paste0("### ", mesi_italiani[m], "\n\n")
                                        df_out <- proiezioni_mese %>%
                                                  arrange(date) %>%
                                                  transmute(
                                                            Data = format(date, "%Y-%m-%d"),
                                                            Titolo = title_link
                                                  )
                                        tabella_mese <- make_md_table(df_out)
                                        chunk_tabella <- paste0(chunk_tabella, intestazione_mese, tabella_mese, "\n\n")
                              }
                    }
          } else {
                    for (anno_corrente in anni_presenti) {
                              proiezioni_anno <- fonte_data %>% filter(year(date) == anno_corrente)
                              chunk_tabella <- paste0(chunk_tabella, "## ", anno_corrente, "\n\n")
                              
                              mesi_presenti <- proiezioni_anno %>%
                                        mutate(mese = month(date)) %>%
                                        pull(mese) %>%
                                        unique() %>%
                                        sort()
                              
                              for (m in mesi_presenti) {
                                        proiezioni_mese <- proiezioni_anno %>% filter(month(date) == m)
                                        
                                        if (nrow(proiezioni_mese) > 0) {
                                                  intestazione_mese <- paste0("### ", mesi_italiani[m], "\n\n")
                                                  df_out <- proiezioni_mese %>%
                                                            arrange(date) %>%
                                                            transmute(
                                                                      Data = format(date, "%Y-%m-%d"),
                                                                      Titolo = title_link
                                                            )
                                                  tabella_mese <- make_md_table(df_out)
                                                  chunk_tabella <- paste0(chunk_tabella, intestazione_mese, tabella_mese, "\n\n")
                                        }
                              }
                    }
          }
          
          # Scrivi il file .md
          nome_cartella <- paste0(first_date, "-", slug)
          cartella_fonti <- file.path(output_dir, nome_cartella)
          
          if (!dir.exists(cartella_fonti)) dir.create(cartella_fonti, recursive = TRUE)
          
          file_name <- file.path(output_dir, nome_cartella, "index.md")
          writeLines(c(front_matter, chunk_gallery, chunk_tabella), file_name)
}
