# Normalized signature of a resource

Builds a lowercased, trimmed tuple from the identifying fields
`(resource_type, vendor, catalog_number, lot_number, rrid, doi, accession)`.
Two resources with the same signature are considered duplicates.

## Usage

``` r
resource_signature(resource)
```

## Arguments

- resource:

  A `krt_resource` or named list.

## Value

A single signature string.

## Examples

``` r
r <- new_resource("Antibody", "Anti-TH", vendor = "Millipore",
                  catalog_number = "AB152", new_or_reuse = "reuse")
resource_signature(r)
#> [1] "antibodymilliporeab152"
```
