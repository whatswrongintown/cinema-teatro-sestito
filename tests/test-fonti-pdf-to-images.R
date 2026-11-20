source("R/fonti_pdf_to_images.R")

test_fonti_pdf_to_images <- function() {
  root <- "tests"
  pdf <- file.path(root, "CTS  Fixture - Alpha.pdf")
  invalid <- file.path(root, "CTS Fixture - Invalid.pdf")
  many <- file.path(root, "CTS Fixture - Many.PDF")
  alpha_dir <- file.path(root, "cts_fixture_alpha")
  many_dir <- file.path(root, "cts_fixture_many")
  paths <- c(pdf, invalid, many, alpha_dir, many_dir)
  if (any(file.exists(paths))) stop("I percorsi di test esistono gia'.")
  on.exit(unlink(paths, recursive = TRUE), add = TRUE)

  make_pdf <- function(path, pages, width, height) {
    grDevices::pdf(path, width = width, height = height)
    for (i in seq_len(pages)) {
      graphics::par(mar = c(0, 0, 0, 0))
      graphics::plot.new()
      graphics::text(0.5, 0.5, paste("Page", i))
    }
    grDevices::dev.off()
  }
  make_pdf(pdf, 2, 12, 6)
  make_pdf(many, 100, 1, 1)
  writeLines("not a PDF", invalid)
  dir.create(alpha_dir)
  writeLines("old", file.path(alpha_dir, "old.png"))
  writeLines("keep", file.path(alpha_dir, "note.txt"))

  result <- convert_fonti_pdfs(c(invalid, pdf, many,
                                 file.path(root, "CTS Collision-A.pdf"),
                                 file.path(root, "CTS Collision A.pdf")), root)
  stopifnot(result$processed == 2L, result$failed == 3L, result$pages == 102L)
  stopifnot(!file.exists(file.path(alpha_dir, "old.png")),
            file.exists(file.path(alpha_dir, "note.txt")))
  alpha_files <- list.files(alpha_dir, pattern = "\\.webp$")
  stopifnot(identical(alpha_files, c("cts_fixture_alpha_01.webp",
                                     "cts_fixture_alpha_02.webp")))
  many_files <- list.files(many_dir, pattern = "\\.webp$")
  stopifnot(length(many_files) == 100L,
            many_files[1] == "cts_fixture_many_001.webp",
            many_files[100] == "cts_fixture_many_100.webp")
  image <- magick::image_read(file.path(alpha_dir, alpha_files[1]))
  info <- magick::image_info(image)
  stopifnot(info$format == "WEBP", info$width == 1800L, info$height == 900L,
            info$colorspace == "sRGB")
  magick::image_destroy(image)
  header <- readBin(file.path(alpha_dir, alpha_files[1]), "raw", n = 16)
  stopifnot(rawToChar(header[13:16]) == "VP8 ")

  make_pdf(pdf, 1, 2, 1)
  result <- convert_fonti_pdfs(pdf, root)
  stopifnot(result$processed == 1L, result$failed == 0L, result$pages == 1L,
            identical(list.files(alpha_dir, pattern = "\\.webp$"),
                      "cts_fixture_alpha_01.webp"),
            file.exists(file.path(alpha_dir, "note.txt")))
  image <- magick::image_read(file.path(alpha_dir, "cts_fixture_alpha_01.webp"))
  info <- magick::image_info(image)
  stopifnot(info$width == 400L, info$height == 200L)
  magick::image_destroy(image)

  message("Test PDF e WebP superati.")
}

test_fonti_pdf_to_images()
