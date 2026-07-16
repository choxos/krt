# Coerce a KRT to a data frame (a rectangular view)

Produces a rectangular *view* of the table by filling the union of
present fields with `NA`. Many-valued fields are collapsed with `"; "`
in this view; the lossless representation is the JSON/YAML export.

## Usage

``` r
# S3 method for class 'krt_tbl'
as.data.frame(x, row.names = NULL, optional = FALSE, ..., view = "wide")
```

## Arguments

- x:

  A [krt_tbl](https://choxos.github.io/krt/reference/new_krt.md).

- row.names, optional:

  Present for consistency with the
  [`as.data.frame()`](https://rdrr.io/r/base/as.data.frame.html)
  generic; not used.

- ...:

  Ignored.

- view:

  The view to produce: `"wide"` (the full union of core fields) or a
  profile name such as `"asap"` (a profile projection). Must be named.

## Value

A data frame with one row per resource.

## Examples

``` r
k <- add_resource(new_krt("Demo"), "Dataset", "RNA-seq",
                  new_or_reuse = "new", doi = "10.5281/zenodo.123")
as.data.frame(k)
#>      resource_id resource_type display_name                doi new_or_reuse
#> 1 res-cbc950c8f4       Dataset      RNA-seq 10.5281/zenodo.123          new
as.data.frame(krt_example, view = "asap")
#>                         RESOURCE TYPE                 RESOURCE NAME
#> 1                            Antibody                Rabbit Anti-TH
#> 2       Experimental model: Cell line                       HEK293T
#> 3                       Software/code                          Fiji
#> 4                             Dataset      Processed RNA-seq counts
#> 5 Experimental model: Organism/strain                 C57BL/6J mice
#> 6                            Protocol Immunohistochemistry protocol
#>                   SOURCE                                         IDENTIFIER
#> 1              Millipore                         Cat# AB152; RRID:AB_390204
#> 2                   ATCC                      Cat# CRL-3216; RRID:CVCL_0063
#> 3                    NIH RRID:SCR_002285; https://imagej.net/software/fiji/
#> 4                 Zenodo            https://doi.org/10.5281/zenodo.11111111
#> 5 The Jackson Laboratory                               RRID:IMSR_JAX:000664
#> 6           protocols.io     https://doi.org/10.17504/protocols.io.abcde123
#>   NEW/REUSE
#> 1     reuse
#> 2     reuse
#> 3     reuse
#> 4       new
#> 5     reuse
#> 6       new
#>                                                                                                                                        ADDITIONAL INFORMATION
#> 1                                                         Antibody host: Rabbit; Antibody clonality: polyclonal; Target: Tyrosine hydroxylase; Dilution 1:500
#> 2 Organism: Homo sapiens; Taxon id: 9606; Cellosaurus id: CVCL_0063; Authentication method: STR; Authentication date: 2026-01-20; Mycoplasma status: negative
#> 3                                                                                                                             Version: 2.14.0; Language: Java
#> 4                                                                                                                          Tabular data underlying Figure 2A.
#> 5                                                                                                   Organism: Mus musculus; Taxon id: 10090; Strain: C57BL/6J
#> 6                                                                                                                                                            
```
