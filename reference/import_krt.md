# Import a Key Resources Table from a file or string

Detects the format (JSON, YAML, ASAP/Cell Press table, or generic
tabular) and reads it into a
[krt_tbl](https://choxos.github.io/krt/reference/new_krt.md).

## Usage

``` r
import_krt(input, format = NULL, profile = NULL, mapping = NULL, sheet = 1)
```

## Arguments

- input:

  A file path, or a JSON/YAML string.

- format:

  One of `"json"`, `"yaml"`, `"asap"`, `"tabular"`; auto-detected when
  `NULL`.

- profile:

  Optional profile to assign to the imported table.

- mapping:

  Optional column-to-field mapping for tabular import.

- sheet:

  Worksheet (for xlsx).

## Value

A [krt_tbl](https://choxos.github.io/krt/reference/new_krt.md).

## Examples

``` r
k <- import_krt(write_krt_json(krt_example))
length(k$resources)
#> [1] 6
```
