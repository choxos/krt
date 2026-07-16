## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new submission.

## Test environments

- local macOS, R release
- GitHub Actions: macOS (release), Windows (release), Ubuntu (release and devel)

## Notes on package policy compliance

- **Internet resources.** Several functions contact public registries and
  repositories (RRID/SciCrunch, Crossref, ORCID, NCBI, ROR, Cellosaurus,
  Zenodo, Figshare, eLabFTW, protocols.io, Europe PMC, bioRxiv) and, optionally,
  an LLM provider. All of them degrade gracefully: on any error or non-success
  status they return `NULL`/`NA` or an unresolved result and never abort. No
  example, test, or vignette contacts the network; live-network tests are
  guarded with `skip_on_cran()` and `skip_if_offline()`, and identifier
  resolution defaults to `resolve = FALSE`.

- **Credentials.** API tokens are read from environment variables or passed
  explicitly; none are bundled, and the package never transmits a user's table
  except for the specific fields required by a lookup or deposit the user
  invokes.

- **Licensing.** The package code is GPL-3. The bundled ASAP profile assets are
  derived from the ASAP Key Resource Table resources (Zenodo
  doi:10.5281/zenodo.17917979) under CC BY 4.0 and are isolated under
  `inst/extdata/profiles/asap/` with attribution and provenance; see
  `LICENSE.note` and `inst/COPYRIGHTS`. No Cell Press / STAR Methods template is
  bundled.

- **Use of AI.** Parts of the package were developed with AI assistance; all
  code was reviewed and tested. This is disclosed in the README.
