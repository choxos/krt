# Extract resources from text with an LLM

Sends the text to the configured provider and parses the returned JSON
into candidate resources. Requires an API key (from the environment);
returns an empty list if none is configured or the call fails.

## Usage

``` r
extract_llm(text, llm = krt_llm(), ...)
```

## Arguments

- text:

  Manuscript text.

- llm:

  A [`krt_llm()`](https://choxos.github.io/krt/reference/krt_llm.md)
  configuration.

- ...:

  Reserved.

## Value

A list of `krt_resource` candidates.

## Examples

``` r
# Uses a mock provider so no network or key is needed:
register_llm_provider("mock",
  function(prompt, llm) '[{"resource_type":"Software/code","display_name":"R"}]')
extract_llm("text", krt_llm("openai"))  # empty without a key
#> list()
extract_llm("text", structure(list(provider = "mock"), class = "krt_llm"))
#> [[1]]
#> <krt_resource> [Software/code] R
#> 
```
