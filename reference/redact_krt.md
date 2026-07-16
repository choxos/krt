# Redact sensitive fields for public sharing

Removes or generalizes fields flagged by the redaction policy, so a
table can be shared publicly without exposing internal ethics or consent
details.

## Usage

``` r
redact_krt(x, level = c("basic", "strict"), policy = NULL)
```

## Arguments

- x:

  A [krt_tbl](https://choxos.github.io/krt/reference/new_krt.md).

- level:

  `"basic"` (default) removes basic-tagged fields; `"strict"` removes
  basic- and strict-tagged fields.

- policy:

  An optional policy data frame overriding
  [`redaction_policy()`](https://choxos.github.io/krt/reference/redaction_policy.md).

## Value

The redacted `krt_tbl`.

## Examples

``` r
k <- add_approval(new_krt("Demo"), "IRB", protocol_number = "IRB-1",
                  consent_scope = "study-specific")
redact_krt(k)$approvals[[1]]$protocol_number
#> NULL
```
