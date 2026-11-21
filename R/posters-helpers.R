POSTER_SIZE_PRIORITY <- c("100x140", "70x100", "140x200", "50x70", "33x70")
POSTER_SQUARE_MIN <- 0.95
POSTER_SQUARE_MAX <- 1.05

poster_normalize_size <- function(width, height) {
  dimensions <- sort(c(as.integer(width), as.integer(height)))
  paste(dimensions, collapse = "x")
}

poster_parse_filename <- function(filename, category, folder_size = NULL) {
  pattern <- paste0(
    "^((?:tt[0-9]{7,8}|[0-9]+))_([0-9]+)x([0-9]+)_",
    "([0-9]+|r(?:[_-]?[0-9]+)?)\\.(?:jpe?g|png)$"
  )
  match <- regmatches(basename(filename),
                      regexec(pattern, basename(filename), ignore.case = TRUE, perl = TRUE))[[1]]
  if (!length(match)) {
    return(list(value = NULL, warnings = "filename does not match the poster pattern"))
  }
  id <- match[2]
  if (grepl("^tt", id, ignore.case = TRUE)) id <- tolower(id)
  dimensions <- suppressWarnings(as.numeric(match[3:4]))
  if (any(!is.finite(dimensions)) || any(dimensions < 1) ||
      any(dimensions > .Machine$integer.max)) {
    return(list(value = NULL, warnings = "poster size is outside the valid range"))
  }
  size <- poster_normalize_size(dimensions[1], dimensions[2])
  token <- tolower(match[5])
  is_retro_token <- startsWith(token, "r")
  digits <- if (is_retro_token) sub("^r[_-]?", "", token) else token
  number <- if (digits == "") 1 else suppressWarnings(as.numeric(digits))
  if (!is.finite(number) || number < 1 || number > .Machine$integer.max) {
    return(list(value = NULL, warnings = "poster number is outside the valid range"))
  }
  warnings <- character()
  if (is_retro_token != (category == "retro")) {
    warnings <- c(warnings, "poster token does not match its folder category")
  }
  if (!is.null(folder_size) && !identical(size, folder_size)) {
    warnings <- c(warnings, "filename size does not match its folder")
  }
  list(
    value = data.frame(source_id = id, category = category, size = size,
                       poster_number = as.integer(number), is_retro = category == "retro",
                       stringsAsFactors = FALSE),
    warnings = warnings
  )
}

poster_orientation <- function(width, height) {
  if (length(width) != 1L || length(height) != 1L ||
      !is.finite(width) || !is.finite(height) || width <= 0 || height <= 0) {
    stop("Image dimensions must be positive scalars.", call. = FALSE)
  }
  ratio <- width / height
  if (ratio < POSTER_SQUARE_MIN) "portrait" else if (ratio > POSTER_SQUARE_MAX) {
    "landscape"
  } else "square"
}

poster_unique_files <- function(posters) {
  required <- c("path", "source_id", "category", "size", "poster_number")
  if (!all(required %in% names(posters))) stop("Missing poster identity columns.", call. = FALSE)
  posters <- posters[order(posters$path, method = "radix"), , drop = FALSE]
  keys <- posters[c("source_id", "category", "size", "poster_number")]
  duplicate <- duplicated(keys)
  list(posters = posters[!duplicate, , drop = FALSE],
       duplicates = posters[duplicate, , drop = FALSE])
}

poster_representatives <- function(posters, by_size = FALSE) {
  required <- c("film_id", "category", "size", "poster_number", "is_retro")
  if (!all(required %in% names(posters))) stop("Missing representative selection columns.", call. = FALSE)
  if (!nrow(posters)) return(posters)
  priority <- match(posters$size, POSTER_SIZE_PRIORITY)
  priority[is.na(priority)] <- length(POSTER_SIZE_PRIORITY) + 1L
  ordering <- order(posters$film_id, posters$is_retro, priority,
                    posters$size, posters$poster_number, posters$category,
                    method = "radix")
  posters <- posters[ordering, , drop = FALSE]
  grouping <- c("film_id", "is_retro")
  if (by_size) grouping <- c(grouping, "category", "size")
  posters[!duplicated(posters[grouping]), , drop = FALSE]
}

poster_match_ids <- function(source_ids, screenings, poster_metadata = NULL) {
  if (!all(c("const", "title") %in% names(screenings))) {
    stop("Screenings must contain const and title columns.", call. = FALSE)
  }
  if (!is.character(source_ids) || !is.character(screenings$const) ||
      ("internal_poster_code" %in% names(screenings) &&
       !is.character(screenings$internal_poster_code))) {
    stop("Poster identifiers and codes must be read as character.", call. = FALSE)
  }
  if (!is.null(poster_metadata) &&
      (!all(c("internal_poster_code", "title", "year") %in% names(poster_metadata)) ||
       !is.character(poster_metadata$internal_poster_code))) {
    stop("Poster metadata must contain character internal_poster_code, title and year columns.",
         call. = FALSE)
  }
  codes <- if ("internal_poster_code" %in% names(screenings)) {
    trimws(screenings$internal_poster_code)
  } else rep("", nrow(screenings))
  ids <- trimws(screenings$const)
  titles <- trimws(screenings$title)
  ids[is.na(ids)] <- ""
  codes[is.na(codes)] <- ""
  codes[codes == "0"] <- ""
  titles[is.na(titles)] <- ""
  metadata_codes <- if (is.null(poster_metadata)) character() else {
    trimws(poster_metadata$internal_poster_code)
  }
  metadata_codes[is.na(metadata_codes)] <- ""
  result <- lapply(source_ids, function(source_id) {
    imdb <- grepl("^tt[0-9]{7,8}$", source_id)
    if (!imdb && !grepl("^[0-9]+$", source_id)) {
      stop("Invalid poster identifier: ", source_id, call. = FALSE)
    }
    rows <- if (imdb) which(ids == source_id) else which(codes == source_id)
    metadata_rows <- if (imdb) integer() else which(metadata_codes == source_id)
    matching_ids <- unique(ids[rows][nzchar(ids[rows])])
    matching_titles <- unique(titles[rows][nzchar(titles[rows])])
    metadata_titles <- if (length(metadata_rows)) {
      trimws(as.character(poster_metadata$title[metadata_rows]))
    } else character()
    metadata_titles <- metadata_titles[!is.na(metadata_titles) & nzchar(metadata_titles)]
    year <- if (length(metadata_rows)) {
      years <- trimws(as.character(poster_metadata$year[metadata_rows]))
      years <- years[!is.na(years) & nzchar(years)]
      if (length(years)) years[1] else NA_character_
    } else NA_character_
    if (!imdb && length(matching_ids) > 1L) {
      stop("Internal code ", source_id, " maps to multiple IMDb IDs.", call. = FALSE)
    }
    film_id <- if (imdb) source_id else if (length(matching_ids)) {
      matching_ids[1]
    } else paste0("internal-", source_id)
    data.frame(source_id = source_id, film_id = film_id,
               id_type = if (startsWith(film_id, "tt")) "imdb" else "internal",
               title = if (length(matching_titles)) matching_titles[1] else if (length(metadata_titles)) {
                 metadata_titles[1]
               } else film_id,
               production_year = year,
               matched = length(rows) > 0L || length(metadata_rows) > 0L,
               multiple_titles = !imdb &&
                 length(unique(c(matching_titles, metadata_titles))) > 1L,
               stringsAsFactors = FALSE)
  })
  if (!length(result)) {
    return(data.frame(source_id = character(), film_id = character(), id_type = character(),
                      title = character(), production_year = character(),
                      matched = logical(), multiple_titles = logical()))
  }
  do.call(rbind, result)
}
