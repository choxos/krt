# Render a KRT as a formatted table

Produces a human-readable Key Resources Table. The `"star-methods"`
profile projects the table to the three Cell Press columns (REAGENT or
RESOURCE, SOURCE, IDENTIFIER) and groups resources under the twelve
standard STAR Methods category headers, in the order the template uses.
The `"generic"` profile (the default) renders the ASAP six-column
layout; any other named profile renders through its own declared
columns.

## Usage

``` r
render_krt(
  x,
  path = NULL,
  format = c("md", "html", "docx"),
  profile = NULL,
  template = NULL,
  audience = c("author", "public"),
  redact = NULL
)
```

## Arguments

- x:

  A [krt_tbl](https://choxos.github.io/krt/reference/new_krt.md).

- path:

  Output path, or `NULL` to return the text (md/html).

- format:

  `"md"`, `"html"`, or `"docx"`.

- profile:

  Profile controlling the layout (default the table's profile).

- template:

  Unused placeholder for a future Word template.

- audience:

  `"author"` (full) or `"public"` (redacted) for shared tables.

- redact:

  Redaction strength for public output, or `FALSE` to disable.

## Value

The rendered text (md/html), or the path (invisibly) for docx.

## Examples

``` r
cat(substr(render_krt(krt_example, profile = "star-methods"), 1, 80))
#> ## Example dopaminergic neuron study
#> 
#> | REAGENT or RESOURCE | SOURCE | IDENTIFIE
```
