# krt: Author, Validate, and Export Key Resources Tables

krt is a toolkit for working with Key Resources Tables (KRTs). A KRT
lists the resources used and generated in a study (antibodies, cell
lines, organisms, chemicals, software, datasets, protocols, and more),
each paired with a persistent identifier so that resources are
unambiguously identifiable and machine-actionable.

## Details

The package is built around a neutral, typed core object
[krt_tbl](https://choxos.github.io/krt/reference/new_krt.md) and a
registry of output *profiles* (generic, ASAP, STAR Methods, and custom)
that the core maps to. The author-facing table is a view; the underlying
record set stays structured, typed, and losslessly round-trippable
through JSON and YAML.

Start with
[`new_krt()`](https://choxos.github.io/krt/reference/new_krt.md) and
[`add_resource()`](https://choxos.github.io/krt/reference/add_resource.md),
validate with
[`validate_krt()`](https://choxos.github.io/krt/reference/validate_krt.md),
normalize identifiers with
[`normalize_ids()`](https://choxos.github.io/krt/reference/normalize_ids.md),
and write output with
[`export_krt()`](https://choxos.github.io/krt/reference/export_krt.md)
or
[`render_krt()`](https://choxos.github.io/krt/reference/render_krt.md).
See the package vignettes and <https://choxos.github.io/krt/> for
details.

## See also

Useful links:

- <https://github.com/choxos/krt>

- <https://choxos.github.io/krt/>

- Report bugs at <https://github.com/choxos/krt/issues>

## Author

**Maintainer**: Ahmad Sofi-Mahmudi <a.sofimahmudi@gmail.com>
([ORCID](https://orcid.org/0000-0001-6829-0823))

Authors:

- Ahmad Sofi-Mahmudi <a.sofimahmudi@gmail.com>
  ([ORCID](https://orcid.org/0000-0001-6829-0823))

Other contributors:

- Aligning Science Across Parkinson's (Copyright holder of the ASAP Key
  Resources Table schema (CC BY 4.0; Zenodo doi:10.5281/zenodo.17917979)
  from which the bundled ASAP profile is derived. ASAP does not endorse
  this package.) \[copyright holder\]
