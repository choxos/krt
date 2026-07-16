# Write attribution to a file

Write attribution to a file

## Usage

``` r
krt_write_attribution(x, path)
```

## Arguments

- x:

  A [krt_tbl](https://choxos.github.io/krt/reference/new_krt.md) or
  profile name.

- path:

  Output file path.

## Value

The path, invisibly.

## Examples

``` r
f <- tempfile(fileext = ".md")
krt_write_attribution(krt_example, f)
```
