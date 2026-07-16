# A base-R command-line interface. No argument-parsing dependency: the small,
# fixed subcommand surface is handled with a hand-rolled parser. Exposed to the
# shell through inst/scripts/krt.

#' @noRd
.parse_cli_opts <- function(args) {
  flags <- list(); pos <- character(0); i <- 1L
  while (i <= length(args)) {
    a <- args[i]
    if (startsWith(a, "--")) {
      key <- sub("^--", "", a)
      if (i + 1L <= length(args) && !startsWith(args[i + 1L], "--")) {
        flags[[key]] <- args[i + 1L]; i <- i + 2L
      } else { flags[[key]] <- TRUE; i <- i + 1L }
    } else { pos <- c(pos, a); i <- i + 1L }
  }
  list(positional = pos, flags = flags)
}

#' @noRd
.cli_usage <- function() {
  cat(paste(
    "krt: author, validate, and export Key Resources Tables",
    "",
    "Usage: krt <command> [file] [--option value]",
    "",
    "Commands:",
    "  new           Create an empty KRT           [--title T --out FILE]",
    "  import        Import to canonical JSON       FILE [--out FILE --profile P]",
    "  validate      Validate a KRT                 FILE [--profile P --layers L]",
    "  normalize     Normalize identifiers          FILE [--out FILE]",
    "  export        Export to a format             FILE --out FILE [--format F --audience A]",
    "  render        Render a table                 FILE --out FILE [--format md|html|docx]",
    "  extract       Extract from a manuscript      FILE [--engine regex|llm --out FILE]",
    "  audit-licenses  Show component licenses",
    "", sep = "\n"))
  invisible(0L)
}

#' Run the krt command-line interface
#'
#' Dispatches a subcommand. Used by the `krt` shell script
#' (`system.file("scripts", "krt", package = "krt")`); can also be called
#' directly with a character vector of arguments.
#'
#' @param args Command-line arguments (defaults to those passed to `Rscript`).
#' @return Invisibly an integer status code (0 success, 1 validation failure).
#' @export
#' @examples
#' krt_cli("audit-licenses")
#' f <- tempfile(fileext = ".json")
#' writeLines(write_krt_json(krt_example), f)
#' krt_cli(c("validate", f))
krt_cli <- function(args = commandArgs(trailingOnly = TRUE)) {
  if (!length(args) || args[1] %in% c("-h", "--help", "help")) return(.cli_usage())
  cmd <- args[1]
  o <- .parse_cli_opts(args[-1])
  f <- o$flags
  infile <- o$positional[1]
  out <- f$out

  status <- 0L
  switch(cmd,
    "new" = {
      k <- new_krt(title = if (is.character(f$title)) f$title else NULL)
      if (!is.null(out)) write_krt_json(k, out) else cat(write_krt_json(k), "\n")
    },
    "import" = {
      k <- import_krt(infile, profile = if (is.character(f$profile)) f$profile else NULL)
      if (!is.null(out)) write_krt_json(k, out) else cat(write_krt_json(k), "\n")
    },
    "normalize" = {
      k <- normalize_ids(import_krt(infile))
      if (!is.null(out)) write_krt_json(k, out) else cat(write_krt_json(k), "\n")
    },
    "validate" = {
      k <- import_krt(infile)
      rep <- validate_krt(k, profile = if (is.character(f$profile)) f$profile else k$profile,
                          layers = if (is.character(f$layers)) strsplit(f$layers, ",")[[1]]
                                   else c("structural", "semantic"))
      print(rep)
      status <- if (isTRUE(rep$valid)) 0L else 1L
    },
    "export" = {
      k <- import_krt(infile)
      aud <- if (is.character(f$audience)) f$audience else "author"
      if (is.character(f$format)) export_krt(k, out, format = f$format, audience = aud)
      else export_krt(k, out, audience = aud)   # infer format from the path
      cat(sprintf("Wrote %s\n", out))
    },
    "render" = {
      k <- import_krt(infile)
      render_krt(k, out, format = if (is.character(f$format)) f$format else "md")
      cat(sprintf("Wrote %s\n", out))
    },
    "extract" = {
      res <- extract_krt(infile, engine = if (is.character(f$engine)) f$engine else "regex")
      if (!is.null(out)) write_krt_json(res$krt, out) else cat(write_krt_json(res$krt), "\n")
      cat(sprintf("Extracted %d resource(s)\n", length(res$krt$resources)))
    },
    "audit-licenses" = {
      print(krt_audit_licenses())
    },
    {
      cat(sprintf("Unknown command '%s'.\n", cmd)); .cli_usage(); status <- 2L
    })
  invisible(status)
}
