# Register an LLM provider

Register an LLM provider

## Usage

``` r
register_llm_provider(name, request_fn, parse_fn = NULL, replace = FALSE)
```

## Arguments

- name:

  Provider name (e.g. `"openai"`, `"anthropic"`, a local endpoint).

- request_fn:

  A function `function(prompt, llm)` returning the model's text output,
  or `NULL` on failure.

- parse_fn:

  Optional custom parser `function(text)`; defaults to JSON array
  extraction.

- replace:

  Overwrite an existing provider named `name`? Defaults to `FALSE` so a
  plugin cannot silently replace a built-in provider.

## Value

Invisibly `NULL`.

## Examples

``` r
register_llm_provider("echo", function(prompt, llm) "[]", replace = TRUE)
"echo" %in% list_llm_providers()
#> [1] TRUE
```
