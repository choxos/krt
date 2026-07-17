# Export a KRT as RDF (JSON-LD or Turtle)

Export a KRT as RDF (JSON-LD or Turtle)

## Usage

``` r
as_rdf(
  x,
  format = c("jsonld", "turtle"),
  path = NULL,
  audience = c("author", "public")
)
```

## Arguments

- x:

  A [krt_tbl](https://choxos.github.io/krt/reference/new_krt.md).

- format:

  `"jsonld"` (default) or `"turtle"` (requires the `rdflib` package).

- path:

  Output path, or `NULL` to return the text.

- audience:

  `"author"` (default) or `"public"` (redacts the table first).

## Value

The serialized RDF text, or the path (invisibly).

## Examples

``` r
invisible(as_rdf(krt_example, format = "jsonld"))
```
