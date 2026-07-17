# ASAP and STAR Methods profiles

``` r

library(krt)
#> krt 0.1.0: author, validate, and export Key Resources Tables.
#>   Start with new_krt(); see https://choxos.github.io/krt/
```

`krt` is a *standards orchestrator*: a neutral core schema plus a
registry of output profiles. Exports are projections of the core, not
the source of truth.

## Available profiles

``` r

krt_profiles()
#>           name                                              title      license
#> 1         asap                   ASAP Key Resources Table profile    CC-BY-4.0
#> 2      generic                               Generic FAIR profile GPL-3.0-only
#> 3 star-methods STAR Methods (Cell Press) interoperability profile GPL-3.0-only
#>   official
#> 1    FALSE
#> 2    FALSE
#> 3    FALSE
```

- `generic`: the full core view (lossless working copy).
- `asap`: the six-column ASAP layout (assets under CC BY 4.0).
- `star-methods`: a three-column STAR Methods-style layout
  (interoperability rules only; no publisher template is bundled).

## Project to the ASAP layout

``` r

project_profile(krt_example, "asap")[, c("RESOURCE TYPE", "IDENTIFIER", "NEW/REUSE")]
#>                         RESOURCE TYPE
#> 1                            Antibody
#> 2       Experimental model: Cell line
#> 3                       Software/code
#> 4                             Dataset
#> 5 Experimental model: Organism/strain
#> 6                            Protocol
#>                                           IDENTIFIER NEW/REUSE
#> 1                         Cat# AB152; RRID:AB_390204     reuse
#> 2                      Cat# CRL-3216; RRID:CVCL_0063     reuse
#> 3 RRID:SCR_002285; https://imagej.net/software/fiji/     reuse
#> 4            https://doi.org/10.5281/zenodo.11111111       new
#> 5                               RRID:IMSR_JAX:000664     reuse
#> 6     https://doi.org/10.17504/protocols.io.abcde123       new
```

The compound `IDENTIFIER` is composed from the typed identifier fields,
and
[`import_asap()`](https://choxos.github.io/krt/reference/import_asap.md)
parses it back into those fields on the way in.

## Lossy fields

Exporting to a profile that folds structured fields into free text is
reported:

``` r

mapping_lossy_fields(krt_example, "asap")
#>  [1] "resource_id"           "antibody_host"         "antibody_clonality"   
#>  [4] "target"                "notes"                 "cellosaurus_id"       
#>  [7] "authentication_method" "authentication_date"   "mycoplasma_status"    
#> [10] "organism"              "taxon_id"              "version"              
#> [13] "language"              "strain"
```

## Licensing and attribution

Profiles expose their licensing programmatically, and the ASAP profile
carries the required CC BY 4.0 attribution.

``` r

krt_profile_info("asap")
#> <krt_profile> asap (v8)
#>   ASAP Key Resources Table profile
#>   license: CC-BY-4.0 | redistributable assets: yes | officially endorsed: no
#>   columns: RESOURCE TYPE, RESOURCE NAME, SOURCE, IDENTIFIER, NEW/REUSE, ADDITIONAL INFORMATION
#>   source: Aligning Science Across Parkinson's (doi:10.5281/zenodo.17917979)
krt_audit_licenses()[, c("component", "license", "redistributable")]
#>                                   component      license redistributable
#> 1                       krt (R source code) GPL-3.0-only            TRUE
#> 2 internal reference tables (R/sysdata.rda) GPL-3.0-only            TRUE
#> 3                             profile: asap    CC-BY-4.0            TRUE
#> 4                          profile: generic GPL-3.0-only            TRUE
#> 5                     profile: star-methods GPL-3.0-only            TRUE
#> 6               inst/licenses/CC-BY-4.0.txt    CC-BY-4.0            TRUE
```

``` r

cat(substr(krt_attribution("asap"), 1, 200))
#> # Attribution
#> 
#> ## Source material
#> 
#> **Title:** ASAP Key Resource Table Guide, FAQ, and Template
#> **Creator:** Aligning Science Across Parkinson's (ASAP)
#> **Source:** DOI [10.5281/zenodo.17917979](https:/
```

This package is independently developed and is **not** an official ASAP
product.

## Round-trip through the ASAP format

``` r

f <- tempfile(fileext = ".csv")
export_asap(krt_example, f)
#> Warning: lossy-export: 14 field(s) are not preserved as columns in 'asap':
#> resource_id, antibody_host, antibody_clonality, target, notes, cellosaurus_id,
#> authentication_method, authentication_date, mycoplasma_status, organism.
k <- import_krt(f)
identical(length(k$resources), length(krt_example$resources))
#> [1] TRUE
```
