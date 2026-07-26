# Resolve identifiers against public registries

Each resolver normalizes an identifier and, when `resolve = TRUE` and
the registry is reachable, retrieves a display name and type. All calls
degrade gracefully: offline or on error, `resolved` is `FALSE`.

## Usage

``` r
resolve_rrid(rrid, resolve = TRUE, timeout = 15)

resolve_doi(doi, resolve = TRUE, timeout = 15)

resolve_orcid(orcid, resolve = TRUE, timeout = 15)

resolve_pubmed(pmid, resolve = TRUE, timeout = 15)

resolve_ror(ror, resolve = TRUE, timeout = 15)

resolve_cellosaurus(cvcl, resolve = TRUE, timeout = 15)
```

## Arguments

- rrid, doi, orcid, pmid, ror, cvcl:

  The identifier to resolve.

- resolve:

  Whether to contact the registry (default `TRUE`). Set `FALSE` for a
  purely offline, normalize-only result.

- timeout:

  Request timeout in seconds.

## Value

A list with `input`, `normalized`, `resolved`, `source`, `name`, `type`,
and `url`.

## Examples

``` r
# Offline: normalize only (no network).
resolve_rrid("RRID:AB_390204", resolve = FALSE)
#> $input
#> [1] "RRID:AB_390204"
#> 
#> $normalized
#> [1] "RRID:AB_390204"
#> 
#> $resolved
#> [1] FALSE
#> 
#> $source
#> [1] "scicrunch"
#> 
#> $name
#> [1] NA
#> 
#> $type
#> [1] "Antibody"
#> 
#> $url
#> [1] NA
#> 
resolve_doi("10.1038/sdata.2016.18", resolve = FALSE)$normalized
#> [1] "10.1038/sdata.2016.18"
# \donttest{
# Live lookup. This contacts Crossref; offline it simply returns the
# normalized identifier with `resolved = FALSE` instead of failing.
resolve_doi("10.1038/sdata.2016.18", resolve = TRUE)$resolved
#> [1] TRUE
# }
```
