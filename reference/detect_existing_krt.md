# Detect and parse a Key Resources Table embedded in a document

Detect and parse a Key Resources Table embedded in a document

## Usage

``` r
detect_existing_krt(doc)
```

## Arguments

- doc:

  The result of
  [`read_input_text()`](https://choxos.github.io/krt/reference/read_input_text.md).

## Value

A [krt_tbl](https://choxos.github.io/krt/reference/new_krt.md) parsed
from the embedded table, or `NULL` if none is found.

## Examples

``` r
detect_existing_krt(read_input_text("No table here."))
#> NULL
```
