# Read a KRT from canonical YAML

Read a KRT from canonical YAML

## Usage

``` r
read_krt_yaml(input)
```

## Arguments

- input:

  A file path or a YAML string.

## Value

A [krt_tbl](https://choxos.github.io/krt/reference/new_krt.md).

## Examples

``` r
k <- read_krt_yaml(write_krt_yaml(krt_example))
identical(length(k$resources), length(krt_example$resources))
#> [1] TRUE
```
