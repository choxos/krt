# Reading manuscript text from PDF, JATS/NISO XML, DOCX, or plain text, and
# detecting an embedded Key Resources Table.

#' @noRd
.detect_text_format <- function(input) {
  if (length(input) == 1L && file.exists(input)) {
    ext <- tolower(tools::file_ext(input))
    if (ext == "pdf") return("pdf")
    if (ext %in% c("xml", "jats", "nxml")) return("jats")
    if (ext %in% c("docx")) return("docx")
    if (ext %in% c("txt", "text", "md")) return("txt")
    return("txt")
  }
  txt <- paste(input, collapse = "\n")
  if (grepl("<article|<!DOCTYPE article|<front>|JATS", txt)) return("jats")
  "plain"
}

#' @noRd
.xml_tables <- function(xml) {
  xml2::xml_ns_strip(xml)
  tabs <- xml2::xml_find_all(xml, ".//table")
  out <- lapply(tabs, function(t) {
    rows <- xml2::xml_find_all(t, ".//tr")
    if (length(rows) < 2L) return(NULL)
    cells <- lapply(rows, function(r)
      trimws(xml2::xml_text(xml2::xml_find_all(r, ".//td|.//th"))))
    nc <- max(lengths(cells))
    if (nc < 3L) return(NULL)
    mat <- do.call(rbind, lapply(cells, function(c) { length(c) <- nc; c }))
    df <- as.data.frame(mat[-1, , drop = FALSE], stringsAsFactors = FALSE)
    names(df) <- trimws(mat[1, ])
    df[] <- lapply(df, function(x) { x[is.na(x)] <- ""; x })
    df
  })
  Filter(Negate(is.null), out)
}

#' Read manuscript text and tables from an input
#'
#' @param input A file path (pdf/xml/jats/docx/txt) or a plain-text string.
#' @param format Optional explicit format; auto-detected when `NULL`.
#' @return A list with `text` (character), `tables` (list of data frames), and
#'   `format`.
#' @export
#' @examples
#' read_input_text("We used FIJI (RRID:SCR_002285).")$text
read_input_text <- function(input, format = NULL) {
  format <- format %||% .detect_text_format(input)
  tables <- list()
  if (identical(format, "jats")) {
    xml <- if (length(input) == 1L && file.exists(input)) {
      xml2::read_xml(input)
    } else {
      xml2::read_xml(paste(input, collapse = "\n"))
    }
    tables <- .xml_tables(xml)
    text <- xml2::xml_text(xml)
  } else if (identical(format, "pdf")) {
    need_pkg("pdftools", "reading PDF")
    text <- paste(pdftools::pdf_text(input), collapse = "\n")
  } else if (identical(format, "docx")) {
    tmp <- tempfile(); on.exit(unlink(tmp, recursive = TRUE), add = TRUE)
    utils::unzip(input, files = "word/document.xml", exdir = tmp)
    xml <- xml2::read_xml(file.path(tmp, "word", "document.xml"))
    xml2::xml_ns_strip(xml)
    text <- paste(xml2::xml_text(xml2::xml_find_all(xml, ".//p")), collapse = "\n")
  } else if (identical(format, "txt")) {
    text <- paste(readLines(input, warn = FALSE, encoding = "UTF-8"), collapse = "\n")
  } else {
    text <- paste(input, collapse = "\n")
  }
  list(text = text, tables = tables, format = format)
}

#' Detect and parse a Key Resources Table embedded in a document
#'
#' @param doc The result of [read_input_text()].
#' @return A [krt_tbl] parsed from the embedded table, or `NULL` if none is
#'   found.
#' @export
#' @examples
#' detect_existing_krt(read_input_text("No table here."))
detect_existing_krt <- function(doc) {
  for (tb in doc$tables) {
    canon <- .canon_asap_headers(names(tb))
    if (any(c("RESOURCE_TYPE", "REAGENT_OR_RESOURCE") %in% canon) &&
        "IDENTIFIER" %in% canon) {
      return(tryCatch(import_asap(tb), error = function(e) NULL))
    }
  }
  NULL
}
