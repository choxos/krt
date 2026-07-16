# Rendering a KRT as a human-readable table (Markdown, HTML, or Word). The
# STAR Methods profile groups rows under the twelve fixed category headers, in
# the order the Cell Press template uses; other profiles render a flat table.

# Ordered section groups for a render. For a profile that declares `sections`
# (STAR Methods), each of the fourteen core resource types is projected onto its
# category, and the categories are emitted in the profile's declared order,
# skipping empty ones. Otherwise rows are grouped by raw resource type in the
# order they appear, and a flat table gets a single unheaded group.
#' @noRd
.render_groups <- function(resources, profile, grouped) {
  if (!isTRUE(grouped) || !length(resources)) return(NULL)
  types <- vapply(resources, function(r) r$resource_type %||% "Other", character(1))
  sec <- tryCatch(get_profile(profile)$sections, error = function(e) NULL)
  if (is.null(sec) || is.null(sec$order)) {
    return(lapply(unique(types), function(ty) list(header = ty, idx = which(types == ty))))
  }
  cat_map <- sec$map %||% list()
  cats <- vapply(types, function(ty) as.character(cat_map[[ty]] %||% "Other"), character(1))
  order <- as.character(unlist(sec$order))
  groups <- list()
  for (h in c(order, setdiff(unique(cats), order))) {
    idx <- which(cats == h)
    if (length(idx)) groups[[length(groups) + 1L]] <- list(header = h, idx = idx)
  }
  groups
}

#' @noRd
.esc_md <- function(x) gsub("|", "\\|", x, fixed = TRUE)

#' @noRd
.md_row <- function(cells) paste0("| ", paste(.esc_md(cells), collapse = " | "), " |")

#' @noRd
.render_md <- function(df, groups, title = NULL) {
  cols <- names(df)
  out <- character(0)
  if (!is.null(title)) out <- c(out, paste("##", title), "")
  out <- c(out, .md_row(cols),
           paste0("|", paste(rep(" --- ", length(cols)), collapse = "|"), "|"))
  emit_row <- function(i) out <<- c(out, .md_row(as.character(df[i, ])))
  emit_header <- function(h)
    out <<- c(out, .md_row(c(paste0("**", h, "**"), rep("", length(cols) - 1L))))
  if (is.null(groups)) {
    for (i in seq_len(nrow(df))) emit_row(i)
  } else {
    for (g in groups) { emit_header(g$header); for (i in g$idx) emit_row(i) }
  }
  paste(out, collapse = "\n")
}

#' @noRd
.esc_html <- function(x) {
  x <- gsub("&", "&amp;", x, fixed = TRUE)
  x <- gsub("<", "&lt;", x, fixed = TRUE)
  gsub(">", "&gt;", x, fixed = TRUE)
}

#' @noRd
.render_html <- function(df, groups, title = NULL) {
  cols <- names(df)
  th <- paste0("<th>", .esc_html(cols), "</th>", collapse = "")
  row_html <- function(i) paste0("<tr>", paste0("<td>", .esc_html(as.character(df[i, ])),
                                                "</td>", collapse = ""), "</tr>")
  header_html <- function(h) sprintf("<tr><td colspan=\"%d\"><strong>%s</strong></td></tr>",
                                     length(cols), .esc_html(h))
  rows <- character(0)
  if (is.null(groups)) {
    for (i in seq_len(nrow(df))) rows <- c(rows, row_html(i))
  } else {
    for (g in groups) {
      rows <- c(rows, header_html(g$header))
      for (i in g$idx) rows <- c(rows, row_html(i))
    }
  }
  paste0(if (!is.null(title)) sprintf("<h2>%s</h2>\n", .esc_html(title)) else "",
         "<table>\n<thead><tr>", th, "</tr></thead>\n<tbody>\n",
         paste(rows, collapse = "\n"), "\n</tbody>\n</table>")
}

#' @noRd
.render_docx <- function(df, path, title = NULL, groups = NULL) {
  need_pkg("officer", "Word (docx) rendering")
  cols <- names(df)
  if (is.null(groups)) {
    tbl <- df
  } else {
    # Interleave a section-header row (category in the first cell) before each
    # group's rows, so the Word table carries the STAR category structure.
    parts <- list()
    for (g in groups) {
      hdr <- as.data.frame(as.list(c(g$header, rep("", length(cols) - 1L))),
                           stringsAsFactors = FALSE)
      names(hdr) <- cols
      parts <- c(parts, list(hdr, df[g$idx, , drop = FALSE]))
    }
    tbl <- do.call(rbind, parts)
    rownames(tbl) <- NULL
  }
  doc <- officer::read_docx()
  if (!is.null(title)) doc <- officer::body_add_par(doc, title, style = "heading 1")
  doc <- tryCatch(officer::body_add_table(doc, tbl, first_row = TRUE),
                  error = function(e) officer::body_add_table(doc, tbl))
  print(doc, target = path)
  invisible(path)
}

#' Render a KRT as a formatted table
#'
#' Produces a human-readable Key Resources Table. The `"star-methods"` profile
#' projects the table to the three Cell Press columns (REAGENT or RESOURCE,
#' SOURCE, IDENTIFIER) and groups resources under the twelve standard STAR
#' Methods category headers, in the order the template uses; other profiles
#' render the ASAP six-column layout.
#'
#' @param x A [krt_tbl].
#' @param path Output path, or `NULL` to return the text (md/html).
#' @param format `"md"`, `"html"`, or `"docx"`.
#' @param profile Profile controlling the layout (default the table's profile).
#' @param template Unused placeholder for a future Word template.
#' @param audience `"author"` (full) or `"public"` (redacted) for shared tables.
#' @param redact Redaction strength for public output, or `FALSE` to disable.
#' @return The rendered text (md/html), or the path (invisibly) for docx.
#' @export
#' @examples
#' cat(substr(render_krt(krt_example, profile = "star-methods"), 1, 80))
render_krt <- function(x, path = NULL, format = c("md", "html", "docx"),
                       profile = NULL, template = NULL,
                       audience = c("author", "public"), redact = NULL) {
  stopifnot(is_krt(x))
  format <- match.arg(format)
  x <- .maybe_redact(x, match.arg(audience), redact)
  profile <- profile %||% x$profile %||% "generic"
  star <- identical(profile, "star-methods")
  df <- project_profile(x, if (star) "star-methods" else "asap")
  groups <- .render_groups(x$resources, profile, grouped = star)

  if (identical(format, "docx")) {
    if (is.null(path)) stop("docx rendering requires a `path`.", call. = FALSE)
    return(.render_docx(df, path, title = x$title, groups = groups))
  }
  content <- if (identical(format, "md")) .render_md(df, groups, title = x$title)
             else .render_html(df, groups, title = x$title)
  if (is.null(path)) return(content)
  .write_utf8(content, path)
  invisible(path)
}
