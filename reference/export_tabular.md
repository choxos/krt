# Export a KRT as a delimited table or spreadsheet

Export a KRT as a delimited table or spreadsheet

## Usage

``` r
export_tabular(
  x,
  path = NULL,
  format = c("csv", "tsv", "xlsx"),
  profile = NULL,
  view = NULL,
  audience = c("author", "public"),
  redact = NULL
)
```

## Arguments

- x:

  A [krt_tbl](https://choxos.github.io/krt/reference/new_krt.md).

- path:

  Output path, or `NULL` to return the content (csv/tsv only).

- format:

  `"csv"`, `"tsv"`, or `"xlsx"`.

- profile:

  Profile whose columns to use (default the wide core view).

- view:

  Optional explicit view name.

- audience:

  `"author"` (full) or `"public"` (redacted).

- redact:

  Redaction strength for public output, or `FALSE` to disable.

## Value

The path (invisibly) when written, or the delimited text.

## Examples

``` r
cat(substr(export_tabular(krt_example, format = "csv"), 1, 60))
#> "resource_id","resource_type","display_name","source_name","
```
