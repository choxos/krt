# Diff two Key Resources Tables

Compares resources by identity signature and reports which were added,
removed, or changed (with field-level deltas).

## Usage

``` r
krt_diff(x, y)
```

## Arguments

- x, y:

  Two [krt_tbl](https://choxos.github.io/krt/reference/new_krt.md)
  objects (`x` is the baseline).

## Value

A `krt_diff` object with [`print()`](https://rdrr.io/r/base/print.html)
and [`as.data.frame()`](https://rdrr.io/r/base/as.data.frame.html)
methods.

## Examples

``` r
a <- add_resource(new_krt("A"), "Dataset", "D", doi = "10.5281/zenodo.1",
                  new_or_reuse = "new")
b <- update_resource(a, a$resources[[1]]$resource_id, notes = "added")
as.data.frame(krt_diff(a, b))
#>    change    resource_id field from    to
#> 1 changed res-2e5c9a1666 notes      added
```
