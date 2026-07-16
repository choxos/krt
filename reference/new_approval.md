# Create and add an ethics or governance approval

Create and add an ethics or governance approval

## Usage

``` r
new_approval(approval_type, ..., .id = NULL)

add_approval(x, ...)
```

## Arguments

- approval_type:

  One of
  [`krt_approval_types()`](https://choxos.github.io/krt/reference/krt_vocabularies.md)
  (e.g. `"IACUC"`, `"IRB"`, `"REB"`, `"ethics"`).

- ...:

  Additional named fields: `board_name`, `protocol_number`,
  `institution_name`, `institution_ror`, `jurisdiction`, `approved_on`,
  `consent_obtained`, `consent_scope`, `data_use_restrictions`,
  `redaction_level`.

- .id:

  Optional explicit approval id.

- x:

  A [krt_tbl](https://choxos.github.io/krt/reference/new_krt.md).

## Value

`new_approval()` returns a `krt_approval`; `add_approval()` returns the
updated [krt_tbl](https://choxos.github.io/krt/reference/new_krt.md).

## Examples

``` r
a <- new_approval("IACUC", protocol_number = "2026-017",
                  board_name = "Example IACUC")
k <- add_approval(new_krt("Demo"), a)
```
