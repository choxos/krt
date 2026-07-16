# Generic tabular import: map arbitrary CSV/TSV/xlsx columns onto core fields,
# guessing the mapping from the headers when none is supplied.

#' @noRd
.guess_mapping <- function(hdrs) {
  fields <- names(all_fields())
  fnorm <- tolower(gsub("_", "", fields))
  aliases <- list(name = "display_name", type = "resource_type",
                  resourcetype = "resource_type", resourcename = "display_name",
                  vendor = "vendor", source = "source_name",
                  catalog = "catalog_number", catalognumber = "catalog_number",
                  cat = "catalog_number", rrid = "rrid", doi = "doi",
                  identifier = "__identifier__", version = "version", notes = "notes",
                  newreuse = "new_or_reuse", organism = "organism")
  map <- list()
  for (h in hdrs) {
    n <- tolower(gsub("[^a-z0-9]", "", tolower(h)))
    if (!nzchar(n)) next
    if (!is.null(aliases[[n]])) { map[[h]] <- aliases[[n]]; next }
    exact <- fields[fnorm == n]
    if (length(exact)) { map[[h]] <- exact[1]; next }
    d <- utils::adist(n, fnorm)[1, ]
    if (length(d) && min(d) <= 2L) map[[h]] <- fields[which.min(d)]
  }
  map
}

#' Import a generic tabular Key Resources Table
#'
#' @param path A file path (csv/tsv/xlsx) or a data frame.
#' @param mapping Optional named list mapping column names to core field names;
#'   guessed from the headers when `NULL`.
#' @param sheet Worksheet (for xlsx).
#' @param profile Profile to assign to the imported table.
#' @param title Optional title.
#' @return A [krt_tbl].
#' @export
#' @examples
#' df <- data.frame(type = "Antibody", name = "Anti-TH", rrid = "RRID:AB_1",
#'                  "new/reuse" = "reuse", check.names = FALSE)
#' import_tabular(df)$resources[[1]]$resource_type
import_tabular <- function(path, mapping = NULL, sheet = 1, profile = "generic",
                           title = NULL) {
  raw <- if (is.data.frame(path)) path else .read_table_any(path, sheet)
  mapping <- mapping %||% .guess_mapping(names(raw))
  k <- new_krt(title = title, profile = profile)
  for (i in seq_len(nrow(raw))) {
    row <- raw[i, , drop = FALSE]
    args <- list()
    for (h in names(mapping)) {
      val <- as.character(row[[h]])
      if (is.na(val) || !nzchar(val)) next
      target <- mapping[[h]]
      if (identical(target, "__identifier__")) {
        # A generic identifier column may hold a DOI, accession, RRID, or a
        # compound string; route it through the typed parser rather than
        # forcing everything into `rrid`.
        parsed <- parse_compound_identifier(val)
        other <- parsed$other; parsed$other <- NULL
        for (fn in names(parsed)) args[[fn]] <- parsed[[fn]]
        if (length(other)) args$notes <- paste(c(args$notes, other), collapse = "; ")
      } else {
        args[[target]] <- val
      }
    }
    rt <- args$resource_type %||% "Other"
    m <- vocab_match(rt, "resource_type", fuzzy = TRUE)
    rt <- if (m$ok) m$value else "Other"
    args$resource_type <- NULL
    dn <- args$display_name; args$display_name <- NULL
    if (is.null(dn) && !length(args)) next
    k <- add_resource(k, do.call(new_resource, c(list(rt, display_name = dn), args)))
  }
  .touch(k, "import", params = list(format = "tabular"))
}
