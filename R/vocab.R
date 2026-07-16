# Controlled-vocabulary accessors over the baked-in reference tables.

#' Access a KRT controlled vocabulary
#'
#' @param key Vocabulary name (e.g. "resource_type", "new_or_reuse", "status").
#' @return A character vector of allowed values.
#' @export
#' @examples
#' krt_vocab("new_or_reuse")
krt_vocab <- function(key) {
  cv <- ref_data("controlled_vocab")
  v <- cv[[key]]
  if (is.null(v)) stop(sprintf("Unknown vocabulary '%s'.", key), call. = FALSE)
  v
}

#' KRT controlled vocabularies
#'
#' Convenience accessors for the controlled vocabularies used across the package.
#'
#' @return A character vector of allowed values.
#' @examples
#' krt_resource_types()
#' krt_new_or_reuse()
#' @name krt_vocabularies
NULL

#' @rdname krt_vocabularies
#' @export
krt_resource_types <- function() krt_vocab("resource_type")

#' @rdname krt_vocabularies
#' @export
krt_new_or_reuse <- function() krt_vocab("new_or_reuse")

#' @rdname krt_vocabularies
#' @export
krt_statuses <- function() krt_vocab("status")

#' @rdname krt_vocabularies
#' @export
krt_approval_types <- function() krt_vocab("approval_type")

#' @rdname krt_vocabularies
#' @export
krt_roles <- function() krt_vocab("role")

#' @rdname krt_vocabularies
#' @export
krt_redaction_levels <- function() krt_vocab("redaction_level")

#' Match a value against a controlled vocabulary
#'
#' @param value A character value to check.
#' @param vocab A character vector of allowed values, or the name of a
#'   vocabulary (resolved with [krt_vocab()]).
#' @param fuzzy If `TRUE`, when there is no exact match return the nearest
#'   vocabulary term (by edit distance) as a suggestion instead of `NA`.
#' @return A list with `ok` (logical), `value` (the matched canonical term or
#'   `NA`), and `suggestion` (nearest term when `fuzzy` and not matched).
#' @export
#' @examples
#' vocab_match("Antibody", "resource_type")
#' vocab_match("antibodies", "resource_type", fuzzy = TRUE)
vocab_match <- function(value, vocab, fuzzy = FALSE) {
  if (is.character(vocab) && length(vocab) == 1L &&
      !is.null(tryCatch(ref_data("controlled_vocab")[[vocab]], error = function(e) NULL))) {
    vocab <- krt_vocab(vocab)
  }
  value <- as.character(value)
  if (length(value) != 1L) stop("`value` must be length one.", call. = FALSE)
  if (value %in% vocab) {
    return(list(ok = TRUE, value = value, suggestion = NA_character_))
  }
  # Case-insensitive exact match maps to the canonical term.
  ci <- which(tolower(vocab) == tolower(value))
  if (length(ci) == 1L) {
    return(list(ok = TRUE, value = vocab[ci], suggestion = NA_character_))
  }
  suggestion <- NA_character_
  if (isTRUE(fuzzy) && length(vocab)) {
    d <- utils::adist(tolower(value), tolower(vocab))[1, ]
    j <- which.min(d)
    # Only suggest when the nearest term is genuinely close, so unrelated input
    # does not get a spurious suggestion.
    threshold <- max(2L, ceiling(0.5 * nchar(value)))
    if (length(j) && d[j] <= threshold) suggestion <- vocab[j]
  }
  list(ok = FALSE, value = NA_character_, suggestion = suggestion)
}
