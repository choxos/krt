# Default redaction strength for a profile's public exports

Default redaction strength for a profile's public exports

## Usage

``` r
redaction_default(profile = NULL)
```

## Arguments

- profile:

  A profile name or `krt_profile`.

## Value

`"basic"` (the default public strip strength).

## Examples

``` r
redaction_default("asap")
#> [1] "basic"
```
