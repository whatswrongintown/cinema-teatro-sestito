update_programmazione_storica <- function(project_root = ".") {
  sections <- c("anni", "fonti", "generi", "paesi")
  scripts <- lapply(sections, function(section) {
    environment <- new.env(parent = globalenv())
    sys.source(file.path(project_root, "R", paste0("update-", section, ".R")), envir = environment)
    environment
  })
  names(scripts) <- sections

  scripts$anni$check_anni_section(project_root, "anni")
  scripts$fonti$prepare_fonti_section(project_root, "fonti", "source")
  scripts$generi$prepare_generi_section(project_root, "generi", "genres")
  scripts$paesi$prepare_paesi_section(project_root, "paesi-di-produzione", "country")

  scripts$anni$update_anni(project_root)
  sources <- scripts$fonti$update_fonti(project_root)
  genres <- scripts$generi$update_generi(project_root)
  countries <- scripts$paesi$update_paesi(project_root)
  invisible(c(sources, genres, countries))
}

if (sys.nframe() == 0L) update_programmazione_storica()