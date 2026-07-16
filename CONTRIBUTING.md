# Contributing to krt

Thank you for your interest in improving krt. Contributions of all kinds
are welcome: bug reports, feature requests, documentation, profiles,
validators, and code.

## Reporting issues

- Search existing issues first.
- Use the bug report or feature request templates.
- For bugs, include a minimal reproducible example (a `reprex`) and the
  output of [`sessionInfo()`](https://rdrr.io/r/utils/sessionInfo.html).

## Development workflow

1.  Fork and clone the repository.
2.  Install development dependencies: `devtools::install_dev_deps()`.
3.  Make your change on a feature branch.
4.  Run `devtools::document()` to regenerate `NAMESPACE` and `man/`.
5.  Run `devtools::test()` and `devtools::check()`; both must pass
    cleanly.
6.  Keep the offline-first testing contract: any function that touches
    the network must have a mock or `resolve = FALSE` path, and its
    tests must `skip_on_cran()` and `skip_if_offline()`.
7.  Open a pull request describing the change and referencing any
    related issue.

## Coding conventions

- Base R and S3; no tidyverse in package code. `snake_case`.
- Call dependencies as `pkg::fn()`; do not add `importFrom` directives.
- Document exported functions with roxygen2 (markdown mode); mark
  internal helpers `@noRd`.
- Heavy or optional dependencies belong in `Suggests` and must be gated
  with [`requireNamespace()`](https://rdrr.io/r/base/ns-load.html).
- American English spelling. Do not use a dash as a sentence connector.

## Adding a profile, validator, resolver, or extractor

krt is extensible through public registries. See
[`vignette("extending-krt")`](https://choxos.github.io/krt/articles/extending-krt.md)
for the plugin contracts and worked examples.

## Licensing of contributions

By contributing, you agree that your contributions are licensed under
GPL-3, the same license as the package. Do not contribute third-party
material unless its license is compatible and you document its
provenance.
