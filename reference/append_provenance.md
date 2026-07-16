# Append a provenance entry to a KRT

Records that an `activity` (for example `"normalize_ids"`, `"import"`,
`"validate"`, `"resolve"`, `"export"`) was applied to the table. Called
automatically by the mutating functions; exported so custom pipelines
can record their own steps.

## Usage

``` r
append_provenance(x, activity, inputs = NULL, outputs = NULL, params = NULL)
```

## Arguments

- x:

  A [krt_tbl](https://choxos.github.io/krt/reference/new_krt.md).

- activity:

  A short activity label.

- inputs, outputs:

  Optional character vectors of input/output identifiers.

- params:

  Optional named list of parameters for the activity.

## Value

The `krt_tbl` with the entry appended.

## Examples

``` r
k <- append_provenance(new_krt("Demo"), "import", params = list(format = "csv"))
length(krt_provenance(k))
#> [1] 1
```
