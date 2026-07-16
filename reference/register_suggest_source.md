# Register an autocomplete source

Register an autocomplete source

## Usage

``` r
register_suggest_source(name, fn)
```

## Arguments

- name:

  Source name (e.g. `"taxonomy"`, `"ror"`).

- fn:

  A function `function(query, n)` returning a data frame with columns
  `label`, `id`, `authority`, `score`, `uri`.

## Value

Invisibly `NULL`.

## Examples

``` r
"ror" %in% list_suggest_sources()
#> [1] TRUE
```
