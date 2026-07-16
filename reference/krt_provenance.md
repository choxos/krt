# Provenance of a KRT

Returns the ordered provenance entries as a `krt_provenance` object (a
list of `krt_prov_entry`, so
[`length()`](https://rdrr.io/r/base/length.html) gives the number of
steps). It has [`print()`](https://rdrr.io/r/base/print.html) and
[`as.data.frame()`](https://rdrr.io/r/base/as.data.frame.html) methods;
serialize the provenance graph with
[`as_prov_json()`](https://choxos.github.io/krt/reference/as_prov_json.md)
and
[`as_rocrate()`](https://choxos.github.io/krt/reference/as_rocrate.md).

## Usage

``` r
krt_provenance(x)
```

## Arguments

- x:

  A [krt_tbl](https://choxos.github.io/krt/reference/new_krt.md).

## Value

A `krt_provenance` object.

## Examples

``` r
krt_provenance(normalize_ids(krt_example))
#> <krt_provenance> 1 step
#>   2026-07-16T15:16:57Z  normalize_ids
```
