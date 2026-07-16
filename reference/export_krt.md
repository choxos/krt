# Export a Key Resources Table

Writes a table in a chosen format. `"json"` and `"yaml"` are lossless;
`"csv"`, `"tsv"`, `"xlsx"`, `"asap"`, `"ris"`, and `"bibtex"` are lossy
views and raise a `lossy-export` warning listing fields that are not
preserved as columns. When `audience = "public"`, sensitive ethics
fields are redacted by default.

## Usage

``` r
export_krt(
  x,
  path = NULL,
  format = c("json", "yaml", "csv", "tsv", "xlsx", "asap", "ris", "bibtex"),
  profile = NULL,
  audience = c("author", "public"),
  redact = NULL,
  attribution = TRUE,
  template = NULL,
  view = NULL
)

krt_write(
  x,
  path = NULL,
  format = c("json", "yaml", "csv", "tsv", "xlsx", "asap", "ris", "bibtex"),
  profile = NULL,
  audience = c("author", "public"),
  redact = NULL,
  attribution = TRUE,
  template = NULL,
  view = NULL
)
```

## Arguments

- x:

  A [krt_tbl](https://choxos.github.io/krt/reference/new_krt.md).

- path:

  Output file path, or `NULL` to return the content as a string.

- format:

  Output format; inferred from `path` when possible.

- profile:

  Profile whose columns tabular exports use (default the table's
  profile).

- audience:

  `"author"` (full) or `"public"` (redacted).

- redact:

  Redaction strength (`"basic"`/`"strict"`) for public exports, or
  `FALSE` to disable (with a warning).

- attribution:

  If `TRUE` (default) and the profile carries an attribution
  requirement, write an attribution sidecar next to `path`.

- template:

  Optional template path for ASAP/xlsx export.

- view:

  Optional explicit view for tabular formats.

## Value

The path (invisibly) when written, otherwise the content string.

## Examples

``` r
export_krt(krt_example, format = "json") |> substr(1, 30)
#> [1] "{\n  \"schema_version\": \"1.0.0\","
suppressWarnings(export_krt(krt_example, format = "asap")) |> substr(1, 40)
#> [1] "\"RESOURCE TYPE\",\"RESOURCE NAME\",\"SOURCE\""
```
