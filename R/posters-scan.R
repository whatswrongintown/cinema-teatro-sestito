POSTER_FOLDERS <- c(
  "fotobuste 50x70" = "fotobuste",
  "locandine 33x70" = "locandine",
  "manifesti 70x100" = "manifesti",
  "manifesti 100x140" = "manifesti",
  "manifesti 140x200" = "manifesti",
  "retro" = "retro"
)

poster_image_dimensions <- function(path) {
  image <- magick::image_read(path)
  on.exit(magick::image_destroy(image))
  oriented <- magick::image_orient(image)
  on.exit(magick::image_destroy(oriented), add = TRUE)
  info <- magick::image_info(oriented)
  if (nrow(info) != 1L || info$width < 1L || info$height < 1L) {
    stop("Expected one image with positive dimensions: ", path, call. = FALSE)
  }
  c(width = info$width, height = info$height)
}

poster_cached_dimensions <- function(path, cache, reader = poster_image_dimensions) {
  info <- file.info(path)
  if (is.na(info$size) || is.na(info$mtime)) {
    stop("Cannot stat image: ", path, call. = FALSE)
  }
  key <- normalizePath(path, winslash = "/", mustWork = TRUE)
  entry <- cache[[key]]
  if (!is.null(entry) && identical(entry$size, info$size) &&
      identical(entry$mtime, as.numeric(info$mtime))) {
    return(list(dimensions = entry$dimensions, cache = cache, read = FALSE))
  }
  dimensions <- reader(path)
  if (!all(c("width", "height") %in% names(dimensions)) ||
      any(!is.finite(dimensions[c("width", "height")])) ||
      any(dimensions[c("width", "height")] < 1)) {
    stop("Invalid image dimensions: ", path, call. = FALSE)
  }
  cache[[key]] <- list(size = info$size, mtime = as.numeric(info$mtime),
                       dimensions = dimensions[c("width", "height")])
  list(dimensions = cache[[key]]$dimensions, cache = cache, read = TRUE)
}

scan_poster_originals <- function(project_root = ".") {
  input <- file.path(project_root, "manifesti")
  if (!dir.exists(input)) {
    stop("Poster originals directory not found: ", input,
         ". No files have been changed.", call. = FALSE)
  }
  if (!requireNamespace("magick", quietly = TRUE)) {
    stop("R package 'magick' is required to scan poster images.", call. = FALSE)
  }
  cache_path <- file.path(project_root, ".cache", "posters", "dimensions.rds")
  cache <- if (file.exists(cache_path)) readRDS(cache_path) else list()
  if (!is.list(cache)) stop("Invalid poster dimension cache: ", cache_path, call. = FALSE)
  posters <- list()
  reports <- list()
  add_report <- function(path, reason) {
    reports[[length(reports) + 1L]] <<- data.frame(path = path, reason = reason)
  }
  scanned <- 0L
  image_reads <- 0L
  for (folder in names(POSTER_FOLDERS)) {
    folder_path <- file.path(input, folder)
    if (!dir.exists(folder_path)) {
      add_report(folder, "poster folder is missing")
      next
    }
    files <- list.files(folder_path, pattern = "\\.(jpe?g|png)$",
                        ignore.case = TRUE, full.names = TRUE)
    files <- sort(files, method = "radix")
    for (path in files) {
      scanned <- scanned + 1L
      relative <- file.path(folder, basename(path))
      folder_size <- if (folder == "retro") NULL else sub("^.* ", "", folder)
      parsed <- poster_parse_filename(path, POSTER_FOLDERS[[folder]], folder_size)
      for (reason in parsed$warnings) {
        add_report(relative, reason)
        if (!is.null(parsed$value)) warning(relative, ": ", reason, call. = FALSE, immediate. = TRUE)
      }
      if (is.null(parsed$value)) next
      row <- parsed$value
      row$path <- relative
      posters[[length(posters) + 1L]] <- row
    }
  }
  if (!length(posters)) {
    return(list(posters = data.frame(), report = if (length(reports)) {
      do.call(rbind, reports)
    } else data.frame(path = character(), reason = character()),
    scanned = scanned, image_reads = 0L))
  }
  unique_result <- poster_unique_files(do.call(rbind, posters))
  if (nrow(unique_result$duplicates)) {
    for (path in unique_result$duplicates$path) {
      add_report(path, "duplicate poster identity; kept the first alphabetically")
      warning(path, ": duplicate poster identity; kept the first alphabetically.",
              call. = FALSE, immediate. = TRUE)
    }
  }
  posters <- unique_result$posters
  dimensions <- vector("list", nrow(posters))
  keep <- rep(TRUE, nrow(posters))
  for (i in seq_len(nrow(posters))) {
    path <- file.path(input, posters$path[i])
    message("Poster ", i, "/", nrow(posters), ": ", posters$path[i])
    result <- tryCatch(poster_cached_dimensions(path, cache), error = function(error) error)
    if (inherits(result, "error")) {
      add_report(posters$path[i], paste("image read failed:", conditionMessage(result)))
      keep[i] <- FALSE
      next
    }
    cache <- result$cache
    image_reads <- image_reads + as.integer(result$read)
    dimensions[[i]] <- result$dimensions
    if (result$read && i %% 50L == 0L) {
      dir.create(dirname(cache_path), recursive = TRUE, showWarnings = FALSE)
      saveRDS(cache, cache_path)
    }
  }
  posters <- posters[keep, , drop = FALSE]
  dimensions <- dimensions[keep]
  posters$width <- vapply(dimensions, function(x) as.integer(x["width"]), integer(1))
  posters$height <- vapply(dimensions, function(x) as.integer(x["height"]), integer(1))
  posters$orientation <- mapply(poster_orientation, posters$width, posters$height,
                                USE.NAMES = FALSE)
  dir.create(dirname(cache_path), recursive = TRUE, showWarnings = FALSE)
  saveRDS(cache, cache_path)
  list(posters = posters, report = if (length(reports)) {
    do.call(rbind, reports)
  } else data.frame(path = character(), reason = character()),
  scanned = scanned, image_reads = image_reads)
}
