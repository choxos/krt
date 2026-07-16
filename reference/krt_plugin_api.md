# The krt plugin API

The krt plugin API

## Usage

``` r
krt_plugin_api()
```

## Value

A data frame describing each plugin kind, its registration function, and
its contract.

## Examples

``` r
krt_plugin_api()
#>             kind                register
#> 1        profile        register_profile
#> 2      validator      register_validator
#> 3       resolver       register_resolver
#> 4   llm_provider   register_llm_provider
#> 5 suggest_source register_suggest_source
#>                                                                       contract
#> 1          a directory with schema.yml + mappings.yml, or a krt_profile object
#> 2                                  function(x, ctx) returning a list of issues
#> 3         function(id, resolve = TRUE, ...) returning a normalized result list
#> 4                      function(prompt, llm) returning the model's text output
#> 5 function(query, n) returning a data frame (label, id, authority, score, uri)
```
