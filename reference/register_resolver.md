# Register an identifier resolver

Register an identifier resolver

## Usage

``` r
register_resolver(scheme, fn)
```

## Arguments

- scheme:

  The identifier scheme (e.g. `"rrid"`, `"doi"`, `"orcid"`).

- fn:

  A function `function(id, resolve = TRUE, ...)` returning a normalized
  result list with at least `input`, `normalized`, and `resolved`.

## Value

Invisibly `NULL`.

## Examples

``` r
"rrid" %in% list_resolvers()
#> [1] TRUE
```
