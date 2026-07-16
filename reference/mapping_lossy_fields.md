# Fields lost or folded when projecting to a profile

Returns the core fields that are present in the table but are not
preserved as their own column by the profile (they are either folded
into a free-text catch-all column or dropped). These drive the
lossy-export warning.

## Usage

``` r
mapping_lossy_fields(x, profile)
```

## Arguments

- x:

  A [krt_tbl](https://choxos.github.io/krt/reference/new_krt.md).

- profile:

  A `krt_profile` or profile name.

## Value

A character vector of field names (empty for a lossless profile).

## Examples

``` r
mapping_lossy_fields(krt_example, "asap")
#>  [1] "antibody_host"         "antibody_clonality"    "target"               
#>  [4] "notes"                 "cellosaurus_id"        "authentication_method"
#>  [7] "authentication_date"   "mycoplasma_status"     "organism"             
#> [10] "taxon_id"              "version"               "language"             
#> [13] "strain"               
```
