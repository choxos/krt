# Import a generic tabular Key Resources Table

Import a generic tabular Key Resources Table

## Usage

``` r
import_tabular(
  path,
  mapping = NULL,
  sheet = 1,
  profile = "generic",
  title = NULL
)
```

## Arguments

- path:

  A file path (csv/tsv/xlsx) or a data frame.

- mapping:

  Optional named list mapping column names to core field names; guessed
  from the headers when `NULL`.

- sheet:

  Worksheet (for xlsx).

- profile:

  Profile to assign to the imported table.

- title:

  Optional title.

## Value

A [krt_tbl](https://choxos.github.io/krt/reference/new_krt.md).

## Examples

``` r
df <- data.frame(type = "Antibody", name = "Anti-TH", rrid = "RRID:AB_1",
                 "new/reuse" = "reuse", check.names = FALSE)
import_tabular(df)$resources[[1]]$resource_type
#> [1] "Antibody"
```
