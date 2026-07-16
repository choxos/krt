# Coerce a KRT's resources to a DataFrame (Bioconductor)

Coerce a KRT's resources to a DataFrame (Bioconductor)

## Usage

``` r
krt_as_dataframe(x, view = "wide")
```

## Arguments

- x:

  A [krt_tbl](https://choxos.github.io/krt/reference/new_krt.md).

- view:

  The view to project (default `"wide"`).

## Value

An
[`S4Vectors::DataFrame`](https://rdrr.io/pkg/S4Vectors/man/DataFrame-class.html)
of the resources (requires the `S4Vectors` package).

## Examples

``` r
if (requireNamespace("S4Vectors", quietly = TRUE)) krt_as_dataframe(krt_example)
#> DataFrame with 6 rows and 23 columns
#>      resource_id          resource_type           display_name
#>      <character>            <character>            <character>
#> 1 res-98afe7fc2d               Antibody         Rabbit Anti-TH
#> 2 res-8d057f14a1 Experimental model: ..                HEK293T
#> 3 res-51c17ebad6          Software/code                   Fiji
#> 4 res-17e9da800e                Dataset Processed RNA-seq co..
#> 5 res-31f7bacd67 Experimental model: ..          C57BL/6J mice
#> 6 res-fc42d10d25               Protocol Immunohistochemistry..
#>              source_name      vendor catalog_number                 rrid
#>              <character> <character>    <character>          <character>
#> 1              Millipore   Millipore          AB152       RRID:AB_390204
#> 2                   ATCC        ATCC       CRL-3216       RRID:CVCL_0063
#> 3                    NIH          NA             NA      RRID:SCR_002285
#> 4                 Zenodo          NA             NA                   NA
#> 5 The Jackson Laboratory          NA             NA RRID:IMSR_JAX:000664
#> 6           protocols.io          NA             NA                   NA
#>                      doi                    url     version new_or_reuse
#>              <character>            <character> <character>  <character>
#> 1                     NA                     NA          NA        reuse
#> 2                     NA                     NA          NA        reuse
#> 3                     NA https://imagej.net/s..      2.14.0        reuse
#> 4 10.5281/zenodo.11111..                     NA          NA          new
#> 5                     NA                     NA          NA        reuse
#> 6 10.17504/protocols.i..                     NA          NA          new
#>       organism    taxon_id      strain cellosaurus_id authentication_method
#>    <character> <character> <character>    <character>           <character>
#> 1           NA          NA          NA             NA                    NA
#> 2 Homo sapiens        9606          NA      CVCL_0063                   STR
#> 3           NA          NA          NA             NA                    NA
#> 4           NA          NA          NA             NA                    NA
#> 5 Mus musculus       10090    C57BL/6J             NA                    NA
#> 6           NA          NA          NA             NA                    NA
#>   authentication_date mycoplasma_status antibody_host antibody_clonality
#>           <character>       <character>   <character>        <character>
#> 1                  NA                NA        Rabbit         polyclonal
#> 2          2026-01-20          negative            NA                 NA
#> 3                  NA                NA            NA                 NA
#> 4                  NA                NA            NA                 NA
#> 5                  NA                NA            NA                 NA
#> 6                  NA                NA            NA                 NA
#>                 target    language                  notes
#>            <character> <character>            <character>
#> 1 Tyrosine hydroxylase          NA         Dilution 1:500
#> 2                   NA          NA                     NA
#> 3                   NA        Java                     NA
#> 4                   NA          NA Tabular data underly..
#> 5                   NA          NA                     NA
#> 6                   NA          NA                     NA
```
