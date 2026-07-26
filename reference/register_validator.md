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
  standard = NA_character_,
  replace = FALSE
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

  Optional reporting standard the rule enforces (e.g.
  `"cell-line-auth-minimum"`).

- replace:

  Overwrite an existing rule with the same `rule_id`? Defaults to
  `FALSE`, so a plugin cannot silently replace a built-in rule; pass
  `TRUE` to deliberately override one.

## Value

Invisibly `NULL`; called for its side effect.

## Examples

``` r
# A rule inspects the table and returns a list of issues. This demonstration
# rule reports nothing, so registering it leaves validation results unchanged.
demo_rule <- function(x, ctx) list()
register_validator("demo-no-op", demo_rule, layer = "semantic",
                   severity = "note", replace = TRUE)
"demo-no-op" %in% list_validators()$rule_id
#> [1] TRUE
validate_krt(krt_example)$valid
#> [1] TRUE
```
