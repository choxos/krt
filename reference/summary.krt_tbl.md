# Summarize a KRT

Summarize a KRT

## Usage

``` r
# S3 method for class 'krt_tbl'
summary(object, ...)
```

## Arguments

- object:

  A [krt_tbl](https://choxos.github.io/krt/reference/new_krt.md).

- ...:

  Ignored.

## Value

A data frame with resource counts per resource type, including the
number of newly generated versus reused resources.

## Examples

``` r
summary(krt_example)
#>                         resource_type n n_new n_reuse
#> 1                            Antibody 1     0       1
#> 2                             Dataset 1     1       0
#> 3       Experimental model: Cell line 1     0       1
#> 4 Experimental model: Organism/strain 1     0       1
#> 5                            Protocol 1     1       0
#> 6                       Software/code 1     0       1
```
