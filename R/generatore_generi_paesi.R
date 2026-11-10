library(tidyverse)
library(fs)

# Carica i CSV
imdb <- read_csv("../cinema-teatro-sestito/static/data/programmazione_imdb.csv") %>%
          select(const = Const, title = Title, genres = Genres, url = URL)

proiezioni <- read_csv("../cinema-teatro-sestito/static/data/programmazione_agende.csv") %>%
          select(const, date)

paesi <- read_csv("../cinema-teatro-sestito/static/data/programmazione_paesi.csv") %>%
          select(const, country)

df <- proiezioni %>%
          left_join(imdb, by = "const") %>%
          left_join(paesi, by = "const")

make_slug <- function(x) {
          str_replace_all(tolower(x), "[^a-z0-9]+", "-")
}

create_md_pages <- function(df, column, output_root, category_label) {
          df_expanded <- df %>%
                    separate_rows({{column}}, sep = ",") %>%
                    mutate({{column}} := str_trim({{column}})) %>%
                    filter(!is.na({{column}}) & {{column}} != "") %>%
                    mutate(year = year(date)) %>%
                    arrange(year, date)   # Ordine per anno e alfabetico per titolo
          
          values <- df_expanded %>% distinct({{column}}) %>% pull({{column}})
          
          for (val in values) {
                    subset <- df_expanded %>% filter({{column}} == val)
                    
                    # Raggruppa per anno
                    sections <- subset %>%
                              group_by(year) %>%
                              summarise(
                                        films = paste0(
                                                  "|", date, " |",
                                                  ifelse(is.na(const) | const == "" | is.na(url) | url == "",
                                                         title,
                                                         paste0("[", title, "](", url, ")")
                                                  ),
                                                  "|",
                                                  collapse = "\n"
                                        ),
                                        .groups = "drop"
                              ) %>%
                              mutate(section = paste0(
                                        "### ", year, "\n\n",
                                        "|          |                                |\n",
                                        "|:---------|:-------------------------------|\n",
                                        films, "\n"
                              )) %>%
                              pull(section) %>%
                              paste(collapse = "\n")
                    
                    # Front matter YAML
                    front_matter <- paste0(
                              "---\n",
                              "title: \"", val, "\"\n",
                              "author: \"Vito Sestito\"\n",
                              "date: \"", Sys.Date(), "\"\n",
                              "slug: \"", make_slug(val), "\"\n",
                              "categories:\n  - ", category_label, "\n",
                              "tags:\n  - Programmazione\n",
                              "description: \"Film suddivisi per ", category_label,
                              " raggruppati per anno di proiezione.\"\n",
                              "---\n\n"
                    )
                    
                    # Contenuto finale
                    content <- sections
                    
                    # Crea cartella e scrivi index.md
                    dir_path <- file.path(output_root, make_slug(val))
                    dir_create(dir_path, recurse = TRUE)
                    file_path <- file.path(dir_path, "index.md")
                    
                    writeLines(c(front_matter, content), file_path)
          }
}

# Percorsi di output
out_countries <- "content/programmazione-storica/paesi-di-produzione"
out_genres    <- "content/programmazione-storica/generi"

# Genera file
create_md_pages(df, country, out_countries, "Paesi di produzione")
create_md_pages(df, genres,  out_genres,    "Generi")
