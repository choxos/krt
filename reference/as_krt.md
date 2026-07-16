# Coerce to and from the S4 `KRT` class

These are inverse coercions named after their target class. `as_krt()`
returns the S3
[krt_tbl](https://choxos.github.io/krt/reference/new_krt.md) (the
package's primary object): pass it a `krt_tbl` and it is returned
unchanged, or an S4 `KRT` and it is converted down. It is the helper to
call when a function should accept either representation. `as_KRT()` is
the opposite direction, a thin idempotent wrapper over
`methods::as(x, "KRT")` for Bioconductor workflows.

## Usage

``` r
as_krt(x)

as_KRT(x)
```

## Arguments

- x:

  A [krt_tbl](https://choxos.github.io/krt/reference/new_krt.md) or
  `KRT` object.

## Value

`as_krt()` returns a `krt_tbl`; `as_KRT()` returns an S4 `KRT`.

## Examples

``` r
k4 <- as_KRT(krt_example)
identical(length(as_krt(k4)$resources), length(krt_example$resources))
#> [1] TRUE
```
