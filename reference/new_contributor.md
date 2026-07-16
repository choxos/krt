# Create and add a contributor

Create and add a contributor

## Usage

``` r
new_contributor(name, ..., .id = NULL)

add_contributor(x, ...)
```

## Arguments

- name:

  Contributor name.

- ...:

  Additional named fields: `orcid`, `role` (see
  [`krt_roles()`](https://choxos.github.io/krt/reference/krt_vocabularies.md)),
  `affiliation`, `affiliation_ror`.

- .id:

  Optional explicit contributor id.

- x:

  A [krt_tbl](https://choxos.github.io/krt/reference/new_krt.md).

## Value

`new_contributor()` returns a `krt_contributor`; `add_contributor()`
returns the updated
[krt_tbl](https://choxos.github.io/krt/reference/new_krt.md).

## Examples

``` r
k <- add_contributor(new_krt("Demo"), "Ada Researcher",
                     orcid = "0000-0002-1825-0097", role = "author")
```
