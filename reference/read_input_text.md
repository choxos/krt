# Read manuscript text and tables from an input

Read manuscript text and tables from an input

## Usage

``` r
read_input_text(input, format = NULL)
```

## Arguments

- input:

  A file path (pdf/xml/jats/docx/txt) or a plain-text string.

- format:

  Optional explicit format; auto-detected when `NULL`.

## Value

A list with `text` (character), `tables` (list of data frames), and
`format`.

## Examples

``` r
read_input_text("We used FIJI (RRID:SCR_002285).")$text
#> [1] "We used FIJI (RRID:SCR_002285)."
```
