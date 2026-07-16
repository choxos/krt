# Find duplicate resources in a KRT

Find duplicate resources in a KRT

## Usage

``` r
find_duplicates(x, fuzzy = FALSE)
```

## Arguments

- x:

  A [krt_tbl](https://choxos.github.io/krt/reference/new_krt.md).

- fuzzy:

  If `TRUE`, also report near-duplicates whose display name and vendor
  are close by edit distance.

## Value

A list of duplicate groups; each element is a character vector of
`resource_id`s that share a signature (or are near-duplicates).

## Examples

``` r
k <- new_krt("Demo")
k <- add_resource(k, "Antibody", "Anti-TH", vendor = "Millipore",
                  catalog_number = "AB152", new_or_reuse = "reuse")
k <- add_resource(k, "Antibody", "Anti-TH (dup)", vendor = "Millipore",
                  catalog_number = "AB152", new_or_reuse = "reuse")
find_duplicates(k)
#> [[1]]
#> [1] "res-166085812a" "res-d1c4f0ae35"
#> 
```
