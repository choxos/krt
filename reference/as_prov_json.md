# Export the provenance graph as PROV-JSON

Serializes the table's recorded activities as a W3C PROV-JSON document:
the table is an entity, each recorded step is an activity associated
with the `krt` software agent and generating the table.

## Usage

``` r
as_prov_json(x, path = NULL, audience = c("author", "public"))
```

## Arguments

- x:

  A [krt_tbl](https://choxos.github.io/krt/reference/new_krt.md).

- path:

  Output path, or `NULL` to return the JSON string.

- audience:

  `"author"` (default) keeps provenance parameters; `"public"` redacts
  the table first, so recorded parameters that could echo sensitive
  input values are dropped.

## Value

The JSON string, or the path (invisibly).

## Examples

``` r
cat(substr(as_prov_json(normalize_ids(krt_example)), 1, 40))
#> {
#>   "prefix": {
#>     "krt": "https://chox
```
