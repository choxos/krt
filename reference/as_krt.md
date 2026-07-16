# Coerce to and from the S4 `KRT` class

Coerce to and from the S4 `KRT` class

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
