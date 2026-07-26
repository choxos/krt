# Deposit a KRT to Figshare

Creates a Figshare article, reserves a DOI, and uploads the table as
JSON. The DOI is recorded in the table's provenance. Deposits default to
the redacted public audience.

## Usage

``` r
krt_deposit_figshare(
  x,
  token = Sys.getenv("FIGSHARE_TOKEN"),
  sandbox = TRUE,
  metadata = NULL,
  audience = c("public", "author"),
  timeout = 60
)
```

## Arguments

- x:

  A [krt_tbl](https://choxos.github.io/krt/reference/new_krt.md).

- token:

  Figshare token (defaults to `FIGSHARE_TOKEN`).

- sandbox:

  Use the Figshare sandbox (default `TRUE`).

- metadata:

  Optional article metadata.

- audience:

  `"public"` (redacted, the default) or `"author"` (full).

- timeout:

  Request timeout in seconds.

## Value

A list with `article` (the API response), `doi`, `uploaded` (logical),
and `x`.

## Examples

``` r
if (FALSE) { # \dontrun{
# Not executable without a Figshare (sandbox) account and access token, so
# this example cannot be run during a check.
krt_deposit_figshare(krt_example)
} # }
```
