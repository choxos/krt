# Extend krt with plugins

krt is extensible through five registries. Register custom components
with the corresponding function;
[`krt_plugin_api()`](https://choxos.github.io/krt/reference/krt_plugin_api.md)
lists the entry points and their contracts, and
[`validate_plugin_contract()`](https://choxos.github.io/krt/reference/validate_plugin_contract.md)
checks an object before you register it.

## See also

[`register_profile()`](https://choxos.github.io/krt/reference/register_profile.md),
[`register_validator()`](https://choxos.github.io/krt/reference/register_validator.md),
[`register_resolver()`](https://choxos.github.io/krt/reference/register_resolver.md),
[`register_llm_provider()`](https://choxos.github.io/krt/reference/register_llm_provider.md),
[`register_suggest_source()`](https://choxos.github.io/krt/reference/register_suggest_source.md).
