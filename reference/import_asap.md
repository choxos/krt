# Import an ASAP or Cell Press Key Resources Table

Import an ASAP or Cell Press Key Resources Table

## Usage

``` r
import_asap(path, sheet = 1, title = NULL)
```

## Arguments

- path:

  A file path (csv/tsv/xlsx) or a data frame already read in.

- sheet:

  Worksheet (for xlsx).

- title:

  Optional title for the resulting table.

## Value

A [krt_tbl](https://choxos.github.io/krt/reference/new_krt.md) with
profile `"asap"`.

## Examples

``` r
f <- tempfile(fileext = ".csv")
writeLines(export_asap(krt_example), f)
k <- import_asap(f)
length(k$resources)
#> [1] 6
```
