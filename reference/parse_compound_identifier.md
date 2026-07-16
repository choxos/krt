# Parse a compound identifier string into typed fields

Splits an ASAP-style `IDENTIFIER` value (parts joined by `;` or
newlines) and classifies each part into a resource field.

## Usage

``` r
parse_compound_identifier(str)
```

## Arguments

- str:

  A compound identifier string.

## Value

A named list of fields (e.g. `catalog_number`, `rrid`, `doi`,
`accession`, `url`), plus `other` for unclassified parts.

## Examples

``` r
parse_compound_identifier("Cat# AB152; RRID:AB_390204")
#> $catalog_number
#> [1] "AB152"
#> 
#> $rrid
#> [1] "RRID:AB_390204"
#> 
```
