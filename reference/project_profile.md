# Project a KRT onto a profile as a data frame

Project a KRT onto a profile as a data frame

## Usage

``` r
project_profile(x, profile)
```

## Arguments

- x:

  A [krt_tbl](https://choxos.github.io/krt/reference/new_krt.md).

- profile:

  A `krt_profile` or profile name.

## Value

A data frame with the profile's columns, one row per resource.

## Examples

``` r
project_profile(krt_example, "asap")[, c("RESOURCE TYPE", "IDENTIFIER")]
#>                         RESOURCE TYPE
#> 1                            Antibody
#> 2       Experimental model: Cell line
#> 3                       Software/code
#> 4                             Dataset
#> 5 Experimental model: Organism/strain
#> 6                            Protocol
#>                                           IDENTIFIER
#> 1                         Cat# AB152; RRID:AB_390204
#> 2                      Cat# CRL-3216; RRID:CVCL_0063
#> 3 RRID:SCR_002285; https://imagej.net/software/fiji/
#> 4            https://doi.org/10.5281/zenodo.11111111
#> 5                               RRID:IMSR_JAX:000664
#> 6     https://doi.org/10.17504/protocols.io.abcde123
```
