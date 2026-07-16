# Access a KRT controlled vocabulary

Access a KRT controlled vocabulary

## Usage

``` r
krt_vocab(key)
```

## Arguments

- key:

  Vocabulary name (e.g. "resource_type", "new_or_reuse", "status").

## Value

A character vector of allowed values.

## Examples

``` r
krt_vocab("new_or_reuse")
#> [1] "new"   "reuse"
```
