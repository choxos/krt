# Suggest canonical names and identifiers from public authorities

Queries ontology and registry search endpoints to autocomplete a
resource's canonical name or identifier. Requires network access;
returns an empty result offline.

## Usage

``` r
krt_suggest(query, type = NULL, authority = "auto", n = 10, resolve = TRUE)
```

## Arguments

- query:

  The text to search for.

- type:

  Optional resource type hint.

- authority:

  Which authority to query: `"auto"`, or the name of any registered
  source (built-ins: `"taxonomy"`, `"cellosaurus"`, `"chebi"`, `"ror"`;
  plus any added with
  [`register_suggest_source()`](https://choxos.github.io/krt/reference/register_suggest_source.md)).

- n:

  Maximum number of suggestions.

- resolve:

  Whether to contact the network (default `TRUE`).

## Value

A data frame with columns `label`, `id`, `authority`, `score`, `uri`.

## Examples

``` r
krt_suggest("dopamine", authority = "chebi", resolve = FALSE)
#> [1] label     id        authority score     uri      
#> <0 rows> (or 0-length row.names)
```
