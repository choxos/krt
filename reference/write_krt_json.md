# Write a KRT to canonical JSON

Write a KRT to canonical JSON

## Usage

``` r
write_krt_json(x, path = NULL, pretty = TRUE)
```

## Arguments

- x:

  A [krt_tbl](https://choxos.github.io/krt/reference/new_krt.md).

- path:

  Output file path, or `NULL` to return the JSON as a string.

- pretty:

  Whether to pretty-print (default `TRUE`).

## Value

The JSON string (invisibly, the path when written to a file).

## Examples

``` r
json <- write_krt_json(krt_example)
substr(json, 1, 40)
#> [1] "{\n  \"schema_version\": \"1.0.0\",\n  \"profil"
```
