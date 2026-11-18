source(file.path("R", "shinyapp_dashboard", "data.R"))
source(file.path("R", "shinyapp_dashboard", "deploy.R"))

data <- dashboard_load_data("static")
entries <- data$entries
films <- dashboard_unique_films(entries)
stopifnot(nrow(entries) == 5290L, nrow(films) == 4567L)

selected <- entries[entries$screening_year >= 1950L &
                      entries$screening_year <= 1959L, , drop = FALSE]
stopifnot(nrow(selected) == 1089L,
          nrow(dashboard_unique_films(selected)) == 948L)

repeat_film <- entries[entries$film_id == "tt0201175", , drop = FALSE]
stopifnot(nrow(repeat_film) == 5L,
          all(c(1981L, 1982L, 1985L, 1987L) %in% repeat_film$screening_year))

example <- entries[1:3, , drop = FALSE]
example$film_id <- c("tt0000001", "tt0000001", "tt0000002")
example$directors <- list(c("A", "B"), c("A", "B"), "A")
example$genres <- list(c("Drammatico", "Commedia"),
                       c("Drammatico", "Commedia"), "Drammatico")
unique_example <- dashboard_unique_films(example)
director_counts <- dashboard_director_counts(unique_example)
genre_counts <- dashboard_genre_counts(unique_example)
stopifnot(
  director_counts$Film[director_counts$Regia == "A"] == 2L,
  director_counts$Film[director_counts$Regia == "B"] == 1L,
  genre_counts$Film[genre_counts$Genere == "Drammatico"] == 2L,
  genre_counts$Film[genre_counts$Genere == "Commedia"] == 1L,
  nrow(dashboard_month_counts(example)) == 12L,
  sum(dashboard_month_counts(example)$Proiezioni) == 3L,
  dashboard_list_text(list(character())) == "Non disponibile"
)

ranked <- unique_example
ranked$imdb_rating <- c(7, 7)
ranked$imdb_votes <- c(20, 50)
stopifnot(dashboard_ranking(ranked)$film_id[1] == "tt0000002")
ranked$imdb_votes <- c(0, NA)
stopifnot(nrow(dashboard_ranking(ranked)) == 0L)
link <- dashboard_title_links("<test>", "tt0000001")
stopifnot(grepl("&lt;test&gt;", link, fixed = TRUE),
          !grepl("<test>", link, fixed = TRUE))

stage <- stage_dashboard(".")
on.exit(unlink(stage, recursive = TRUE), add = TRUE)
staged <- dashboard_load_data(file.path(stage, "static"))
stopifnot(
  nrow(staged$entries) == nrow(entries),
  identical(unname(tools::md5sum(file.path(stage, "static", "data",
                                            "programmazione_agende.csv"))),
            unname(tools::md5sum(file.path("static", "data",
                                            "programmazione_agende.csv"))))
)
expect_error <- function(expression, expected) {
  result <- tryCatch({ force(expression); "" }, error = conditionMessage)
  if (!grepl(expected, result, fixed = TRUE)) {
    stop("Expected an error containing: ", expected, call. = FALSE)
  }
}
staged_entries_path <- file.path(stage, "static", "data", "programmazione_agende.csv")
fixture <- dashboard_read_csv(staged_entries_path, c("date", "const", "title", "source"))
fixture$date[1] <- "1950-02-30"
utils::write.csv(fixture, staged_entries_path, row.names = FALSE, na = "",
                 fileEncoding = "UTF-8")
expect_error(dashboard_load_data(file.path(stage, "static")), "date devono essere valide")
fixture$date[1] <- "1948-01-06"
fixture$const[1] <- "tt999999999"
utils::write.csv(fixture, staged_entries_path, row.names = FALSE, na = "",
                 fileEncoding = "UTF-8")
expect_error(dashboard_load_data(file.path(stage, "static")), "Film senza metadati IMDb")
stopifnot(file.copy(file.path("static", "data", "programmazione_agende.csv"),
                    staged_entries_path, overwrite = TRUE))
local({
  old_working_directory <- getwd()
  on.exit(setwd(old_working_directory), add = TRUE)
  setwd(stage)
  app_environment <- new.env(parent = globalenv())
  sys.source("app.R", envir = app_environment)
  local({
    image_path <- tempfile(fileext = ".png")
    on.exit(unlink(image_path), add = TRUE)
    grDevices::png(image_path, width = 960, height = 420, res = 110)
    on.exit(grDevices::dev.off(), add = TRUE)
    sample <- films[films$screening_year == 2001L, , drop = FALSE]
    labels <- app_environment$dashboard_imdb_plot(
      sample, app_environment$chart_helpers$anni_place_labels
    )
    stopifnot(length(labels) > 0L,
              all(labels %in% sample$recorded_title))
    all_labels <- app_environment$dashboard_imdb_plot(
      films, app_environment$chart_helpers$anni_place_labels
    )
    stopifnot(length(all_labels) > 0L, length(all_labels) <= 250L,
              all(all_labels %in% films$recorded_title))
    empty <- sample[FALSE, , drop = FALSE]
    app_environment$dashboard_imdb_plot(
      empty, app_environment$chart_helpers$anni_place_labels
    )
  })
  shiny::testServer(app_environment$server, {
    session$setInputs(year = "1982", chart = "Proiezioni mensili",
                      director = "all", genre = "all")
    stopifnot(
      nrow(selected_entries()) == 107L,
      nrow(selected_films()) == 103L,
      output$entry_count == "107",
      output$film_count == "103"
    )
    session$setInputs(year = "all")
    stopifnot(nrow(selected_entries()) == 5290L,
              nrow(selected_films()) == 4567L)
  })
})
message("Shiny dashboard data and staging tests passed.")
