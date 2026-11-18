library(shiny)
library(DT)
library(showtext)
library(sysfonts)

source("data.R", local = TRUE)
source("plots.R", local = TRUE)

static_dir <- dashboard_static_dir()
chart_helpers <- new.env(parent = globalenv())
sys.source(file.path(dirname(static_dir), "R", "update-anni.R"), envir = chart_helpers)
database <- dashboard_load_data(static_dir)
font_dir <- file.path(static_dir, "fonts")
font_path <- file.path(font_dir, "merriweather-v13-latin-regular.woff")
if (!file.exists(font_path) ||
    !file.exists(file.path(font_dir, "lato-v11-latin-regular.woff2")) ||
    !file.exists(file.path(font_dir, "merriweather-v13-latin-regular.woff2"))) {
  stop("Font locali della dashboard mancanti in ", font_dir, call. = FALSE)
}
sysfonts::font_add("dashboard-merriweather", regular = font_path)
showtext::showtext_auto()
addResourcePath("dashboard-fonts", font_dir)

genres <- dashboard_choices(database$entries$genres)
directors <- dashboard_choices(database$entries$directors)
years <- sort(unique(database$entries$screening_year), decreasing = TRUE)
table_language <- list(
  search = "Cerca:",
  lengthMenu = "Mostra _MENU_ righe",
  info = "Da _START_ a _END_ di _TOTAL_ righe",
  infoEmpty = "Nessuna riga",
  infoFiltered = "(filtrate da _MAX_ righe)",
  zeroRecords = "Nessun risultato",
  emptyTable = "Nessun dato disponibile",
  paginate = list(previous = "Precedente", `next` = "Successiva"),
  aria = list(sortAscending = ": ordina in modo crescente",
              sortDescending = ": ordina in modo decrescente")
)

ui <- fluidPage(
  tags$head(tags$style(HTML("
    @font-face { font-family: Lato; src: url('dashboard-fonts/lato-v11-latin-regular.woff2'); }
    @font-face { font-family: Merriweather; src: url('dashboard-fonts/merriweather-v13-latin-regular.woff2'); }
    body { font-family: Merriweather, serif; color: #333; background: #fff; }
    h1, h2, h3, h4, label, .nav, button, .dataTables_wrapper { font-family: Lato, sans-serif; }
    h1 { font-size: 30px; color: #222; }
    h2 { font-size: 23px; }
    h3 { font-size: 20px; }
    .container-fluid { max-width: 1000px; padding: 18px 20px 36px; }
    .nav-tabs { border-bottom: 1px solid #CBF8DF; }
    .nav-tabs > li > a,
    .nav-tabs > li.active > a,
    .nav-tabs > li.active > a:focus,
    .nav-tabs > li.active > a:hover {
      margin: 0 15px 0 0; padding: 8px 0 5px;
      border: 0; border-bottom: 3px solid #CBF8DF; border-radius: 0;
      box-shadow: inset 0 -4px 0 #CBF8DF;
      color: inherit; background: transparent; text-decoration: none;
      transition: background 150ms ease;
    }
    .nav-tabs > li > a:hover, .nav-tabs > li > a:focus,
    .nav-tabs > li.active > a:hover, .nav-tabs > li.active > a:focus {
      background: #CBF8DF; color: inherit;
    }
    .nav-tabs > li.active > a { font-weight: bold; }
    .tab-content table.dataTable tbody a,
    .tab-content summary {
      text-decoration: none; color: inherit;
      border-bottom: 3px solid #CBF8DF;
      box-shadow: inset 0 -4px 0 #CBF8DF;
      background: transparent;
      transition: background 150ms ease;
    }
    .tab-content table.dataTable tbody a:hover,
    .tab-content table.dataTable tbody a:focus,
    .tab-content summary:hover,
    .tab-content summary:focus { background: #CBF8DF; color: inherit; }
    .tab-content summary { display: list-item; width: fit-content;
      margin-left: 1em; cursor: pointer; }
    .form-control:focus, button:focus, a:focus, select:focus, input:focus {
      outline: 2px solid #286a4a; outline-offset: 2px;
    }
    .nav-tabs > li > a:focus { outline: 2px solid #286a4a; outline-offset: 2px; }
    .tab-content summary:focus { outline: 2px solid #286a4a; outline-offset: 2px; }
    .dashboard-intro, .dashboard-note { line-height: 1.65; }
    .dashboard-note { color: #555; font-size: 0.9em; margin: 12px 0 20px; }
    .dashboard-counts { display: flex; flex-wrap: wrap; gap: 12px; margin: 18px 0; }
    .dashboard-count { background: #f5f5f5; border-left: 4px solid #CBF8DF;
      padding: 12px 16px; flex: 1 1 180px; }
    .dashboard-count strong { display: block; font-size: 1.65em; color: #222; }
    .tab-content { padding-top: 20px; }
    .dataTables_wrapper { overflow-x: auto; }
    .dashboard-plot-scroll { max-width: 100%; overflow-x: auto; }
    .dashboard-plot-scroll .shiny-plot-output { min-width: 580px; }
    table.dataTable { width: 100% !important; }
    @media (max-width: 600px) {
      .container-fluid { padding: 12px 15px 28px; }
      h1 { font-size: 25px; }
    }
  "))),
  titlePanel("Esplora la programmazione storica"),
  p(
    class = "dashboard-intro",
    "Consulta le date registrate nelle fonti del Cinema Teatro Sestito. ",
    "Uno stesso film può comparire in più date."
  ),
  fluidRow(column(
    5,
    selectInput(
      "year", "Anno di proiezione",
      choices = c("Tutti gli anni" = "all", stats::setNames(years, years))
    )
  )),
  div(
    class = "dashboard-counts",
    div(class = "dashboard-count", "Proiezioni registrate",
        strong(textOutput("entry_count", inline = TRUE))),
    div(class = "dashboard-count", "Film distinti",
        strong(textOutput("film_count", inline = TRUE)))
  ),
  tabsetPanel(
    tabPanel(
      "Grafici",
      fluidRow(column(
        5,
        selectInput(
          "chart", "Seleziona un grafico",
          choices = c("Proiezioni mensili", "Generi cinematografici",
                      "Valutazioni IMDb")
        )
      )),
      p(class = "dashboard-note", textOutput("chart_description", inline = TRUE)),
      p(class = "dashboard-note",
        "Su schermi stretti scorri il grafico in orizzontale o apri i valori sottostanti."),
      uiOutput("chart_container"),
      uiOutput("chart_values")
    ),
    tabPanel(
      "Riepilogo",
      p(class = "dashboard-note",
        "Le classifiche contano ogni film una sola volta. Le valutazioni e i voti ",
        "provengono da IMDb e non misurano il gradimento del pubblico locale."),
      h3("Film con valutazione IMDb più alta"),
      DTOutput("highest"),
      h3("Film con valutazione IMDb più bassa"),
      DTOutput("lowest"),
      p(class = "dashboard-note",
        "Sono inclusi i film con valutazione e almeno un voto. In caso di ",
        "parità prevalgono più voti e poi l'identificativo IMDb."),
      h3("Registi più frequenti"),
      p(class = "dashboard-note",
        "Ogni film conta una volta per ciascun regista; un film può avere più registi."),
      DTOutput("director_summary")
    ),
    tabPanel(
      "Tabella",
      p(class = "dashboard-note",
        "I filtri per regia e genere riguardano solo questa tabella. ",
        "La selezione dell'anno riguarda tutti i pannelli."),
      fluidRow(
        column(5, selectizeInput("director", "Regia", choices = NULL)),
        column(5, selectInput("genre", "Genere",
                              c("Tutti i generi" = "all", genres)))
      ),
      DTOutput("entries_table")
    )
  ),
  p(
    class = "dashboard-note",
    "La copertura delle fonti è incompleta, in particolare per il 1960 e il 1961. ",
    "Una data assente non indica necessariamente la chiusura del cinema. ",
    "Information courtesy of IMDb (https://www.imdb.com)."
  )
)

server <- function(input, output, session) {
  updateSelectizeInput(
    session, "director", choices = c("Tutte le regie" = "all", directors),
    selected = "all", server = TRUE
  )
  selected_entries <- reactive({
    req(input$year)
    if (identical(input$year, "all")) database$entries else {
      database$entries[database$entries$screening_year == as.integer(input$year), ,
                       drop = FALSE]
    }
  })
  selected_films <- reactive(dashboard_unique_films(selected_entries()))

  output$entry_count <- renderText(
    format(nrow(selected_entries()), big.mark = ".", decimal.mark = ",")
  )
  output$film_count <- renderText(
    format(nrow(selected_films()), big.mark = ".", decimal.mark = ",")
  )

  output$chart_description <- renderText({
    switch(
      input$chart,
      "Proiezioni mensili" = paste(
        "Numero di date registrate per mese.",
        "Se sono selezionati tutti gli anni, i mesi sono sommati tra gli anni."
      ),
      "Generi cinematografici" = paste(
        "Numero di film distinti per genere nella selezione.",
        "Un film può appartenere a più generi; i totali quindi si sovrappongono."
      ),
      "Valutazioni IMDb" = paste(
        "Una posizione per ogni film distinto con valutazione e voti positivi.",
        "Il numero di voti è su scala logaritmica; i dati provengono da IMDb.",
        "I titoli sono mostrati dove c'è spazio; la tabella contiene tutti i valori."
      )
    )
  })

  output$chart_container <- renderUI({
    height <- if (identical(input$chart, "Generi cinematografici")) "650px" else "420px"
    tags$div(class = "dashboard-plot-scroll", role = "region",
             `aria-label` = paste("Grafico:", input$chart), tabindex = "0",
             plotOutput("chart_plot", height = height))
  })

  output$chart_plot <- renderPlot({
    req(input$chart)
    switch(
      input$chart,
      "Proiezioni mensili" = dashboard_month_plot(selected_entries()),
      "Generi cinematografici" = dashboard_genre_plot(selected_films()),
      "Valutazioni IMDb" = dashboard_imdb_plot(selected_films(),
                                                chart_helpers$anni_place_labels)
    )
  }, res = 110)

  output$chart_values <- renderUI({
    req(input$chart)
    if (identical(input$chart, "Valutazioni IMDb")) {
      return(tags$details(
        tags$summary("Mostra i valori del grafico"),
        DTOutput("imdb_values")
      ))
    }
    tags$details(
      tags$summary("Mostra i valori del grafico"),
      tableOutput("chart_values_table")
    )
  })
  output$chart_values_table <- renderTable({
    if (identical(input$chart, "Proiezioni mensili")) {
      dashboard_month_counts(selected_entries())
    } else {
      dashboard_genre_counts(selected_films())
    }
  }, striped = TRUE, width = "100%")
  output$imdb_values <- renderDT({
    films <- dashboard_rated_films(selected_films())
    datatable(
      data.frame(
        Titolo = films$recorded_title,
        `Valutazione IMDb` = films$imdb_rating,
        Voti = films$imdb_votes,
        check.names = FALSE
      ),
      rownames = FALSE,
      options = list(pageLength = 10, scrollX = TRUE, language = table_language)
    )
  })

  ranking_table <- function(descending) {
    films <- dashboard_ranking(selected_films(), descending)
    datatable(
      data.frame(
        Titolo = dashboard_title_links(films$title, films$film_id),
        Regia = dashboard_list_text(films$directors),
        IMDb = films$imdb_rating,
        Voti = films$imdb_votes,
        check.names = FALSE
      ),
      rownames = FALSE, escape = -1,
      options = list(dom = "t", ordering = FALSE, scrollX = TRUE)
    )
  }
  output$highest <- renderDT(ranking_table(TRUE))
  output$lowest <- renderDT(ranking_table(FALSE))
  output$director_summary <- renderDT({
    datatable(
      head(dashboard_director_counts(selected_films()), 5L),
      rownames = FALSE,
      options = list(dom = "t", ordering = FALSE)
    )
  })
  output$entries_table <- renderDT({
    entries <- selected_entries()
    if (!is.null(input$director) && input$director != "all") {
      entries <- entries[vapply(entries$directors, function(values) {
        input$director %in% values
      }, logical(1)), , drop = FALSE]
    }
    if (!is.null(input$genre) && input$genre != "all") {
      entries <- entries[vapply(entries$genres, function(values) {
        input$genre %in% values
      }, logical(1)), , drop = FALSE]
    }
    datatable(
      data.frame(
        Data = format(entries$date, "%Y-%m-%d"),
        Titolo = dashboard_title_links(entries$recorded_title, entries$film_id),
        Regia = dashboard_list_text(entries$directors),
        Genere = dashboard_list_text(entries$genres),
        Fonti = dashboard_list_text(entries$sources),
        check.names = FALSE
      ),
      rownames = FALSE, escape = -2,
      options = list(pageLength = 10, order = list(), scrollX = TRUE,
                     language = table_language)
    )
  })
}

shinyApp(ui, server)
