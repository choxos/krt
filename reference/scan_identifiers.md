# Scan free text for research identifiers

Finds RRIDs, DOIs, catalog numbers, database accessions, ORCIDs, and
PMIDs in a block of text and classifies each. Used by the regex
extraction engine and available on its own.

## Usage

``` r
scan_identifiers(text)
```

## Arguments

- text:

  A character vector of text.

## Value

A data frame with columns `value`, `field`, and `type` (an inferred
resource type, or `NA`).

## Examples

``` r
scan_identifiers("We used anti-TH (RRID:AB_390204) and FIJI (RRID:SCR_002285).")
#>        value field          type
#> 1  AB_390204  rrid      Antibody
#> 2 SCR_002285  rrid Software/code
```
