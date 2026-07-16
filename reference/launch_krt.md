# Launch the interactive KRT editor

Starts a Shiny application for importing, editing (in the generic view),
validating, normalizing identifiers, and exporting a Key Resources
Table. Requires the `shiny`, `bslib`, and `DT` packages.

## Usage

``` r
launch_krt(...)
```

## Arguments

- ...:

  Passed to
  [`shiny::runApp()`](https://rdrr.io/pkg/shiny/man/runApp.html).

## Value

Called for its side effect (runs the app).

## Examples

``` r
if (interactive()) launch_krt()
```
