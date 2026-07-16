# Interactive Key Resources Table editor. Launch with krt::launch_krt().
library(shiny)
library(bslib)
library(DT)
library(krt)

profiles <- tryCatch(krt_profiles()$name, error = function(e) c("generic", "asap"))

ui <- page_sidebar(
  title = "krt · Key Resources Table editor",
  sidebar = sidebar(
    width = 320,
    fileInput("file", "Import KRT or manuscript",
              accept = c(".csv", ".tsv", ".json", ".yaml", ".yml", ".xlsx",
                         ".xml", ".txt", ".pdf")),
    selectInput("profile", "Profile", choices = profiles, selected = "asap"),
    radioButtons("mode", "Imported file is",
                 c("A Key Resources Table" = "krt", "A manuscript to extract" = "extract"),
                 selected = "krt"),
    actionButton("example", "Load example", icon = icon("table")),
    actionButton("validate", "Validate", class = "btn-primary", icon = icon("check")),
    hr(),
    radioButtons("audience", "Export audience", c("Author" = "author", "Public (redacted)" = "public")),
    downloadButton("dl_json", "JSON"),
    downloadButton("dl_asap", "ASAP CSV"),
    downloadButton("dl_md", "Markdown")
  ),
  navset_card_tab(
    nav_panel("Resources", DTOutput("tbl")),
    nav_panel("Validation", verbatimTextOutput("report")),
    nav_panel("Provenance", tableOutput("prov")),
    nav_panel("Attribution", verbatimTextOutput("attrib"))
  )
)

server <- function(input, output, session) {
  rv <- reactiveValues(k = krt_example)

  observeEvent(input$example, rv$k <- krt_example)

  observeEvent(input$profile, {
    k <- rv$k; k$profile <- input$profile; rv$k <- k
  })

  observeEvent(input$file, {
    req(input$file)
    rv$k <- tryCatch({
      if (identical(input$mode, "extract")) {
        extract_krt(input$file$datapath, profile = input$profile)$krt
      } else {
        import_krt(input$file$datapath, profile = input$profile)
      }
    }, error = function(e) {
      showNotification(conditionMessage(e), type = "error"); rv$k
    })
  })

  view_df <- reactive({
    v <- if (input$profile %in% c("asap", "star-methods")) input$profile else "wide"
    as.data.frame(rv$k, view = v)
  })

  output$tbl <- renderDT(
    datatable(view_df(), editable = TRUE, rownames = FALSE,
              options = list(scrollX = TRUE, pageLength = 25)))

  report_text <- eventReactive(input$validate, {
    paste(format(validate_krt(rv$k, profile = input$profile)), collapse = "\n")
  }, ignoreNULL = FALSE)

  output$report <- renderText({
    if (input$validate == 0) "Click 'Validate' to check the table." else report_text()
  })

  output$prov <- renderTable(as.data.frame(krt_provenance(rv$k)))
  output$attrib <- renderText(krt_attribution(input$profile))

  output$dl_json <- downloadHandler(
    filename = function() "key-resources-table.json",
    content = function(f) suppressWarnings(
      export_krt(rv$k, f, format = "json", audience = input$audience)))
  output$dl_asap <- downloadHandler(
    filename = function() "key-resources-table.csv",
    content = function(f) suppressWarnings(
      export_asap(rv$k, f, audience = input$audience)))
  output$dl_md <- downloadHandler(
    filename = function() "key-resources-table.md",
    content = function(f) render_krt(rv$k, f, profile = input$profile,
                                     audience = input$audience))
}

shinyApp(ui, server)
