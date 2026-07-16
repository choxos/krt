# Resolve any identifier by detecting its scheme

Resolve any identifier by detecting its scheme

## Usage

``` r
resolve_id(id, resolve = TRUE, ...)
```

## Arguments

- id:

  An identifier string.

- resolve:

  Whether to contact the registry.

- ...:

  Passed to the scheme-specific resolver.

## Value

A resolver result list, or `NULL` if the scheme is unsupported.

## Examples

``` r
resolve_id("RRID:AB_390204", resolve = FALSE)$normalized
#> [1] "RRID:AB_390204"
```
