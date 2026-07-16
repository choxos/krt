# List available profiles

List available profiles

## Usage

``` r
krt_profiles()
```

## Value

A data frame with one row per registered profile (name, title, license,
whether it is officially endorsed).

## Examples

``` r
krt_profiles()
#>           name                                              title      license
#> 1         asap                   ASAP Key Resources Table profile    CC-BY-4.0
#> 2      generic                               Generic FAIR profile GPL-3.0-only
#> 3 star-methods STAR Methods (Cell Press) interoperability profile GPL-3.0-only
#>   official
#> 1    FALSE
#> 2    FALSE
#> 3    FALSE
```
