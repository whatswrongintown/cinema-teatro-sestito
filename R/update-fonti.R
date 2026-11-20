# Controlla che i pacchetti necessari siano installati prima di generare le pagine.
# Oltre a R base servono yaml (metadati delle schede) e showtext/sysfonts (font nei grafici).
check_fonti_packages <- function() {
  packages <- c("yaml", "showtext", "sysfonts")
  missing <- packages[!vapply(packages, requireNamespace, logical(1), quietly = TRUE)]
  if (length(missing)) {
    stop("Pacchetti R mancanti: ", paste(missing, collapse = ", "), call. = FALSE)
  }
}

# Legge un CSV come testo e controlla che non contenga errori o colonne mancanti.
read_fonti_csv <- function(path, required) {
  data <- tryCatch(
    utils::read.csv(
      path, colClasses = "character", na.strings = c("", "NA"), check.names = FALSE,
      strip.white = TRUE, fill = FALSE, comment.char = "", encoding = "UTF-8",
      stringsAsFactors = FALSE
    ),
    error = function(error) stop("CSV non valido: ", path, call. = FALSE)
  )
  names(data) <- sub("^\ufeff", "", names(data))
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

fonti_trim <- function(x) trimws(x, whitespace = "[\\h\\v]")

# Valori con cui il database puo' indicare le "Note sui manifesti". Tutti puntano alla
# stessa scheda, che puo' avere uno qualsiasi di questi titoli (maiuscole escluse).
fonti_manifesti <- c("note sui manifesti", "note su manifesti", "note_su_manifesti",
                     "note su manifesto", "note_su_manifesto", "nota_su_manifesto")

# Chiave della scheda delle note sui manifesti: quella della scheda esistente oppure,
# se non c'e' ancora, "note sui manifesti".
fonti_manifesti_key <- function(page_keys) {
  existing <- page_keys[page_keys %in% fonti_manifesti]
  if (length(existing) > 1) {
    stop("Piu' schede per le note sui manifesti: ", paste(existing, collapse = ", "),
         call. = FALSE)
  }
  if (length(existing)) existing else fonti_manifesti[1]
}

# Riconduce tutti i modi di scrivere le note sui manifesti alla stessa chiave e allo
# stesso nome; una proiezione che li elenca piu' volte conta una sola volta.
fonti_merge_manifesti <- function(data, pages) {
  hit <- data$key %in% fonti_manifesti
  if (!any(hit)) {
    return(data)
  }
  key <- fonti_manifesti_key(pages$key)
  data$key[hit] <- key
  data$value[hit] <- if (key %in% pages$key) pages$title[match(key, pages$key)] else "Note sui manifesti"
  data[!duplicated(paste(data$screening_id, data$key, sep = "\r")), , drop = FALSE]
}

fonti_cache <- new.env(parent = emptyenv())

# Carica le proiezioni e i dati IMDb, verifica i valori e li unisce per film.
# Il risultato resta in memoria finche' i file CSV non cambiano.
load_fonti_screenings <- function(project_root) {
  directory <- file.path(project_root, "static", "data")
  paths <- file.path(directory, c("programmazione_agende.csv", "programmazione_imdb.csv"))
  info <- file.info(paths)
  signature <- paste(normalizePath(paths, mustWork = FALSE), info$size,
                     as.numeric(info$mtime), collapse = "|")
  if (identical(fonti_cache$signature, signature)) {
    return(fonti_cache$data)
  }
  screenings <- read_fonti_csv(paths[1], c("date", "const", "title", "source"))
  imdb <- read_fonti_csv(paths[2], c("Const", "IMDb Rating", "Num Votes", "URL"))
  if (!nrow(screenings)) {
    stop("Il database delle proiezioni e' vuoto.", call. = FALSE)
  }
  for (column in c("date", "title", "source")) {
    if (any(is.na(screenings[[column]]) | !nzchar(trimws(screenings[[column]])))) {
      stop("Valori mancanti nella colonna delle proiezioni: ", column, call. = FALSE)
    }
  }
  missing_const_count <- sum(is.na(screenings$const) | !nzchar(trimws(screenings$const)))
  if (missing_const_count > 0) {
    warning(missing_const_count,
            " proiezioni senza identificativo IMDb: i titoli appariranno senza collegamento.",
            call. = FALSE)
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
  rating <- suppressWarnings(as.numeric(imdb[["IMDb Rating"]]))
  votes <- suppressWarnings(as.numeric(imdb[["Num Votes"]]))
  if (any(!is.na(imdb[["IMDb Rating"]]) & !is.finite(rating)) ||
      any(!is.na(imdb[["Num Votes"]]) & !is.finite(votes)) ||
      any(rating < 0 | rating > 10, na.rm = TRUE) ||
      any(votes < 0 | votes != floor(votes), na.rm = TRUE)) {
    stop("Valutazioni o numeri di voti IMDb non validi.", call. = FALSE)
  }
  # Aggiunge anno, mese e URL IMDb a ogni proiezione, mantenendo le ripetizioni.
  has_const <- !is.na(screenings$const) & nzchar(trimws(screenings$const))
  screenings$date_text <- screenings$date
  screenings$date <- dates
  screenings$anno <- as.integer(substr(screenings$date_text, 1L, 4L))
  screenings$mese <- as.integer(substr(screenings$date_text, 6L, 7L))
  screenings$url <- NA_character_
  screenings$url[has_const] <- imdb$URL[match(screenings$const[has_const], imdb$Const)]
  missing_url_count <- sum(is.na(screenings$url) | !nzchar(screenings$url))
  if (missing_url_count > 0) {
    warning(missing_url_count,
            " proiezioni senza URL IMDb: il titolo restera' senza collegamento.",
            call. = FALSE)
  }
  screenings <- screenings[order(screenings$date), , drop = FALSE]
  rownames(screenings) <- NULL
  fonti_cache$signature <- signature
  fonti_cache$data <- screenings
  screenings
}

# Legge titolo e percorso delle pagine esistenti nella sezione indicata.
read_fonti_pages <- function(directory) {
  files <- list.files(directory, pattern = "^index\\.md$", recursive = TRUE,
                      full.names = TRUE)
  titles <- vapply(files, function(path) {
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
    metadata$title
  }, character(1), USE.NAMES = FALSE)
  data.frame(path = files, title = titles, key = tolower(fonti_trim(titles)),
             stringsAsFactors = FALSE)
}

# Separa fonti, generi o paesi elencati nella stessa cella del database.
split_fonti_values <- function(data, column) {
  # Crea una riga per valore, elimina spazi e valori vuoti e rimuove i duplicati
  # dello stesso valore per la stessa proiezione.
  pieces <- strsplit(data[[column]], ",", fixed = TRUE)
  row <- rep.int(seq_len(nrow(data)), lengths(pieces))
  value <- fonti_trim(unlist(pieces, use.names = FALSE))
  keep <- !is.na(value) & nzchar(value)
  row <- row[keep]
  value <- value[keep]
  key <- tolower(value)
  keep <- !duplicated(paste(data$screening_id[row], key, sep = "\r"))
  result <- data[row[keep], , drop = FALSE]
  result$value <- value[keep]
  result$key <- key[keep]
  result
}

load_fonti_data <- function(project_root, section = NULL) {
  data <- load_fonti_screenings(project_root)
  data$screening_id <- seq_len(nrow(data))
  # Riga della tabella Markdown: data e titolo, con il collegamento IMDb se presente.
  title <- escape_fonti_text(data$title)
  linked <- !is.na(data$url) & nzchar(data$url)
  title[linked] <- paste0("[", title[linked], "](", data$url[linked], ")")
  data$row_text <- paste0("| ", data$date_text, " | ", title, " |")
  data
}

# Costruisce le tabelle Markdown di una fonte, per mese e, se serve, anche per anno.
fonti_source_table <- function(data) {
  months <- c("Gennaio", "Febbraio", "Marzo", "Aprile", "Maggio", "Giugno",
              "Luglio", "Agosto", "Settembre", "Ottobre", "Novembre", "Dicembre")
  by_year <- split(seq_len(nrow(data)), data$anno)
  unlist(lapply(names(by_year), function(year) {
    rows <- data[by_year[[year]], , drop = FALSE]
    by_month <- split(rows$row_text, rows$mese)
    tables <- unlist(lapply(names(by_month), function(month) {
      c(paste("###", months[as.integer(month)]), "", "|  |  |", "|---|---|",
        by_month[[month]], "")
    }), use.names = FALSE)
    c(if (length(by_year) > 1) c(paste("##", year), ""), tables)
  }), use.names = FALSE)
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

# Trova la prima immagine nella cartella statica per una fonte.
# date_slug ha il formato "1948_01_01_calendario_1948".
find_first_image <- function(project_root, date_slug) {
  image_dir <- file.path(project_root, "static", "images", "programmazione_storica", date_slug)
  if (!dir.exists(image_dir)) {
    return(NA_character_)
  }
  images <- list.files(image_dir, pattern = "\\.(png|jpg|jpeg|webp)$",
                       ignore.case = TRUE, full.names = FALSE)
  if (!length(images)) {
    return(NA_character_)
  }
  # Restituisce il percorso Hugo della prima immagine, in ordine alfabetico.
  paste0("/images/programmazione_storica/", date_slug, "/", sort(images)[1])
}

# Aggiunge o aggiorna il campo image nei metadati quando la cartella delle immagini esiste.
fonti_description <- function(prefix, title, project_root = NULL, date_slug = NULL) {
  if (is.null(project_root) || is.null(date_slug)) {
    return(prefix)
  }
  image_path <- find_first_image(project_root, date_slug)
  if (is.na(image_path)) {
    return(prefix)
  }
  boundary <- which(prefix == "---")[2]
  image_line_idx <- which(grepl("^image[[:space:]]*:", prefix[seq_len(boundary - 1)]))
  replacement <- paste0("image: ", image_path)
  if (!length(image_line_idx)) {
    return(append(prefix, replacement, after = boundary - 1))
  }
  # Con piu' campi image non modifica i metadati.
  if (length(image_line_idx) == 1) {
    prefix[image_line_idx] <- replacement
  }
  prefix
}

# Nomi dei PDF verificati rispetto alle scansioni delle quattro gallerie originali.
fonti_gallery_exceptions <- c(
  "1968_11_01_morganite_1968_69" = "1968_11_01_carboni_morganite_1968_69",
  "1969_11_01_lorraine_1969_70" = "1969_11_01_carboni_lorraine_1969_70",
  "1970_12_01_lorraine_1970_71" = "1970_12_01_carboni_lorraine_1970_71",
  "1994_10_01_appunti_new_europe_1994_95" = "1994_10_01_appunti_new_europe_1994_94"
)

fonti_gallery_images <- function(directory) {
  if (!dir.exists(directory)) return(character())
  files <- list.files(directory, pattern = "\\.(png|jpe?g|webp|gif|bmp|tiff?)$",
                      ignore.case = TRUE)
  files[!dir.exists(file.path(directory, files))]
}

# Conserva il testo editoriale e aggiorna soltanto i riferimenti a una galleria verificata.
fonti_gallery_prefix <- function(prefix, image_root, page_path) {
  gallery_lines <- grep("\\{\\{[<%][[:space:]]*image-gallery\\b", prefix, perl = TRUE)
  if (!length(gallery_lines)) return(list(prefix = prefix, gallery = FALSE, slug = NULL))
  if (length(gallery_lines) != 1L) {
    warning("Gallerie multiple non aggiornate in ", page_path, call. = FALSE)
    return(list(prefix = prefix, gallery = TRUE, slug = NULL))
  }
  line <- gallery_lines[1]
  match <- regexec("gallery_dir[[:space:]]*=[[:space:]]*['\"]([^'\"]+)['\"]",
                   prefix[line], perl = TRUE)
  parts <- regmatches(prefix[line], match)[[1]]
  if (length(parts) != 2L) {
    warning("Percorso della galleria non riconosciuto in ", page_path, call. = FALSE)
    return(list(prefix = prefix, gallery = TRUE, slug = NULL))
  }
  old_path <- parts[2]
  new_root <- file.path(image_root, "programmazione_storica")
  new_prefix <- "/images/programmazione_storica/"
  boundary <- which(prefix == "---")[2]
  metadata <- yaml::yaml.load(paste(prefix[2:(boundary - 1L)], collapse = "\n"))
  descriptions <- metadata$galleryDescriptions
  if (grepl("^/images/programmazione_storica/[^/]+$", old_path)) {
    slug <- basename(old_path)
    if (!length(fonti_gallery_images(file.path(new_root, slug))) ||
        (!is.null(descriptions) && !old_path %in% names(descriptions))) {
      warning("Galleria senza immagini o descrizione corrispondente: ",
              old_path, " in ", page_path, call. = FALSE)
      slug <- NULL
    }
    return(list(prefix = prefix, gallery = TRUE, slug = slug))
  }
  if (!grepl("^/images/[^/]+$", old_path)) {
    warning("Percorso della galleria non riconosciuto: ", old_path, call. = FALSE)
    return(list(prefix = prefix, gallery = TRUE, slug = NULL))
  }
  old_slug <- basename(old_path)
  old_files <- fonti_gallery_images(file.path(image_root, old_slug))
  folders <- list.dirs(new_root, full.names = FALSE, recursive = FALSE)
  stems <- sub("_[0-9]+$", "", tools::file_path_sans_ext(old_files))
  if (old_slug %in% names(fonti_gallery_exceptions)) {
    candidates <- intersect(unname(fonti_gallery_exceptions[old_slug]), folders)
  } else if (old_slug %in% folders) {
    candidates <- old_slug
  } else {
    candidates <- intersect(unique(stems), folders)
  }
  if (length(candidates) != 1L || !length(old_files) ||
      length(fonti_gallery_images(file.path(new_root, candidates[1]))) != length(old_files)) {
    warning("Galleria non aggiornata (corrispondenza mancante, ambigua o incompleta): ",
            old_path, " in ", page_path, call. = FALSE)
    return(list(prefix = prefix, gallery = TRUE, slug = NULL))
  }
  slug <- candidates[1]
  new_path <- paste0(new_prefix, slug)
  if (!is.null(descriptions) && !old_path %in% names(descriptions) &&
      !new_path %in% names(descriptions)) {
    warning("Descrizione della galleria non trovata: ", old_path, " in ",
            page_path, call. = FALSE)
    return(list(prefix = prefix, gallery = TRUE, slug = NULL))
  }
  if (!is.null(descriptions) && old_path %in% names(descriptions)) {
    if (length(descriptions[[old_path]]$images)) {
      warning("Galleria con descrizioni per immagine da aggiornare manualmente: ",
              old_path, " in ", page_path, call. = FALSE)
      return(list(prefix = prefix, gallery = TRUE, slug = NULL))
    }
    if (new_path %in% names(descriptions)) {
      stop("Descrizioni duplicate per la galleria in ", page_path, call. = FALSE)
    }
    keys <- c(paste0(old_path, ":"), paste0('"', old_path, '":'),
              paste0("'", old_path, "':"))
    key_lines <- which(trimws(prefix[seq_len(boundary - 1L)]) %in% keys)
    if (length(key_lines) != 1L) {
      stop("Chiave galleryDescriptions non riconosciuta in ", page_path, call. = FALSE)
    }
    prefix[key_lines] <- sub(old_path, new_path, prefix[key_lines], fixed = TRUE)
  }
  prefix[line] <- sub(old_path, new_path, prefix[line], fixed = TRUE)
  list(prefix = prefix, gallery = TRUE, slug = slug)
}

# Crea automaticamente una pagina di fonte mancante con titolo e metadata di base.
create_missing_fonti_page <- function(value, directory, project_root) {
  # Genera slug dal titolo: convert to lowercase, replace spaces/special chars with hyphens
  slug <- tolower(fonti_trim(value))
  slug <- gsub("[^a-z0-9]+", "-", slug)
  slug <- sub("^-|-$", "", slug)
  
  # Usa la data della prima proiezione di questa fonte come data della pagina
  date_text <- "1965-01-01"
  folder_name <- paste0(date_text, "-", slug)
  page_path <- file.path(directory, folder_name, "index.md")
  
  # Crea la cartella
  dir.create(dirname(page_path), recursive = TRUE, showWarnings = FALSE)
  
  # Front matter template
  front_matter <- paste0(
    "---\n",
    "title: ", value, "\n",
    "author: Vito Sestito\n",
    "date: '", date_text, "'\n",
    "slug: ", slug, "\n",
    "categories:\n",
    "  - ", value, "\n",
    "description: Screenings from this source in the cinema archive.\n",
    "---\n",
    "\n",
    "<!-- Tabelle generate automaticamente. -->\n"
  )
  
  # Scrivi il file
  writeLines(enc2utf8(front_matter), page_path, useBytes = TRUE)
  
  # Restituisci il titolo della pagina creata
  message("Creata automaticamente pagina: ", page_path)
  value
}

# Prepara le pagine di una sezione in memoria, senza ancora scriverle su disco.
prepare_fonti_pages <- function(data, section, directory, project_root, selection = NULL) {
  pages <- read_fonti_pages(directory)
  if (anyDuplicated(pages$key)) {
    stop("Titoli duplicati in ", directory, call. = FALSE)
  }
  data <- fonti_merge_manifesti(data, pages)
  if (!is.null(selection)) {
    if (!is.character(selection) || !length(selection) || anyNA(selection) ||
        any(!nzchar(trimws(selection)))) {
      stop("Specificare uno o piu nomi non vuoti per ", section, ".", call. = FALSE)
    }
    keys <- unique(tolower(fonti_trim(selection)))
    keys[keys %in% fonti_manifesti] <- fonti_manifesti_key(pages$key)
    keys <- unique(keys)
    unknown_keys <- setdiff(keys, union(pages$key, data$key))
    if (length(unknown_keys)) {
      stop("Nomi non trovati in ", section, ": ", paste(unknown_keys, collapse = ", "), call. = FALSE)
    }
    pages <- pages[pages$key %in% keys, , drop = FALSE]
    data <- data[data$key %in% keys, , drop = FALSE]
  }
  values <- data[!duplicated(paste(data$key, data$value, sep = "\r")), c("key", "value")]
  if (anyDuplicated(values$key)) {
    stop("Nomi ambigui in ", section, call. = FALSE)
  }
  unknown <- values$value[!values$key %in% pages$key]
  if (length(unknown)) {
    # Auto-crea le pagine mancanti
    for (val in unknown) {
      create_missing_fonti_page(val, directory, project_root)
    }
    # Rileggi le pagine dopo aver creato le nuove
    pages <- read_fonti_pages(directory)
  }
  # Mantiene la parte iniziale delle pagine esistenti e sostituisce le tabelle.
  by_key <- split(seq_len(nrow(data)), data$key)
  lapply(seq_len(nrow(pages)), function(index) {
    path <- pages$path[index]
    rows <- data[by_key[[pages$key[index]]], , drop = FALSE]
    # Il percorso della cartella, ad esempio "1948-01-01-calendario-1948", diventa
    # il nome della cartella delle immagini "1948_01_01_calendario_1948".
    date_slug <- gsub("-", "_", basename(dirname(path)), fixed = TRUE)
    gallery <- fonti_gallery_prefix(fonti_prefix(path),
                                    file.path(project_root, "static", "images"), path)
    prefix <- gallery$prefix
    if (!gallery$gallery || !is.null(gallery$slug)) {
      image_slug <- if (gallery$gallery) gallery$slug else date_slug
      prefix <- fonti_description(prefix, pages$title[index], project_root, image_slug)
    }
    list(path = path, lines = c(prefix, "<!-- Tabelle generate automaticamente. -->", "",
                                fonti_source_table(rows)))
  })
}

check_fonti_section <- function(project_root, section) {
  project_root <- normalizePath(project_root, mustWork = TRUE)
  check_fonti_packages()
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

update_fonti <- function(project_root = ".", sources = NULL) {
  pages <- prepare_fonti_section(project_root, "fonti", "source", selection = sources)
  write_fonti_pages(pages)
  if (is.null(sources)) update_fonti_index(project_root)
  invisible(pages)
}

# Rigenera il grafico della pagina indice della sezione (vedi R/update-indici.R).
update_fonti_index <- function(project_root = ".") {
  helpers <- new.env(parent = globalenv())
  sys.source(file.path(project_root, "R", "update-indici.R"), envir = helpers)
  helpers$update_indici(project_root, "fonti")
}

# Esegui: update_fonti()
# Oppure per una fonte specifica: update_fonti(sources = "Calendario 1948")
if (sys.nframe() == 0L) update_fonti()
