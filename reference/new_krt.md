# Create a Key Resources Table

Constructs an empty (or pre-populated) `krt_tbl`: the neutral, typed
core object of the package. Resources, approvals, and contributors are
stored as present-only records; the rectangular table an author sees is
a *view* produced on demand by
[as.data.frame()](https://choxos.github.io/krt/reference/as.data.frame.krt_tbl.md).

## Usage

``` r
new_krt(
  title = NULL,
  profile = "generic",
  study_type = NULL,
  locale = NULL,
  resources = list(),
  approvals = list(),
  contributors = list()
)

krt_new(
  title = NULL,
  profile = "generic",
  study_type = NULL,
  locale = NULL,
  resources = list(),
  approvals = list(),
  contributors = list()
)

is_krt(x)
```

## Arguments

- title:

  A short table or study title.

- profile:

  Output profile name (default `"generic"`); see
  [`krt_profiles()`](https://choxos.github.io/krt/reference/krt_profiles.md).

- study_type:

  Optional character vector describing the study (e.g.
  `c("wet-lab", "computational")`).

- locale:

  Optional locale string (e.g. `"en-US"`).

- resources, approvals, contributors:

  Optional lists of records to seed the table with.

- x:

  An object to test.

## Value

An object of class `krt_tbl`.

## Examples

``` r
k <- new_krt("Example study", study_type = "wet-lab")
k <- add_resource(k, "Antibody", "Rabbit Anti-TH", vendor = "Millipore",
                  catalog_number = "AB152", rrid = "RRID:AB_390204",
                  new_or_reuse = "reuse")
k
#> <krt_tbl> Example study
#>   profile: generic | schema: 1.0.0 | resources: 1
#>     Antibody                                   1 (new 0, reuse 1)
```
