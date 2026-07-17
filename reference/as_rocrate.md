# Export a KRT as an RO-Crate 1.1 metadata document

Describes the table as an RO-Crate Dataset whose parts are its
resources, each carrying its name, type, and identifiers.

## Usage

``` r
as_rocrate(x, path = NULL, audience = c("author", "public"))
```

## Arguments

- x:

  A [krt_tbl](https://choxos.github.io/krt/reference/new_krt.md).

- path:

  Output path, or `NULL` to return the JSON-LD string.

- audience:

  `"author"` (default) or `"public"` (redacts the table first).

## Value

The JSON-LD string, or the path (invisibly).

## Examples

``` r
cat(substr(as_rocrate(krt_example), 1, 40))
#> {
#>   "@context": "https://w3id.org/ro/cra
```
