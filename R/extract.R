# The manuscript-extraction orchestrator. Reads an input, optionally detects an
# existing KRT, runs the chosen engine, and funnels the result through the same
# normalize + validate pipeline as every other import path.

#' Extract a Key Resources Table from a manuscript
#'
#' Reads a manuscript (PDF, JATS/NISO XML, DOCX, or text), extracts candidate
#' resources with the deterministic regex engine (default) or an LLM, and
#' returns them as a validated [krt_tbl]. Every result is provenance-stamped
#' with the engine used.
#'
#' @param input A file path or text string.
#' @param engine `"regex"` (deterministic, offline) or `"llm"` (requires a
#'   configured provider and API key).
#' @param format Optional explicit input format.
#' @param profile Profile to assign to the extracted table.
#' @param llm A [krt_llm()] configuration (for the LLM engine).
#' @param resolve Whether to resolve identifiers during validation.
#' @param existing `"detect"` to also parse an embedded KRT, or `"ignore"`.
#' @param title Optional title for the extracted table.
#' @return A list with `krt` (the extracted [krt_tbl]), `candidates` (the raw
#'   resource candidates), `existing_krt` (a parsed embedded table or `NULL`),
#'   and `report` (a validation report).
#' @export
#' @examples
#' res <- extract_krt("Anti-TH (RRID:AB_390204); FIJI (RRID:SCR_002285).")
#' nrow(as.data.frame(res$krt))
extract_krt <- function(input, engine = c("regex", "llm"), format = NULL,
                        profile = "generic", llm = NULL, resolve = FALSE,
                        existing = c("detect", "ignore"), title = NULL) {
  engine <- match.arg(engine)
  existing <- match.arg(existing)
  doc <- read_input_text(input, format)
  existing_krt <- if (identical(existing, "detect")) detect_existing_krt(doc) else NULL

  candidates <- if (identical(engine, "llm")) {
    extract_llm(doc$text, llm = llm %||% krt_llm())
  } else {
    extract_candidates(doc$text)
  }

  k <- new_krt(title = title, profile = profile)
  for (r in candidates) k <- add_resource(k, r)
  k <- normalize_ids(k)
  k <- .touch(k, "extract", params = list(engine = engine, format = doc$format))
  report <- validate_krt(k, resolve = resolve)
  list(krt = k, candidates = candidates, existing_krt = existing_krt, report = report)
}
