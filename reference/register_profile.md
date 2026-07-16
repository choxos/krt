# Register an output profile

Register an output profile

## Usage

``` r
register_profile(name = NULL, path = NULL, profile = NULL)
```

## Arguments

- name:

  Profile name. If omitted, taken from the profile's `schema.yml` or the
  supplied object.

- path:

  Path to a profile directory containing `schema.yml` and `mappings.yml`
  (loaded lazily), or `NULL`.

- profile:

  A pre-built `krt_profile` object, or `NULL`.

## Value

Invisibly the profile name.

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
