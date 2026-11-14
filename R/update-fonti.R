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

# Trova la prima immagine nella cartella statica per una fonte
find_first_image <- function(project_root, date_slug) {
  # date_slug è nel formato "1948_01_01_calendario_1948"
  image_dir <- file.path(project_root, "static", "images", date_slug)
  if (!dir.exists(image_dir)) {
    return(NA_character_)
  }
  
  # Cerca file immagine (png, jpg, webp)
  images <- list.files(
    image_dir,
    pattern = "\\.(png|jpg|jpeg|webp)$",
    ignore.case = TRUE,
    full.names = FALSE
  )
  
  if (length(images) == 0) {
    return(NA_character_)
  }
  
  # Restituisce il percorso Hugo della prima immagine (in ordine alfabetico)
  first_image <- sort(images)[1]
  paste0("/images/", date_slug, "/", first_image)
}

fonti_description <- function(prefix, title, project_root = NULL, date_slug = NULL) {
  boundary <- which(prefix == "---")[2]
  metadata <- yaml::yaml.load(paste(prefix[2:(boundary - 1)], collapse = "\n"))
  
  # Mantieni la description e image esistenti se valide
  new_fields <- list()
  
  # Mantieni la description esistente se valida, altrimenti non modificarla
  current_desc <- metadata$description
  if (is.character(current_desc) && length(current_desc) == 1L && 
      !is.na(current_desc) && nzchar(trimws(current_desc))) {
    # Descrizione già presente, non toccarla
  }
  
  # Aggiungi l'immagine se disponibile
  if (!is.null(project_root) && !is.null(date_slug)) {
    image_path <- find_first_image(project_root, date_slug)
    if (!is.na(image_path)) {
      new_fields$image <- image_path
    }
  }
  
  # Se non c'è niente da aggiungere, ritorna il prefix originale
  if (length(new_fields) == 0) {
    return(prefix)
  }
  
  # Trova se il campo image esiste già
  image_line_idx <- which(grepl("^image[[:space:]]*:", prefix[seq_len(boundary - 1)]))
  
  if (length(image_line_idx) == 0) {
    # Image non esiste, aggiungilo prima del marcatore "---" finale
    # Crea manualmente la riga YAML per l'immagine
    yaml_lines <- paste0("image: ", new_fields$image)
    return(append(prefix, yaml_lines, after = boundary - 1))
  } else if (length(image_line_idx) == 1) {
    # Image esiste, sostituiscilo
    new_prefix <- prefix
    new_prefix[image_line_idx] <- paste0("image: ", new_fields$image)
    return(new_prefix)
  }
  
  # Se ci sono più di un campo image, non modificare
  return(prefix)
}



# Prepara le pagine di una sezione in memoria, senza ancora scriverle su disco.
prepare_fonti_pages <- function(data, section, directory, project_root, selection = NULL) {
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
    # Estrae il date_slug dal percorso della cartella
    # Es: "/path/1948-01-01-calendario-1948/index.md" -> "1948_01_01_calendario_1948"
    folder_name <- basename(dirname(page$path))
    date_slug <- gsub("-", "_", folder_name)  # Converte i trattini in underscore
    prefix <- fonti_description(fonti_prefix(page$path), page$title, project_root, date_slug)
    table <- fonti_source_table(rows)
    list(path = page$path, lines = c(prefix, "<!-- Tabelle generate automaticamente. -->", "", table))
  })
}

check_fonti_section <- function(project_root, section) {
  project_root <- normalizePath(project_root, mustWork = TRUE)
  check_fonti_packages()
  packages <- c("tibble", "tidyr")
  missing <- packages[!vapply(packages, requireNamespace, logical(1), quietly = TRUE)]
  if (length(missing)) stop("Pacchetti R mancanti: ", paste(missing, collapse = ", "), call. = FALSE)
  invisible(project_root)
}

prepare_fonti_section <- function(project_root, section, column, selection = NULL) {
  project_root <- check_fonti_section(project_root, section)
  data <- load_fonti_data(project_root, section)
  directory <- file.path(project_root, "content", "programmazione-storica", section)
  prepare_fonti_pages(split_fonti_values(data, column), section, directory, project_root, selection)
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


update_fonti <- function(project_root = ".", sources = NULL) {
  pages <- prepare_fonti_section(project_root, "fonti", "source", selection = sources)
  write_fonti_pages(pages)
  invisible(pages)
}

# Esegui: update_fonti()
# Oppure per una fonte specifica: update_fonti(sources = "Calendario 1948")
