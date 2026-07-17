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
#>  [1] "resource_id"           "antibody_host"         "antibody_clonality"   
#>  [4] "target"                "notes"                 "cellosaurus_id"       
#>  [7] "authentication_method" "authentication_date"   "mycoplasma_status"    
#> [10] "organism"              "taxon_id"              "version"              
#> [13] "language"              "strain"               
```
