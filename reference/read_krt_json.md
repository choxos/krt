# Read a KRT from canonical JSON

Read a KRT from canonical JSON

## Usage

``` r
read_krt_json(input)
```

## Arguments

- input:

  A file path or a JSON string.

## Value

A [krt_tbl](https://choxos.github.io/krt/reference/new_krt.md).

## Examples

``` r
k <- read_krt_json(write_krt_json(krt_example))
identical(length(k$resources), length(krt_example$resources))
#> [1] TRUE
```
