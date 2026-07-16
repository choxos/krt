# Write a KRT to canonical YAML

Write a KRT to canonical YAML

## Usage

``` r
write_krt_yaml(x, path = NULL)
```

## Arguments

- x:

  A [krt_tbl](https://choxos.github.io/krt/reference/new_krt.md).

- path:

  Output file path, or `NULL` to return the YAML as a string.

## Value

The YAML string (invisibly, the path when written to a file).

## Examples

``` r
cat(substr(write_krt_yaml(krt_example), 1, 40))
#> schema_version: 1.0.0
#> profile: generic
#> t
```
