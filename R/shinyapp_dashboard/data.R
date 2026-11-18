dashboard_static_dir <- function() {
  candidates <- c(
    "static",
    file.path("..", "..", "static")
  )
  for (candidate in candidates) {
    paths <- file.path(candidate, "data",
                       c("programmazione_agende.csv", "programmazione_imdb.csv"))
    if (all(file.exists(paths))) return(normalizePath(candidate))
  }
  stop("CSV della programmazione non trovati in static/data.", call. = FALSE)
}

dashboard_read_csv <- function(path, required) {
  data <- utils::read.csv(
    path, colClasses = "character", na.strings = c("", "NA"),
    check.names = FALSE, strip.white = TRUE, fill = FALSE,
    comment.char = "", fileEncoding = "UTF-8-BOM", stringsAsFactors = FALSE
  )
  missing <- setdiff(required, names(data))
  if (length(missing)) {
    stop("Colonne mancanti in ", path, ": ", paste(missing, collapse = ", "),
         call. = FALSE)
  }
  data
}

dashboard_split_values <- function(value) {
  if (is.na(value) || !nzchar(trimws(value))) return(character())
  values <- trimws(strsplit(value, ",", fixed = TRUE)[[1]],
                   whitespace = "[\\h\\v]")
  unique(values[nzchar(values)])
}

dashboard_number <- function(value, name, minimum, maximum = Inf, integer = FALSE) {
  number <- suppressWarnings(as.numeric(value))
  invalid <- !is.na(value) &
    (!is.finite(number) | number < minimum | number > maximum |
       (integer & number != floor(number)))
  if (any(invalid)) stop("Valori non validi: ", name, call. = FALSE)
  number
}

dashboard_load_data <- function(static_dir) {
  entries <- dashboard_read_csv(
    file.path(static_dir, "data", "programmazione_agende.csv"),
    c("date", "const", "title", "source")
  )
  films <- dashboard_read_csv(
    file.path(static_dir, "data", "programmazione_imdb.csv"),
    c("Const", "Title", "Year", "Directors", "Genres", "IMDb Rating", "Num Votes")
  )
  for (column in c("date", "const", "title", "source")) {
    if (anyNA(entries[[column]]) || any(!nzchar(trimws(entries[[column]])))) {
      stop("Valori mancanti nelle proiezioni: ", column, call. = FALSE)
    }
  }
  if (!nrow(entries) || !nrow(films) || anyNA(films$Const) ||
      any(!grepl("^tt[0-9]+$", films$Const)) || anyDuplicated(films$Const) ||
      any(!grepl("^tt[0-9]+$", entries$const))) {
    stop("Database vuoto o identificativi IMDb mancanti, duplicati o non validi.",
         call. = FALSE)
  }
  dates <- as.Date(entries$date, format = "%Y-%m-%d")
  if (anyNA(dates) || any(format(dates, "%Y-%m-%d") != entries$date)) {
    stop("Le date devono essere valide e nel formato YYYY-MM-DD.", call. = FALSE)
  }
  matches <- match(entries$const, films$Const)
  if (anyNA(matches)) {
    stop("Film senza metadati IMDb: ",
         paste(sort(unique(entries$const[is.na(matches)])), collapse = ", "),
         call. = FALSE)
  }
  rating <- dashboard_number(films[["IMDb Rating"]], "IMDb Rating", 0, 10)
  votes <- dashboard_number(films[["Num Votes"]], "Num Votes", 0, integer = TRUE)
  release_year <- dashboard_number(films$Year, "Year", 1, 9999, integer = TRUE)

  film_titles <- films$Title[matches]
  missing_titles <- is.na(film_titles) | !nzchar(trimws(film_titles))
  film_titles[missing_titles] <- entries$title[missing_titles]
  result <- data.frame(
    film_id = entries$const,
    date = dates,
    screening_year = as.integer(format(dates, "%Y")),
    recorded_title = entries$title,
    title = film_titles,
    release_year = release_year[matches],
    imdb_rating = rating[matches],
    imdb_votes = votes[matches],
    stringsAsFactors = FALSE
  )
  result$directors <- lapply(films$Directors[matches], dashboard_split_values)
  result$genres <- lapply(films$Genres[matches], dashboard_split_values)
  result$sources <- lapply(entries$source, dashboard_split_values)
  result <- result[order(result$date, result$film_id), , drop = FALSE]
  rownames(result) <- NULL
  list(entries = result)
}

dashboard_unique_films <- function(entries) {
  entries[!duplicated(entries$film_id), , drop = FALSE]
}

dashboard_choices <- function(values) {
  sort(unique(unlist(values, use.names = FALSE)), na.last = NA)
}

dashboard_list_text <- function(values) {
  vapply(values, function(x) {
    if (length(x)) paste(x, collapse = ", ") else "Non disponibile"
  }, character(1))
}

dashboard_title_links <- function(titles, ids) {
  if (anyNA(ids) || any(!grepl("^tt[0-9]+$", ids))) {
    stop("Identificativo IMDb non valido.", call. = FALSE)
  }
  paste0('<a href="https://www.imdb.com/title/', ids,
         '/" target="_blank" rel="noopener noreferrer">',
         htmltools::htmlEscape(titles), "</a>")
}

dashboard_month_counts <- function(entries) {
  months <- c("Gen", "Feb", "Mar", "Apr", "Mag", "Giu",
              "Lug", "Ago", "Set", "Ott", "Nov", "Dic")
  counts <- tabulate(as.integer(format(entries$date, "%m")), nbins = 12L)
  data.frame(Mese = months, Proiezioni = counts)
}

dashboard_genre_counts <- function(films) {
  values <- unlist(films$genres, use.names = FALSE)
  counts <- sort(table(values), decreasing = TRUE)
  data.frame(Genere = names(counts), Film = as.integer(counts),
             row.names = NULL)
}

dashboard_director_counts <- function(films) {
  counts <- sort(table(unlist(films$directors, use.names = FALSE)),
                 decreasing = TRUE)
  data.frame(Regia = names(counts), Film = as.integer(counts), row.names = NULL)
}

dashboard_rated_films <- function(films) {
  films[is.finite(films$imdb_rating) & is.finite(films$imdb_votes) &
          films$imdb_votes > 0, , drop = FALSE]
}

dashboard_ranking <- function(films, descending = TRUE) {
  rated <- dashboard_rated_films(films)
  score <- if (descending) -rated$imdb_rating else rated$imdb_rating
  rated <- rated[order(score, -rated$imdb_votes, rated$film_id), , drop = FALSE]
  head(rated, 5L)
}
