# Grafici riassuntivi delle pagine indice di "programmazione storica" (anni, fonti,
# generi, paesi di produzione). Producono i file PNG citati nei file _index.md, quindi
# non serve piu' renderizzare i file _index.Rmd. Solo R base, piu' showtext/sysfonts
# per usare il font Merriweather del sito leggendolo dal file locale.
#
#   source("R/update-indici.R")
#   update_indici()                    # tutte le sezioni
#   update_indici(sections = "generi") # una sola sezione

indici_sections <- c("anni", "fonti", "generi", "paesi")

# Cartella di destinazione e nome dei file PNG di ogni sezione (gli stessi che gli
# _index.md gia' usano).
indici_files <- list(
  anni = list(directory = "anni", files = "film-per-anno-1.png"),
  fonti = list(directory = "fonti", files = "fonti-per-decennio-1.png"),
  generi = list(directory = "generi",
                files = c("generi-per-decennio-1.png", "film-per-adulti-per-anno-1.png")),
  paesi = list(directory = "paesi-di-produzione",
               files = c("italia-estero-per-decennio-1.png", "paesi-per-decennio-1.png"))
)

check_indici_packages <- function() {
  packages <- c("showtext", "sysfonts")
  missing <- packages[!vapply(packages, requireNamespace, logical(1), quietly = TRUE)]
  if (length(missing)) {
    stop("Pacchetti R mancanti: ", paste(missing, collapse = ", "), call. = FALSE)
  }
}

# ---- Dati -------------------------------------------------------------------------

indici_read_csv <- function(path, required) {
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
    stop("Colonne mancanti in ", path, ": ", paste(missing, collapse = ", "), call. = FALSE)
  }
  data
}

indici_trim <- function(x) trimws(x, whitespace = "[\\h\\v]")

# Una riga per proiezione con anno, decennio, fonte, generi IMDb e paesi di produzione.
indici_load <- function(project_root) {
  directory <- file.path(project_root, "static", "data")
  screenings <- indici_read_csv(file.path(directory, "programmazione_agende.csv"),
                                c("date", "const", "source"))
  imdb <- indici_read_csv(file.path(directory, "programmazione_imdb.csv"), c("Const", "Genres"))
  countries <- indici_read_csv(file.path(directory, "programmazione_paesi.csv"),
                               c("const", "country"))
  if (anyDuplicated(imdb$Const) || anyDuplicated(countries$const)) {
    stop("Gli identificativi IMDb e dei paesi devono essere univoci.", call. = FALSE)
  }
  dates <- as.Date(screenings$date, format = "%Y-%m-%d")
  if (anyNA(dates)) {
    stop("Le date delle proiezioni devono essere valide e nel formato YYYY-MM-DD.", call. = FALSE)
  }
  anno <- as.integer(format(dates, "%Y"))
  data.frame(
    const = screenings$const, anno = anno, decennio = floor(anno / 10) * 10,
    source = screenings$source,
    genres = imdb$Genres[match(screenings$const, imdb$Const)],
    country = countries$country[match(screenings$const, countries$const)],
    stringsAsFactors = FALSE
  )
}

# Separa i valori elencati nella stessa cella: una riga per valore, come separate_rows.
indici_expand <- function(data, column, trim = TRUE) {
  pieces <- strsplit(data[[column]], ",", fixed = TRUE)
  expanded <- data[rep.int(seq_len(nrow(data)), lengths(pieces)), , drop = FALSE]
  expanded[[column]] <- unlist(pieces, use.names = FALSE)
  if (trim) expanded[[column]] <- indici_trim(expanded[[column]])
  rownames(expanded) <- NULL
  expanded
}

# Proiezioni per anno, esclusi il 1960 e il 1961 (documentazione parziale).
indici_data_anni <- function(data) {
  counts <- table(data$anno[!data$anno %in% c(1960L, 1961L)])
  data.frame(anno = as.integer(names(counts)), n = as.integer(counts))
}

# Numero di film per tipologia di fonte e decennio.
indici_data_fonti <- function(data) {
  long <- indici_expand(data, "source")
  lower <- tolower(long$source)
  type <- rep("Agende", nrow(long))
  rules <- list(
    Appunti = "cif|italautogamma|europe|victory", "Note sui manifesti" = "manifest",
    Calendari = "calendario", Rubriche = "rubric"
  )
  assigned <- rep(FALSE, nrow(long))
  for (name in names(rules)) {
    hit <- !assigned & grepl(rules[[name]], lower)
    type[hit] <- name
    assigned <- assigned | hit
  }
  levels <- c("Appunti", "Rubriche", "Calendari", "Agende", "Note sui manifesti")
  counts <- as.data.frame(table(tipo = type, decennio = long$decennio), stringsAsFactors = FALSE)
  counts <- counts[counts$Freq > 0, , drop = FALSE]
  counts$decennio <- as.integer(counts$decennio)
  counts$tipo <- factor(counts$tipo, levels = levels[levels %in% counts$tipo])
  data.frame(tipo = counts$tipo, decennio = counts$decennio, n = counts$Freq)
}

# Quota di ogni genere per decennio. "Drammatico" e' escluso quando e' abbinato ad altri
# generi; i generi sono ordinati dal piu' al meno frequente.
indici_data_generi <- function(data) {
  long <- indici_expand(data, "genres")
  rows_per_film <- table(long$const)[long$const]
  long <- long[!(long$genres %in% "Drammatico" & rows_per_film > 1) & !is.na(long$genres), ]
  totals <- table(long$genres)
  order <- names(totals)[order(-as.integer(totals), names(totals), method = "radix")]
  counts <- as.data.frame(table(decennio = long$decennio, genere = long$genres),
                          stringsAsFactors = FALSE)
  counts <- counts[counts$Freq > 0, , drop = FALSE]
  counts$decennio <- as.integer(counts$decennio)
  counts$prop <- counts$Freq / as.numeric(tapply(counts$Freq, counts$decennio, sum)[as.character(counts$decennio)])
  list(tiles = data.frame(decennio = counts$decennio, genere = counts$genere, n = counts$Freq,
                          prop = counts$prop),
       order = order)
}

# Percentuale annuale di film per adulti.
indici_data_adulti <- function(data) {
  adult <- grepl("Per adulti", data$genres, fixed = TRUE)
  total <- table(data$anno)
  adults <- tapply(adult, data$anno, sum)
  data.frame(anno = as.integer(names(total)),
             perc = as.numeric(adults[names(total)]) / as.integer(total) * 100)
}

# Percentuale di film italiani ed esteri per decennio. Un film con piu' paesi conta in
# ciascuno; i valori mancanti contano come esteri.
indici_data_italia <- function(data) {
  long <- indici_expand(data, "country", trim = FALSE)
  italian <- grepl("Italy", long$country, ignore.case = TRUE)
  total <- table(long$decennio)
  italy <- tapply(italian, long$decennio, sum)
  decades <- as.integer(names(total))
  data.frame(decennio = decades, italia = as.numeric(italy[names(total)]) / as.integer(total) * 100)
}

# Numero di paesi distinti per decennio.
indici_data_paesi <- function(data) {
  long <- indici_expand(data, "country")
  distinct <- long[!duplicated(paste(long$decennio, long$country)), ]
  counts <- table(distinct$decennio)
  data.frame(decennio = as.integer(names(counts)), n = as.integer(counts))
}

# ---- Scala degli assi (algoritmo "extended" di Talbot et al., come in ggplot2) ------

indici_extended <- function(dmin, dmax, m = 5, Q = c(1, 5, 2, 2.5, 4, 3),
                            w = c(0.25, 0.2, 0.5, 0.05)) {
  eps <- .Machine$double.eps * 100
  if (dmin > dmax) {
    swap <- dmin
    dmin <- dmax
    dmax <- swap
  }
  if (dmax - dmin < eps) {
    return(seq(dmin, dmax, length.out = m))
  }
  n <- length(Q)
  simplicity <- function(q, j, lmin, lmax, lstep) {
    v <- as.numeric((lmin %% lstep < eps || lstep - (lmin %% lstep) < eps) &&
                      lmin <= 0 && lmax >= 0)
    1 - (match(q, Q) - 1) / (n - 1) - j + v
  }
  simplicity_max <- function(q, j) 1 - (match(q, Q) - 1) / (n - 1) - j + 1
  coverage <- function(lmin, lmax) {
    range <- dmax - dmin
    1 - 0.5 * ((dmax - lmax)^2 + (dmin - lmin)^2) / ((0.1 * range)^2)
  }
  coverage_max <- function(span) {
    range <- dmax - dmin
    if (span > range) {
      half <- (span - range) / 2
      1 - 0.5 * (half^2 + half^2) / ((0.1 * range)^2)
    } else {
      1
    }
  }
  density <- function(k, lmin, lmax) {
    r <- (k - 1) / (lmax - lmin)
    rt <- (m - 1) / (max(lmax, dmax) - min(dmin, lmin))
    2 - max(r / rt, rt / r)
  }
  density_max <- function(k) if (k >= m) 2 - (k - 1) / (m - 1) else 1
  best <- list(score = -2)
  j <- 1
  while (j < Inf) {
    for (q in Q) {
      sm <- simplicity_max(q, j)
      if (w[1] * sm + w[2] + w[3] + w[4] < best$score) {
        j <- Inf
        break
      }
      k <- 2
      while (k < Inf) {
        dm <- density_max(k)
        if (w[1] * sm + w[2] + w[3] * dm + w[4] < best$score) break
        delta <- (dmax - dmin) / (k + 1) / j / q
        z <- ceiling(log10(delta))
        while (z < Inf) {
          step <- j * q * 10^z
          cm <- coverage_max(step * (k - 1))
          if (w[1] * sm + w[2] * cm + w[3] * dm + w[4] < best$score) break
          min_start <- floor(dmax / step) * j - (k - 1) * j
          max_start <- ceiling(dmin / step) * j
          if (min_start > max_start) {
            z <- z + 1
            next
          }
          for (start in min_start:max_start) {
            lmin <- start * (step / j)
            lmax <- lmin + step * (k - 1)
            score <- w[1] * simplicity(q, j, lmin, lmax, step) + w[2] * coverage(lmin, lmax) +
              w[3] * density(k, lmin, lmax) + w[4]
            if (score > best$score) best <- list(lmin = lmin, lmax = lmax, lstep = step, score = score)
          }
          z <- z + 1
        }
        k <- k + 1
      }
    }
    j <- j + 1
  }
  seq(best$lmin, best$lmax, by = best$lstep)
}

# Estende l'intervallo del 5% per lato, come ggplot2 sugli assi continui.
indici_expand_range <- function(range) {
  if (diff(range) == 0) range <- range + c(-0.5, 0.5)
  range + c(-0.05, 0.05) * diff(range)
}

# Valori dell'asse compresi nell'intervallo visibile.
indici_breaks <- function(limits) {
  breaks <- indici_extended(limits[1], limits[2])
  breaks[breaks >= limits[1] - 1e-9 & breaks <= limits[2] + 1e-9]
}

# ---- Disegno ----------------------------------------------------------------------

# Il PNG e' largo 8 pollici a 192 dpi (1536 px), come quelli prodotti da knitr. Nel
# vecchio flusso showtext (96 dpi) disegnava i testi a poco piu' della meta' della
# dimensione indicata: qui si applica lo stesso rapporto, misurato sui grafici gia'
# pubblicati, cosi' il testo ha le stesse proporzioni.
indici_dpi <- 192
indici_text_ratio <- 0.483
indici_size <- function(nominal) nominal * indici_text_ratio

# Spessori delle linee misurati sui grafici gia' pubblicati (unita' di R: 1/96 di pollice).
indici_lwd <- list(line = 3.4, border = 0.7, dash = 1)
indici_colour <- list(mint = "#CBF8DF", grey = "grey90", tick_text = "#4D4D4D")
indici_state <- new.env(parent = emptyenv())

indici_open <- function(path, height, family) {
  args <- list(filename = path, width = 8, height = height, units = "in", res = indici_dpi,
               bg = "white", pointsize = 12, family = family)
  if (isTRUE(capabilities("cairo"))) args$type <- "cairo"
  do.call(grDevices::png, args)
  graphics::par(mar = c(0, 0, 0, 0), ljoin = "mitre", lend = "butt", family = family)
  graphics::plot.new()
  indici_state$width <- 8 * indici_dpi
  indici_state$height <- height * indici_dpi
}

# Testo posizionato in pixel della figura, con l'origine in alto a sinistra.
indici_text <- function(x, y, labels, size, colour = "black", adj = c(0.5, 0.5), srt = 0) {
  graphics::text(
    graphics::grconvertX(x / indici_dpi, "inches", "user"),
    graphics::grconvertY((indici_state$height - y) / indici_dpi, "inches", "user"),
    labels, cex = size / 12, col = colour, adj = adj, srt = srt, xpd = NA
  )
}

indici_rect <- function(x0, y0, x1, y1, ...) {
  graphics::rect(
    graphics::grconvertX(x0 / indici_dpi, "inches", "user"),
    graphics::grconvertY((indici_state$height - y1) / indici_dpi, "inches", "user"),
    graphics::grconvertX(x1 / indici_dpi, "inches", "user"),
    graphics::grconvertY((indici_state$height - y0) / indici_dpi, "inches", "user"),
    xpd = NA, ...
  )
}

# Larghezza in pixel del testo piu' largo.
indici_width <- function(labels, size) {
  max(graphics::strwidth(labels, units = "inches", cex = size / 12)) * indici_dpi
}

# Imposta l'area del grafico. Il margine sinistro dipende dalla larghezza dei valori
# dell'asse y; quello destro lascia posto alla legenda (legend_width, in pixel).
# Restituisce le coordinate in pixel di sinistra, destra, alto e basso.
indici_panel <- function(xlim, ylim, y_labels, text_size, top, bottom, ytitle_x = 27,
                         ytitle_gap = 29, legend_width = 0, right_margin = 15) {
  right <- if (legend_width > 0) 30 + legend_width + 48 else right_margin
  left <- ytitle_x + ytitle_gap + indici_width(y_labels, text_size) + 13
  graphics::par(mai = c(bottom, left, top, right) / indici_dpi, xaxs = "i", yaxs = "i")
  graphics::plot.window(xlim, ylim)
  indici_state$panel <- c(left, indici_state$width - right, top, indici_state$height - bottom)
  indici_state$xlim <- xlim
  indici_state$ylim <- ylim
  invisible(indici_state$panel)
}

indici_px_x <- function(x) {
  p <- indici_state$panel
  p[1] + (x - indici_state$xlim[1]) / diff(indici_state$xlim) * (p[2] - p[1])
}
indici_px_y <- function(y) {
  p <- indici_state$panel
  p[4] - (y - indici_state$ylim[1]) / diff(indici_state$ylim) * (p[4] - p[3])
}

# Valori e titoli degli assi, come nel tema minimal: nessuna linea, tacca o griglia.
indici_axes <- function(x_at, x_labels, y_at, y_labels, xtitle, ytitle, sizes,
                        label_offset = 23, xtitle_offset = 33, ytitle_x = 27) {
  p <- indici_state$panel
  indici_text(indici_px_x(x_at), p[4] + label_offset, x_labels, sizes$text,
              indici_colour$tick_text)
  indici_text(p[1] - 13, indici_px_y(y_at), y_labels, sizes$text, indici_colour$tick_text,
              adj = c(1, 0.5))
  indici_text((p[1] + p[2]) / 2, indici_state$height - xtitle_offset, xtitle, sizes$axis_title)
  indici_text(ytitle_x, (p[3] + p[4]) / 2, ytitle, sizes$axis_title, srt = 90)
}

# Dimensioni dei testi (pt): quelle dei grafici con tema comune e quelle del grafico
# dei film per adulti, che usa un tema proprio.
indici_large <- list(title = indici_size(28), subtitle = indici_size(24),
                     axis_title = indici_size(24), text = indici_size(20))
indici_small <- list(title = indici_size(16), subtitle = indici_size(12),
                     axis_title = indici_size(11), text = indici_size(10))

# Gradiente da grigio chiaro a verde menta, interpolato in CIELAB come scale_fill_gradient.
indici_gradient <- function(values, limits) {
  ramp <- grDevices::colorRamp(c(indici_colour$grey, indici_colour$mint), space = "Lab")
  scaled <- if (diff(limits) == 0) rep(0.5, length(values)) else (values - limits[1]) / diff(limits)
  colours <- ramp(pmin(pmax(scaled, 0), 1))
  grDevices::rgb(colours[, 1], colours[, 2], colours[, 3], maxColorValue = 255)
}

indici_legend_font <- indici_size(24)
indici_legend_text <- indici_size(20)

# Larghezza in pixel di una legenda a barra di colore (titolo, barra ed etichette).
indici_colorbar_width <- function(title, labels) {
  max(indici_width(title, indici_legend_font), 46 + 15 + indici_width(labels, indici_legend_text))
}

# Legenda a barra di colore a destra del grafico, centrata sull'area del grafico.
indici_colorbar <- function(title, limits, breaks, labels, legend_width) {
  p <- indici_state$panel
  left <- indici_state$width - 30 - legend_width
  centre <- (p[3] + p[4]) / 2
  top <- centre - 90
  bar_height <- 230
  indici_text(left, centre - 121, title, indici_legend_font, adj = c(0, 0.5))
  steps <- 200
  colours <- indici_gradient(seq(limits[2], limits[1], length.out = steps), limits)
  graphics::rasterImage(
    grDevices::as.raster(matrix(colours, ncol = 1)),
    graphics::grconvertX(left / indici_dpi, "inches", "user"),
    graphics::grconvertY((indici_state$height - top - bar_height) / indici_dpi, "inches", "user"),
    graphics::grconvertX((left + 46) / indici_dpi, "inches", "user"),
    graphics::grconvertY((indici_state$height - top) / indici_dpi, "inches", "user"),
    interpolate = TRUE, xpd = NA
  )
  y <- top + bar_height - (breaks - limits[1]) / diff(limits) * bar_height
  for (side in c(0, 1)) {
    x0 <- left + side * 46
    x1 <- x0 + (1 - 2 * side) * 46 / 5
    graphics::segments(
      graphics::grconvertX(x0 / indici_dpi, "inches", "user"),
      graphics::grconvertY((indici_state$height - y) / indici_dpi, "inches", "user"),
      graphics::grconvertX(x1 / indici_dpi, "inches", "user"),
      graphics::grconvertY((indici_state$height - y) / indici_dpi, "inches", "user"),
      col = "white", lwd = 1, xpd = NA
    )
  }
  indici_text(left + 46 + 15, y, labels, indici_legend_text, adj = c(0, 0.5))
}

indici_rgb_blend <- function(colour, alpha) {
  rgb <- grDevices::col2rgb(colour)[, 1]
  grDevices::rgb(t(alpha * rgb + (1 - alpha) * 255), maxColorValue = 255)
}

# Andamento del numero di film proposti per anno.
indici_chart_anni <- function(data, path, family) {
  counts <- indici_data_anni(data)
  sizes <- indici_large
  xlim <- indici_expand_range(range(counts$anno))
  ylim <- indici_expand_range(range(counts$n))
  x_at <- indici_breaks(xlim)
  y_at <- indici_breaks(ylim)
  indici_open(path, 3, family)
  on.exit(grDevices::dev.off(), add = TRUE)
  p <- indici_panel(xlim, ylim, format(y_at, trim = TRUE), sizes$text, top = 114, bottom = 95)
  graphics::lines(counts$anno, counts$n, col = indici_colour$mint, lwd = indici_lwd$line, lend = "butt",
                  ljoin = "round")
  indici_text(p[1], 29, "Un viaggio nella sala buia", sizes$title, adj = c(0, 0.5))
  indici_text(p[1], 80, paste("Frequenza dei film proposti dal", min(data$anno), "al", max(data$anno)),
              sizes$subtitle, adj = c(0, 0.5))
  indici_axes(x_at, format(x_at, trim = TRUE), y_at, format(y_at, trim = TRUE), "Anni",
              "Numero di film", sizes)
  invisible(path)
}

# Mappa di calore delle tipologie di fonti per decennio.
indici_chart_fonti <- function(data, path, family) {
  tiles <- indici_data_fonti(data)
  sizes <- indici_large
  types <- levels(tiles$tipo)
  row <- match(tiles$tipo, types)
  xlim <- indici_expand_range(range(tiles$decennio) + c(-5, 5))
  ylim <- c(0.4, length(types) + 0.6)
  limits <- range(tiles$n)
  fill_at <- indici_breaks(limits)
  fill_labels <- format(fill_at, trim = TRUE)
  legend_width <- indici_colorbar_width("N\u00b0 film", fill_labels)
  indici_open(path, 3, family)
  on.exit(grDevices::dev.off(), add = TRUE)
  p <- indici_panel(xlim, ylim, types, sizes$text, top = 67, bottom = 95,
                    legend_width = legend_width)
  graphics::rect(tiles$decennio - 5, row - 0.5, tiles$decennio + 5, row + 0.5,
                 col = indici_gradient(tiles$n, limits), border = "white", lwd = indici_lwd$border)
  indici_text((p[1] + p[2]) / 2, 29, "Presenza delle fonti per decennio", sizes$title)
  x_at <- indici_breaks(xlim)
  indici_axes(x_at, format(x_at, trim = TRUE), seq_along(types), types, "Anni", "Fonti", sizes)
  indici_colorbar("N\u00b0 film", limits, fill_at, fill_labels, legend_width)
  invisible(path)
}

# Mappa di calore dei generi per decennio e andamento dei film per adulti.
indici_chart_generi <- function(data, path, family) {
  generi <- indici_data_generi(data)
  tiles <- generi$tiles
  sizes <- indici_large
  decades <- sort(unique(tiles$decennio))
  genres <- rev(generi$order)
  limits <- range(tiles$prop)
  fill_at <- indici_breaks(limits)
  fill_labels <- format(fill_at, trim = TRUE)
  legend_width <- indici_colorbar_width("Percentuale", fill_labels)
  indici_open(path, 5, family)
  on.exit(grDevices::dev.off(), add = TRUE)
  p <- indici_panel(c(0.4, length(decades) + 0.6), c(0.4, length(genres) + 0.6), genres,
                    sizes$text, top = 67, bottom = 94, legend_width = legend_width)
  column <- match(tiles$decennio, decades)
  row <- match(tiles$genere, genres)
  graphics::rect(column - 0.5, row - 0.5, column + 0.5, row + 0.5,
                 col = indici_gradient(tiles$prop, limits), border = "white", lwd = indici_lwd$border)
  indici_text((p[1] + p[2]) / 2, 29, "Dominanza dei generi per decennio", sizes$title)
  indici_axes(seq_along(decades), as.character(decades), seq_along(genres), genres,
              "Decennio", "Genere", sizes)
  indici_colorbar("Percentuale", limits, fill_at, fill_labels, legend_width)
  invisible(path)
}

indici_chart_adulti <- function(data, path, family) {
  yearly <- indici_data_adulti(data)
  sizes <- indici_small
  xlim <- indici_expand_range(range(yearly$anno))
  ylim <- indici_expand_range(range(c(0, yearly$perc, 50)))
  x_at <- indici_breaks(xlim)
  y_at <- indici_breaks(ylim)
  indici_open(path, 3, family)
  on.exit(grDevices::dev.off(), add = TRUE)
  p <- indici_panel(xlim, ylim, format(y_at, trim = TRUE), sizes$text, top = 80, bottom = 64,
                    ytitle_x = 20, ytitle_gap = 18, right_margin = 21)
  graphics::polygon(c(yearly$anno, rev(yearly$anno)), c(yearly$perc, rep(0, nrow(yearly))),
                    col = indici_rgb_blend(indici_colour$mint, 0.8), border = NA)
  graphics::abline(h = 50, lty = "dashed", col = "red", lwd = indici_lwd$dash)
  indici_text(p[1], 21, "Percentuale annuale di film per adulti nella programmazione", sizes$title,
              adj = c(0, 0.5))
  indici_text(p[1], 57, "Linea tratteggiata = soglia del 50%", sizes$subtitle, adj = c(0, 0.5))
  indici_axes(x_at, format(x_at, trim = TRUE), y_at, format(y_at, trim = TRUE), "Anno",
              "Percentuale (%)", sizes, label_offset = 15, xtitle_offset = 25, ytitle_x = 20)
  invisible(path)
}

# Percentuale di film italiani ed esteri per decennio, con legenda a chiavi colorate.
indici_chart_italia <- function(data, path, family) {
  share <- indici_data_italia(data)
  sizes <- indici_large
  labels <- c("Estero", "Italia")
  fills <- c(indici_colour$grey, indici_colour$mint)
  key <- 44
  legend_width <- key + 16 + indici_width(labels, indici_legend_text)
  xlim <- indici_expand_range(range(share$decennio) + c(-4.5, 4.5))
  ylim <- indici_expand_range(c(0, 100))
  y_at <- indici_breaks(ylim)
  x_at <- indici_breaks(xlim)
  y_labels <- format(y_at, trim = TRUE)
  indici_open(path, 3, family)
  on.exit(grDevices::dev.off(), add = TRUE)
  p <- indici_panel(xlim, ylim, y_labels, sizes$text, top = 67, bottom = 95,
                    legend_width = legend_width)
  graphics::rect(share$decennio - 4.5, 0, share$decennio + 4.5, share$italia, col = fills[2],
                 border = NA)
  graphics::rect(share$decennio - 4.5, share$italia, share$decennio + 4.5, 100, col = fills[1],
                 border = NA)
  indici_text((p[1] + p[2]) / 2, 29, "Cinema italiano vs estero: evoluzione per decennio", sizes$title)
  indici_axes(x_at, format(x_at, trim = TRUE), y_at, y_labels, "Decennio", "% sul totale", sizes)
  left <- indici_state$width - 30 - legend_width
  top <- (p[3] + p[4]) / 2 - 20
  for (i in 1:2) {
    indici_rect(left, top + (i - 1) * key, left + key, top + i * key, col = fills[i], border = NA)
    indici_text(left + key + 16, top + (i - 0.5) * key, labels[i], indici_legend_text,
                adj = c(0, 0.5))
  }
  invisible(path)
}

# Numero di paesi di produzione rappresentati in ogni decennio.
indici_chart_paesi <- function(data, path, family) {
  counts <- indici_data_paesi(data)
  sizes <- indici_large
  position <- seq_len(nrow(counts))
  ylim <- indici_expand_range(range(counts$n))
  y_at <- indici_breaks(ylim)
  y_labels <- format(y_at, trim = TRUE)
  indici_open(path, 3, family)
  on.exit(grDevices::dev.off(), add = TRUE)
  p <- indici_panel(c(0.4, nrow(counts) + 0.6), ylim, y_labels, sizes$text, top = 67,
                    bottom = 95, ytitle_x = 26)
  graphics::lines(position, counts$n, col = indici_colour$mint, lwd = indici_lwd$line, lend = "butt",
                  ljoin = "round")
  indici_text((p[1] + p[2]) / 2, 29, "Numero di paesi rappresentati nella programmazione per decennio",
              sizes$title)
  indici_axes(position, as.character(counts$decennio), y_at, y_labels, "Decennio",
              "Numero di paesi distinti", sizes, ytitle_x = 26)
  invisible(path)
}

# Registra il font del sito leggendolo dal file locale: nessun download.
indici_font <- function(project_root) {
  family <- "merriweather"
  font <- file.path(project_root, "static", "fonts", "merriweather-v13-latin-regular.woff")
  if (!file.exists(font)) {
    stop("Font Merriweather non trovato: ", font, call. = FALSE)
  }
  sysfonts::font_add(family, font)
  family
}

indici_charts <- list(
  anni = list(indici_chart_anni),
  fonti = list(indici_chart_fonti),
  generi = list(indici_chart_generi, indici_chart_adulti),
  paesi = list(indici_chart_italia, indici_chart_paesi)
)

# Genera i grafici delle pagine indice. I testi degli _index.md non vengono modificati:
# i file PNG sostituiscono quelli che prima produceva knitr.
update_indici <- function(project_root = ".", sections = indici_sections,
                          output_dir = file.path(project_root, "static", "programmazione-storica")) {
  check_indici_packages()
  project_root <- normalizePath(project_root, mustWork = TRUE)
  unknown <- setdiff(sections, indici_sections)
  if (length(unknown)) {
    stop("Sezioni sconosciute: ", paste(unknown, collapse = ", "), call. = FALSE)
  }
  data <- indici_load(project_root)
  family <- indici_font(project_root)
  previous_opts <- showtext::showtext_opts()
  showtext::showtext_auto(TRUE)
  showtext::showtext_opts(dpi = indici_dpi)
  on.exit({
    showtext::showtext_auto(FALSE)
    do.call(showtext::showtext_opts, previous_opts)
  }, add = TRUE)
  paths <- character()
  for (section in sections) {
    spec <- indici_files[[section]]
    directory <- file.path(output_dir, spec$directory, "_index_files", "figure-html")
    if (!dir.exists(directory) && !dir.create(directory, recursive = TRUE)) {
      stop("Impossibile creare la cartella: ", directory, call. = FALSE)
    }
    for (i in seq_along(spec$files)) {
      path <- file.path(directory, spec$files[i])
      indici_charts[[section]][[i]](data, path, family)
      paths <- c(paths, path)
    }
    message("Generati i grafici dell'indice: ", section)
  }
  invisible(paths)
}

if (sys.nframe() == 0L) update_indici()
