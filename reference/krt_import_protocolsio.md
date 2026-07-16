# Import a protocol from protocols.io

Fetches a protocol and records it as a Protocol resource.

## Usage

``` r
krt_import_protocolsio(
  id,
  token = Sys.getenv("PROTOCOLSIO_TOKEN"),
  timeout = 30
)
```

## Arguments

- id:

  A protocols.io protocol id or DOI.

- token:

  API token (defaults to `PROTOCOLSIO_TOKEN`).

- timeout:

  Request timeout in seconds.

## Value

A [krt_tbl](https://choxos.github.io/krt/reference/new_krt.md) with a
single Protocol resource.

## Examples

``` r
if (FALSE) { # \dontrun{
krt_import_protocolsio("kxygx3w")
} # }
```
