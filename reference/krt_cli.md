# Run the krt command-line interface

Dispatches a subcommand. Used by the `krt` shell script
(`system.file("scripts", "krt", package = "krt")`); can also be called
directly with a character vector of arguments.

## Usage

``` r
krt_cli(args = commandArgs(trailingOnly = TRUE))
```

## Arguments

- args:

  Command-line arguments (defaults to those passed to `Rscript`).

## Value

Invisibly an integer status code (0 success, 1 validation failure).

## Examples

``` r
krt_cli("audit-licenses")
#>                                   component                              source
#> 1                       krt (R source code)                        this package
#> 2 internal reference tables (R/sysdata.rda)                    public standards
#> 3                             profile: asap Aligning Science Across Parkinson's
#> 4                          profile: generic                        this package
#> 5                     profile: star-methods                        this package
#> 6               inst/licenses/CC-BY-4.0.txt                   SPDX License List
#>        license                     doi redistributable
#> 1 GPL-3.0-only                    <NA>            TRUE
#> 2 GPL-3.0-only                    <NA>            TRUE
#> 3    CC-BY-4.0 10.5281/zenodo.17917979            TRUE
#> 4 GPL-3.0-only                    <NA>            TRUE
#> 5 GPL-3.0-only                    <NA>            TRUE
#> 6    CC-BY-4.0                    <NA>            TRUE
#>                                                            notes
#> 1                            Package code and validation engine.
#> 2 KRT vocabularies, RRID prefixes, identifier syntax, endpoints.
#> 3                                       Not officially endorsed.
#> 4                                       Not officially endorsed.
#> 5                                       Not officially endorsed.
#> 6              License text for the ASAP-derived profile assets.
f <- tempfile(fileext = ".json")
writeLines(write_krt_json(krt_example), f)
krt_cli(c("validate", f))
#> <krt_validation_report> profile: generic | VALID | 0 findings
#>   errors: 0  warnings: 0  notes: 0  info: 0
```
