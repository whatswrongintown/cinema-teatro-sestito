# Controlla che i pacchetti necessari siano installati prima di generare le pagine.
# Oltre a R base servono yaml (metadati delle schede) e showtext/sysfonts (font nei grafici).
check_anni_packages <- function() {
  packages <- c("yaml", "showtext", "sysfonts")
  missing <- packages[!vapply(packages, requireNamespace, logical(1), quietly = TRUE)]
  if (length(missing)) {
    stop("Pacchetti R mancanti: ", paste(missing, collapse = ", "), call. = FALSE)
  }
}

# Legge un CSV come testo e controlla che non contenga errori o colonne mancanti.
read_anni_csv <- function(path, required) {
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
  titles <- vapply(files, function(path) {
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
    metadata$title
  }, character(1), USE.NAMES = FALSE)
  references <- paste("programmazione-storica", "fonti", basename(dirname(files)),
                      "index.md", sep = "/")
  keys <- tolower(trimws(titles, whitespace = "[\\h\\v]"))
  links <- paste0("[", escape_anni_text(titles), "]({{< relref \"", references, "\" >}})")
  if (anyDuplicated(keys)) {
    stop("Titoli delle fonti duplicati: impossibile risolvere i collegamenti.",
         call. = FALSE)
  }
  # Le note sui manifesti hanno un'unica scheda, qualunque sia il nome usato nel database;
  # finche' la scheda non esiste il collegamento punta all'indice delle fonti.
  page <- match(TRUE, keys %in% anni_manifesti)
  target <- if (is.na(page)) {
    '[Note sui manifesti]({{< relref "programmazione-storica/fonti/_index.md" >}}#note-sui-manifesti)'
  } else {
    links[page]
  }
  aliases <- setdiff(anni_manifesti, keys)
  stats::setNames(c(links, rep(target, length(aliases))), c(keys, aliases))
}

# Valori con cui il database puo' indicare le "Note sui manifesti" (come in update-fonti.R).
anni_manifesti <- c("note sui manifesti", "note su manifesti", "note_su_manifesti",
                    "note su manifesto", "note_su_manifesto", "nota_su_manifesto")

# Separa i valori di una cella elencati con la virgola, senza spazi e senza vuoti.
split_anni_values <- function(x) {
  values <- trimws(unlist(strsplit(x, ",", fixed = TRUE), use.names = FALSE),
                   whitespace = "[\\h\\v]")
  values[!is.na(values) & nzchar(values)]
}

anni_cache <- new.env(parent = emptyenv())

# Carica le proiezioni e i dati IMDb, verifica i valori e li unisce per film.
# Il risultato resta in memoria finche' i file CSV non cambiano.
load_anni_data <- function(project_root) {
  directory <- file.path(project_root, "static", "data")
  paths <- file.path(directory, c("programmazione_agende.csv", "programmazione_imdb.csv"))
  info <- file.info(paths)
  signature <- paste(normalizePath(paths, mustWork = FALSE), info$size,
                     as.numeric(info$mtime), collapse = "|")
  if (identical(anni_cache$signature, signature)) {
    return(anni_cache$data)
  }
  screenings <- read_anni_csv(paths[1], c("date", "const", "title", "source"))
  imdb <- read_anni_csv(paths[2], c("Const", "IMDb Rating", "Num Votes", "URL"))
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
            " proiezioni senza identificativo IMDb: il titolo restera' senza collegamento.",
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
  # Aggiunge anno, mese e dati IMDb a ogni proiezione, mantenendo le ripetizioni.
  has_const <- !is.na(screenings$const) & nzchar(trimws(screenings$const))
  position <- rep(NA, nrow(screenings))
  position[has_const] <- match(screenings$const[has_const], imdb$Const)
  screenings$date_text <- screenings$date
  screenings$date <- dates
  screenings$anno <- as.integer(substr(screenings$date_text, 1L, 4L))
  screenings$mese <- as.integer(substr(screenings$date_text, 6L, 7L))
  screenings$imdb_rating <- rating[position]
  screenings$imdb_votes <- votes[position]
  screenings$url <- imdb$URL[position]
  missing_url_count <- sum(is.na(screenings$url) | !nzchar(screenings$url))
  if (missing_url_count > 0) {
    warning(missing_url_count,
            " proiezioni senza URL IMDb: il titolo restera' senza collegamento.",
            call. = FALSE)
  }
  screenings <- screenings[order(screenings$date), , drop = FALSE]
  rownames(screenings) <- NULL
  anni_cache$signature <- signature
  anni_cache$data <- screenings
  screenings
}

# Registra Merriweather leggendolo sempre da static/fonts (nessun download e nessun
# font gia' registrato nella sessione); se il file manca si ferma invece di usare un altro font.
anni_font <- function(project_root) {
  family <- "merriweather"
  font <- file.path(project_root, "static", "fonts", "merriweather-v13-latin-regular.woff")
  if (!file.exists(font)) {
    stop("Font Merriweather non trovato: ", font, call. = FALSE)
  }
  sysfonts::font_add(family, font)
  family
}

# Dimensioni tipografiche (pt), colori e spessori dei grafici, pensati per 8 x 3 pollici.
anni_style <- list(
  title = 11, tick = 8, label = 8.5, point_label = 7.5, caption = 8.8, point = "#CBF8DF",
  axis = "black", text = "black", line = 1.42, tick_length = 0.038
)

anni_open_png <- function(path, family) {
  args <- list(filename = path, width = 8, height = 3, units = "in", res = 200,
               bg = "white", pointsize = 12, family = family)
  if (isTRUE(capabilities("cairo"))) args$type <- "cairo"
  do.call(grDevices::png, args)
}

# Converte pollici in unita' dell'asse per posizionare i testi a distanza fissa.
anni_inch_x <- function(inches) inches * diff(graphics::par("usr")[1:2]) / graphics::par("pin")[1]
anni_inch_y <- function(inches) inches * diff(graphics::par("usr")[3:4]) / graphics::par("pin")[2]

anni_text <- function(x, y, labels, size, colour = "black", ...) {
  graphics::text(x, y, labels, cex = size / 12, col = colour, xpd = NA, ...)
}

# Disegna gli assi in stile theme_classic: linee a sinistra e in basso, tacche e valori.
anni_axes <- function(x_at, x_labels, y_at, y_labels) {
  usr <- graphics::par("usr")
  tick <- anni_style$tick_length
  graphics::segments(
    c(usr[1], usr[1], x_at, rep(usr[1], length(y_at))),
    c(usr[3], usr[3], rep(usr[3], length(x_at)), y_at),
    c(usr[2], usr[1], x_at, rep(usr[1] - anni_inch_x(tick), length(y_at))),
    c(usr[3], usr[4], rep(usr[3] - anni_inch_y(tick), length(x_at)), y_at),
    lwd = anni_style$line, col = anni_style$axis, lend = "square", xpd = NA
  )
  anni_text(x_at, usr[3] - anni_inch_y(tick + 0.085), x_labels, anni_style$tick,
            anni_style$text, adj = c(0.5, 0.5))
  anni_text(usr[1] - anni_inch_x(tick + 0.03), y_at, y_labels, anni_style$tick,
            anni_style$text, adj = c(1, 0.5))
}

# Imposta l'area del grafico lasciando posto a valori, titolo dell'asse e didascalia.
# Restituisce il margine sinistro in pollici.
anni_panel <- function(xlim, ylim, y_labels, top, bottom) {
  graphics::plot.new()
  widest <- max(graphics::strwidth(y_labels, units = "inches", cex = anni_style$tick / 12))
  left <- widest + anni_style$tick_length + 0.03 + 0.33
  graphics::par(mai = c(bottom, left, top, 0.14), xaxs = "i", yaxs = "i")
  graphics::plot.window(xlim, ylim)
  left
}

# Grafico a colonne delle proiezioni per mese, con il numero sopra ogni colonna.
anni_monthly_plot <- function(path, counts, total, family) {
  anni_open_png(path, family)
  on.exit(grDevices::dev.off(), add = TRUE)
  graphics::par(family = family, mar = c(0, 0, 0, 0))
  top <- max(counts$n)
  y_at <- pretty(c(0, top), n = 4)
  y_at <- y_at[y_at >= -0.05 * top & y_at <= 1.05 * top]
  left <- anni_panel(c(0.4, nrow(counts) + 0.6), c(-0.05 * top, 1.05 * top),
                     as.character(y_at), top = 0.5, bottom = 0.515)
  usr <- graphics::par("usr")
  index <- seq_len(nrow(counts))
  graphics::rect(index - 0.45, 0, index + 0.45, counts$n, col = anni_style$point,
                 border = NA)
  anni_axes(index, counts$month, y_at, as.character(y_at))
  anni_text(index, counts$n + anni_inch_y(0.05), counts$n, anni_style$label,
            adj = c(0.5, 0))
  anni_text(usr[1], usr[4] + anni_inch_y(0.11), paste("Totale proiezioni:", total),
            anni_style$title, adj = c(0, 0))
  anni_text(usr[1] - anni_inch_x(left - 0.18), mean(usr[3:4]), "Numero di proiezioni",
            anni_style$title, srt = 90, adj = c(0.5, 0.5))
  invisible(path)
}

# Cerca per ogni etichetta una posizione libera vicino al punto, senza coprire punti
# o altre etichette; le etichette senza spazio vengono omesse. Le coordinate sono in
# pollici e le etichette vanno passate in ordine di priorita'.
anni_place_labels <- function(px, py, widths, height, width_limit, height_limit,
                              radius = 0.04, gap = c(0.015, 0.05, 0.1)) {
  n <- length(px)
  dx <- c(1, -1, 0, 0, 1, -1, 1, -1)
  dy <- c(0, 0, 1, -1, 1, 1, -1, -1)
  boxes <- matrix(NA_real_, n, 4L)
  centre <- matrix(NA_real_, n, 2L)
  ring <- integer(n)
  pad <- 0.012
  for (i in seq_len(n)) {
    for (level in seq_along(gap)) {
      offset <- radius + gap[level]
      cx <- px[i] + dx * (offset + widths[i] / 2)
      cy <- py[i] + dy * (offset + height / 2)
      x0 <- cx - widths[i] / 2 - pad
      x1 <- cx + widths[i] / 2 + pad
      y0 <- cy - height / 2 - pad
      y1 <- cy + height / 2 + pad
      for (k in which(x0 >= 0 & x1 <= width_limit & y0 >= 0 & y1 <= height_limit)) {
        if (any(px + radius > x0[k] & px - radius < x1[k] &
                py + radius > y0[k] & py - radius < y1[k])) next
        if (i > 1L && any(boxes[seq_len(i - 1L), 1L] < x1[k] & boxes[seq_len(i - 1L), 2L] > x0[k] &
                          boxes[seq_len(i - 1L), 3L] < y1[k] & boxes[seq_len(i - 1L), 4L] > y0[k],
                          na.rm = TRUE)) next
        boxes[i, ] <- c(x0[k], x1[k], y0[k], y1[k])
        centre[i, ] <- c(cx[k], cy[k])
        ring[i] <- level
        break
      }
      if (ring[i]) break
    }
  }
  list(centre = centre, box = boxes, ring = ring)
}

# Estende l'intervallo del 5% per lato, come fa ggplot2 sugli assi continui.
anni_expand <- function(range) {
  if (diff(range) == 0) range <- range + c(-0.5, 0.5)
  range + c(-0.05, 0.05) * diff(range)
}

# Posizioni dei valori dell'asse logaritmico: le potenze di 10 comprese nell'intervallo
# e, se sono poche, anche i multipli per 3.
anni_log_breaks <- function(limits) {
  powers <- seq.int(ceiling(limits[1]), floor(limits[2]))
  if (length(powers) >= 3L) return(powers)
  candidates <- sort(log10(c(1, 3) %o% 10^seq.int(floor(limits[1]), ceiling(limits[2]))))
  candidates[candidates >= limits[1] & candidates <= limits[2]]
}

# Grafico logaritmico delle valutazioni IMDb con i titoli dove c'e' spazio.
anni_imdb_plot <- function(path, rated, family) {
  anni_open_png(path, family)
  on.exit(grDevices::dev.off(), add = TRUE)
  graphics::par(family = family, mar = c(0, 0, 0, 0))
  # Se non ci sono dati IMDb utilizzabili, mostra un messaggio al posto del grafico.
  if (!nrow(rated)) {
    graphics::plot.new()
    anni_text(0.5, 0.5, "Dati IMDb non disponibili", 11)
    return(invisible(path))
  }
  x <- log10(rated$imdb_votes)
  y <- rated$imdb_rating
  xlim <- anni_expand(range(x))
  ylim <- anni_expand(range(y))
  y_at <- (1:10)[1:10 >= ylim[1] & 1:10 <= ylim[2]]
  x_at <- anni_log_breaks(xlim)
  left <- anni_panel(xlim, ylim, as.character(y_at), top = 0.275, bottom = 0.715)
  usr <- graphics::par("usr")
  pin <- graphics::par("pin")
  graphics::points(x, y, pch = 16, cex = 0.95, col = anni_style$point, xpd = NA)
  anni_axes(x_at, formatC(10^x_at, format = "fg", big.mark = ","), y_at,
            as.character(y_at))

  # Un'etichetta per film e posizione; si parte dai punti piu' isolati.
  ix <- (x - usr[1]) / diff(usr[1:2]) * pin[1]
  iy <- (y - usr[3]) / diff(usr[3:4]) * pin[2]
  candidates <- which(!duplicated(paste(rated$title, x, y)))
  isolation <- (ix[candidates] - mean(ix))^2 + (iy[candidates] - mean(iy))^2
  chosen <- candidates[order(-isolation)]
  widths <- graphics::strwidth(rated$title[chosen], units = "inches",
                               cex = anni_style$point_label / 12)
  height <- graphics::strheight("Mg", units = "inches", cex = anni_style$point_label / 12)
  layout <- anni_place_labels(ix[chosen], iy[chosen], widths, height, pin[1], pin[2])
  shown <- layout$ring > 0L
  to_x <- function(inches) usr[1] + inches / pin[1] * diff(usr[1:2])
  to_y <- function(inches) usr[3] + inches / pin[2] * diff(usr[3:4])
  anni_text(to_x(layout$centre[shown, 1L]), to_y(layout$centre[shown, 2L]),
            rated$title[chosen][shown], anni_style$point_label, adj = c(0.5, 0.5))
  anni_text(usr[1] + diff(usr[1:2]) / 2, usr[3] - anni_inch_y(0.28),
            "Numero di voti (log)", anni_style$title, adj = c(0.5, 0.5))
  anni_text(usr[1] - anni_inch_x(left - 0.18), mean(usr[3:4]), "Valutazioni medie IMDb",
            anni_style$title, srt = 90, adj = c(0.5, 0.5))
  anni_text(usr[2], usr[3] - anni_inch_y(0.5),
            "Information courtesy of IMDb (https://www.imdb.com)", anni_style$caption,
            adj = c(1, 0.5))
  invisible(path)
}

# Salva i due grafici di un anno: proiezioni per mese e valutazioni IMDb.
anni_charts <- function(screenings, year, months, images, family) {
  # Conta le proiezioni registrate in ogni mese, non i titoli distinti.
  counted <- table(screenings$mese)
  counts <- data.frame(mese = as.integer(names(counted)), n = as.integer(counted))
  counts$month <- months[counts$mese]
  anni_monthly_plot(file.path(images, "proiezioni-mensili.png"), counts,
                    nrow(screenings), family)
  # Il grafico logaritmico usa solo valutazioni valide e numeri di voti positivi.
  rated <- screenings[
    is.finite(screenings$imdb_rating) & is.finite(screenings$imdb_votes) &
      screenings$imdb_votes > 0, , drop = FALSE
  ]
  if (!nrow(rated)) {
    warning("Nessun dato IMDb utilizzabile per il grafico del ", year, ".",
            call. = FALSE)
  }
  anni_imdb_plot(file.path(images, "valutazioni-imdb.png"), rated, family)
}

# Costruisce la pagina Markdown di un anno: metadati, grafici, tabelle mensili e fonti.
anni_page_lines <- function(data, year, months, source_links, lastmod = NULL) {
  if (!is.null(lastmod)) {
    if (!is.character(lastmod) || length(lastmod) != 1L ||
        !grepl("^[0-9]{4}-[0-9]{2}-[0-9]{2}$", lastmod)) {
      stop("lastmod deve essere una data YYYY-MM-DD.", call. = FALSE)
    }
    parsed_lastmod <- as.Date(lastmod, format = "%Y-%m-%d")
    if (is.na(parsed_lastmod) || format(parsed_lastmod, "%Y-%m-%d") != lastmod) {
      stop("lastmod non e' una data valida.", call. = FALSE)
    }
  }
  lines <- c(
    "---", paste("title: Programmazione", year), "author: Vito Sestito",
    sprintf("date: '%d-01-01'", year),
    if (!is.null(lastmod)) paste0("lastmod: '", lastmod, "'"),
    paste0("slug: programmazione-", year),
    paste0("description: Programmazione cinematografica del Cinema Teatro Sestito nel ", year, "."),
    paste0(
      "image: \"/", year, "/01/01/programmazione-", year,
      "/index_files/figure-html/proiezioni-mensili.png\""
    ),
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
  title <- escape_anni_text(data$title)
  linked <- !is.na(data$url) & nzchar(data$url)
  title[linked] <- paste0("[", title[linked], "](", data$url[linked], ")")
  by_month <- split(paste0("| ", data$date_text, " | ", title, " |"), data$mese)
  first_month <- min(data$mese)
  tables <- unlist(lapply(names(by_month), function(month) {
    number <- as.integer(month)
    c(paste0("### ", months[number], if (number == first_month) "[^1]" else ""),
      "", "|           |                                       |",
      "|:----------|:--------------------------------------|", by_month[[month]], "")
  }), use.names = FALSE)
  # La nota finale riunisce le fonti distinte usate nell'anno.
  sources <- sort(unique(tolower(split_anni_values(data$source))))
  c(lines, tables,
    paste0("[^1]: Fonti: ", paste(unique(unname(source_links[sources])), collapse = ", ")), "")
}

# Genera le pagine annuali per tutti gli anni disponibili o per quelli richiesti.
generate_anni <- function(project_root = ".", years = NULL,
                          output_dir = file.path(
                            project_root, "content", "programmazione-storica", "anni"
                          ), lastmod = NULL) {
  check_anni_packages()
  project_root <- normalizePath(project_root, mustWork = TRUE)
  screenings <- load_anni_data(project_root)
  available_years <- sort(unique(screenings$anno))
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
  source_names <- unique(split_anni_values(screenings$source[screenings$anno %in% years]))
  unknown <- source_names[!tolower(source_names) %in% names(source_links)]
  if (length(unknown)) {
    stop("Schede fonte mancanti per: ", paste(unknown, collapse = ", "),
         call. = FALSE)
  }
  months <- c(
    "Gennaio", "Febbraio", "Marzo", "Aprile", "Maggio", "Giugno",
    "Luglio", "Agosto", "Settembre", "Ottobre", "Novembre", "Dicembre"
  )
  family <- anni_font(project_root)
  previous_opts <- showtext::showtext_opts()
  showtext::showtext_auto(TRUE)
  showtext::showtext_opts(dpi = 200)
  on.exit({
    showtext::showtext_auto(FALSE)
    do.call(showtext::showtext_opts, previous_opts)
  }, add = TRUE)
  by_year <- split(seq_len(nrow(screenings)), screenings$anno)
  pages <- character()
  # Per ogni anno salva i grafici e costruisce la relativa pagina Markdown.
  for (year in years) {
    data <- screenings[by_year[[as.character(year)]], , drop = FALSE]
    directory <- file.path(output_dir, sprintf("%d-01-01-programmazione-%d", year, year))
    images <- file.path(directory, "index_files", "figure-html")
    if (!dir.exists(images) && !dir.create(images, recursive = TRUE)) {
      stop("Impossibile creare la cartella: ", images, call. = FALSE)
    }
    anni_charts(data, year, months, images, family)
    path <- file.path(directory, "index.md")
    writeLines(enc2utf8(anni_page_lines(data, year, months, source_links, lastmod)), path,
               useBytes = TRUE)
    pages <- c(pages, path)
    message("Generata programmazione ", year, ": ", nrow(data), " proiezioni.")
  }
  invisible(pages)
}

check_anni_section <- function(project_root, section) {
  project_root <- normalizePath(project_root, mustWork = TRUE)
  check_anni_packages()
  invisible(project_root)
}

update_anni <- function(project_root = ".", years = NULL, lastmod = NULL) {
  project_root <- check_anni_section(project_root, "anni")
  data <- load_anni_data(project_root)
  directory <- file.path(project_root, "content", "programmazione-storica", "anni")
  year_dirs <- basename(list.dirs(directory, recursive = FALSE))
  year_dirs <- year_dirs[grepl("^[0-9]{4}-01-01-programmazione-[0-9]{4}$", year_dirs)]
  old_years <- year_dirs[!as.integer(substr(year_dirs, 1, 4)) %in% data$anno]
  if (length(old_years)) {
    warning("Pagine annuali senza dati non rimosse: ", paste(old_years, collapse = ", "),
            call. = FALSE)
  }
  pages <- generate_anni(project_root = project_root, years = years, lastmod = lastmod)
  if (is.null(years)) update_anni_index(project_root)
  invisible(pages)
}

# Rigenera il grafico della pagina indice della sezione (vedi R/update-indici.R).
update_anni_index <- function(project_root = ".") {
  helpers <- new.env(parent = globalenv())
  sys.source(file.path(project_root, "R", "update-indici.R"), envir = helpers)
  helpers$update_indici(project_root, "anni")
}

if (sys.nframe() == 0L) update_anni()
