# Extract candidate resources from text (regex engine)

Extract candidate resources from text (regex engine)

## Usage

``` r
extract_candidates(text)
```

## Arguments

- text:

  A character vector of manuscript text.

## Value

A list of `krt_resource` candidates.

## Examples

``` r
cand <- extract_candidates("Anti-TH (RRID:AB_390204); FIJI (RRID:SCR_002285)")
length(cand)
#> [1] 2
```
