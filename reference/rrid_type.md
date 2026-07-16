# Resource type implied by an RRID

Resource type implied by an RRID

## Usage

``` r
rrid_type(rrid)
```

## Arguments

- rrid:

  An RRID string (with or without the `RRID:` prefix).

## Value

The implied resource type (character) or `NA` if the authority is
unknown.

## Examples

``` r
rrid_type("RRID:AB_390204")
#> [1] "Antibody"
rrid_type("CVCL_0063")
#> [1] "Experimental model: Cell line"
```
