# Load a profile from a directory

Reads `schema.yml`, `mappings.yml`, and (optionally) `validation.yml`,
`provenance.json`, and `ATTRIBUTION.md` from a profile directory.

## Usage

``` r
load_profile(path)

is_profile(x)
```

## Arguments

- path:

  Path to the profile directory.

- x:

  An object to test.

## Value

A `krt_profile` object.

## Examples

``` r
p <- load_profile(system.file("extdata", "profiles", "asap", package = "krt"))
p$columns
#> [1] "RESOURCE TYPE"          "RESOURCE NAME"          "SOURCE"                
#> [4] "IDENTIFIER"             "NEW/REUSE"              "ADDITIONAL INFORMATION"
```
