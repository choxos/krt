# Export citable resources as RIS or BibTeX

Only resources that are citable scholarly objects (datasets, software,
protocols, or anything with a DOI) are emitted. This format cannot
encode the full biological or ethics semantics of a KRT; use it for
reference managers, not as an archival copy.

## Usage

``` r
export_citation(
  x,
  path = NULL,
  format = c("ris", "bibtex"),
  audience = c("author", "public"),
  redact = NULL
)
```

## Arguments

- x:

  A [krt_tbl](https://choxos.github.io/krt/reference/new_krt.md).

- path:

  Output path, or `NULL` to return the text.

- format:

  `"ris"` or `"bibtex"`.

- audience:

  `"author"` (full) or `"public"` (redacted).

- redact:

  Redaction strength (`"basic"`/`"strict"`) for public output, or
  `FALSE` to disable; `NULL` uses the profile default.

## Value

The path (invisibly) when written, or the citation text.

## Examples

``` r
cat(export_citation(krt_example, format = "bibtex"))
#> Warning: lossy-export: 17 field(s) are not preserved as columns in 'bibtex': vendor, source_name, catalog_number, rrid, antibody_host, antibody_clonality, target, new_or_reuse, notes, cellosaurus_id.
#> @misc{res-51c17ebad6,
#>   title = {Fiji},
#>   url = {https://imagej.net/software/fiji/},
#> }
#> 
#> @misc{res-17e9da800e,
#>   title = {Processed RNA-seq counts},
#>   doi = {10.5281/zenodo.11111111},
#> }
#> 
#> @misc{res-fc42d10d25,
#>   title = {Immunohistochemistry protocol},
#>   doi = {10.17504/protocols.io.abcde123},
#> }
```
