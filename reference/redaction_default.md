# Default redaction strength for a profile's public exports

Default redaction strength for a profile's public exports

## Usage

``` r
redaction_default(profile = NULL)
```

## Arguments

- profile:

  A profile name or `krt_profile`. A profile may declare a
  `redaction_default` in its `schema.yml`; otherwise the strength is
  `"basic"`.

## Value

`"basic"` or `"strict"`.

## Examples

``` r
redaction_default("asap")
#> [1] "basic"
```
