# Compose a compound identifier string from a resource's typed fields

Compose a compound identifier string from a resource's typed fields

## Usage

``` r
compose_identifier(resource, order = NULL)
```

## Arguments

- resource:

  A `krt_resource` (or a named list of fields).

- order:

  Optional character vector giving the field order; defaults to a
  sensible canonical order.

## Value

A single `"; "`-joined identifier string.

## Examples

``` r
r <- new_resource("Antibody", "Anti-TH", catalog_number = "AB152",
                  rrid = "RRID:AB_390204", new_or_reuse = "reuse")
compose_identifier(r)
#> [1] "Cat# AB152; RRID:AB_390204"
```
