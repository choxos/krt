# Check that an object satisfies a plugin contract

Check that an object satisfies a plugin contract

## Usage

``` r
validate_plugin_contract(kind, obj)
```

## Arguments

- kind:

  One of `"profile"`, `"validator"`, `"resolver"`, `"llm_provider"`,
  `"suggest_source"`.

- obj:

  The plugin object or function to check.

## Value

Invisibly `TRUE`; errors early if the contract is not met.

## Examples

``` r
validate_plugin_contract("validator", function(x, ctx) list())
validate_plugin_contract("suggest_source", function(query, n) NULL)
```
