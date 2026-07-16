# Getting started with krt

``` r

library(krt)
#> krt 0.1.0: author, validate, and export Key Resources Tables.
#>   Start with new_krt(); see https://choxos.github.io/krt/
```

A **Key Resources Table** (KRT) lists the resources a study used and
generated, each paired with a persistent identifier. `krt` models
resources around a neutral, typed core schema and lets you validate,
enrich, render, and export them.

## Build a table

``` r

k <- new_krt("Dopaminergic neuron study", study_type = "wet-lab")

k <- add_resource(k, "Antibody", "Rabbit Anti-TH",
                  vendor = "Millipore", catalog_number = "AB152",
                  rrid = "RRID:AB_390204", new_or_reuse = "reuse",
                  notes = "Dilution 1:500")

k <- add_resource(k, "Software/code", "Fiji", version = "2.14.0",
                  rrid = "RRID:SCR_002285", new_or_reuse = "reuse")

k <- add_resource(k, "Dataset", "Processed counts",
                  doi = "10.5281/zenodo.11111111", new_or_reuse = "new")
k
#> <krt_tbl> Dopaminergic neuron study
#>   profile: generic | schema: 1.0.0 | resources: 3
#>     Antibody                                   1 (new 0, reuse 1)
#>     Dataset                                    1 (new 1, reuse 0)
#>     Software/code                              1 (new 0, reuse 1)
```

Identifiers are stored in their own typed fields (`catalog_number`,
`rrid`, `doi`, …); they are only combined into a compound string at
export time. The author-facing table is a *view* of the underlying
records:

``` r

as.data.frame(k)[, c("resource_type", "display_name", "rrid", "doi")]
#>   resource_type     display_name            rrid                     doi
#> 1      Antibody   Rabbit Anti-TH  RRID:AB_390204                    <NA>
#> 2 Software/code             Fiji RRID:SCR_002285                    <NA>
#> 3       Dataset Processed counts            <NA> 10.5281/zenodo.11111111
```

## Validate

Validation runs structural and semantic rules, with conditional packs
that fire only for the relevant resource types. Severity depends on the
profile.

``` r

validate_krt(k, profile = "generic")
#> <krt_validation_report> profile: generic | VALID | 0 findings
#>   errors: 0  warnings: 0  notes: 0  info: 0
```

Under the stricter ASAP profile, a missing identifier becomes an error:

``` r

summary(validate_krt(k, profile = "asap"))
#> [1] severity layer    standard n       
#> <0 rows> (or 0-length row.names)
```

## Normalize and export

``` r

k <- normalize_ids(k)

# Lossless canonical formats
cat(substr(write_krt_json(k), 1, 120))
#> {
#>   "schema_version": "1.0.0",
#>   "profile": "generic",
#>   "table_id": "krt-fb987b5438",
#>   "title": "Dopaminergic neuron s
```

Tabular and profile exports are lossy views and warn about it:

``` r

cat(suppressWarnings(export_krt(k, format = "asap")))
#> "RESOURCE TYPE","RESOURCE NAME","SOURCE","IDENTIFIER","NEW/REUSE","ADDITIONAL INFORMATION"
#> "Antibody","Rabbit Anti-TH","Millipore","Cat# AB152; RRID:AB_390204","reuse","Dilution 1:500"
#> "Software/code","Fiji","","RRID:SCR_002285","reuse","Version: 2.14.0"
#> "Dataset","Processed counts","","https://doi.org/10.5281/zenodo.11111111","new",""
```

## Render for a manuscript

``` r

cat(render_krt(k, format = "md", profile = "star-methods"))
#> ## Dopaminergic neuron study
#> 
#> | REAGENT or RESOURCE | SOURCE | IDENTIFIER |
#> | --- | --- | --- |
#> | **Antibody** |  |  |
#> | Rabbit Anti-TH | Millipore | Cat# AB152; RRID:AB_390204 |
#> | **Software/code** |  |  |
#> | Fiji |  | RRID:SCR_002285 |
#> | **Dataset** |  |  |
#> | Processed counts |  | https://doi.org/10.5281/zenodo.11111111 |
```

## Provenance

Every step is recorded:

``` r

as.data.frame(krt_provenance(k))[, c("activity", "software")]
#>        activity  software
#> 1  add_resource krt 0.1.0
#> 2  add_resource krt 0.1.0
#> 3  add_resource krt 0.1.0
#> 4 normalize_ids krt 0.1.0
```
