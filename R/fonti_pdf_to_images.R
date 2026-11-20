# Converte una pagina alla volta per limitare la memoria utilizzata.
convert_fonti_pdf_page <- function(pdf, page, output) {
  image <- magick::image_read_pdf(pdf, pages = page, density = 200)
  on.exit(magick::image_destroy(image))
  image <- magick::image_convert(image, colorspace = "sRGB")
  image <- magick::image_resize(image, "1800x>")
  image <- magick::image_strip(image)
  magick::image_write(image, path = output, format = "webp", quality = 85,
                      defines = c("webp:lossless" = "false"))
}

fonti_pdf_to_images <- function(project_root = ".") {
  packages <- c("pdftools", "magick")
  missing <- packages[!vapply(packages, requireNamespace, logical(1), quietly = TRUE)]
  if (length(missing)) {
    stop("Pacchetti R mancanti: ", paste(missing, collapse = ", "), call. = FALSE)
  }
  if (!isTRUE(magick::magick_config()$webp)) {
    stop("La libreria ImageMagick non supporta WebP.", call. = FALSE)
  }
  project_root <- normalizePath(project_root, mustWork = TRUE)
  input_dir <- file.path(project_root, "programmazione_storica_pdf")
  output_root <- file.path(project_root, "static", "images", "programmazione_storica")
  if (!dir.exists(input_dir)) {
    stop("Cartella PDF non trovata: ", input_dir, call. = FALSE)
  }
  pdfs <- list.files(input_dir, pattern = "\\.pdf$", ignore.case = TRUE, full.names = TRUE)
  pdfs <- pdfs[!dir.exists(pdfs)]
  convert_fonti_pdfs(pdfs, output_root)
}

convert_fonti_pdfs <- function(pdfs, output_root) {
  folder_names <- tolower(sub("\\.pdf$", "", basename(pdfs), ignore.case = TRUE))
  folder_names <- gsub("[ -]", "_", folder_names)
  folder_names <- gsub("_+", "_", folder_names)
  folder_names <- gsub("^_+|_+$", "", folder_names)
  collisions <- duplicated(folder_names) | duplicated(folder_names, fromLast = TRUE)

  processed <- 0L
  failed <- 0L
  pages_converted <- 0L
  for (i in seq_along(pdfs)) {
    folder <- folder_names[i]
    output_dir <- file.path(output_root, folder)
    message("\nPDF: ", basename(pdfs[i]), "\nCartella: ", folder,
            "\nPercorso: ", output_dir)
    success <- tryCatch({
      if (!nzchar(folder) || folder %in% c(".", "..")) {
        stop("Nome della cartella non valido.")
      }
      if (collisions[i]) {
        stop("Piu' PDF producono lo stesso nome di cartella: ", folder)
      }
      page_count <- pdftools::pdf_info(pdfs[i])$pages
      message("Pagine: ", page_count)
      if (length(page_count) != 1L || is.na(page_count) || page_count < 1L) {
        stop("Il PDF non contiene pagine.")
      }
      if (!dir.exists(output_dir) &&
          !dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)) {
        stop("Impossibile creare la cartella: ", output_dir)
      }
      old_images <- list.files(output_dir, pattern = "\\.(png|jpe?g|webp|gif|bmp|tiff?)$",
                               ignore.case = TRUE, full.names = TRUE, all.files = TRUE)
      old_images <- old_images[!dir.exists(old_images)]
      if (length(old_images) && any(unlink(old_images) != 0L)) {
        stop("Impossibile eliminare le immagini precedenti in: ", output_dir)
      }
      digits <- max(2L, nchar(as.character(page_count)))
      for (page in seq_len(page_count)) {
        filename <- paste0(folder, "_", sprintf(paste0("%0", digits, "d"), page), ".webp")
        output <- file.path(output_dir, filename)
        convert_fonti_pdf_page(pdfs[i], page, output)
        pages_converted <- pages_converted + 1L
        message("  Pagina ", page, "/", page_count, ": ", output)
      }
      TRUE
    }, error = function(error) {
      message("Errore: ", conditionMessage(error))
      FALSE
    })
    if (success) processed <- processed + 1L else failed <- failed + 1L
  }
  message("\nPDF elaborati: ", processed, "\nPDF non riusciti: ", failed,
          "\nPagine convertite: ", pages_converted)
  invisible(list(processed = processed, failed = failed, pages = pages_converted))
}

if (sys.nframe() == 0L) {
  result <- fonti_pdf_to_images()
  if (result$failed > 0L) stop("Alcuni PDF non sono stati convertiti.", call. = FALSE)
}
