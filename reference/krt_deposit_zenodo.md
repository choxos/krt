# Deposit a KRT to Zenodo

Creates a Zenodo deposition, uploads the table as JSON, sets metadata,
and optionally publishes. The minted (pre-reserved) DOI is written back
into the table's provenance and `table_id`. Deposits default to the
redacted public audience, since a deposit is a shared artifact.

## Usage

``` r
krt_deposit_zenodo(
  x,
  token = Sys.getenv("ZENODO_TOKEN"),
  sandbox = TRUE,
  metadata = NULL,
  publish = FALSE,
  audience = c("public", "author"),
  timeout = 60
)
```

## Arguments

- x:

  A [krt_tbl](https://choxos.github.io/krt/reference/new_krt.md).

- token:

  Zenodo access token (defaults to `ZENODO_TOKEN`).

- sandbox:

  Use the Zenodo sandbox (default `TRUE`).

- metadata:

  Optional Zenodo metadata list (a sensible default otherwise).

- publish:

  Whether to publish immediately (default `FALSE`).

- audience:

  `"public"` (redacted, the default) or `"author"` (full).

- timeout:

  Request timeout in seconds.

## Value

A list with `deposit` (the API response), `doi`, `uploaded` and
`published` (per-stage status), and `x` (the table, with the DOI
recorded only when every stage succeeded). On failure, `deposit` is
`NULL`.

## Examples

``` r
if (FALSE) { # \dontrun{
# Not executable without a Zenodo (sandbox) account and access token, so
# this example cannot be run during a check.
res <- krt_deposit_zenodo(krt_example, sandbox = TRUE)
res$doi
} # }
```
