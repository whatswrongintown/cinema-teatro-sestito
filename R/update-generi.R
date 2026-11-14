# Controlla che i pacchetti necessari siano installati prima di generare le pagine.
check_generi_packages <- function() {
  packages <- c("readr", "dplyr", "purrr", "stringr", "yaml", "tibble", "tidyr")
  missing <- packages[!vapply(packages, requireNamespace, logical(1), quietly = TRUE)]
  if (length(missing)) {
    stop("Pacchetti R mancanti: ", paste(missing, collapse = ", "), call. = FALSE)
  }
}

# Legge un CSV come testo e controlla che non contenga errori o colonne mancanti.
read_generi_csv <- function(path, required) {
  data <- readr::read_csv(
    path, col_types = readr::cols(.default = readr::col_character()),
    locale = readr::locale(encoding = "UTF-8"), show_col_types = FALSE
  )
  if (nrow(readr::problems(data))) {
    stop("CSV non valido: ", path, call. = FALSE)
  }
  missing <- setdiff(required, names(data))
  if (length(missing)) {
    stop("Colonne mancanti in ", path, ": ", paste(missing, collapse = ", "),
         call. = FALSE)
  }
  data
}

# Protegge i caratteri speciali nei titoli usati nelle tabelle Markdown e HTML.
escape_generi_text <- function(text) {
  replacements <- c("&" = "&amp;", "<" = "&lt;", ">" = "&gt;", "|" = "&#124;")
  for (character in names(replacements)) {
    text <- gsub(character, replacements[[character]], text, fixed = TRUE)
  }
  for (character in c("\\", "[", "]", "*", "_", "`")) {
    text <- gsub(character, paste0("\\", character), text, fixed = TRUE)
  }
  gsub("[\r\n]", " ", text)
}

# Carica le proiezioni e i dati IMDb, verifica i valori e li unisce per film.
load_generi_screenings <- function(project_root) {
  directory <- file.path(project_root, "static", "data")
  screenings <- read_generi_csv(
    file.path(directory, "programmazione_agende.csv"),
    c("date", "const", "title", "source")
  )
  imdb <- read_generi_csv(
    file.path(directory, "programmazione_imdb.csv"),
    c("Const", "IMDb Rating", "Num Votes", "URL")
  )
  if (!nrow(screenings)) {
    stop("Il database delle proiezioni e' vuoto.", call. = FALSE)
  }
  for (column in c("date", "title", "source")) {
    if (any(is.na(screenings[[column]]) | !nzchar(trimws(screenings[[column]])))) {
      stop("Valori mancanti nella colonna delle proiezioni: ", column, call. = FALSE)
    }
  }
  # Le date devono essere valide; gli identificativi IMDb devono essere univoci.
  dates <- as.Date(screenings$date, format = "%Y-%m-%d")
  if (anyNA(dates) || any(format(dates, "%Y-%m-%d") != screenings$date)) {
    stop("Le date delle proiezioni devono essere valide e nel formato YYYY-MM-DD.",
         call. = FALSE)
  }
  if (anyNA(imdb$Const) || any(!nzchar(imdb$Const)) || anyDuplicated(imdb$Const)) {
    stop("Gli identificativi IMDb devono essere presenti e univoci.", call. = FALSE)
  }
  rating <- as.numeric(imdb[["IMDb Rating"]])
  votes <- as.numeric(imdb[["Num Votes"]])
  if (any(!is.na(imdb[["IMDb Rating"]]) & !is.finite(rating)) ||
      any(!is.na(imdb[["Num Votes"]]) & !is.finite(votes)) ||
      any(rating < 0 | rating > 10, na.rm = TRUE) ||
      any(votes < 0 | votes != floor(votes), na.rm = TRUE)) {
    stop("Valutazioni o numeri di voti IMDb non validi.", call. = FALSE)
  }
  # Aggiunge anno, mese e dati IMDb a ogni proiezione, mantenendo le ripetizioni.
  films <- data.frame(
    const = imdb$Const, imdb_rating = rating, imdb_votes = votes,
    url = imdb$URL, stringsAsFactors = FALSE
  )
  screenings <- screenings |>
    dplyr::mutate(
      date = dates,
      anno = as.integer(format(date, "%Y")),
      mese = as.integer(format(date, "%m"))
    ) |>
    dplyr::left_join(films, by = "const")
  missing_url_count <- screenings |>
    dplyr::filter(is.na(url) | !nzchar(url)) |>
    nrow()
  if (missing_url_count > 0) {
    warning(missing_url_count,
            " proiezioni senza URL IMDb: il titolo restera' senza collegamento.",
            call. = FALSE)
  }
  dplyr::arrange(screenings, date)
}

# Legge titolo e percorso delle pagine esistenti nella sezione indicata.
read_generi_pages <- function(directory) {
  files <- list.files(directory, pattern = "^index\\.md$", recursive = TRUE,
                      full.names = TRUE)
  if (!length(files)) {
    return(tibble::tibble(path = character(), title = character(), key = character()))
  }
  purrr::map_dfr(files, function(path) {
    lines <- readLines(path, encoding = "UTF-8", warn = FALSE)
    boundaries <- which(lines == "---")
    if (length(boundaries) < 2 || boundaries[1] != 1) {
      stop("Front matter non valido: ", path, call. = FALSE)
    }
    metadata <- yaml::yaml.load(paste(lines[2:(boundaries[2] - 1)], collapse = "\n"))
    if (!is.character(metadata$title) || length(metadata$title) != 1 ||
        is.na(metadata$title) || !nzchar(trimws(metadata$title))) {
      stop("Titolo mancante: ", path, call. = FALSE)
    }
    tibble::tibble(path = path, title = metadata$title,
                   key = stringr::str_to_lower(stringr::str_trim(metadata$title)))
  })
}

# Separa fonti, generi o paesi elencati nella stessa cella del database.
split_generi_values <- function(data, column) {
  # Crea una riga per valore, elimina spazi e valori vuoti e rimuove i duplicati
  # dello stesso valore per la stessa proiezione.
  data |>
    dplyr::mutate(value = stringr::str_split(.data[[column]], ",")) |>
    tidyr::unnest_longer(value) |>
    dplyr::mutate(value = stringr::str_trim(value)) |>
    dplyr::filter(!is.na(value), value != "") |>
    dplyr::mutate(key = stringr::str_to_lower(value)) |>
    dplyr::distinct(screening_id, key, .keep_all = TRUE)
}

load_generi_data <- function(project_root, section = NULL) {
  directory <- file.path(project_root, "static", "data")
  screenings <- load_generi_screenings(project_root) |>
    dplyr::mutate(screening_id = dplyr::row_number())
  imdb <- read_generi_csv(file.path(directory, "programmazione_imdb.csv"),
                        c("Const", "Genres")) |>
    dplyr::transmute(const = Const, genres = Genres)
  dplyr::left_join(screenings, imdb, by = "const")
}

# Costruisce tabelle Markdown raggruppate per anno o mese, con eventuali link IMDb.
generi_table <- function(data, group_column, heading_level = "###") {
  groups <- sort(unique(data[[group_column]]))
  purrr::map(groups, function(group) {
    rows <- data |>
      dplyr::filter(.data[[group_column]] == group) |>
      dplyr::mutate(
        display_title = escape_generi_text(title),
        display_title = dplyr::if_else(
          !is.na(url) & nzchar(url),
          paste0("[", display_title, "](", url, ")"), display_title
        )
      )
    c(paste(heading_level, group), "", "|  |  |", "|---|---|",
      paste0("| ", format(rows$date, "%Y-%m-%d"), " | ", rows$display_title, " |"), "")
  }) |>
    unlist(use.names = FALSE)
}

# Conserva metadati, descrizioni e gallerie che precedono le tabelle generate.
generi_prefix <- function(path) {
  lines <- readLines(path, encoding = "UTF-8", warn = FALSE)
  start <- which(grepl("^(## [0-9]{4}|### (Gennaio|Febbraio|Marzo|Aprile|Maggio|Giugno|Luglio|Agosto|Settembre|Ottobre|Novembre|Dicembre)|### [0-9]{4})$", lines))
  if (!length(start)) {
    marker <- which(lines == "<!-- Tabelle generate automaticamente. -->")
    if (length(marker) == 1) {
      prefix <- lines[seq_len(marker - 1)]
      return(prefix[seq_len(max(c(0, which(nzchar(trimws(prefix))))))])
    }
    stop("Tabelle non riconosciute in ", path, call. = FALSE)
  }
  # Interrompe l'aggiornamento se dopo le tabelle trova contenuti non riconosciuti.
  first <- start[1]
  generated <- lines[first:length(lines)]
  allowed <- grepl("^(\\s*$|## [0-9]{4}$|### ([0-9]{4}|Gennaio|Febbraio|Marzo|Aprile|Maggio|Giugno|Luglio|Agosto|Settembre|Ottobre|Novembre|Dicembre)$|\\|)", generated)
  if (!all(allowed)) {
    stop("Contenuto non riconosciuto dopo le tabelle in ", path, call. = FALSE)
  }
  prefix <- lines[seq_len(first - 1)]
  prefix <- prefix[prefix != "<!-- Tabelle generate automaticamente. -->"]
  prefix[seq_len(max(c(0, which(nzchar(trimws(prefix))))))]
}

generi_description <- function(prefix, title) {
  boundary <- which(prefix == "---")[2]
  metadata <- yaml::yaml.load(paste(prefix[2:(boundary - 1)], collapse = "\n"))
  current <- metadata$description
  legacy <- "Film suddivisi per Generi raggruppati per anno di proiezione."
  if (!is.null(current) && (!is.character(current) || length(current) != 1L ||
                            is.na(current) || (nzchar(trimws(current)) && current != legacy))) return(prefix)
  description <- paste0("Film di genere ", title, " nella programmazione del Cinema Teatro Sestito, suddivisi per anno.")
  replacement <- strsplit(yaml::as.yaml(list(description = description)), "\n", fixed = TRUE)[[1]]
  fields <- which(grepl("^description[[:space:]]*:", prefix[seq_len(boundary - 1)]))
  if (!length(fields)) return(append(prefix, replacement, after = boundary - 1))
  if (length(fields) != 1L) return(prefix)
  line_value <- tryCatch(yaml::yaml.load(prefix[fields])$description, error = function(error) NA)
  if (!identical(current, line_value)) return(prefix)
  c(prefix[seq_len(fields - 1)], replacement, prefix[seq.int(fields + 1, length(prefix))])
}

# Imposta l'immagine condivisa dalle pagine dei generi senza riscrivere gli altri metadati.
generi_image <- function(prefix) {
  boundary <- which(prefix == "---")[2]
  metadata <- yaml::yaml.load(paste(prefix[2:(boundary - 1)], collapse = "\n"))
  fields <- which(grepl("^image[[:space:]]*:", prefix[seq_len(boundary - 1)]))
  image <- "/programmazione-storica/generi/_index_files/figure-html/generi-per-decennio-1.png"
  replacement <- paste0('image: "', image, '"')
  if (!length(fields)) return(append(prefix, replacement, after = boundary - 1))
  if (length(fields) != 1L) stop("Campo image duplicato nei metadati.", call. = FALSE)
  line_value <- tryCatch(yaml::yaml.load(prefix[fields])$image, error = function(error) NULL)
  if (!identical(metadata$image, line_value)) {
    stop("Campo image multilinea o non valido nei metadati.", call. = FALSE)
  }
  prefix[fields] <- replacement
  prefix
}

generi_permalink <- function(prefix, slug) {
  boundary <- which(prefix == "---")[2]
  metadata <- yaml::yaml.load(paste(prefix[2:(boundary - 1)], collapse = "\n"))
  if (is.null(metadata$date) || as.character(metadata$date) != "2025-12-02") return(prefix)
  old_url <- paste0("/2025/12/02/", slug, "/")
  if (is.null(metadata$url) || identical(metadata$url, old_url)) {
    metadata$url <- paste0("/programmazione-storica/generi/", slug, "/")
  }
  metadata$aliases <- as.list(unique(c(unlist(metadata$aliases, use.names = FALSE), old_url)))
  metadata$date <- NULL
  c("---", strsplit(yaml::as.yaml(metadata), "\n", fixed = TRUE)[[1]], "---")
}

# Trasforma il nome di un nuovo genere o paese in un nome adatto alla cartella.
generi_slug <- function(value) {
  ascii <- iconv(value, from = "UTF-8", to = "ASCII//TRANSLIT")
  slug <- stringr::str_to_lower(ascii) |>
    stringr::str_replace_all("[^a-z0-9]+", "-") |>
    stringr::str_replace_all("^-|-$", "")
  if (anyNA(slug) || any(!nzchar(slug))) {
    stop("Impossibile creare uno slug per: ", paste(value, collapse = ", "), call. = FALSE)
  }
  slug
}

# Prepara le pagine di una sezione in memoria, senza ancora scriverle su disco.
prepare_generi_pages <- function(data, section, directory, selection = NULL) {
  pages <- read_generi_pages(directory)
  if (anyDuplicated(pages$key)) {
    stop("Titoli duplicati in ", directory, call. = FALSE)
  }
  if (!is.null(selection)) {
    if (!is.character(selection) || !length(selection) || anyNA(selection) ||
        any(!nzchar(trimws(selection)))) {
      stop("Specificare uno o piu nomi non vuoti per ", section, ".", call. = FALSE)
    }
    keys <- unique(stringr::str_to_lower(stringr::str_trim(selection)))
    available <- union(pages$key, data$key)
    unknown_keys <- setdiff(keys, available)
    if (length(unknown_keys)) {
      stop("Nomi non trovati in ", section, ": ", paste(unknown_keys, collapse = ", "), call. = FALSE)
    }
    pages <- dplyr::filter(pages, key %in% keys)
    data <- dplyr::filter(data, key %in% keys)
  }
  values <- data |>
    dplyr::distinct(key, value)
  if (anyDuplicated(values$key)) {
    stop("Nomi ambigui in ", section, call. = FALSE)
  }
  unknown <- dplyr::anti_join(values, pages, by = "key")
  if (nrow(unknown)) {
    unknown <- unknown |>
      dplyr::mutate(slug = generi_slug(value),
                    path = file.path(directory, slug, "index.md"), title = value)
    if (anyDuplicated(unknown$path) || any(unknown$path %in% pages$path) ||
        any(file.exists(unknown$path))) {
      stop("Slug duplicato o pagina esistente in ", section, call. = FALSE)
    }
    pages <- dplyr::bind_rows(pages, dplyr::select(unknown, path, title, key))
  }
  # Mantiene la parte iniziale delle pagine esistenti e sostituisce le tabelle.
  purrr::map(seq_len(nrow(pages)), function(index) {
    page <- pages[index, ]
    rows <- data |>
      dplyr::filter(key == page$key)
    if (file.exists(page$path)) {
      prefix <- generi_prefix(page$path)
      prefix <- generi_permalink(prefix, basename(dirname(page$path)))
      prefix <- generi_description(prefix, page$title)
    } else {
      metadata <- list(title = page$title, author = "Vito Sestito",
                       slug = basename(dirname(page$path)),
                       url = paste0("/programmazione-storica/generi/", basename(dirname(page$path)), "/"),
                       categories = list("Generi"),
                       tags = list("Programmazione"),
                       description = paste0("Film di genere ", page$title, " nella programmazione del Cinema Teatro Sestito, suddivisi per anno."))
      prefix <- c("---", strsplit(yaml::as.yaml(metadata), "\n", fixed = TRUE)[[1]], "---", "")
    }
    prefix <- generi_image(prefix)
    table <- generi_table(rows, "anno")
    list(path = page$path, lines = c(prefix, "<!-- Tabelle generate automaticamente. -->", "", table))
  })
}

check_generi_section <- function(project_root, section) {
  project_root <- normalizePath(project_root, mustWork = TRUE)
  check_generi_packages()
  invisible(project_root)
}

prepare_generi_section <- function(project_root, section, column, selection = NULL) {
  project_root <- check_generi_section(project_root, section)
  data <- load_generi_data(project_root, section)
  directory <- file.path(project_root, "content", "programmazione-storica", section)
  prepare_generi_pages(split_generi_values(data, column), section, directory, selection)
}

write_generi_pages <- function(pages) {
  for (page in pages) {
    dir.create(dirname(page$path), recursive = TRUE, showWarnings = FALSE)
    writeLines(enc2utf8(page$lines), page$path, useBytes = TRUE)
  }
  invisible(pages)
}

update_generi <- function(project_root = ".", genres = NULL) {
  pages <- prepare_generi_section(project_root, "generi", "genres", genres)
  write_generi_pages(pages)
  invisible(pages)
}

if (sys.nframe() == 0L) update_generi()
