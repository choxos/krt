# Export a KRT in the ASAP six-column format

Projects the table to the ASAP columns and writes it as CSV or into an
xlsx template. If `template` is supplied (or the bundled ASAP template
is used), the data is written into its `KRT` sheet, preserving its
dropdowns and attribution worksheet.

## Usage

``` r
export_asap(
  x,
  path = NULL,
  template = NULL,
  format = NULL,
  audience = c("author", "public"),
  redact = NULL
)
```

## Arguments

- x:

  A [krt_tbl](https://choxos.github.io/krt/reference/new_krt.md).

- path:

  Output path, or `NULL` to return CSV text.

- template:

  Optional xlsx template path. When supplied, output is xlsx.

- format:

  `"csv"` or `"xlsx"`; inferred from `path`/`template`.

- audience:

  `"author"` (full) or `"public"` (redacted).

- redact:

  Redaction strength for public output, or `FALSE` to disable.

## Value

The path (invisibly) when written, or CSV text.

## Examples

``` r
cat(substr(export_asap(krt_example), 1, 60))
#> "RESOURCE TYPE","RESOURCE NAME","SOURCE","IDENTIFIER","NEW/R
```
