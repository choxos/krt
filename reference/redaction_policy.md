# The default redaction policy

The default redaction policy

## Usage

``` r
redaction_policy()
```

## Value

A data frame with columns `scope` (`"approval"` or `"resource"`),
`field`, `level` (the strip strength at which the field is removed:
`"basic"` fields are removed at both `"basic"` and `"strict"`;
`"strict"` fields only at `"strict"`), and `action` (`"drop"` or
`"generalize"`).

## Examples

``` r
redaction_policy()
#>       scope                 field level     action
#> 1  approval       protocol_number basic       drop
#> 2  approval            board_name basic       drop
#> 3  approval      institution_name basic       drop
#> 4  approval       institution_ror basic       drop
#> 5  approval           approved_on basic       drop
#> 6  approval          jurisdiction basic generalize
#> 7  approval         consent_scope basic generalize
#> 8  approval data_use_restrictions basic generalize
#> 9  approval      consent_obtained basic       drop
#> 10 resource            lot_number basic       drop
#> 11 resource          batch_number basic       drop
#> 12 resource                 notes basic generalize
```
