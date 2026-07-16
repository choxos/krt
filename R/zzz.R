# Package load hooks.
#
# `.onLoad` populates the package's five registries (profiles, validators,
# resolvers, LLM providers, suggest sources) once all functions are defined.
# A missing or failing built-in registrar is surfaced as a warning.

.onLoad <- function(libname, pkgname) {
  registrars <- c(
    ".register_builtin_profiles",
    ".register_builtin_validators",
    ".register_builtin_resolvers",
    ".register_builtin_llm_providers",
    ".register_builtin_suggest_sources"
  )
  ns <- asNamespace(pkgname)
  for (fn in registrars) {
    f <- tryCatch(get(fn, envir = ns, mode = "function", inherits = FALSE),
                  error = function(e) NULL)
    # A missing or failing built-in registrar leaves the package with an empty
    # or partial registry; surface it as a warning rather than loading a
    # silently broken package.
    if (is.null(f)) {
      warning(sprintf("krt: built-in registrar '%s' is missing.", fn), call. = FALSE)
      next
    }
    tryCatch(f(), error = function(e) warning(sprintf(
      "krt: built-in registrar '%s' failed: %s", fn, conditionMessage(e)),
      call. = FALSE))
  }
  # Register the optional tibble method only when tibble is installed, so tibble
  # stays a Suggest.
  if (requireNamespace("tibble", quietly = TRUE) &&
      exists("as_tibble.krt_tbl", envir = ns, mode = "function", inherits = FALSE)) {
    registerS3method("as_tibble", "krt_tbl", get("as_tibble.krt_tbl", envir = ns),
                     envir = asNamespace("tibble"))
  }
  invisible()
}

.onAttach <- function(libname, pkgname) {
  version <- utils::packageVersion(pkgname)
  packageStartupMessage(sprintf(
    paste0("krt %s: author, validate, and export Key Resources Tables.\n",
           "  Start with new_krt(); see https://choxos.github.io/krt/"),
    version))
  invisible()
}
