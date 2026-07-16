# List registered validation rules

List registered validation rules

## Usage

``` r
list_validators()
```

## Value

A data frame of registered rules (id, layer, default severity,
standard).

## Examples

``` r
head(list_validators())
#>                                                 rule_id    layer severity
#> cond-arrive                                 cond-arrive semantic  warning
#> cond-cellline                             cond-cellline semantic  warning
#> cond-ethics                                 cond-ethics semantic  warning
#> cond-software                             cond-software semantic  warning
#> sem-catalog-in-rrid                 sem-catalog-in-rrid semantic  warning
#> sem-cellosaurus-consistency sem-cellosaurus-consistency semantic  warning
#>                                        standard
#> cond-arrive                 ARRIVE-2.0 (subset)
#> cond-cellline                             ICLAC
#> cond-ethics                              ethics
#> cond-software                              <NA>
#> sem-catalog-in-rrid                        <NA>
#> sem-cellosaurus-consistency                <NA>
```
