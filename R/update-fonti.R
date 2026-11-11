# Controlla che i pacchetti necessari siano installati prima di generare le pagine.
check_fonti_packages <- function() {
  packages <- c("readr", "dplyr", "purrr", "stringr", "ggplot2", "ggrepel", "scales", "yaml", "showtext")
  missing <- packages[!vapply(packages, requireNamespace, logical(1), quietly = TRUE)]
  if (length(missing)) {
    stop("Pacchetti R mancanti: ", paste(missing, collapse = ", "), call. = FALSE)
  }
}

# Legge un CSV come testo e controlla che non contenga errori o colonne mancanti.
read_fonti_csv <- function(path, required) {
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
escape_fonti_text <- function(text) {
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
load_fonti_screenings <- function(project_root) {
  directory <- file.path(project_root, "static", "data")
  screenings <- read_fonti_csv(
    file.path(directory, "programmazione_agende.csv"),
    c("date", "const", "title", "source")
  )
  imdb <- read_fonti_csv(
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
read_fonti_pages <- function(directory) {
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
split_fonti_values <- function(data, column) {
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

load_fonti_data <- function(project_root, section = NULL) {
  load_fonti_screenings(project_root) |>
    dplyr::mutate(screening_id = dplyr::row_number())
}

# Costruisce tabelle Markdown raggruppate per anno o mese, con eventuali link IMDb.
fonti_table <- function(data, group_column, heading_level = "###") {
  groups <- sort(unique(data[[group_column]]))
  purrr::map(groups, function(group) {
    rows <- data |>
      dplyr::filter(.data[[group_column]] == group) |>
      dplyr::mutate(
        display_title = escape_fonti_text(title),
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

# Per le fonti raggruppa le proiezioni per mese e, se necessario, anche per anno.
fonti_source_table <- function(data) {
  months <- c("Gennaio", "Febbraio", "Marzo", "Aprile", "Maggio", "Giugno",
              "Luglio", "Agosto", "Settembre", "Ottobre", "Novembre", "Dicembre")
  years <- sort(unique(data$anno))
  purrr::map(years, function(year) {
    rows <- data |>
      dplyr::filter(anno == year) |>
      dplyr::mutate(month_name = factor(months[mese], levels = months))
    c(if (length(years) > 1) c(paste("##", year), ""),
      fonti_table(rows, "month_name"))
  }) |>
    unlist(use.names = FALSE)
}

# Conserva metadati, descrizioni e gallerie che precedono le tabelle generate.
fonti_prefix <- function(path) {
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

fonti_description <- function(prefix, title) {
  boundary <- which(prefix == "---")[2]
  metadata <- yaml::yaml.load(paste(prefix[2:(boundary - 1)], collapse = "\n"))
  current <- metadata$description
  if (!is.null(current) && (!is.character(current) || length(current) != 1L ||
                            is.na(current) || nzchar(trimws(current)))) return(prefix)
  description <- paste0("Programmazione cinematografica del Cinema Teatro Sestito documentata da ", title, ".")
  replacement <- strsplit(yaml::as.yaml(list(description = description)), "\n", fixed = TRUE)[[1]]
  fields <- which(grepl("^description[[:space:]]*:", prefix[seq_len(boundary - 1)]))
  if (!length(fields)) return(append(prefix, replacement, after = boundary - 1))
  if (length(fields) != 1L) return(prefix)
  line_value <- tryCatch(yaml::yaml.load(prefix[fields])$description, error = function(error) NA)
  if (!identical(current, line_value)) return(prefix)
  c(prefix[seq_len(fields - 1)], replacement, prefix[seq.int(fields + 1, length(prefix))])
}

# Prepara le pagine di una sezione in memoria, senza ancora scriverle su disco.
prepare_fonti_pages <- function(data, section, directory, selection = NULL) {
  pages <- read_fonti_pages(directory)
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
    available <- union(available, "note_su_manifesti")
    unknown_keys <- setdiff(keys, available)
    if (length(unknown_keys)) {
      stop("Nomi non trovati in ", section, ": ", paste(unknown_keys, collapse = ", "), call. = FALSE)
    }
    pages <- dplyr::filter(pages, key %in% keys)
    data <- dplyr::filter(data, key %in% keys)
  }
  values <- data |>
    dplyr::distinct(key, value)
  data <- dplyr::filter(data, key != "note_su_manifesti")
  values <- dplyr::filter(values, key != "note_su_manifesti")
  if (anyDuplicated(values$key)) {
    stop("Nomi ambigui in ", section, call. = FALSE)
  }
  unknown <- dplyr::anti_join(values, pages, by = "key")
  if (nrow(unknown)) {
    stop("Creare prima le schede delle fonti: ",
         paste(unknown$value, collapse = ", "), call. = FALSE)
  }
  # Mantiene la parte iniziale delle pagine esistenti e sostituisce le tabelle.
  purrr::map(seq_len(nrow(pages)), function(index) {
    page <- pages[index, ]
    rows <- data |>
      dplyr::filter(key == page$key)
    prefix <- fonti_description(fonti_prefix(page$path), page$title)
    table <- fonti_source_table(rows)
    list(path = page$path, lines = c(prefix, "<!-- Tabelle generate automaticamente. -->", "", table))
  })
}

check_fonti_section <- function(project_root, section, render_index) {
  project_root <- normalizePath(project_root, mustWork = TRUE)
  check_fonti_packages()
  packages <- c("tibble", "tidyr", if (render_index) c("tidyverse", "knitr", "here", "viridis"))
  missing <- packages[!vapply(packages, requireNamespace, logical(1), quietly = TRUE)]
  if (length(missing)) stop("Pacchetti R mancanti: ", paste(missing, collapse = ", "), call. = FALSE)
  font <- file.path(project_root, "static", "fonts", "merriweather-v13-latin-regular.woff")
  if (render_index && !file.exists(font)) {
    stop("Carattere Merriweather mancante: ", font, call. = FALSE)
  }
  root <- file.path(project_root, "content", "programmazione-storica")
  if (render_index) {
    read_fonti_csv(file.path(project_root, "static", "data", "programmazione_imdb.csv"),
                  c("Const", "Year", "Title", "Directors", "Genres", "IMDb Rating",
                    "Num Votes", "Runtime (mins)", "URL"))
    read_fonti_csv(file.path(project_root, "static", "data", "programmazione_paesi.csv"),
                  c("const", "country", "is_adult"))
    index <- file.path(root, section, "_index.Rmd")
    if (!file.exists(index)) {
      stop("File R Markdown mancante: ", index, call. = FALSE)
    }
  }
  invisible(project_root)
}

prepare_fonti_section <- function(project_root, section, column, render_index, selection = NULL) {
  project_root <- check_fonti_section(project_root, section, render_index)
  data <- load_fonti_data(project_root, section)
  directory <- file.path(project_root, "content", "programmazione-storica", section)
  prepare_fonti_pages(split_fonti_values(data, column), section, directory, selection)
}

write_fonti_pages <- function(pages) {
  for (page in pages) {
    dir.create(dirname(page$path), recursive = TRUE, showWarnings = FALSE)
    writeLines(enc2utf8(page$lines), page$path, useBytes = TRUE)
  }
  invisible(pages)
}

render_fonti_index <- function(project_root, section) {
    project_root <- normalizePath(project_root, mustWork = TRUE)
    root <- file.path(project_root, "content", "programmazione-storica")
    font <- file.path(project_root, "static", "fonts", "merriweather-v13-latin-regular.woff")
    previous_chunks <- knitr::opts_chunk$get()
    previous_knit <- knitr::opts_knit$get()
    previous_showtext <- showtext::showtext_opts()
    on.exit({
      do.call(knitr::opts_chunk$set, previous_chunks)
      do.call(knitr::opts_knit$set, previous_knit)
      do.call(showtext::showtext_opts, previous_showtext)
    }, add = TRUE)
    # La risoluzione di knitr e showtext deve coincidere per evitare testi ingranditi.
    knitr::opts_chunk$set(dpi = 96)
    showtext::showtext_opts(dpi = 96)
      input <- file.path(root, section, "_index.Rmd")
      output <- file.path(root, section, "_index.md")
      figure_dir <- file.path(project_root, "static", "programmazione-storica", section, "_index_files", "figure-html")
      dir.create(figure_dir, recursive = TRUE, showWarnings = FALSE)
      knitr::opts_chunk$set(fig.path = paste0(gsub("\\\\", "/", figure_dir), "/"))
      knitr::opts_knit$set(root.dir = project_root)
      temporary <- tempfile(fileext = ".md")
      # Usa i dati del progetto scelto e il font locale invece di scaricarlo.
      knit_env <- new.env(parent = globalenv())
      knit_env$here <- function(...) file.path(project_root, ...)
      knit_env$font_add_google <- function(name, family) sysfonts::font_add(family, font)
      knitr::knit(input, output = temporary, envir = knit_env, quiet = TRUE)
      lines <- readLines(temporary, encoding = "UTF-8", warn = FALSE)
      # Converte i percorsi locali dei grafici in indirizzi utilizzabili dal sito.
      lines <- gsub(paste0(gsub("\\\\", "/", figure_dir), "/"),
                    paste0("/programmazione-storica/", section, "/_index_files/figure-html/"),
                    lines, fixed = TRUE)
      writeLines(enc2utf8(lines), output, useBytes = TRUE)
      unlink(temporary)
}


update_fonti <- function(project_root = ".", render_index = TRUE, sources = NULL) {
  if (!render_index && is.character(sources) &&
      any(stringr::str_to_lower(stringr::str_trim(sources)) == "note_su_manifesti", na.rm = TRUE)) {
    stop("note_su_manifesti richiede render_index = TRUE.", call. = FALSE)
  }
  pages <- prepare_fonti_section(project_root, "fonti", "source", render_index, sources)
  write_fonti_pages(pages)
  if (render_index) render_fonti_index(project_root, "fonti")
  invisible(pages)
}

if (sys.nframe() == 0L) update_fonti()
