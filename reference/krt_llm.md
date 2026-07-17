# Configure an LLM for extraction

Configure an LLM for extraction

## Usage

``` r
krt_llm(
  provider = c("openai", "anthropic", "gemini", "openai_compat"),
  model = NULL,
  base_url = NULL,
  api_key = NULL,
  temperature = 0,
  max_tokens = 4096
)

# S3 method for class 'krt_llm'
format(x, ...)

# S3 method for class 'krt_llm'
print(x, ...)
```

## Arguments

- provider:

  One of the registered providers (`"openai"`, `"anthropic"`,
  `"gemini"`, `"openai_compat"` for local/OpenAI-compatible servers).

- model:

  Model id (a sensible default per provider when `NULL`).

- base_url:

  Base URL for `"openai_compat"` (e.g. a local server).

- api_key:

  API key; defaults to the provider's environment variable.

- temperature, max_tokens:

  Generation parameters.

- x:

  A `krt_llm` object.

- ...:

  Ignored.

## Value

A `krt_llm` configuration object.

## Examples

``` r
krt_llm("openai", model = "gpt-4o-mini")$provider
#> [1] "openai"
```
