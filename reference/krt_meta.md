# Get or set KRT metadata

Get or set KRT metadata

## Usage

``` r
krt_meta(x)

krt_meta(x) <- value
```

## Arguments

- x:

  A [krt_tbl](https://choxos.github.io/krt/reference/new_krt.md).

- value:

  A named list of metadata fields to set (any of `title`, `profile`,
  `study_type`, `locale`).

## Value

`krt_meta()` returns a named list of the table's metadata.

## Examples

``` r
k <- new_krt("Demo")
krt_meta(k)$title
#> [1] "Demo"
krt_meta(k) <- list(title = "Renamed")
```
