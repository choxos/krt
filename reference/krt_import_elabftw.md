# Import resources from an eLabFTW experiment

Fetches an experiment and extracts candidate resources from its body
text.

## Usage

``` r
krt_import_elabftw(
  base_url,
  experiment_id,
  token = Sys.getenv("ELABFTW_TOKEN"),
  timeout = 30
)
```

## Arguments

- base_url:

  The eLabFTW instance base URL (e.g. `https://elab.example.org`).

- experiment_id:

  The experiment id.

- token:

  API token (defaults to `ELABFTW_TOKEN`).

- timeout:

  Request timeout in seconds.

## Value

A [krt_tbl](https://choxos.github.io/krt/reference/new_krt.md) of
extracted resources.

## Examples

``` r
if (FALSE) { # \dontrun{
krt_import_elabftw("https://elab.example.org", experiment_id = 42)
} # }
```
