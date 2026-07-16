# Parse and classify an identifier string

Detects the scheme of a single identifier token (DOI, ORCID, ROR, RRID,
PMID, PMCID, URL, or a database accession) using the bundled syntax
patterns.

## Usage

``` r
id_parse(idstring)
```

## Arguments

- idstring:

  A single identifier token.

## Value

A list with `scheme` (character, or `NA` if unrecognized), `value` (the
cleaned identifier), and `field` (the resource field the value belongs
in, e.g. `"doi"`, `"rrid"`, `"accession"`).

## Examples

``` r
id_parse("https://doi.org/10.5281/zenodo.123")
#> $scheme
#> [1] "doi"
#> 
#> $value
#> [1] "10.5281/zenodo.123"
#> 
#> $field
#> [1] "doi"
#> 
id_parse("RRID:AB_390204")
#> $scheme
#> [1] "rrid"
#> 
#> $value
#> [1] "RRID:AB_390204"
#> 
#> $field
#> [1] "rrid"
#> 
id_parse("GSE12345")
#> $scheme
#> [1] "geo_series"
#> 
#> $value
#> [1] "GSE12345"
#> 
#> $field
#> [1] "accession"
#> 
```
