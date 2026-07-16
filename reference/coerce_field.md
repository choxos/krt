# Coerce a field value to its declared type.

Light, non-destructive coercion used when building resource records.
Enum fields are lower/normalized where the vocabulary is lowercase;
unknown enum values are passed through unchanged (validation reports on
them separately).

## Usage

``` r
coerce_field(name, value)
```

## Arguments

- name:

  Field name.

- value:

  The value to coerce.

## Value

The coerced value.

## Examples

``` r
coerce_field("new_or_reuse", "NEW")
#> [1] "new"
coerce_field("pmid", 12345)
#> [1] "12345"
```
