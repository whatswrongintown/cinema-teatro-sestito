# Controlla che i pacchetti necessari siano installati prima di generare le pagine.
check_anni_packages <- function() {
  packages <- c("readr", "dplyr", "purrr", "stringr", "ggplot2", "ggrepel", "scales", "yaml", "showtext")
  missing <- packages[!vapply(packages, requireNamespace, logical(1), quietly = TRUE)]
  if (length(missing)) {
    stop("Pacchetti R mancanti: ", paste(missing, collapse = ", "), call. = FALSE)
  }
}

# Legge un CSV come testo e controlla che non contenga errori o colonne mancanti.
read_anni_csv <- function(path, required) {
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
escape_anni_text <- function(text) {
  replacements <- c("&" = "&amp;", "<" = "&lt;", ">" = "&gt;", "|" = "&#124;")
  for (character in names(replacements)) {
    text <- gsub(character, replacements[[character]], text, fixed = TRUE)
  }
  for (character in c("\\", "[", "]", "*", "_", "`")) {
    text <- gsub(character, paste0("\\", character), text, fixed = TRUE)
  }
  gsub("[\r\n]", " ", text)
}

# Legge i titoli delle schede fonte e prepara i collegamenti Hugo per le note.
read_anni_sources <- function(project_root) {
  directory <- file.path(project_root, "content", "programmazione-storica", "fonti")
  files <- list.files(directory, pattern = "^index\\.md$", recursive = TRUE,
                      full.names = TRUE)
  # Il titolo si trova nei metadati YAML all'inizio di ogni scheda.
  sources <- purrr::map(files, function(path) {
    lines <- readLines(path, encoding = "UTF-8", warn = FALSE)
    boundaries <- which(lines == "---")
    if (length(boundaries) < 2L || boundaries[1] != 1L) {
      stop("Front matter non valido: ", path, call. = FALSE)
    }
    metadata <- yaml::yaml.load(paste(lines[2:(boundaries[2] - 1L)], collapse = "\n"))
    if (!is.character(metadata$title) || length(metadata$title) != 1L ||
        is.na(metadata$title) || !nzchar(trimws(metadata$title))) {
      stop("Titolo della fonte mancante: ", path, call. = FALSE)
    }
    reference <- paste(
      "programmazione-storica", "fonti", basename(dirname(path)), "index.md",
      sep = "/"
    )
    data.frame(
      key = stringr::str_to_lower(stringr::str_trim(metadata$title)),
      link = paste0("[", escape_anni_text(metadata$title), "]({{< relref \"",
                    reference, "\" >}})"),
      stringsAsFactors = FALSE
    )
  })
  sources <- dplyr::bind_rows(c(sources, list(data.frame(
    key = "note_su_manifesti",
    link = '[Note sui manifesti]({{< relref "programmazione-storica/fonti/_index.md" >}}#note-sui-manifesti)',
    stringsAsFactors = FALSE
  ))))
  if (anyDuplicated(sources$key)) {
    stop("Titoli delle fonti duplicati: impossibile risolvere i collegamenti.",
         call. = FALSE)
  }
  stats::setNames(sources$link, sources$key)
}

# Carica le proiezioni e i dati IMDb, verifica i valori e li unisce per film.
load_anni_data <- function(project_root) {
  directory <- file.path(project_root, "static", "data")
  screenings <- read_anni_csv(
    file.path(directory, "programmazione_agende.csv"),
    c("date", "const", "title", "source")
  )
  imdb <- read_anni_csv(
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

# Crea i due grafici di un anno: proiezioni per mese e valutazioni IMDb.
anni_charts <- function(screenings, year, months) {
  sysfonts::font_add_google("Merriweather", "merriweather")
  showtext::showtext_auto()
  theme <- ggplot2::theme_classic(base_family = "merriweather") +
    ggplot2::theme(
      plot.subtitle = ggplot2::element_text(size = 11),
      axis.title = ggplot2::element_text(size = 11),
      axis.text = ggplot2::element_text(size = 8),
      panel.grid.major = ggplot2::element_blank(),
      panel.grid.minor = ggplot2::element_blank(),
      plot.margin = ggplot2::margin(t = 20, r = 10, b = 10, l = 10)
    )
  # Conta le proiezioni registrate in ogni mese, non i titoli distinti.
  counts <- screenings |>
    dplyr::count(mese, name = "n") |>
    dplyr::mutate(
      month = factor(months[mese], levels = months[sort(unique(mese))])
    )
  monthly <- ggplot2::ggplot(counts, ggplot2::aes(x = month, y = n)) +
    ggplot2::geom_col(fill = "#CBF8DF") +
    ggplot2::geom_text(ggplot2::aes(label = n), vjust = -0.5, size = 3) +
    ggplot2::labs(
      y = "Numero di proiezioni", x = "",
      subtitle = paste("Totale proiezioni:", nrow(screenings))
    ) +
    theme +
    ggplot2::coord_cartesian(clip = "off")

  # Il grafico logaritmico usa solo valutazioni valide e numeri di voti positivi.
  rated <- screenings |>
    dplyr::filter(
      is.finite(imdb_rating), is.finite(imdb_votes), imdb_votes > 0
    )
  scatter <- ggplot2::ggplot(
    rated, ggplot2::aes(x = imdb_votes, y = imdb_rating)
  ) +
    ggplot2::geom_point(colour = "#CBF8DF", size = 2) +
    ggrepel::geom_text_repel(
      ggplot2::aes(label = title), size = 3, seed = year, max.time = Inf
    ) +
    ggplot2::scale_x_log10(labels = scales::label_comma()) +
    ggplot2::scale_y_continuous(breaks = 1:10) +
    ggplot2::labs(
      y = "Valutazioni medie IMDb", x = "Numero di voti (log)",
      caption = "Information courtesy of IMDb (https://www.imdb.com)"
    ) +
    theme +
    ggplot2::coord_cartesian(clip = "off")
  # Se non ci sono dati IMDb utilizzabili, mostra un messaggio al posto del grafico.
  if (!nrow(rated)) {
    warning("Nessun dato IMDb utilizzabile per il grafico del ", year, ".",
            call. = FALSE)
    scatter <- ggplot2::ggplot() +
      ggplot2::annotate(
        "text", x = 0, y = 0, label = "Dati IMDb non disponibili",
        family = "merriweather"
      ) +
      ggplot2::theme_void(base_family = "merriweather")
  }
  list(monthly = monthly, imdb = scatter)
}

# Genera le pagine annuali per tutti gli anni disponibili o per quelli richiesti.
generate_anni <- function(project_root = ".", years = NULL,
                          output_dir = file.path(
                            project_root, "content", "programmazione-storica", "anni"
                          )) {
  check_anni_packages()
  project_root <- normalizePath(project_root, mustWork = TRUE)
  screenings <- load_anni_data(project_root)
  available_years <- screenings |>
    dplyr::distinct(anno) |>
    dplyr::arrange(anno) |>
    dplyr::pull(anno)
  if (is.null(years)) {
    years <- available_years
  } else if (!is.numeric(years) || !length(years) || anyNA(years) ||
             any(!is.finite(years)) || any(years != floor(years)) ||
             any(!years %in% available_years)) {
    stop("Specificare anni interi presenti nel database.", call. = FALSE)
  }
  years <- sort(unique(as.integer(years)))
  # Verifica le schede fonte prima di scrivere pagine o grafici.
  source_links <- read_anni_sources(project_root)
  source_names <- screenings |>
    dplyr::filter(anno %in% years) |>
    dplyr::pull(source) |>
    stringr::str_split(",") |>
    unlist() |>
    stringr::str_trim() |>
    unique()
  unknown <- source_names[!stringr::str_to_lower(source_names) %in% names(source_links)]
  if (length(unknown)) {
    stop("Schede fonte mancanti per: ", paste(unknown, collapse = ", "),
         call. = FALSE)
  }
  months <- c(
    "Gennaio", "Febbraio", "Marzo", "Aprile", "Maggio", "Giugno",
    "Luglio", "Agosto", "Settembre", "Ottobre", "Novembre", "Dicembre"
  )
  pages <- character()
  previous_showtext <- showtext::showtext_opts()
  on.exit(do.call(showtext::showtext_opts, previous_showtext), add = TRUE)
  showtext::showtext_opts(dpi = 200)
  # Per ogni anno salva i grafici e costruisce la relativa pagina Markdown.
  for (year in years) {
    data <- screenings |>
      dplyr::filter(anno == year)
    directory <- file.path(output_dir, sprintf("%d-01-01-programmazione-%d", year, year))
    images <- file.path(directory, "index_files", "figure-html")
    if (!dir.exists(images) && !dir.create(images, recursive = TRUE)) {
      stop("Impossibile creare la cartella: ", images, call. = FALSE)
    }
    charts <- anni_charts(data, year, months)
    filenames <- c("proiezioni-mensili.png", "valutazioni-imdb.png")
    for (i in seq_along(charts)) {
      ggplot2::ggsave(
        file.path(images, filenames[i]), plot = charts[[i]],
        device = "png", width = 8, height = 3, units = "in", dpi = 200, bg = "white"
      )
    }
    # Prepara i metadati Hugo, le immagini e le informazioni iniziali della pagina.
    lines <- c(
      "---", paste("title: Programmazione", year), "author: Vito Sestito",
      sprintf("date: '%d-01-01'", year), paste0("slug: programmazione-", year),
      paste0("description: Programmazione cinematografica del Cinema Teatro Sestito nel ", year, "."),
      "categories:", "  - programmazione-per-anni", "params:",
      paste("  anno:", year), "---", "",
      "<!-- Generato da R/update-anni.R; modificare i dati, non questa pagina. -->", "",
      '<img src="index_files/figure-html/proiezioni-mensili.png" width="768" alt="Proiezioni documentate per mese" />',
      '<img src="index_files/figure-html/valutazioni-imdb.png" width="768" alt="Valutazioni medie IMDb e numero di voti" />',
      "",
      "I grafici riassumono le voci di programmazione associate alle date nel database, non il numero delle singole proiezioni. In alcuni casi la data assegnata puo' essere adiacente a quella riportata nella fonte; per verificarla, consulta la scansione e la [metodologia](/2026/11/11/metodologia-ricostruzione-programmazione/).",
      "",
      "I voti IMDb descrivono le valutazioni degli utenti IMDb, non il pubblico o gli incassi del Cinema Sestito.",
      ""
    )
    if (year %in% c(1960L, 1961L)) {
      lines <- c(
        lines,
        "> La documentazione disponibile per questo anno e' parziale: i mesi senza registrazioni non indicano necessariamente l'assenza di proiezioni.",
        ""
      )
    }
    # Aggiunge una tabella per ogni mese e collega i titoli a IMDb quando possibile.
    first_month <- min(data$mese)
    for (month in sort(unique(data$mese))) {
      rows <- data |>
        dplyr::filter(mese == month) |>
        dplyr::mutate(
          title = escape_anni_text(title),
          title = dplyr::if_else(
            !is.na(url) & nzchar(url), paste0("[", title, "](", url, ")"), title
          )
        )
      lines <- c(
        lines, paste0("### ", months[month], if (month == first_month) "[^1]" else ""),
        "", "|           |                                       |", "|:----------|:--------------------------------------|",
        paste0("| ", format(rows$date, "%Y-%m-%d"), " | ", rows$title, " |"), ""
      )
    }
    # La nota finale riunisce le fonti distinte usate nell'anno.
    sources <- data |>
      dplyr::pull(source) |>
      stringr::str_split(",") |>
      unlist() |>
      stringr::str_trim() |>
      stringr::str_to_lower() |>
      unique() |>
      sort()
    lines <- c(
      lines, paste0("[^1]: Fonti: ", paste(unname(source_links[sources]), collapse = ", ")),
      ""
    )
    path <- file.path(directory, "index.md")
    writeLines(enc2utf8(lines), path, useBytes = TRUE)
    pages <- c(pages, path)
    message("Generata programmazione ", year, ": ", nrow(data), " proiezioni.")
  }
  invisible(pages)
}

check_anni_section <- function(project_root, section, render_index) {
  project_root <- normalizePath(project_root, mustWork = TRUE)
  check_anni_packages()
  packages <- c("tibble", "tidyr", if (render_index) c("tidyverse", "knitr", "here", "viridis"))
  missing <- packages[!vapply(packages, requireNamespace, logical(1), quietly = TRUE)]
  if (length(missing)) stop("Pacchetti R mancanti: ", paste(missing, collapse = ", "), call. = FALSE)
  font <- file.path(project_root, "static", "fonts", "merriweather-v13-latin-regular.woff")
  if (render_index && !file.exists(font)) {
    stop("Carattere Merriweather mancante: ", font, call. = FALSE)
  }
  root <- file.path(project_root, "content", "programmazione-storica")
  if (render_index) {
    read_anni_csv(file.path(project_root, "static", "data", "programmazione_imdb.csv"),
                  c("Const", "Year", "Title", "Directors", "Genres", "IMDb Rating",
                    "Num Votes", "Runtime (mins)", "URL"))
    read_anni_csv(file.path(project_root, "static", "data", "programmazione_paesi.csv"),
                  c("const", "country", "is_adult"))
    index <- file.path(root, section, "_index.Rmd")
    if (!file.exists(index)) {
      stop("File R Markdown mancante: ", index, call. = FALSE)
    }
  }
  invisible(project_root)
}

render_anni_index <- function(project_root, section) {
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


update_anni <- function(project_root = ".", render_index = TRUE, years = NULL) {
  project_root <- check_anni_section(project_root, "anni", render_index)
  data <- load_anni_data(project_root)
  directory <- file.path(project_root, "content", "programmazione-storica", "anni")
  year_dirs <- basename(list.dirs(directory, recursive = FALSE))
  year_dirs <- year_dirs[grepl("^[0-9]{4}-01-01-programmazione-[0-9]{4}$", year_dirs)]
  old_years <- year_dirs[!as.integer(substr(year_dirs, 1, 4)) %in% data$anno]
  if (length(old_years)) {
    warning("Pagine annuali senza dati non rimosse: ", paste(old_years, collapse = ", "),
            call. = FALSE)
  }
  pages <- generate_anni(project_root = project_root, years = years)
  if (render_index) render_anni_index(project_root, "anni")
  invisible(pages)
}

if (sys.nframe() == 0L) update_anni()
