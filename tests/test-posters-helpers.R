source("R/posters-helpers.R")
source("R/posters-scan.R")
source("R/posters-build.R")

parse <- function(name, category = "fotobuste", size = "50x70") {
  poster_parse_filename(name, category, size)
}
stopifnot(parse("tt0034167_50x70_01.jpeg")$value$poster_number == 1L,
          parse("tt0034167_70x50_02.JPEG")$value$size == "50x70",
          parse("007_50x70_01.jpeg")$value$source_id == "007",
          parse("892_50x70_01.png")$value$source_id == "892",
          is.null(parse("892_0x70_01.jpeg")$value),
          is.null(parse("892_999999999999x70_01.jpeg")$value),
          is.null(parse("tt123_50x70_01.jpeg")$value),
          is.null(parse("unexpected.jpeg")$value))
for (token in c("r", "r1", "r01", "r_01", "r-01")) {
  result <- parse(paste0("892_70x100_", token, ".jpeg"), "retro", NULL)
  stopifnot(result$value$poster_number == 1L, !length(result$warnings))
}
stopifnot(parse("892_70x100_r_02.jpeg", "retro", NULL)$value$poster_number == 2L,
          length(parse("892_50x70_r.jpeg")$warnings) == 1L,
          length(parse("892_50x70_01.jpeg", "retro", NULL)$warnings) == 1L,
          length(parse("892_70x100_01.jpeg")$warnings) == 1L)

duplicate <- data.frame(path = c("b", "a"), source_id = "892", category = "retro",
                        size = "70x100", poster_number = 1L)
unique <- poster_unique_files(duplicate)
stopifnot(unique$posters$path == "a", unique$duplicates$path == "b")
stopifnot(poster_orientation(100, 50) == "landscape",
          poster_orientation(50, 100) == "portrait",
          poster_orientation(100, 100) == "square")

screenings <- data.frame(const = c("", "", "tt0034167", "tt0034167"),
                         internal_poster_code = c("007", "007", "892", "892"),
                         title = c("Primo", "Altro", "Film", "Film"))
joined <- poster_match_ids(c("007", "999", "892", "tt0034167"), screenings)
stopifnot(joined$film_id[1] == "internal-007", joined$multiple_titles[1],
          joined$film_id[2] == "internal-999", !joined$matched[2],
          joined$film_id[3] == "tt0034167", joined$film_id[4] == "tt0034167")
without_codes <- poster_match_ids("007", screenings[c("const", "title")])
stopifnot(!without_codes$matched)
zero_screenings <- data.frame(const = "tt0034167", title = "Film",
                              internal_poster_code = "0")
stopifnot(!poster_match_ids("0", zero_screenings)$matched)
metadata <- data.frame(internal_poster_code = c("999", "892"),
                       title = c("Senza proiezioni", "Titolo alternativo"),
                       year = c("1983", "1969"))
joined_metadata <- poster_match_ids(c("999", "892", "998"), screenings, metadata)
stopifnot(joined_metadata$matched[1],
          joined_metadata$title[1] == "Senza proiezioni",
          joined_metadata$production_year[1] == "1983",
          joined_metadata$title[2] == "Film",
          joined_metadata$production_year[2] == "1969",
          joined_metadata$film_id[2] == "tt0034167",
          joined_metadata$multiple_titles[2],
          !joined_metadata$matched[3], is.na(joined_metadata$production_year[3]))

posters <- data.frame(film_id = c("a", "a", "a", "a", "b"),
                      category = c("manifesti", "manifesti", "manifesti", "retro", "retro"),
                      size = c("70x100", "100x140", "100x140", "50x70", "70x100"),
                      poster_number = c(1L, 2L, 1L, 1L, 1L),
                      is_retro = c(FALSE, FALSE, FALSE, TRUE, TRUE))
representatives <- poster_representatives(posters)
stopifnot(nrow(representatives) == 3L,
          representatives$size[1] == "100x140",
          representatives$poster_number[1] == 1L,
          nrow(poster_representatives(posters, by_size = TRUE)) == 4L)

test_image_dimensions <- function() {
  path <- file.path("tests", "cts-poster-exif-fixture.jpeg")
  if (file.exists(path)) stop("Poster fixture already exists.")
  on.exit(unlink(path))
  image <- magick::image_blank(80, 40, "red")
  magick::image_write(image, path, format = "jpeg")
  magick::image_destroy(image)
  bytes <- readBin(path, "raw", n = file.info(path)$size)
  exif <- as.raw(c(0x45, 0x78, 0x69, 0x66, 0, 0, 0x49, 0x49, 0x2a, 0,
                   8, 0, 0, 0, 1, 0, 0x12, 1, 3, 0, 1, 0, 0, 0,
                   6, 0, 0, 0, 0, 0, 0, 0))
  writeBin(c(bytes[1:2], as.raw(c(0xff, 0xe1, 0, length(exif) + 2)),
             exif, bytes[-(1:2)]), path)
  first <- poster_cached_dimensions(path, list())
  stopifnot(first$read, first$dimensions["width"] == 40,
            first$dimensions["height"] == 80,
            poster_orientation(first$dimensions["width"], first$dimensions["height"]) == "portrait")
  second <- poster_cached_dimensions(path, first$cache,
                                     reader = function(path) stop("cache miss"))
  stopifnot(!second$read, identical(first$dimensions, second$dimensions))
  converted <- poster_convert_one(path, 90L, "webp")
  webp_image <- magick::image_read(converted$large$bytes)
  on.exit(magick::image_destroy(webp_image), add = TRUE)
  stopifnot(converted$thumb$width == 80, converted$thumb$height == 40,
            converted$large$width == 80, converted$large$height == 40,
            length(converted$thumb$bytes) <= POSTER_THUMB_CEILING,
            !any(grepl("^exif:", magick::image_attributes(webp_image)$property)))
  jpeg <- poster_convert_one(path, 90L, "jpeg")
  decoded <- magick::image_read(jpeg$thumb$bytes)
  on.exit(magick::image_destroy(decoded), add = TRUE)
  attrs <- magick::image_attributes(decoded)
  bytes <- as.integer(jpeg$thumb$bytes)
  stopifnot(magick::image_info(decoded)$format == "JPEG",
            magick::image_info(decoded)$width == 80,
            magick::image_info(decoded)$height == 40,
            attrs$value[attrs$property == "jpeg:sampling-factor"] == "2x2,1x1,1x1",
            any(bytes[-length(bytes)] == 255 & bytes[-1] == 194))
  large_image <- magick::image_blank(2000, 1000, "blue")
  floor_check <- poster_encode_image(large_image, "400x>", "webp", 75L, 1L)
  stopifnot(floor_check$quality == POSTER_QUALITY_FLOOR, floor_check$exceeds)
  magick::image_write(large_image, path, format = "jpeg")
  magick::image_destroy(large_image)
  reduced <- poster_convert_one(path, 0L, "webp")
  stopifnot(reduced$thumb$width == 400, reduced$thumb$height == 200,
            reduced$large$width == 1400, reduced$large$height == 700)
}
test_image_dimensions()


test_generation_data <- function() {
  dates <- poster_months(c("1953-12-29 - 1954-02-01", "03/03/1954", "invalid"))
  stopifnot(identical(dates$months, c("1953-12", "1954-01", "1954-02", "1954-03")),
            identical(dates$invalid, "invalid"))
  screening <- data.frame(date = c("1953-12-29 - 1954-02-01", "1954-03-03", "1954-03-03", NA),
                          const = c("", "tt0034167", "tt0034167", "tt0034167"),
                          title = c("Film interno", "Il film", "Il film", "Il film"),
                          internal_poster_code = c("007", "892", "892", "0"))
  imdb <- data.frame(Const = "tt0034167", Title = "Il film", Year = "1945",
                     Genres = "Drammatico, Avventura")
  supplementary <- data.frame(internal_poster_code = c("007", "999", "892"),
                              title = c("Altro titolo", "Senza proiezioni", "Il film"),
                              year = c("1960", "1983", "1945"))
  poster_metadata <- data.frame(Const = "tt0034167", Title = "Titolo alternativo",
                                Year = "1946", Genres = "Commedia",
                                `Release Date` = "1946-02-01", Directors = "Regista",
                                check.names = FALSE)
  input <- data.frame(source_id = c("007", "999", "892", "tt0034167"),
                      category = c("fotobuste", "fotobuste", "retro", "manifesti"),
                      size = c("50x70", "50x70", "70x100", "100x140"),
                      poster_number = 1L, is_retro = c(FALSE, FALSE, TRUE, FALSE),
                      path = c("a", "b", "c", "d"), width = 50L, height = 70L,
                      orientation = "portrait")
  warnings <- character()
  result <- withCallingHandlers(poster_make_metadata(input, screening, imdb, supplementary, poster_metadata),
                                warning = function(warning) {
                                  warnings <<- c(warnings, conditionMessage(warning))
                                  invokeRestart("muffleWarning")
                                })
  stopifnot(result$films[["internal-007"]]$title == "Film interno",
            identical(result$films[["internal-007"]]$screening_months,
                      c("1953-12", "1954-01", "1954-02")),
            result$films[["internal-999"]]$production_year == "1983",
            !length(result$films[["internal-999"]]$screening_months),
            result$posters$film_id[3] == result$posters$film_id[4],
            result$films[["tt0034167"]]$title == "Il film",
            result$films[["tt0034167"]]$production_year == "1945",
            identical(result$films[["tt0034167"]]$genres, c("Drammatico", "Avventura")),
            identical(result$films[["tt0034167"]]$screening_months, "1954-03"),
            identical(result$films[["tt0034167"]]$screening_dates, "1954-03-03"),
            result$films[["tt0034167"]]$extra[["Release Date"]] == "1946-02-01",
            any(grepl("conflicting titles", result$report$reason)),
            any(grepl("conflicting titles", warnings)))
  overrides <- data.frame(film_id = c("internal-007", "internal-123"),
                          category = "fotobuste", size = "50x70", number = "1",
                          rotate = c("90", "0"), exclude = "FALSE")
  adjusted <- poster_apply_overrides(result$posters, overrides)
  stopifnot(adjusted$posters$rotate[1] == 90L, nrow(adjusted$report) == 1L)
  overrides$rotate[1] <- "90.5"
  stopifnot(inherits(try(poster_apply_overrides(result$posters, overrides), silent = TRUE), "try-error"))
  specs <- poster_page_specs(result$posters, result$films)
  stopifnot("by-year/1953/_index.md" %in% names(specs),
            !"by-year/1954/01/_index.md" %in% names(specs),
            !"by-year/1983/_index.md" %in% names(specs),
            !"retro/by-year/1954/03/_index.md" %in% names(specs),
            isTRUE(specs[["by-year/1953/_index.md"]]$posters_managed))
  index <- data.frame(film_id = "internal-007", id_type = "internal", imdb_id = "",
                      internal_poster_code = "007", title = "Film interno", production_year = "1960",
                      sort_key = "film-interno", letter = "F", matched = TRUE)
  index$genres <- list(character())
  index$extra <- list(list())
  index$screening_dates <- list("1953-12-29 - 1954-02-01")
  index$screenings <- list(data.frame(year = c(1953L, 1954L), month = c(12L, 1L)))
  stopifnot(identical(poster_films_from_index(index)[["internal-007"]]$screening_months,
                      c("1953-12", "1954-01")))
  for (field in c("thumb", "large")) result$posters[[field]] <- paste0("images/", field, ".webp")
  for (field in c("thumb_width", "thumb_height", "large_width", "large_height")) {
    result$posters[[field]] <- 100L
  }
  data <- poster_json_data(result$posters, result$films)
  decoded <- jsonlite::fromJSON(jsonlite::toJSON(data, auto_unbox = TRUE), simplifyVector = FALSE)
  stopifnot(length(decoded$films) == 3L,
            length(Filter(function(x) x$film_id == "internal-999", decoded$films)[[1]]$screenings) == 0L)
}
test_generation_data()

test_generated_markers <- function() {
  path <- file.path("tests", "cts-poster-page-fixture.md")
  if (file.exists(path) || dir.exists(file.path("tests", "manifesti"))) {
    stop("Poster fixture path already exists.")
  }
  on.exit(unlink(path))
  writeLines(c("---", "generated: true", "---"), path)
  stopifnot(poster_generated_page(path),
            poster_has_managed_marker(c("---", "generated: yes", "---")),
            poster_has_managed_marker(c("---", "posters_managed: true", "---")),
            !poster_has_managed_marker(c("---", "generated: no", "---")))
  writeLines(c("---", "title: Manuale", "---", "Testo"), path)
  before <- tools::md5sum(path)
  original <- list(title = "Titolo", description = "Descrizione", image = "/hero.webp",
                   custom = "Dato", generated = TRUE, year = 1952, type = "old")
  updated <- poster_merge_managed(original, list(type = "posters", layout = "year", year = 1953))
  stopifnot(updated$title == original$title, updated$description == original$description,
            updated$image == original$image, updated$custom == original$custom,
            updated$year == 1953, updated$type == "posters",
            isTRUE(updated$posters_managed), is.null(updated$generated),
            poster_removable_managed(list(body = poster_scaffold("by-year/1953/_index.md")),
                                     "by-year/1953/_index.md"),
            !poster_removable_managed(list(body = "Testo personale"), "by-year/1953/_index.md"))
  stopifnot(!poster_generated_page(path),
            inherits(try(build_posters("tests"), silent = TRUE), "try-error"),
            identical(before, tools::md5sum(path)))
  for (layout in c("year", "genre")) {
    spec <- list(title = "Generato", type = "posters", layout = layout, year = 1953,
                 description = "Iniziale", image = "", posters_managed = TRUE)
    writeLines(c("---", "generated: true", "title: Titolo", "---"), path)
    writeLines(poster_render_page(path, spec, "by-year/1953/_index.md"), path, useBytes = TRUE)
    parts <- poster_page_parts(path)
    parts$front$description <- "Descrizione personale"
    parts$front$image <- "/hero.webp"
    parts$front$custom <- "Valore personale"
    writeLines(c("---", sub("\n$", "", yaml::as.yaml(parts$front)), "---",
                 "", "Testo personale."), path, useBytes = TRUE)
    spec$year <- 1954
    writeLines(poster_render_page(path, spec, "by-year/1953/_index.md"), path, useBytes = TRUE)
    parts <- poster_page_parts(path)
    stopifnot(parts$front$description == "Descrizione personale",
              parts$front$image == "/hero.webp", parts$front$custom == "Valore personale",
              parts$front$year == 1954, identical(parts$body, c("", "Testo personale.")))
    first <- readLines(path, warn = FALSE)
    second <- poster_render_page(path, spec, "by-year/1953/_index.md")
    stopifnot(identical(first, second))
  }
}
test_generated_markers()

test_csv_detection <- function() {
  path <- file.path("tests", "cts-poster-csv-fixture.csv")
  if (file.exists(path)) stop("Poster CSV fixture already exists.")
  on.exit(unlink(path))
  text <- paste0("code;title;score\n007;\u00c9poca;6,5\n")
  writeBin(charToRaw(iconv(text, from = "UTF-8", to = "windows-1252")), path)
  data <- poster_read_csv(path)
  stopifnot(data$code == "007", data$title == "\u00c9poca", data$score == "6,5")
}
test_csv_detection()
message("Poster helper tests passed.")
