# Pre-flight release readiness check for a Key Resources Table

Runs the checks that together decide whether a table is ready to share
or deposit, and returns a single machine-readable verdict plus a
human-readable checklist: profile validation (no errors), lossless JSON
round-trip, a working public (redacted) export that leaks none of the
policy's dropped fields, attribution availability, and whether the
profile projection would drop fields.

## Usage

``` r
krt_preflight(x, profile = NULL)
```

## Arguments

- x:

  A [krt_tbl](https://choxos.github.io/krt/reference/new_krt.md).

- profile:

  Profile to check against (defaults to the table's profile).

## Value

A `krt_preflight` object: a list with `profile`, `ok` (TRUE when no
check fails), and `checks` (a data frame of `check`, `status`,
`detail`), with [`print()`](https://rdrr.io/r/base/print.html),
[`format()`](https://rdrr.io/r/base/format.html), and
[`as.data.frame()`](https://rdrr.io/r/base/as.data.frame.html) methods.

## Examples

``` r
pf <- krt_preflight(krt_example)
pf$ok
#> [1] TRUE
```
