# Map one resource to a profile's columns

Map one resource to a profile's columns

## Usage

``` r
apply_mapping(resource, profile)
```

## Arguments

- resource:

  A `krt_resource`.

- profile:

  A `krt_profile` or profile name.

## Value

A named list of column values.

## Examples

``` r
r <- new_resource("Antibody", "Anti-TH", vendor = "Millipore",
                  catalog_number = "AB152", rrid = "RRID:AB_390204",
                  new_or_reuse = "reuse")
apply_mapping(r, "asap")[["IDENTIFIER"]]
#> [1] "Cat# AB152; RRID:AB_390204"
```
