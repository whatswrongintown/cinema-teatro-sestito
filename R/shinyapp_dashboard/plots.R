dashboard_plot_colour <- "#CBF8DF"

dashboard_no_plot <- function(message) {
  graphics::plot.new()
  graphics::text(0.5, 0.5, message, family = "dashboard-merriweather")
}

dashboard_month_plot <- function(entries) {
  counts <- dashboard_month_counts(entries)
  if (!nrow(entries)) return(dashboard_no_plot("Nessuna proiezione registrata"))
  graphics::par(family = "dashboard-merriweather", mar = c(4, 4.5, 3, 1),
                las = 1, bty = "l")
  ymax <- max(counts$Proiezioni)
  positions <- graphics::barplot(
    counts$Proiezioni, names.arg = counts$Mese, col = dashboard_plot_colour,
    border = NA, ylim = c(0, ymax * 1.18),
    ylab = "Numero di proiezioni", xlab = "",
    main = paste("Totale proiezioni:", nrow(entries)), cex.names = 0.8
  )
  graphics::text(positions, counts$Proiezioni, labels = counts$Proiezioni,
                 pos = 3, cex = 0.8, offset = 0.25)
}

dashboard_genre_plot <- function(films) {
  counts <- dashboard_genre_counts(films)
  if (!nrow(counts)) return(dashboard_no_plot("Generi non disponibili"))
  counts <- counts[rev(seq_len(nrow(counts))), , drop = FALSE]
  graphics::par(family = "dashboard-merriweather", mar = c(4, 9.5, 1, 2.5),
                las = 1, bty = "l")
  positions <- graphics::barplot(
    counts$Film, names.arg = counts$Genere, horiz = TRUE,
    col = dashboard_plot_colour, border = NA,
    xlim = c(0, max(counts$Film) * 1.22), xlab = "Film distinti",
    cex.names = 0.7
  )
  graphics::text(counts$Film, positions, labels = counts$Film, pos = 4,
                 cex = 0.7, offset = 0.25)
}

dashboard_imdb_plot <- function(films, place_labels) {
  rated <- dashboard_rated_films(films)
  if (!nrow(rated)) return(dashboard_no_plot("Dati IMDb non disponibili"))
  graphics::par(family = "dashboard-merriweather", mar = c(5, 4.5, 1.5, 1),
                las = 1, bty = "l")
  graphics::plot(
    rated$imdb_votes, rated$imdb_rating, log = "x", pch = 16,
    col = dashboard_plot_colour, cex = 0.95,
    xlab = "Numero di voti (log)", ylab = "Valutazioni medie IMDb",
    ylim = c(0, 10), xaxt = "n", yaxt = "n"
  )
  graphics::axis(1)
  graphics::axis(2, at = seq(0, 10, by = 2))
  usr <- graphics::par("usr")
  pin <- graphics::par("pin")
  x <- (log10(rated$imdb_votes) - usr[1]) / diff(usr[1:2]) * pin[1]
  y <- (rated$imdb_rating - usr[3]) / diff(usr[3:4]) * pin[2]
  candidates <- which(!duplicated(paste(rated$recorded_title, x, y)))
  isolation <- (x[candidates] - mean(x))^2 + (y[candidates] - mean(y))^2
  # Limit placement work for the all-years view; the values table remains complete.
  chosen <- head(candidates[order(-isolation)], 250L)
  labels <- rated$recorded_title[chosen]
  label_cex <- 7.5 / 12
  layout <- place_labels(
    x[chosen], y[chosen],
    graphics::strwidth(labels, units = "inches", cex = label_cex),
    graphics::strheight("Mg", units = "inches", cex = label_cex),
    pin[1], pin[2]
  )
  shown <- which(layout$ring > 0L)
  if (length(chosen) < nrow(rated)) {
    shown <- shown[vapply(shown, function(i) {
      box <- layout$box[i, ]
      !any(x + 0.04 > box[1] & x - 0.04 < box[2] &
             y + 0.04 > box[3] & y - 0.04 < box[4])
    }, logical(1))]
  }
  if (length(shown)) {
    label_x <- 10^(usr[1] + layout$centre[shown, 1L] / pin[1] * diff(usr[1:2]))
    label_y <- usr[3] + layout$centre[shown, 2L] / pin[2] * diff(usr[3:4])
    graphics::text(label_x, label_y, labels[shown], cex = label_cex)
  }
  graphics::mtext("Information courtesy of IMDb (https://www.imdb.com)",
                  side = 1, line = 3.4, adj = 1, cex = 0.65)
  invisible(labels[shown])
}
