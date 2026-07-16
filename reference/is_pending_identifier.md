# Is a value the ASAP "identifier pending" placeholder?

Is a value the ASAP "identifier pending" placeholder?

## Usage

``` r
is_pending_identifier(str)
```

## Arguments

- str:

  A candidate identifier string.

## Value

`TRUE` if the string matches the "Identifier from ... pending"
convention.

## Examples

``` r
is_pending_identifier("Identifier from Cellosaurus pending")
#> [1] TRUE
```
