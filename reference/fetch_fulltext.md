# Fetch manuscript full text

Retrieves full text (JATS XML where available) from Europe PMC or
bioRxiv, for feeding into
[`extract_krt()`](https://choxos.github.io/krt/reference/extract_krt.md).
Returns `NULL` offline or when the text is not openly available.

## Usage

``` r
fetch_fulltext(id, source = c("auto", "europepmc", "biorxiv"), timeout = 30)
```

## Arguments

- id:

  A PMCID, DOI, or bioRxiv DOI.

- source:

  `"auto"`, `"europepmc"`, or `"biorxiv"`.

- timeout:

  Request timeout in seconds.

## Value

A character string of the full text or abstract, or `NULL`.

## Examples

``` r
# \donttest{
# Contacts Europe PMC. Offline, or when the text is not openly available,
# this returns NULL rather than failing.
txt <- fetch_fulltext("PMC5334499")
is.null(txt) || nchar(txt) > 0
#> [1] TRUE
# }
```
