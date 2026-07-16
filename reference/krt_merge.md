# Merge Key Resources Tables

Combines resources from two or more tables, matching by normalized
identity signature. Matching resources are merged field by field; the
`strategy` resolves field-level conflicts. Conflicts are attached to the
result as the `"merge_conflicts"` attribute.

## Usage

``` r
krt_merge(
  x,
  y,
  ...,
  strategy = c("union", "prefer_x", "prefer_y", "manual"),
  by = resource_signature
)
```

## Arguments

- x, y, ...:

  Tables to merge (`x` supplies the result's metadata).

- strategy:

  `"union"`/`"prefer_x"` (x wins conflicts), `"prefer_y"` (later table
  wins), or `"manual"` (x wins but every conflict is recorded).

- by:

  A function computing a resource's match key (default
  [`resource_signature()`](https://choxos.github.io/krt/reference/resource_signature.md)).

## Value

The merged [krt_tbl](https://choxos.github.io/krt/reference/new_krt.md).

## Examples

``` r
a <- add_resource(new_krt("A"), "Antibody", "Anti-TH", vendor = "Millipore",
                  catalog_number = "AB152", new_or_reuse = "reuse")
b <- add_resource(new_krt("B"), "Dataset", "D", doi = "10.5281/zenodo.1",
                  new_or_reuse = "new")
krt_merge(a, b)
#> <krt_tbl> A
#>   profile: generic | schema: 1.0.0 | resources: 2
#>     Antibody                                   1 (new 0, reuse 1)
#>     Dataset                                    1 (new 1, reuse 0)
```
