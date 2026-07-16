# Validate a Key Resources Table

Runs the registered validation rules over a table and returns a
[krt_validation_report](https://choxos.github.io/krt/reference/krt_validation_report.md).
Structural rules check schema conformance offline; semantic rules check
cross-field consistency and, when `resolve = TRUE`, identifier
existence. Conditional packs (ICLAC cell-line, ARRIVE 2.0 animal,
ethics/consent) apply only when the relevant resource types are present.

## Usage

``` r
validate_krt(
  x,
  profile = NULL,
  layers = c("structural", "semantic"),
  resolve = FALSE,
  severity = NULL,
  attach = FALSE
)
```

## Arguments

- x:

  A [krt_tbl](https://choxos.github.io/krt/reference/new_krt.md).

- profile:

  Profile whose severity overrides apply (default the table's profile).

- layers:

  Which layers to run: `"structural"`, `"semantic"`, or both.

- resolve:

  If `TRUE`, semantic rules may perform online existence checks (off by
  default; never on CRAN).

- severity:

  Optional named list mapping `rule_id` to a severity (or `"off"`),
  overriding rule and profile defaults.

- attach:

  If `TRUE`, return the table with the findings stored in its
  `validation` slot instead of returning the report.

## Value

A `krt_validation_report`, or the `krt_tbl` when `attach = TRUE`.

## Details

Each finding's severity is resolved from the rule default, then any
profile override, then any per-rule value in `severity`. A severity of
`"off"` disables the rule.

## Examples

``` r
validate_krt(krt_example)
#> <krt_validation_report> profile: generic | VALID | 0 findings
#>   errors: 0  warnings: 0  notes: 0  info: 0
validate_krt(krt_example, layers = "structural")
#> <krt_validation_report> profile: generic | VALID | 0 findings
#>   errors: 0  warnings: 0  notes: 0  info: 0
```
