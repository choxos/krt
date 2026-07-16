# Package load hooks.
#
# `.onLoad` populates the package registries (profiles, validators, resolvers,
# extractors, LLM providers, suggest sources) once all functions are defined.
# Registration helpers are added as each subsystem lands; the dispatcher below
# calls whichever registrars exist so partially built states still load.

.onLoad <- function(libname, pkgname) {
  registrars <- c(
    ".register_builtin_profiles",
    ".register_builtin_validators",
    ".register_builtin_resolvers",
    ".register_builtin_extractors",
    ".register_builtin_llm_providers",
    ".register_builtin_suggest_sources"
  )
  ns <- asNamespace(pkgname)
  for (fn in registrars) {
    if (exists(fn, envir = ns, mode = "function", inherits = FALSE)) {
      # Registrars that are not yet defined are skipped above; a defined
      # registrar that errors is a bug surfaced by the test suite, so we do not
      # emit output from .onLoad here.
      try(get(fn, envir = ns)(), silent = TRUE)
    }
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
