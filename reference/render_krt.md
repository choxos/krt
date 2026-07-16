# Render a KRT as a formatted table

Produces a STAR Methods-style table for human review. The
`"star-methods"` profile groups resources under type headers; other
profiles render the ASAP six-column layout.

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
cat(substr(render_krt(krt_example, format = "md"), 1, 80))
#> ## Example dopaminergic neuron study
#> 
#> | RESOURCE TYPE | RESOURCE NAME | SOURCE |
```
