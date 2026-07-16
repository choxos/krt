# Import an ASAP six-column table (or a Cell Press STAR three-column table with
# section headers), parsing the compound IDENTIFIER back into typed fields.

#' @noRd
.read_table_any <- function(path, sheet = 1) {
  ext <- tolower(tools::file_ext(path))
  if (ext %in% c("xlsx", "xls")) {
    need_pkg("openxlsx", "reading xlsx")
    df <- openxlsx::read.xlsx(path, sheet = sheet, colNames = TRUE)
  } else {
    sep <- if (ext == "tsv") "\t" else ","
    df <- utils::read.csv(path, sep = sep, check.names = FALSE,
                          stringsAsFactors = FALSE, colClasses = "character",
                          na.strings = c("", "NA"))
  }
  df[] <- lapply(df, function(col) { col <- as.character(col); col[is.na(col)] <- ""; col })
  df
}

#' @noRd
.canon_asap_headers <- function(hdrs) {
  norm <- function(s) gsub("[^A-Z0-9]", "", toupper(s))
  known <- c(RESOURCETYPE = "RESOURCE_TYPE", RESOURCENAME = "RESOURCE_NAME",
             REAGENTORRESOURCE = "REAGENT_OR_RESOURCE", SOURCE = "SOURCE",
             IDENTIFIER = "IDENTIFIER", IDENTIFIERS = "IDENTIFIER",
             NEWREUSE = "NEW_REUSE", ADDITIONALINFORMATION = "ADDITIONAL_INFORMATION",
             ADDITIONALINFO = "ADDITIONAL_INFORMATION", NOTES = "ADDITIONAL_INFORMATION")
  vapply(hdrs, function(h) { v <- known[[norm(h)]]; if (is.null(v)) h else v }, character(1))
}

#' @noRd
.cellpress_section_type <- function(name) {
  n <- tolower(name)
  if (grepl("antibod", n)) return("Antibody")
  if (grepl("cell line", n)) return("Experimental model: Cell line")
  if (grepl("organism|strain|mouse|animal", n)) return("Experimental model: Organism/strain")
  if (grepl("software|algorithm|code", n)) return("Software/code")
  if (grepl("bacter", n)) return("Bacterial strain")
  if (grepl("virus|viral", n)) return("Viral vector")
  if (grepl("chemical|peptide|protein|reagent", n)) return("Chemical, peptide, or recombinant protein")
  if (grepl("oligo", n)) return("Oligonucleotide")
  if (grepl("recombinant dna|plasmid", n)) return("Recombinant DNA")
  if (grepl("deposited|dataset|data", n)) return("Dataset")
  if (grepl("critical|assay|kit", n)) return("Critical commercial assay")
  if (grepl("biological sample|specimen", n)) return("Biological sample")
  "Other"
}

#' Import an ASAP or Cell Press Key Resources Table
#'
#' @param path A file path (csv/tsv/xlsx) or a data frame already read in.
#' @param sheet Worksheet (for xlsx).
#' @param title Optional title for the resulting table.
#' @return A [krt_tbl] with profile `"asap"`.
#' @export
#' @examples
#' f <- tempfile(fileext = ".csv")
#' writeLines(export_asap(krt_example), f)
#' k <- import_asap(f)
#' length(k$resources)
import_asap <- function(path, sheet = 1, title = NULL) {
  raw <- if (is.data.frame(path)) path else .read_table_any(path, sheet)
  names(raw) <- .canon_asap_headers(names(raw))
  cn <- names(raw)
  cellpress <- ("REAGENT_OR_RESOURCE" %in% cn) && !("RESOURCE_TYPE" %in% cn)
  getcol <- function(row, col) if (col %in% cn) as.character(row[[col]]) else ""

  k <- new_krt(title = title, profile = "asap")
  current_type <- "Other"
  for (i in seq_len(nrow(raw))) {
    row <- raw[i, , drop = FALSE]
    src <- getcol(row, "SOURCE")
    idc <- getcol(row, "IDENTIFIER")
    if (cellpress) {
      name <- getcol(row, "REAGENT_OR_RESOURCE")
      if (!nzchar(src) && !nzchar(idc) && nzchar(name)) {
        current_type <- .cellpress_section_type(name); next
      }
      rtype <- current_type; nr <- ""; addl <- ""
    } else {
      rtype <- getcol(row, "RESOURCE_TYPE")
      name <- getcol(row, "RESOURCE_NAME")
      nr <- getcol(row, "NEW_REUSE")
      addl <- getcol(row, "ADDITIONAL_INFORMATION")
    }
    if (!nzchar(name) && !nzchar(idc)) next

    m <- vocab_match(if (nzchar(rtype)) rtype else "Other", "resource_type", fuzzy = TRUE)
    rt <- if (m$ok) m$value else "Other"

    fields <- parse_compound_identifier(idc)
    other <- fields$other; fields$other <- NULL
    notes <- paste(c(if (nzchar(addl)) addl, other), collapse = "; ")
    if (length(fields) == 0L && is_pending_identifier(idc)) {
      notes <- paste(c(notes, idc), collapse = "; ")
    }

    args <- c(list(rt, display_name = if (nzchar(name)) name else NULL), fields)
    if (nzchar(src)) args$source_name <- src
    if (nzchar(nr)) args$new_or_reuse <- tolower(nr)
    if (nzchar(notes)) args$notes <- notes
    k <- add_resource(k, do.call(new_resource, args))
  }
  .touch(k, "import", params = list(format = if (cellpress) "cell-press" else "asap"))
}
