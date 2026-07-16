# Retrieve a registered profile

Retrieve a registered profile

## Usage

``` r
get_profile(name)
```

## Arguments

- name:

  Profile name.

## Value

A `krt_profile` object.

## Examples

``` r
get_profile("asap")$columns
#> [1] "RESOURCE TYPE"          "RESOURCE NAME"          "SOURCE"                
#> [4] "IDENTIFIER"             "NEW/REUSE"              "ADDITIONAL INFORMATION"
```
