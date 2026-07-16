# Audit the licenses of the package and its bundled assets

Audit the licenses of the package and its bundled assets

## Usage

``` r
krt_audit_licenses()
```

## Value

A data frame with one row per licensable component (the package code,
each profile, the bundled reference data and license text), giving its
source, license, DOI, whether it is redistributable, and notes.

## Examples

``` r
krt_audit_licenses()
#>                                   component                              source
#> 1                       krt (R source code)                        this package
#> 2 internal reference tables (R/sysdata.rda)                    public standards
#> 3                             profile: asap Aligning Science Across Parkinson's
#> 4                          profile: generic                        this package
#> 5                     profile: star-methods                        this package
#> 6               inst/licenses/CC-BY-4.0.txt                   SPDX License List
#>        license                     doi redistributable
#> 1 GPL-3.0-only                    <NA>            TRUE
#> 2 GPL-3.0-only                    <NA>            TRUE
#> 3    CC-BY-4.0 10.5281/zenodo.17917979            TRUE
#> 4 GPL-3.0-only                    <NA>            TRUE
#> 5 GPL-3.0-only                    <NA>            TRUE
#> 6    CC-BY-4.0                    <NA>            TRUE
#>                                                            notes
#> 1                            Package code and validation engine.
#> 2 KRT vocabularies, RRID prefixes, identifier syntax, endpoints.
#> 3                                       Not officially endorsed.
#> 4                                       Not officially endorsed.
#> 5                                       Not officially endorsed.
#> 6              License text for the ASAP-derived profile assets.
```
