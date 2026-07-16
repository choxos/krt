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
                         ".xml", ".jats", ".nxml", ".docx", ".txt", ".pdf")),
    selectInput("profile", "Profile", choices = profiles, selected = "asap"),
    radioButtons("mode", "Imported file is",
                 c("A Key Resources Table" = "krt", "A manuscript to extract" = "extract"),
                 selected = "krt"),
    actionButton("example", "Load example", icon = icon("table")),
    actionButton("normalize", "Normalize identifiers", icon = icon("wand-magic-sparkles")),
    actionButton("validate", "Validate", class = "btn-primary", icon = icon("check")),
    helpText("Cells are editable in the generic (wide) view; profile views are read-only projections."),
    hr(),
    radioButtons("audience", "Export audience",
                 c("Author" = "author", "Public (redacted)" = "public")),
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
  rv <- reactiveValues(k = krt_example, report = NULL)

  # Any change to the table invalidates the last validation report, so a stale
  # result is never shown for edited or newly imported data.
  set_table <- function(k) { rv$k <- k; rv$report <- NULL }

  observeEvent(input$example, set_table(krt_example))

  observeEvent(input$profile, {
    k <- rv$k; k$profile <- input$profile; set_table(k)
  })

  observeEvent(input$normalize, set_table(normalize_ids(rv$k)))

  observeEvent(input$file, {
    req(input$file)
    k <- tryCatch({
      if (identical(input$mode, "extract")) {
        extract_krt(input$file$datapath, profile = input$profile)$krt
      } else {
        import_krt(input$file$datapath, profile = input$profile)
      }
    }, error = function(e) {
      showNotification(conditionMessage(e), type = "error"); NULL
    })
    if (!is.null(k)) set_table(k)
  })

  is_wide <- reactive(!(input$profile %in% c("asap", "star-methods")))

  view_df <- reactive({
    v <- if (is_wide()) "wide" else input$profile
    as.data.frame(rv$k, view = v)
  })

  output$tbl <- renderDT(
    datatable(view_df(), editable = if (is_wide()) "cell" else FALSE,
              rownames = FALSE,
              options = list(scrollX = TRUE, pageLength = 25)))

  # Write an edited cell back into the underlying record. Only the wide view is
  # editable, so a column name maps directly to a resource field.
  observeEvent(input$tbl_cell_edit, {
    info <- input$tbl_cell_edit
    df <- view_df()
    fld <- names(df)[as.integer(info$col) + 1L]
    res <- rv$k$resources
    row <- as.integer(info$row)
    if (row < 1L || row > length(res)) return(NULL)
    rid <- res[[row]]$resource_id
    upd <- stats::setNames(list(info$value), fld)
    k2 <- tryCatch(do.call(update_resource, c(list(rv$k, rid), upd)),
                   error = function(e) {
                     showNotification(conditionMessage(e), type = "error"); NULL
                   })
    if (!is.null(k2)) set_table(k2)
  })

  observeEvent(input$validate, {
    rv$report <- paste(format(validate_krt(rv$k, profile = input$profile)),
                       collapse = "\n")
  })

  output$report <- renderText({
    if (is.null(rv$report)) "Table changed. Click 'Validate' to (re)check it." else rv$report
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
