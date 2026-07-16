# Register a validation rule

Adds a rule to the validation engine. A rule is a function `fn(x, ctx)`
that inspects a
[krt_tbl](https://choxos.github.io/krt/reference/new_krt.md) and returns
a list of issues (each created with the internal issue helper); the
engine attaches the rule id, layer, standard, and resolved severity.

## Usage

``` r
register_validator(
  rule_id,
  fn,
  layer = c("structural", "semantic"),
  severity = c("error", "warning", "note", "info"),
  applies = function(x) TRUE,
  standard = NA_character_
)
```

## Arguments

- rule_id:

  A unique rule identifier, e.g. `"struct-missing-name"`.

- fn:

  The rule function `function(x, ctx)` returning a list of issues.

- layer:

  Either `"structural"` or `"semantic"`.

- severity:

  Default severity: one of `"error"`, `"warning"`, `"note"`, `"info"`.

- applies:

  A predicate `function(x)`; the rule runs only when it returns `TRUE`
  (used by conditional rule packs).

- standard:

  Optional reporting standard the rule enforces (e.g. `"ARRIVE-2.0"`).

## Value

Invisibly `NULL`; called for its side effect.

## Examples

``` r
# A rule flags resources whose display name is very long.
long_name_rule <- function(x, ctx) list()
# register_validator("demo-long-name", long_name_rule, severity = "note")
head(list_validators(), 3)
#>                     rule_id    layer severity            standard
#> cond-arrive     cond-arrive semantic  warning ARRIVE-2.0 (subset)
#> cond-cellline cond-cellline semantic  warning               ICLAC
#> cond-ethics     cond-ethics semantic  warning              ethics
```
