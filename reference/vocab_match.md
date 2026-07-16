# Match a value against a controlled vocabulary

Match a value against a controlled vocabulary

## Usage

``` r
vocab_match(value, vocab, fuzzy = FALSE)
```

## Arguments

- value:

  A character value to check.

- vocab:

  A character vector of allowed values, or the name of a vocabulary
  (resolved with
  [`krt_vocab()`](https://choxos.github.io/krt/reference/krt_vocab.md)).

- fuzzy:

  If `TRUE`, when there is no exact match return the nearest vocabulary
  term (by edit distance) as a suggestion instead of `NA`.

## Value

A list with `ok` (logical), `value` (the matched canonical term or
`NA`), and `suggestion` (nearest term when `fuzzy` and not matched).

## Examples

``` r
vocab_match("Antibody", "resource_type")
#> $ok
#> [1] TRUE
#> 
#> $value
#> [1] "Antibody"
#> 
#> $suggestion
#> [1] NA
#> 
vocab_match("antibodies", "resource_type", fuzzy = TRUE)
#> $ok
#> [1] FALSE
#> 
#> $value
#> [1] NA
#> 
#> $suggestion
#> [1] "Antibody"
#> 
```
