# Rendering a KRT as a human-readable table (Markdown, HTML, or Word). The
# STAR Methods profile groups rows under resource-type section headers.

#' @noRd
.esc_md <- function(x) gsub("|", "\\|", x, fixed = TRUE)

#' @noRd
.md_row <- function(cells) paste0("| ", paste(.esc_md(cells), collapse = " | "), " |")

#' @noRd
.render_md <- function(df, types, star, title = NULL) {
  cols <- names(df)
  out <- character(0)
  if (!is.null(title)) out <- c(out, paste("##", title), "")
  out <- c(out, .md_row(cols),
           paste0("|", paste(rep(" --- ", length(cols)), collapse = "|"), "|"))
  emit_group <- function(idx, header = NULL) {
    if (!is.null(header)) {
      pad <- c(paste0("**", header, "**"), rep("", length(cols) - 1L))
      out <<- c(out, .md_row(pad))
    }
    for (i in idx) out <<- c(out, .md_row(as.character(df[i, ])))
  }
  if (isTRUE(star) && nrow(df)) {
    for (ty in unique(types)) emit_group(which(types == ty), header = ty)
  } else if (nrow(df)) {
    emit_group(seq_len(nrow(df)))
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
.render_html <- function(df, types, star, title = NULL) {
  cols <- names(df)
  th <- paste0("<th>", .esc_html(cols), "</th>", collapse = "")
  rows <- character(0)
  row_html <- function(i) paste0("<tr>", paste0("<td>", .esc_html(as.character(df[i, ])),
                                                "</td>", collapse = ""), "</tr>")
  if (isTRUE(star) && nrow(df)) {
    for (ty in unique(types)) {
      rows <- c(rows, sprintf("<tr><td colspan=\"%d\"><strong>%s</strong></td></tr>",
                              length(cols), .esc_html(ty)))
      for (i in which(types == ty)) rows <- c(rows, row_html(i))
    }
  } else {
    for (i in seq_len(nrow(df))) rows <- c(rows, row_html(i))
  }
  paste0(if (!is.null(title)) sprintf("<h2>%s</h2>\n", .esc_html(title)) else "",
         "<table>\n<thead><tr>", th, "</tr></thead>\n<tbody>\n",
         paste(rows, collapse = "\n"), "\n</tbody>\n</table>")
}

#' @noRd
.render_docx <- function(df, path, title = NULL) {
  need_pkg("officer", "Word (docx) rendering")
  doc <- officer::read_docx()
  if (!is.null(title)) doc <- officer::body_add_par(doc, title, style = "heading 1")
  doc <- tryCatch(officer::body_add_table(doc, df, first_row = TRUE),
                  error = function(e) officer::body_add_table(doc, df))
  print(doc, target = path)
  invisible(path)
}

#' Render a KRT as a formatted table
#'
#' Produces a STAR Methods-style table for human review. The `"star-methods"`
#' profile groups resources under type headers; other profiles render the ASAP
#' six-column layout.
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
#' cat(substr(render_krt(krt_example, format = "md"), 1, 80))
render_krt <- function(x, path = NULL, format = c("md", "html", "docx"),
                       profile = NULL, template = NULL,
                       audience = c("author", "public"), redact = NULL) {
  stopifnot(is_krt(x))
  format <- match.arg(format)
  x <- .maybe_redact(x, match.arg(audience), redact)
  profile <- profile %||% x$profile %||% "generic"
  star <- identical(profile, "star-methods")
  df <- project_profile(x, if (star) "star-methods" else "asap")
  types <- vapply(x$resources, function(r) r$resource_type %||% "Other", character(1))

  if (identical(format, "docx")) {
    if (is.null(path)) stop("docx rendering requires a `path`.", call. = FALSE)
    return(.render_docx(df, path, title = x$title))
  }
  content <- if (identical(format, "md")) .render_md(df, types, star, title = x$title)
             else .render_html(df, types, star, title = x$title)
  if (is.null(path)) return(content)
  .write_utf8(content, path)
  invisible(path)
}
