POSTER_THUMB_WIDTH <- 400L
POSTER_LARGE_SIDE <- 1400L
POSTER_THUMB_QUALITY <- 75L
POSTER_LARGE_QUALITY <- 80L
POSTER_QUALITY_FLOOR <- 60L
POSTER_QUALITY_STEP <- 5L
POSTER_THUMB_CEILING <- 60L * 1024L
POSTER_LARGE_CEILING <- 400L * 1024L
POSTER_RATIO_TOLERANCE <- 0.12
POSTER_WEBP_METHOD <- 2L

poster_read_csv <- function(path) {
  if (!file.exists(path)) stop("Missing poster input CSV: ", path, call. = FALSE)
  bytes <- readBin(path, "raw", n = file.info(path)$size)
  text <- rawToChar(bytes)
  encoding <- if (!is.na(iconv(text, from = "UTF-8", to = "UTF-8"))) {
    "UTF-8"
  } else "windows-1252"
  header <- strsplit(iconv(text, from = encoding, to = "UTF-8"), "\n", fixed = TRUE)[[1]][1]
  counts <- vapply(c(",", ";", "\t"), function(x) {
    length(gregexpr(x, header, fixed = TRUE)[[1]][gregexpr(x, header, fixed = TRUE)[[1]] > 0L])
  }, integer(1))
  delimiter <- c(",", ";", "\t")[which.max(counts)]
  if (!max(counts)) stop("Cannot detect CSV delimiter in ", path, call. = FALSE)
  result <- readr::read_delim(path, delim = delimiter, locale = readr::locale(encoding = encoding),
                              col_types = readr::cols(.default = readr::col_character()),
                              show_col_types = FALSE, progress = FALSE)
  problems <- readr::problems(result)
  if (nrow(problems)) stop("CSV parsing problems in ", path, ": ",
                           paste(capture.output(print(problems)), collapse = " "), call. = FALSE)
  values <- unlist(result, use.names = FALSE)
  dot <- any(grepl("^[+-]?[0-9]+\\.[0-9]+$", values))
  comma <- any(grepl("^[+-]?[0-9]+,[0-9]+$", values))
  decimal <- if (dot && comma) "mixed" else if (dot) "." else if (comma) "," else "not detected"
  message(basename(path), ": delimiter=", if (delimiter == "\t") "tab" else delimiter,
          ", encoding=", encoding, ", decimal mark=", decimal)
  as.data.frame(result, stringsAsFactors = FALSE)
}

poster_months <- function(values) {
  months <- character()
  invalid <- character()
  for (value in unique(values[!is.na(values) & nzchar(trimws(values))])) {
    dates <- regmatches(value, gregexpr("[0-9]{4}-[0-9]{2}-[0-9]{2}|[0-9]{2}/[0-9]{2}/[0-9]{4}",
                                       value, perl = TRUE))[[1]]
    parsed <- as.Date(ifelse(grepl("/", dates, fixed = TRUE),
                             format(as.Date(dates, format = "%d/%m/%Y"), "%Y-%m-%d"),
                             dates))
    if (!length(parsed) || any(is.na(parsed)) || length(parsed) > 2L ||
        (length(parsed) == 2L && parsed[2] < parsed[1])) {
      invalid <- c(invalid, value)
      next
    }
    start <- as.Date(format(parsed[1], "%Y-%m-01"))
    end <- as.Date(format(parsed[length(parsed)], "%Y-%m-01"))
    months <- c(months, format(seq(start, end, by = "month"), "%Y-%m"))
  }
  list(months = sort(unique(months)), invalid = invalid)
}

poster_slug <- function(value) {
  ascii <- iconv(value, from = "UTF-8", to = "ASCII//TRANSLIT")
  ascii[is.na(ascii)] <- value[is.na(ascii)]
  result <- tolower(gsub("[^a-zA-Z0-9]+", "-", ascii))
  gsub("^-+|-+$", "", result)
}

poster_sort_key <- function(title) {
  title <- trimws(tolower(title))
  title <- sub("^(il|lo|la|i|gli|le|un|uno|una|the|a|an)[[:space:]]+", "", title)
  title <- sub("^l['\u2019]", "", title)
  slug <- poster_slug(title)
  ifelse(nzchar(slug), slug, "#")
}

poster_make_metadata <- function(posters, screenings, imdb, supplementary, poster_metadata = NULL) {
  required <- c("date", "const", "title", "internal_poster_code")
  if (!all(required %in% names(screenings))) stop("Screenings CSV lacks required columns.", call. = FALSE)
  if (!all(c("Const", "Title", "Year", "Genres") %in% names(imdb))) {
    stop("IMDb CSV lacks required columns.", call. = FALSE)
  }
  if (!all(c("internal_poster_code", "title", "year") %in% names(supplementary))) {
    stop("Supplemental poster CSV lacks required columns.", call. = FALSE)
  }
  if (is.null(poster_metadata)) {
    poster_metadata <- data.frame(Const = character(), Title = character(), Year = character(),
                                  Genres = character())
  }
  if (!all(c("Const", "Title", "Year", "Genres") %in% names(poster_metadata))) {
    stop("Poster metadata CSV lacks required columns.", call. = FALSE)
  }
  reports <- list()
  add_report <- function(path, reason) reports[[length(reports) + 1L]] <<-
    data.frame(path = path, reason = reason, stringsAsFactors = FALSE)
  imdb$Const <- trimws(imdb$Const)
  duplicated_ids <- unique(imdb$Const[duplicated(imdb$Const) & !is.na(imdb$Const)])
  for (id in duplicated_ids) {
    add_report(id, "duplicate IMDb metadata; used first row")
    warning(id, ": duplicate IMDb metadata; used first row.", call. = FALSE, immediate. = TRUE)
  }
  imdb <- imdb[!duplicated(imdb$Const), , drop = FALSE]
  screenings$const <- trimws(screenings$const)
  screenings$internal_poster_code <- trimws(screenings$internal_poster_code)
  screenings$internal_poster_code[is.na(screenings$internal_poster_code) |
                                    screenings$internal_poster_code == "0"] <- ""
  screenings$const[is.na(screenings$const)] <- ""
  ids <- unique(posters$source_id)
  matching <- poster_match_ids(ids, screenings, supplementary)
  matching$matched <- matching$matched | matching$source_id %in% imdb$Const |
    matching$source_id %in% trimws(poster_metadata$Const)
  for (i in seq_len(nrow(matching))) {
    if (!matching$matched[i]) add_report(matching$source_id[i], "poster has no metadata match")
    if (matching$multiple_titles[i]) {
      add_report(matching$source_id[i], "conflicting titles; used first preferred title")
      warning(matching$source_id[i], ": conflicting titles; used first preferred title.",
              call. = FALSE, immediate. = TRUE)
    }
  }
  posters$film_id <- matching$film_id[match(posters$source_id, matching$source_id)]
  films <- list()
  for (film_id in unique(posters$film_id)) {
    maps <- matching[matching$film_id == film_id, , drop = FALSE]
    codes <- maps$source_id[grepl("^[0-9]+$", maps$source_id)]
    rows <- screenings[screenings$const == film_id |
                         (nzchar(screenings$internal_poster_code) &
                            screenings$internal_poster_code %in% codes), , drop = FALSE]
    row_titles <- trimws(rows$title)
    row_titles <- row_titles[!is.na(row_titles) & nzchar(row_titles)]
    imdb_row <- imdb[!is.na(imdb$Const) & imdb$Const == film_id, , drop = FALSE]
    poster_rows <- poster_metadata[!is.na(poster_metadata$Const) &
                                     trimws(poster_metadata$Const) == film_id, , drop = FALSE]
    metadata_rows <- supplementary[!is.na(supplementary$internal_poster_code) &
                                     trimws(supplementary$internal_poster_code) %in% codes, , drop = FALSE]
    supplemental_titles <- trimws(metadata_rows$title)
    supplemental_titles <- supplemental_titles[!is.na(supplemental_titles) & nzchar(supplemental_titles)]
    clean_values <- function(values) {
      values <- trimws(values)
      values[!is.na(values) & nzchar(values)]
    }
    imdb_titles <- clean_values(imdb_row$Title)
    poster_titles <- clean_values(poster_rows$Title)
    titles <- c(imdb_titles, poster_titles, row_titles, supplemental_titles)
    title <- if (length(titles)) titles[1] else film_id
    if (length(unique(titles)) > 1L) {
      add_report(film_id, "conflicting titles; used IMDb, poster metadata, then screening title")
    }
    year <- if (nrow(imdb_row)) imdb_row$Year[1] else NA_character_
    if (is.na(year) || !nzchar(trimws(year))) {
      years <- clean_values(poster_rows$Year)
      year <- if (length(years)) years[1] else NA_character_
    }
    if (is.na(year) || !nzchar(year)) {
      year_column <- intersect(c("production_year", "year", "Year"), names(rows))
      years <- if (length(year_column)) trimws(rows[[year_column[1]]]) else character()
      years <- years[!is.na(years) & nzchar(years)]
      year <- if (length(years)) years[1] else NA_character_
    }
    if (is.na(year) || !nzchar(year)) {
      years <- trimws(metadata_rows$year)
      years <- years[!is.na(years) & nzchar(years)]
      year <- if (length(years)) years[1] else NA_character_
    }
    genre_text <- if (nrow(imdb_row)) imdb_row$Genres[1] else NA_character_
    if (is.na(genre_text) || !nzchar(trimws(genre_text))) {
      values <- clean_values(poster_rows$Genres)
      genre_text <- if (length(values)) values[1] else NA_character_
    }
    if (is.na(genre_text) || !nzchar(genre_text)) {
      genre_column <- intersect(c("genres", "Genres"), names(rows))
      values <- if (length(genre_column)) trimws(rows[[genre_column[1]]]) else character()
      values <- values[!is.na(values) & nzchar(values)]
      genre_text <- if (length(values)) values[1] else NA_character_
    }
    genres <- if (!is.na(genre_text) && nzchar(genre_text)) {
      unique(trimws(strsplit(genre_text, ",", fixed = TRUE)[[1]]))
    } else character()
    genres <- genres[nzchar(genres)]
    dates <- poster_months(rows$date)
    for (date in dates$invalid) add_report(film_id, paste("invalid screening date:", date))
    key <- poster_sort_key(title)
    letter <- toupper(substr(key, 1, 1))
    if (!grepl("^[A-Z]$", letter)) letter <- "#"
    extra_columns <- setdiff(names(poster_rows), c("Const", "Title", "Year", "Genres"))
    extra <- lapply(poster_rows[extra_columns], function(values) unique(clean_values(values)))
    extra <- extra[lengths(extra) > 0L]
    films[[film_id]] <- list(film_id = film_id,
                             id_type = if (startsWith(film_id, "tt")) "imdb" else "internal",
                             imdb_id = if (startsWith(film_id, "tt")) film_id else "",
                             internal_poster_code = if (length(codes)) codes[1] else "",
                             title = title, production_year = if (is.na(year)) "" else year,
                             genres = genres, screening_months = dates$months,
                             screening_dates = sort(unique(rows$date[!is.na(rows$date) & nzchar(rows$date)])),
                             sort_key = key, letter = letter, matched = any(maps$matched), extra = extra)
  }
  posters$title <- vapply(posters$film_id, function(id) films[[id]]$title, character(1))
  posters$alt <- posters$title
  list(posters = posters, films = films,
       report = if (length(reports)) do.call(rbind, reports) else
         data.frame(path = character(), reason = character()))
}

poster_apply_overrides <- function(posters, overrides) {
  fields <- c("film_id", "category", "size", "number", "rotate", "exclude")
  if (!all(fields %in% names(overrides))) stop("Invalid poster overrides columns.", call. = FALSE)
  posters$rotate <- 0L
  posters$exclude <- FALSE
  if (!nrow(overrides)) return(list(posters = posters, report = data.frame(path = character(), reason = character())))
  overrides[] <- lapply(overrides, function(x) trimws(as.character(x)))
  key <- function(film_id, category, size, number) paste(film_id, category, size, number, sep = "\r")
  numbers <- suppressWarnings(as.integer(overrides$number))
  rotation <- suppressWarnings(as.integer(overrides$rotate))
  rotation[is.na(overrides$rotate) | overrides$rotate == ""] <- 0L
  exclude <- toupper(overrides$exclude)
  exclude[is.na(exclude) | exclude == ""] <- "FALSE"
  if (any(is.na(numbers) | numbers < 1L | !grepl("^[0-9]+$", overrides$number)) ||
      any(is.na(rotation) | !rotation %in% c(0L, 90L, 180L, 270L) |
            (!is.na(overrides$rotate) & nzchar(overrides$rotate) & !grepl("^[0-9]+$", overrides$rotate))) ||
      any(!exclude %in% c("TRUE", "FALSE"))) {
    stop("Invalid number, rotation or exclude value in poster overrides.", call. = FALSE)
  }
  override_keys <- key(overrides$film_id, overrides$category, overrides$size, numbers)
  if (anyDuplicated(override_keys)) stop("Duplicate poster overrides.", call. = FALSE)
  poster_keys <- key(posters$film_id, posters$category, posters$size, posters$poster_number)
  indices <- match(poster_keys, override_keys)
  selected <- !is.na(indices)
  posters$rotate[selected] <- rotation[indices[selected]]
  posters$exclude[selected] <- exclude[indices[selected]] == "TRUE"
  unmatched <- which(!override_keys %in% poster_keys)
  report <- data.frame(path = paste(overrides$film_id[unmatched], overrides$category[unmatched],
                                   overrides$size[unmatched], numbers[unmatched], sep = " / "),
                       reason = rep("override did not match a poster", length(unmatched)))
  list(posters = posters, report = report)
}

poster_encode_image <- function(image, geometry, format, quality, ceiling) {
  variant <- magick::image_resize(image, geometry, filter = "Lanczos")
  on.exit(magick::image_destroy(variant))
  if (format == "jpeg") {
    variant <- magick::image_convert(variant, interlace = "Plane")
  }
  dimensions <- magick::image_info(variant)
  repeat {
    defines <- if (format == "webp") c("webp:method" = as.character(POSTER_WEBP_METHOD)) else
      c("jpeg:sampling-factor" = "2x2,1x1,1x1")
    bytes <- magick::image_write(variant, format = format, quality = quality, defines = defines)
    if (length(bytes) <= ceiling || quality <= POSTER_QUALITY_FLOOR) break
    quality <- max(POSTER_QUALITY_FLOOR, quality - POSTER_QUALITY_STEP)
  }
  list(bytes = bytes, width = dimensions$width[1], height = dimensions$height[1],
       quality = quality, exceeds = length(bytes) > ceiling)
}

poster_convert_one <- function(path, rotate, format) {
  original <- magick::image_read(path)
  on.exit(magick::image_destroy(original))
  oriented <- magick::image_orient(original)
  on.exit(magick::image_destroy(oriented), add = TRUE)
  rotated <- if (rotate) magick::image_rotate(oriented, rotate) else oriented
  if (rotate) on.exit(magick::image_destroy(rotated), add = TRUE)
  srgb <- magick::image_convert(rotated, colorspace = "sRGB")
  on.exit(magick::image_destroy(srgb), add = TRUE)
  clean <- magick::image_strip(srgb)
  on.exit(magick::image_destroy(clean), add = TRUE)
  list(thumb = poster_encode_image(clean, paste0(POSTER_THUMB_WIDTH, "x>"), format,
                                   POSTER_THUMB_QUALITY, POSTER_THUMB_CEILING),
       large = poster_encode_image(clean, paste0(POSTER_LARGE_SIDE, "x", POSTER_LARGE_SIDE, ">"),
                                   format, POSTER_LARGE_QUALITY, POSTER_LARGE_CEILING))
}

poster_make_derivatives <- function(posters, project_root) {
  format <- if (isTRUE(magick::magick_config()$webp)) "webp" else "jpeg"
  extension <- if (format == "jpeg") "jpg" else "webp"
  cache_file <- file.path(project_root, ".cache", "posters", "derivatives.rds")
  cache <- if (file.exists(cache_file)) readRDS(cache_file) else list()
  if (!is.list(cache)) stop("Invalid derivative cache.", call. = FALSE)
  reports <- list()
  settings <- c(POSTER_THUMB_WIDTH, POSTER_LARGE_SIDE, POSTER_THUMB_QUALITY, POSTER_LARGE_QUALITY,
                POSTER_QUALITY_FLOOR, POSTER_QUALITY_STEP, POSTER_THUMB_CEILING,
                POSTER_LARGE_CEILING, POSTER_WEBP_METHOD)
  legacy_settings <- c(400L, 1400L, 75L, 80L, 60L, 5L, 60L * 1024L, 400L * 1024L, 2L)
  add_report <- function(path, reason) reports[[length(reports) + 1L]] <<-
    data.frame(path = path, reason = reason, stringsAsFactors = FALSE)
  kept <- rep(TRUE, nrow(posters))
  output_fields <- c("thumb", "large", "thumb_width", "thumb_height", "large_width", "large_height",
                     "thumb_bytes", "large_bytes")
  for (field in output_fields) posters[[field]] <- if (field %in% c("thumb", "large")) "" else 0
  for (i in seq_len(nrow(posters))) {
    path <- file.path(project_root, "manifesti", posters$path[i])
    folder <- poster_slug(dirname(posters$path[i]))
    stem <- sub("\\.[^.]+$", "", basename(posters$path[i]))
    relative <- c(thumb = paste0("images/manifesti/thumbs/", folder, "/", stem, ".", extension),
                  large = paste0("images/manifesti/large/", folder, "/", stem, ".", extension))
    destination <- stats::setNames(file.path(project_root, "static", relative), names(relative))
    info <- file.info(path)
    key <- normalizePath(path, winslash = "/", mustWork = TRUE)
    entry <- cache[[key]]
    entry_settings <- if (!is.null(entry) && is.null(entry$settings)) legacy_settings else entry$settings
    valid <- !is.null(entry) && identical(entry$size, info$size) &&
      identical(entry$mtime, as.numeric(info$mtime)) && identical(entry$rotate, posters$rotate[i]) &&
      identical(entry$format, format) && identical(entry$version, 2L) && identical(entry_settings, settings) &&
      all(file.exists(destination)) &&
      all(file.info(destination)$size == c(entry$thumb_bytes, entry$large_bytes))
    if (!valid) {
      message("Derivatives ", i, "/", nrow(posters), ": ", posters$path[i])
      converted <- tryCatch(poster_convert_one(path, posters$rotate[i], format),
                            error = function(error) error)
      if (inherits(converted, "error")) {
        add_report(posters$path[i], paste("derivative conversion failed:", conditionMessage(converted)))
        kept[i] <- FALSE
        next
      }
      for (kind in c("thumb", "large")) {
        dir.create(dirname(destination[kind]), recursive = TRUE, showWarnings = FALSE)
        writeBin(converted[[kind]]$bytes, destination[kind])
      }
      entry <- list(size = info$size, mtime = as.numeric(info$mtime), rotate = posters$rotate[i],
                    format = format, version = 2L, settings = settings,
                    thumb_width = converted$thumb$width, thumb_height = converted$thumb$height,
                    large_width = converted$large$width, large_height = converted$large$height,
                    thumb_bytes = length(converted$thumb$bytes), large_bytes = length(converted$large$bytes),
                    thumb_quality = converted$thumb$quality, large_quality = converted$large$quality,
                    thumb_exceeds = converted$thumb$exceeds, large_exceeds = converted$large$exceeds)
      cache[[key]] <- entry
      if (i %% 50L == 0L) {
        dir.create(dirname(cache_file), recursive = TRUE, showWarnings = FALSE)
        saveRDS(cache, cache_file)
      }
    }
    if (valid && is.null(entry$settings)) {
      entry$settings <- settings
      cache[[key]] <- entry
    }
    for (kind in c("thumb", "large")) {
      if (entry[[paste0(kind, "_quality")]] == POSTER_QUALITY_FLOOR) {
        suffix <- if (isTRUE(entry[[paste0(kind, "_exceeds")]])) "; exceeds ceiling" else ""
        add_report(posters$path[i], paste0(kind, " reached quality floor", suffix))
      }
    }
    for (field in output_fields) {
      posters[[field]][i] <- if (field %in% c("thumb", "large")) relative[field] else entry[[field]]
    }
  }
  dir.create(dirname(cache_file), recursive = TRUE, showWarnings = FALSE)
  saveRDS(cache, cache_file)
  list(posters = posters[kept, , drop = FALSE],
       report = if (length(reports)) do.call(rbind, reports) else
         data.frame(path = character(), reason = character()))
}

poster_page_specs <- function(posters, films) {
  specs <- list()
  add <- function(path, title, layout, editable = TRUE, description = "", ...) {
    specs[[path]] <<- c(list(title = title, type = "posters", layout = layout),
                        list(...), if (editable) list(description = description, image = "",
                                                      posters_managed = TRUE) else list(generated = TRUE))
  }
  add("_index.md", "Manifesti e locandine", "index", description = "Esplora la raccolta di manifesti e locandine del cinema.")
  collections <- c("printed", "retro")
  for (collection in collections) {
    subset <- posters[posters$is_retro == (collection == "retro"), , drop = FALSE]
    if (!nrow(subset)) next
    if (collection == "retro") {
      add("retro/_index.md", "Retro", "retro", collection = "retro",
          description = "Manifesti realizzati a mano dal cinema quando non era disponibile quello ufficiale, in formati diversi.")
      next
    }
    film_ids <- unique(subset$film_id)
    all_months <- sort(unique(unlist(lapply(films[film_ids], `[[`, "screening_months"))))
    if (length(all_months)) {
      add("by-year/_index.md", "Per anno", "index", collection = collection, browse = "year",
          description = "Manifesti raggruppati per anno e mese di proiezione al cinema.")
    }
    for (year in unique(substr(all_months, 1, 4))) {
      add(paste0("by-year/", year, "/_index.md"), year, "year",
          collection = collection, year = as.integer(year))
    }
    if (collection == "printed") {
      add("by-size/_index.md", "Per formato", "index", collection = collection, browse = "size",
          description = "I formati della raccolta, dalle locandine strette ai manifesti più grandi.")
      add("by-title/_index.md", "Per titolo", "index", collection = collection, browse = "title",
          description = "Tutti i manifesti in ordine alfabetico per titolo del film.")
      sizes <- unique(subset[c("category", "size")])
      for (i in seq_len(nrow(sizes))) {
        category <- sizes$category[i]
        size <- sizes$size[i]
        label <- paste(paste0(toupper(substr(category, 1, 1)), substring(category, 2)), size)
        key <- paste(category, size)
        descriptions <- c(
          "locandine 33x70" = "Formato italiano alto e stretto, di circa 33 × 70 cm, generalmente verticale.",
          "fotobuste 50x70" = "Serie di immagini fotografiche o illustrate esposte al cinema, spesso da 8 a 16 soggetti e di circa 50 × 70 cm; alcune serie più antiche erano più piccole.",
          "manifesti 70x100" = "Manifesto di circa 70 × 100 cm, noto anche come un foglio.",
          "manifesti 100x140" = "Il classico manifesto italiano a due fogli, di circa 100 × 140 cm, generalmente distribuito piegato.",
          "manifesti 140x200" = "Manifesto a quattro fogli, di circa 140 × 200 cm, generalmente piegato e stampato in due parti sovrapponibili.")
        weights <- c("locandine 33x70" = 1L, "fotobuste 50x70" = 2L,
                     "manifesti 70x100" = 3L, "manifesti 100x140" = 4L,
                     "manifesti 140x200" = 5L)
        add(paste0("by-size/", category, "-", size, "/_index.md"), label, "size",
            collection = collection, category = category, size = size,
            weight = if (key %in% names(weights)) weights[[key]] else 99L,
            description = if (key %in% names(descriptions)) descriptions[[key]] else "")
      }
      genres <- sort(unique(unlist(lapply(films[film_ids], `[[`, "genres"))))
      slugs <- poster_slug(genres)
      if (any(!nzchar(slugs)) || anyDuplicated(slugs)) stop("Genre URL collision; review genres.", call. = FALSE)
      if (length(genres)) add("by-genre/_index.md", "Per genere", "index", collection = collection,
                              browse = "genre", description = "Manifesti raggruppati per genere cinematografico.")
      for (i in seq_along(genres)) {
        add(paste0("by-genre/", slugs[i], "/_index.md"), genres[i], "genre",
            collection = collection, genre = slugs[i])
      }
      letters <- sort(unique(vapply(films[film_ids], `[[`, character(1), "letter")))
      for (letter in letters) {
        slug <- if (letter == "#") "0-9" else tolower(letter)
        add(paste0("by-title/", slug, "/_index.md"), letter, "letter", editable = FALSE,
            collection = collection, letter = letter)
      }
    }
  }
  for (id in unique(posters$film_id)) {
    add(paste0("films/", id, "/index.md"), films[[id]]$title, "film", editable = FALSE, film_id = id)
  }
  specs
}

poster_generated_page <- function(path) {
  lines <- readLines(path, warn = FALSE, encoding = "UTF-8")
  if (!length(lines) || lines[1] != "---") return(FALSE)
  ends <- which(lines[-1] == "---")
  if (!length(ends)) return(FALSE)
  front <- yaml::yaml.load(paste(lines[seq.int(2L, ends[1])], collapse = "\n"))
  is.list(front) && isTRUE(front$generated)
}

POSTER_MANAGED_KEYS <- c("type", "layout", "browse", "collection", "category", "size",
                         "year", "genre", "letter", "film_id", "weight")

poster_page_parts <- function(path) {
  lines <- readLines(path, warn = FALSE, encoding = "UTF-8")
  if (!length(lines) || lines[1] != "---") stop("Missing YAML front matter: ", path, call. = FALSE)
  end <- which(lines[-1] == "---")[1]
  if (is.na(end)) stop("Unclosed YAML front matter: ", path, call. = FALSE)
  front <- yaml::yaml.load(paste(lines[seq.int(2L, end)], collapse = "\n"))
  if (!is.list(front)) stop("Invalid YAML front matter: ", path, call. = FALSE)
  list(front = front, body = lines[-seq_len(end + 1L)])
}

poster_scaffold <- function(path) {
  if (path %in% c("_index.md", "by-size/_index.md")) {
    c("", "<!-- Write your text here -->", "", "{{< poster-subsections >}}",
      "", "<!-- Write your text here -->")
  } else c("", "<!-- Write your text here -->")
}

poster_merge_managed <- function(front, spec) {
  for (key in POSTER_MANAGED_KEYS) front[key] <- if (key %in% names(spec)) list(spec[[key]]) else NULL
  front$generated <- NULL
  front$posters_managed <- TRUE
  front
}

poster_removable_managed <- function(parts, relative) {
  !any(nzchar(trimws(parts$body))) || identical(parts$body, poster_scaffold(relative))
}

poster_has_managed_marker <- function(lines) {
  length(lines) && lines[1] == "---" &&
    any(grepl("^(generated|posters_managed):[[:space:]]*(true|yes)[[:space:]]*(#.*)?$",
              lines, ignore.case = TRUE))
}

poster_render_page <- function(path, spec, relative) {
  editable <- isTRUE(spec$posters_managed)
  exists <- file.exists(path)
  body <- if (editable) poster_scaffold(relative) else character()
  front <- spec
  if (exists && editable) {
    previous <- poster_page_parts(path)
    if (!isTRUE(previous$front$generated) && !isTRUE(previous$front$posters_managed)) {
      stop("Refusing to overwrite hand-written page: ", path, call. = FALSE)
    }
    front <- poster_merge_managed(previous$front, spec)
    body <- previous$body
    if (isTRUE(previous$front$generated) && !any(nzchar(trimws(body)))) {
      body <- poster_scaffold(relative)
      if (is.null(front$description)) front$description <- spec$description
      if (is.null(front$image)) front$image <- ""
    }
  }
  yaml_lines <- strsplit(sub("\n$", "", yaml::as.yaml(front, unicode = TRUE, line.sep = "\n")),
                         "\n", fixed = TRUE)[[1]]
  c("---", yaml_lines, "---", body)
}

poster_write_pages <- function(specs, project_root) {
  root <- file.path(project_root, "content", "posters")
  desired <- file.path(root, names(specs))
  reports <- list()
  counts <- list(created = character(), updated = character(), removed = character())
  for (i in seq_along(specs)) {
    if (!file.exists(desired[i])) next
    front <- poster_page_parts(desired[i])$front
    if (!isTRUE(front$generated) && !isTRUE(front$posters_managed)) {
      stop("Refusing to overwrite hand-written page: ", desired[i], call. = FALSE)
    }
  }
  old <- if (dir.exists(root)) list.files(root, pattern = "\\.md$", recursive = TRUE, full.names = TRUE) else character()
  for (i in seq_along(specs)) {
    path <- desired[i]
    spec <- specs[[i]]
    exists <- file.exists(path)
    text <- poster_render_page(path, spec, names(specs)[i])
    if (!exists || !identical(readLines(path, warn = FALSE, encoding = "UTF-8"), text)) {
      dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
      writeLines(text, path, useBytes = TRUE)
      action <- if (exists) "updated" else "created"
      counts[[action]] <- c(counts[[action]], spec$layout)
    }
  }
  stale <- setdiff(old, desired)
  for (path in stale) {
    lines <- readLines(path, warn = FALSE, encoding = "UTF-8")
    if (!poster_has_managed_marker(lines)) next
    parts <- poster_page_parts(path)
    if (isTRUE(parts$front$generated) || isTRUE(parts$front$posters_managed)) {
      relative <- substring(gsub("\\\\", "/", path), nchar(gsub("\\\\", "/", root)) + 2L)
      empty <- poster_removable_managed(parts, relative)
      if (isTRUE(parts$front$generated) || empty) {
        if (unlink(path) != 0L) stop("Cannot remove stale page: ", path, call. = FALSE)
        counts$removed <- c(counts$removed, parts$front$layout)
      } else {
        reports[[length(reports) + 1L]] <- data.frame(path = relative,
          reason = "empty managed page retained because it contains editorial text")
      }
    }
  }
  for (action in names(counts)) {
    message("Pages ", action, " by type:")
    print(table(counts[[action]]))
  }
  list(report = if (length(reports)) do.call(rbind, reports) else
    data.frame(path = character(), reason = character()), counts = counts)
}

poster_json_data <- function(posters, films) {
  records <- lapply(names(films), function(id) {
    film <- films[[id]]
    rows <- posters[posters$film_id == id, , drop = FALSE]
    priority <- match(rows$size, POSTER_SIZE_PRIORITY)
    priority[is.na(priority)] <- length(POSTER_SIZE_PRIORITY) + 1L
    rows <- rows[order(rows$is_retro, priority, rows$size, rows$poster_number,
                       rows$category, method = "radix"), , drop = FALSE]
    images <- lapply(seq_len(nrow(rows)), function(i) {
      list(category = rows$category[i], size = rows$size[i], number = rows$poster_number[i],
           is_retro = rows$is_retro[i], orientation = rows$orientation[i], alt = rows$alt[i],
           thumb = rows$thumb[i], thumb_width = rows$thumb_width[i], thumb_height = rows$thumb_height[i],
           large = rows$large[i], large_width = rows$large_width[i], large_height = rows$large_height[i])
    })
    months <- lapply(film$screening_months, function(value) {
      list(year = as.integer(substr(value, 1, 4)), month = as.integer(substr(value, 6, 7)))
    })
    list(film_id = id, id_type = film$id_type, imdb_id = film$imdb_id,
         internal_poster_code = film$internal_poster_code, title = film$title,
         production_year = film$production_year, genres = as.list(film$genres),
         genre_slugs = as.list(poster_slug(film$genres)), screenings = months,
         screening_dates = as.list(film$screening_dates), sort_key = film$sort_key,
         letter = film$letter, extra = lapply(film$extra, as.list), posters = images)
  })
  records <- records[order(vapply(records, `[[`, character(1), "sort_key"),
                           vapply(records, `[[`, character(1), "film_id"), method = "radix")]
  list(generated = TRUE, films = records)
}

poster_films_from_index <- function(posters) {
  result <- list()
  for (id in unique(posters$film_id)) {
    row <- posters[match(id, posters$film_id), , drop = FALSE]
    screenings <- row$screenings[[1]]
    result[[id]] <- list(film_id = id, id_type = row$id_type, imdb_id = row$imdb_id,
                         internal_poster_code = row$internal_poster_code, title = row$title,
                         production_year = row$production_year, genres = row$genres[[1]],
                         screening_months = sprintf("%04d-%02d", screenings$year, screenings$month),
                         screening_dates = row$screening_dates[[1]], sort_key = row$sort_key,
                         letter = row$letter, matched = row$matched, extra = row$extra[[1]])
  }
  result
}

poster_report_sizes <- function(posters) {
  for (kind in c("thumb", "large")) {
    sizes <- posters[[paste0(kind, "_bytes")]]
    if (!length(sizes)) next
    message(kind, ": ", length(sizes), " files; total ", sum(sizes), " bytes; median ",
            round(stats::median(sizes)), "; p95 ", round(stats::quantile(sizes, .95)),
            "; maximum ", max(sizes))
  }
  sizes <- data.frame(path = c(posters$thumb, posters$large),
                      bytes = c(posters$thumb_bytes, posters$large_bytes))
  if (nrow(sizes)) print(utils::head(sizes[order(sizes$bytes, decreasing = TRUE), ], 10L), row.names = FALSE)
}

poster_cleanup_derivatives <- function(posters, project_root, safe_to_remove) {
  manifest_path <- file.path(project_root, ".cache", "posters", "generated-derivatives.rds")
  previous <- if (file.exists(manifest_path)) readRDS(manifest_path) else
    data.frame(output = character(), source = character())
  if (!is.data.frame(previous) || !all(c("output", "source") %in% names(previous))) {
    stop("Invalid generated derivative manifest.", call. = FALSE)
  }
  current <- data.frame(output = c(posters$thumb, posters$large),
                        source = rep(posters$path, 2L), stringsAsFactors = FALSE)
  if (safe_to_remove) {
    stale <- previous[!previous$output %in% current$output, , drop = FALSE]
    for (i in seq_len(nrow(stale))) {
      output <- stale$output[i]
      source <- stale$source[i]
      if (!startsWith(output, "images/manifesti/") || grepl("(^|[/\\\\])\\.\\.([/\\\\]|$)", output) ||
          grepl("(^|[/\\\\])\\.\\.([/\\\\]|$)", source)) {
        stop("Unsafe path in generated derivative manifest.", call. = FALSE)
      }
      if (!file.exists(file.path(project_root, "manifesti", source))) {
        target <- file.path(project_root, "static", output)
        if (file.exists(target) && unlink(target) != 0L) stop("Cannot remove stale derivative: ", target, call. = FALSE)
      } else {
        current <- rbind(current, stale[i, , drop = FALSE])
      }
    }
  } else {
    current <- rbind(current, previous[!previous$output %in% current$output, , drop = FALSE])
  }
  saveRDS(unique(current), manifest_path)
}

build_posters <- function(project_root = ".") {
  input <- file.path(project_root, "manifesti")
  if (!dir.exists(input)) stop("Poster originals directory not found: ", input,
                               ". No files have been changed.", call. = FALSE)
  packages <- c("magick", "readr", "jsonlite", "yaml")
  missing <- packages[!vapply(packages, requireNamespace, logical(1), quietly = TRUE)]
  if (length(missing)) stop("Missing R packages: ", paste(missing, collapse = ", "), call. = FALSE)
  source(file.path(project_root, "R", "posters-helpers.R"), local = environment(build_posters))
  source(file.path(project_root, "R", "posters-scan.R"), local = environment(build_posters))
  screenings <- poster_read_csv(file.path(project_root, "static", "data", "programmazione_agende.csv"))
  imdb <- poster_read_csv(file.path(project_root, "static", "data", "programmazione_imdb.csv"))
  poster_metadata <- poster_read_csv(file.path(project_root, "static", "data", "programmazione_manifesti.csv"))
  supplementary <- poster_read_csv(file.path(project_root, "static", "data", "posters_wiht_no_imdb_id.csv"))
  overrides <- poster_read_csv(file.path(project_root, "static", "data", "poster_overrides.csv"))
  example_dates <- screenings$date[!is.na(screenings$date) & nzchar(screenings$date)]
  message("Screening date format: ", if (!length(example_dates)) "no dates" else if
            (grepl("/", example_dates[1], fixed = TRUE)) "dd/mm/yyyy" else "yyyy-mm-dd")
  scan <- scan_poster_originals(project_root)
  if (!nrow(scan$posters)) stop("No readable poster originals; existing output retained.", call. = FALSE)
  metadata <- poster_make_metadata(scan$posters, screenings, imdb, supplementary, poster_metadata)
  result <- poster_apply_overrides(metadata$posters, overrides)
  posters <- result$posters[!result$posters$exclude, , drop = FALSE]
  if (!nrow(posters)) stop("No posters remain after overrides; existing output retained.", call. = FALSE)
  duplicate_keys <- posters[c("film_id", "category", "size", "poster_number")]
  duplicate <- duplicated(duplicate_keys)
  duplicate_report <- data.frame(path = posters$path[duplicate],
                                 reason = rep("duplicate canonical film poster; kept first", sum(duplicate)))
  for (path in duplicate_report$path) {
    warning(path, ": duplicate canonical film poster; kept first.", call. = FALSE, immediate. = TRUE)
  }
  posters <- posters[!duplicate, , drop = FALSE]
  posters$original_width <- posters$width
  posters$original_height <- posters$height
  rotated <- posters$rotate %in% c(90L, 270L)
  original_width <- posters$width
  posters$width[rotated] <- posters$height[rotated]
  posters$height[rotated] <- original_width[rotated]
  posters$orientation <- mapply(poster_orientation, posters$width, posters$height, USE.NAMES = FALSE)
  nominal <- strsplit(posters$size, "x", fixed = TRUE)
  nominal_ratio <- vapply(nominal, function(x) as.numeric(x[1]) / as.numeric(x[2]), numeric(1))
  actual_ratio <- pmin(posters$width, posters$height) / pmax(posters$width, posters$height)
  suspicious <- abs(actual_ratio / nominal_ratio - 1) > POSTER_RATIO_TOLERANCE
  ratio_report <- data.frame(path = posters$path[suspicious],
                             reason = rep("pixel ratio differs from nominal size by more than 12%", sum(suspicious)))
  derived <- poster_make_derivatives(posters, project_root)
  posters <- derived$posters
  if (!nrow(posters)) stop("No derivatives succeeded; existing pages retained.", call. = FALSE)
  films <- metadata$films[unique(posters$film_id)]
  reps <- poster_representatives(posters)
  posters$is_representative <- posters$path %in% reps$path
  posters$id_type <- vapply(posters$film_id, function(id) films[[id]]$id_type, character(1))
  posters$imdb_id <- vapply(posters$film_id, function(id) films[[id]]$imdb_id, character(1))
  posters$internal_poster_code <- vapply(posters$film_id, function(id) films[[id]]$internal_poster_code, character(1))
  posters$production_year <- vapply(posters$film_id, function(id) films[[id]]$production_year, character(1))
  posters$sort_key <- vapply(posters$film_id, function(id) films[[id]]$sort_key, character(1))
  posters$letter <- vapply(posters$film_id, function(id) films[[id]]$letter, character(1))
  posters$matched <- vapply(posters$film_id, function(id) films[[id]]$matched, logical(1))
  posters$genres <- lapply(posters$film_id, function(id) films[[id]]$genres)
  posters$extra <- lapply(posters$film_id, function(id) films[[id]]$extra)
  posters$screening_dates <- lapply(posters$film_id, function(id) films[[id]]$screening_dates)
  posters$screenings <- lapply(posters$film_id, function(id) {
    months <- films[[id]]$screening_months
    data.frame(year = as.integer(substr(months, 1, 4)),
               month = as.integer(substr(months, 6, 7)))
  })
  index_path <- file.path(project_root, ".cache", "posters", "posters_index.rds")
  saveRDS(posters, index_path)
  posters <- readRDS(index_path)
  films <- poster_films_from_index(posters)
  specs <- poster_page_specs(posters, films)
  data <- poster_json_data(posters, films)
  json_path <- file.path(project_root, "data", "posters", "films.json")
  if (file.exists(json_path)) {
    old <- jsonlite::fromJSON(json_path, simplifyVector = FALSE)
    if (!isTRUE(old$generated)) stop("Refusing to overwrite hand-written poster data.", call. = FALSE)
  }
  page_result <- poster_write_pages(specs, project_root)
  dir.create(dirname(json_path), recursive = TRUE, showWarnings = FALSE)
  jsonlite::write_json(data, json_path, auto_unbox = TRUE, pretty = FALSE, null = "null")
  report <- rbind(scan$report, metadata$report, result$report, duplicate_report, ratio_report,
                  derived$report, page_result$report)
  no_genre <- sum(vapply(films, function(x) !length(x$genres), logical(1)))
  internal_no_genre <- sum(vapply(films, function(x) x$id_type == "internal" && !length(x$genres), logical(1)))
  imdb_without_screenings <- sum(vapply(films, function(x) x$id_type == "imdb" &&
                                         !length(x$screening_dates), logical(1)))
  report <- rbind(report, data.frame(path = "", reason = paste("films without genre:", no_genre,
                                                             "; internal:", internal_no_genre)),
                  data.frame(path = "", reason = "films with screenings only from poster metadata: 0 (metadata only)"),
                  data.frame(path = "", reason = paste("IMDb posters without screening dates:",
                                                        sum(posters$id_type == "imdb" &
                                                              vapply(posters$screenings, nrow, integer(1)) == 0L))))
  message("Films with screenings only from poster metadata: 0 (metadata only); IMDb films without screenings: ",
          imdb_without_screenings)
  readr::write_csv(report, file.path(project_root, "static", "data", "manifesti_report.csv"))
  incomplete <- any(grepl("poster folder is missing|image read failed|derivative conversion failed", report$reason))
  poster_cleanup_derivatives(posters, project_root, safe_to_remove = !incomplete)
  message("Scanned: ", scan$scanned, "; parsed: ", nrow(scan$posters), "; skipped: ",
          scan$scanned - nrow(scan$posters), "; image dimension reads: ", scan$image_reads)
  message("Films IMDb: ", sum(vapply(films, function(x) x$id_type == "imdb", logical(1))),
          "; internal: ", sum(vapply(films, function(x) x$id_type == "internal", logical(1))),
          "; matched: ", sum(vapply(films, `[[`, logical(1), "matched")),
          "; unmatched: ", sum(!vapply(films, `[[`, logical(1), "matched")),
          "; without genre: ", no_genre,
          "; retro: ", length(unique(posters$film_id[posters$is_retro])))
  message("Pages by type:")
  print(table(vapply(specs, `[[`, character(1), "layout")))
  poster_report_sizes(posters)
  invisible(list(posters = posters, films = films, report = report, pages = specs))
}

