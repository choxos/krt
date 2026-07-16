# Describe a profile

Describe a profile

## Usage

``` r
krt_profile_info(name)
```

## Arguments

- name:

  A profile name or a `krt_profile`.

## Value

The `krt_profile` (invisibly); prints a human-readable summary including
its license and redistribution status.

## Examples

``` r
krt_profile_info("asap")
#> <krt_profile> asap (v8)
#>   ASAP Key Resources Table profile
#>   license: CC-BY-4.0 | redistributable assets: yes | officially endorsed: no
#>   columns: RESOURCE TYPE, RESOURCE NAME, SOURCE, IDENTIFIER, NEW/REUSE, ADDITIONAL INFORMATION
#>   source: Aligning Science Across Parkinson's (doi:10.5281/zenodo.17917979)
```
