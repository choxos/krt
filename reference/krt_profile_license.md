# Licensing of a profile

Licensing of a profile

## Usage

``` r
krt_profile_license(name)

krt_profile_sources(name)

krt_profile_attribution(name)
```

## Arguments

- name:

  A profile name or `krt_profile`.

## Value

`krt_profile_license()` returns the SPDX license id;
`krt_profile_sources()` returns the source metadata list;
`krt_profile_attribution()` returns the attribution text (or `NULL`).

## Examples

``` r
krt_profile_license("asap")
#> [1] "CC-BY-4.0"
krt_profile_sources("asap")$doi
#> [1] "10.5281/zenodo.17917979"
```
