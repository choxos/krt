# Normalize identifiers to canonical forms

Canonicalizes the identifier fields of a table, a resource, or a bare
character vector: strips resolver prefixes from DOIs, hyphenates ORCIDs,
ensures the `RRID:` prefix, and so on. Applied consistently, this
prevents the same identifier from appearing in several syntactic forms.

## Usage

``` r
normalize_ids(x, ...)
```

## Arguments

- x:

  A [krt_tbl](https://choxos.github.io/krt/reference/new_krt.md), a
  `krt_resource`, or a character vector of identifiers.

- ...:

  Ignored.

## Value

An object of the same type as `x`, with identifiers normalized.

## Examples

``` r
normalize_ids("https://doi.org/10.1038/SDATA.2016.18")
#> [1] "10.1038/SDATA.2016.18"
r <- new_resource("Software/code", "Fiji", rrid = "SCR_002285",
                  new_or_reuse = "reuse")
normalize_ids(r)$rrid
#> [1] "RRID:SCR_002285"
```
