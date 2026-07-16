# Register an autocomplete source

Register an autocomplete source

## Usage

``` r
register_suggest_source(name, fn, replace = FALSE)
```

## Arguments

- name:

  Source name (e.g. `"taxonomy"`, `"ror"`).

- fn:

  A function `function(query, n)` returning a data frame with columns
  `label`, `id`, `authority`, `score`, `uri`.

- replace:

  Overwrite an existing source named `name`? Defaults to `FALSE` so a
  plugin cannot silently replace a built-in source.

## Value

Invisibly `NULL`.

## Examples

``` r
"ror" %in% list_suggest_sources()
#> [1] TRUE
```
