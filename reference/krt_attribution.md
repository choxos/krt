# Attribution text for a table's profile

Returns the attribution block that should accompany outputs produced
with the table's profile. For the ASAP profile (CC BY 4.0) this is the
required attribution; for profiles with no redistribution obligation it
is a short note.

## Usage

``` r
krt_attribution(x)
```

## Arguments

- x:

  A [krt_tbl](https://choxos.github.io/krt/reference/new_krt.md) or a
  profile name.

## Value

A character string.

## Examples

``` r
cat(krt_attribution(krt_example))
#> The 'generic' profile imposes no attribution requirement.
```
