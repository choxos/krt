# The `KRT` S4 class

An S4 wrapper around a
[krt_tbl](https://choxos.github.io/krt/reference/new_krt.md), for
interoperability with Bioconductor. Convert with `as(x, "KRT")` and
`as(y, "krt_tbl")`, or
[`as_krt()`](https://choxos.github.io/krt/reference/as_krt.md).

## Slots

- `schema_version,profile,table_id,title`:

  Character metadata.

- `resources,approvals,contributors,provenance`:

  Record lists.

- `metadata`:

  A list of remaining metadata (study type, locale, timestamps).

## Examples

``` r
k4 <- methods::as(krt_example, "KRT")
methods::is(k4, "KRT")
#> [1] TRUE
```
