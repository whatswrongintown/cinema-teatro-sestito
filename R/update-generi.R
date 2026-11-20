# Controlla che i pacchetti necessari siano installati prima di generare le pagine.
# Oltre a R base servono yaml (metadati delle schede) e showtext/sysfonts (font nei grafici).
check_generi_packages <- function() {
  packages <- c("yaml", "showtext", "sysfonts")
  missing <- packages[!vapply(packages, requireNamespace, logical(1), quietly = TRUE)]
  if (length(missing)) {
    stop("Pacchetti R mancanti: ", paste(missing, collapse = ", "), call. = FALSE)
  }
}

# Legge un CSV come testo e controlla che non contenga errori o colonne mancanti.
read_generi_csv <- function(path, required) {
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

generi_trim <- function(x) trimws(x, whitespace = "[\\h\\v]")

generi_cache <- new.env(parent = emptyenv())

# Carica le proiezioni e i dati IMDb, verifica i valori e li unisce per film.
# Il risultato resta in memoria finche' i file CSV non cambiano.
load_generi_screenings <- function(project_root) {
  directory <- file.path(project_root, "static", "data")
  paths <- file.path(directory, c("programmazione_agende.csv", "programmazione_imdb.csv"))
  info <- file.info(paths)
  signature <- paste(normalizePath(paths, mustWork = FALSE), info$size,
                     as.numeric(info$mtime), collapse = "|")
  if (identical(generi_cache$signature, signature)) {
    return(generi_cache$data)
  }
  screenings <- read_generi_csv(paths[1], c("date", "const", "title", "source"))
  imdb <- read_generi_csv(paths[2], c("Const", "IMDb Rating", "Num Votes", "URL", "Genres"))
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
  # Aggiunge anno, mese, URL e generi IMDb a ogni proiezione, mantenendo le ripetizioni.
  has_const <- !is.na(screenings$const) & nzchar(trimws(screenings$const))
  position <- rep(NA_integer_, nrow(screenings))
  position[has_const] <- match(screenings$const[has_const], imdb$Const)
  screenings$date_text <- screenings$date
  screenings$date <- dates
  screenings$anno <- as.integer(substr(screenings$date_text, 1L, 4L))
  screenings$mese <- as.integer(substr(screenings$date_text, 6L, 7L))
  screenings$url <- imdb$URL[position]
  screenings$genres <- imdb$Genres[position]
  missing_url_count <- sum(is.na(screenings$url) | !nzchar(screenings$url))
  if (missing_url_count > 0) {
    warning(missing_url_count,
            " proiezioni senza URL IMDb: il titolo restera' senza collegamento.",
            call. = FALSE)
  }
  screenings <- screenings[order(screenings$date), , drop = FALSE]
  rownames(screenings) <- NULL
  generi_cache$signature <- signature
  generi_cache$data <- screenings
  screenings
}

# Legge titolo e percorso delle pagine esistenti nella sezione indicata.
read_generi_pages <- function(directory) {
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
  data.frame(path = files, title = titles, key = tolower(generi_trim(titles)),
             stringsAsFactors = FALSE)
}

# Separa fonti, generi o paesi elencati nella stessa cella del database.
split_generi_values <- function(data, column) {
  # Crea una riga per valore, elimina spazi e valori vuoti e rimuove i duplicati
  # dello stesso valore per la stessa proiezione.
  pieces <- strsplit(data[[column]], ",", fixed = TRUE)
  row <- rep.int(seq_len(nrow(data)), lengths(pieces))
  value <- generi_trim(unlist(pieces, use.names = FALSE))
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

load_generi_data <- function(project_root, section = NULL) {
  data <- load_generi_screenings(project_root)
  data$screening_id <- seq_len(nrow(data))
  # Riga della tabella Markdown: data e titolo, con il collegamento IMDb se presente.
  title <- escape_generi_text(data$title)
  linked <- !is.na(data$url) & nzchar(data$url)
  title[linked] <- paste0("[", title[linked], "](", data$url[linked], ")")
  data$row_text <- paste0("| ", data$date_text, " | ", title, " |")
  data
}

# Costruisce una tabella Markdown per ogni anno.
generi_table <- function(data) {
  by_year <- split(data$row_text, data$anno)
  unlist(lapply(names(by_year), function(year) {
    c(paste("###", year), "", "|  |  |", "|---|---|", by_year[[year]], "")
  }), use.names = FALSE)
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
  slug <- gsub("^-|-$", "", gsub("[^a-z0-9]+", "-", tolower(ascii)))
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
    keys <- unique(tolower(generi_trim(selection)))
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
  unknown <- values[!values$key %in% pages$key, , drop = FALSE]
  if (nrow(unknown)) {
    unknown$path <- file.path(directory, generi_slug(unknown$value), "index.md")
    if (anyDuplicated(unknown$path) || any(unknown$path %in% pages$path) ||
        any(file.exists(unknown$path))) {
      stop("Slug duplicato o pagina esistente in ", section, call. = FALSE)
    }
    pages <- rbind(pages, data.frame(path = unknown$path, title = unknown$value,
                                     key = unknown$key, stringsAsFactors = FALSE))
  }
  # Mantiene la parte iniziale delle pagine esistenti e sostituisce le tabelle.
  by_key <- split(seq_len(nrow(data)), data$key)
  lapply(seq_len(nrow(pages)), function(index) {
    path <- pages$path[index]
    title <- pages$title[index]
    rows <- data[by_key[[pages$key[index]]], , drop = FALSE]
    if (file.exists(path)) {
      prefix <- generi_prefix(path)
      prefix <- generi_permalink(prefix, basename(dirname(path)))
      prefix <- generi_description(prefix, title)
    } else {
      slug <- basename(dirname(path))
      metadata <- list(title = title, author = "Vito Sestito", slug = slug,
                       url = paste0("/programmazione-storica/generi/", slug, "/"),
                       categories = list("Generi"),
                       tags = list("Programmazione"),
                       description = paste0("Film di genere ", title, " nella programmazione del Cinema Teatro Sestito, suddivisi per anno."))
      prefix <- c("---", strsplit(yaml::as.yaml(metadata), "\n", fixed = TRUE)[[1]], "---", "")
    }
    prefix <- generi_image(prefix)
    list(path = path, lines = c(prefix, "<!-- Tabelle generate automaticamente. -->", "",
                                generi_table(rows)))
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
  if (is.null(genres)) update_generi_index(project_root)
  invisible(pages)
}

# Rigenera i grafici della pagina indice della sezione (vedi R/update-indici.R).
update_generi_index <- function(project_root = ".") {
  helpers <- new.env(parent = globalenv())
  sys.source(file.path(project_root, "R", "update-indici.R"), envir = helpers)
  helpers$update_indici(project_root, "generi")
}

if (sys.nframe() == 0L) update_generi()
