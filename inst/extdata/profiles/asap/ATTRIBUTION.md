# Attribution

## Source material

**Title:** ASAP Key Resource Table Guide, FAQ, and Template
**Creator:** Aligning Science Across Parkinson's (ASAP)
**Source:** DOI [10.5281/zenodo.17917979](https://doi.org/10.5281/zenodo.17917979), version 8
**License:** Creative Commons Attribution 4.0 International (CC BY 4.0)

## Modifications

The source material was adapted into a machine-readable profile for the `krt`
R package. Modifications include:

- conversion of the spreadsheet column structure into a YAML column schema;
- a mapping from the package's neutral core fields to the six ASAP columns;
- machine-readable validation severity overrides reflecting the ASAP
  requirement that RESOURCE TYPE, RESOURCE NAME, IDENTIFIER, and NEW/REUSE are
  present in every row;
- an independently generated template following the ASAP column structure
  (no source workbook content is copied).

Changes are recorded in `provenance.json`.

## No endorsement

This package is independently developed and is not an official ASAP product.
No affiliation with or endorsement by ASAP is implied. The CC BY 4.0 license
text is included in `inst/licenses/CC-BY-4.0.txt`.
