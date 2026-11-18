stage_dashboard <- function(project_root = ".") {
  project_root <- normalizePath(project_root, mustWork = TRUE)
  files <- c(
    "R/shinyapp_dashboard/app.R",
    "R/shinyapp_dashboard/data.R",
    "R/shinyapp_dashboard/plots.R",
    "R/update-anni.R",
    "static/data/programmazione_agende.csv",
    "static/data/programmazione_imdb.csv",
    "static/fonts/merriweather-v13-latin-regular.woff",
    "static/fonts/merriweather-v13-latin-regular.woff2",
    "static/fonts/lato-v11-latin-regular.woff2"
  )
  paths <- file.path(project_root, files)
  if (any(!file.exists(paths))) {
    stop("File necessari mancanti: ",
         paste(files[!file.exists(paths)], collapse = ", "), call. = FALSE)
  }
  stage <- tempfile("shiny-dashboard-")
  dir.create(stage)
  success <- FALSE
  on.exit(if (!success) unlink(stage, recursive = TRUE), add = TRUE)
  for (index in seq_along(files)) {
    destination <- if (startsWith(files[index], "R/shinyapp_dashboard/")) {
      file.path(stage, basename(files[index]))
    } else {
      file.path(stage, files[index])
    }
    dir.create(dirname(destination), recursive = TRUE, showWarnings = FALSE)
    if (!file.copy(paths[index], destination)) {
      stop("Impossibile preparare ", files[index], call. = FALSE)
    }
  }
  success <- TRUE
  stage
}

deploy_dashboard <- function(project_root = ".") {
  if (!requireNamespace("rsconnect", quietly = TRUE)) {
    stop("Pacchetto R mancante per la pubblicazione: rsconnect", call. = FALSE)
  }
  project_root <- normalizePath(project_root, mustWork = TRUE)
  app_dir <- file.path(project_root, "R", "shinyapp_dashboard")
  record <- file.path(
    app_dir, "rsconnect", "shinyapps.io", "whatswrongintown",
    "programmazione_film_shiny.dcf"
  )
  if (!file.exists(record)) {
    stop("Record della pubblicazione Shiny non trovato: ", record, call. = FALSE)
  }
  metadata <- read.dcf(record)
  required <- c("name", "account", "server", "appId")
  if (!all(required %in% colnames(metadata)) ||
      any(!nzchar(metadata[1, required]))) {
    stop("Record della pubblicazione Shiny incompleto: ", record, call. = FALSE)
  }
  stage <- stage_dashboard(project_root)
  on.exit(unlink(stage, recursive = TRUE), add = TRUE)
  rsconnect::deployApp(
    appDir = stage,
    appName = metadata[1, "name"],
    appId = metadata[1, "appId"],
    account = metadata[1, "account"],
    server = metadata[1, "server"],
    recordDir = app_dir
  )
}

if (sys.nframe() == 0L) deploy_dashboard()
