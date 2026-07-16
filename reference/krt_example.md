# An example Key Resources Table

A small [krt_tbl](https://choxos.github.io/krt/reference/new_krt.md)
spanning several common resource types (antibody, cell line, software,
dataset, organism/strain, and protocol). Used throughout the
documentation and tests so that examples run offline.

## Usage

``` r
krt_example
```

## Format

An object of class `krt_tbl` with six resources.

## Source

Constructed by `data-raw/06-build-example-krt.R`. Identifiers are real,
publicly resolvable examples; the study is fictional.

## Examples

``` r
krt_example
#> <krt_tbl> Example dopaminergic neuron study
#>   profile: generic | schema: 1.0.0 | resources: 6
#>     Antibody                                   1 (new 0, reuse 1)
#>     Dataset                                    1 (new 1, reuse 0)
#>     Experimental model: Cell line              1 (new 0, reuse 1)
#>     Experimental model: Organism/strain        1 (new 0, reuse 1)
#>     Protocol                                   1 (new 1, reuse 0)
#>     Software/code                              1 (new 0, reuse 1)
#>   approvals: 2
#>   contributors: 1
summary(krt_example)
#>                         resource_type n n_new n_reuse
#> 1                            Antibody 1     0       1
#> 2                             Dataset 1     1       0
#> 3       Experimental model: Cell line 1     0       1
#> 4 Experimental model: Organism/strain 1     0       1
#> 5                            Protocol 1     1       0
#> 6                       Software/code 1     0       1
```
