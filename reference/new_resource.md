# Create a resource record

Builds a single `krt_resource`: a flat, present-only record describing
one research resource. Identifier fields are stored separately by type
(`catalog_number`, `rrid`, `doi`, ...); they are only combined into a
compound identifier string at export time.

## Usage

``` r
new_resource(
  resource_type,
  display_name = NULL,
  ...,
  .id = NULL,
  .validate = TRUE
)

is_resource(x)
```

## Arguments

- resource_type:

  One of
  [`krt_resource_types()`](https://choxos.github.io/krt/reference/krt_vocabularies.md).

- display_name:

  The resource name as it appears in the manuscript.

- ...:

  Additional named fields (see
  [`all_fields()`](https://choxos.github.io/krt/reference/field_registry.md)
  for the vocabulary), for example `vendor`, `catalog_number`, `rrid`,
  `doi`, `new_or_reuse`, `notes`.

- .id:

  Optional explicit resource id; generated from content if omitted.

- .validate:

  If `TRUE` (default), check `resource_type` against the controlled
  vocabulary and warn about unknown fields.

- x:

  An object to test.

## Value

An object of class `krt_resource`.

## Examples

``` r
new_resource("Antibody", "Rabbit Anti-TH", vendor = "Millipore",
             catalog_number = "AB152", rrid = "RRID:AB_390204",
             new_or_reuse = "reuse")
#> <krt_resource> [Antibody] Rabbit Anti-TH  (reuse)
#>   RRID: RRID:AB_390204; Cat#: AB152
```
