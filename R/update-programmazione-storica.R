update_programmazione_storica <- function(project_root = ".", render_indexes = TRUE) {
  sections <- c("anni", "fonti", "generi", "paesi")
  scripts <- lapply(sections, function(section) {
    environment <- new.env(parent = globalenv())
    sys.source(file.path("R", paste0("update-", section, ".R")), envir = environment)
    environment
  })
  names(scripts) <- sections

  for (section in sections) {
    directory <- if (section == "paesi") "paesi-di-produzione" else section
    scripts[[section]][[paste0("check_", section, "_section")]](project_root, directory, render_indexes)
  }
  scripts$fonti$prepare_fonti_section(project_root, "fonti", "source", render_indexes)
  scripts$generi$prepare_generi_section(project_root, "generi", "genres", render_indexes)
  scripts$paesi$prepare_paesi_section(project_root, "paesi-di-produzione", "country", render_indexes)

  scripts$anni$update_anni(project_root, render_indexes)
  sources <- scripts$fonti$update_fonti(project_root, render_indexes)
  genres <- scripts$generi$update_generi(project_root, render_indexes)
  countries <- scripts$paesi$update_paesi(project_root, render_indexes)
  invisible(c(sources, genres, countries))
}

if (sys.nframe() == 0L) update_programmazione_storica()