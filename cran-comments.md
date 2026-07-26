## Resubmission

This is a resubmission. Thank you for the review; every point is addressed
below.

* **All acronyms are now explained in the Description.** STAR (Structured,
  Transparent, Accessible Reporting) Methods, ASAP (Aligning Science Across
  Parkinson's), FAIR (Findable, Accessible, Interoperable, Reusable), RRID
  (Research Resource Identifier), DOI (Digital Object Identifier), and KRT (Key
  Resources Table) are each spelled out at first use.

* **No example code is commented out.** The commented-out call in
  `register_validator.Rd` has been replaced by a runnable example: it registers
  a no-op demonstration rule, confirms the engine picked it up, and runs a
  validation. It executes in well under a second. The whole `man/` directory was
  re-checked; the only remaining `#` lines in examples are prose comments, not
  disabled code.

* **`\dontrun{}` replaced by `\donttest{}` wherever the example can actually
  run.** `resolvers.Rd` (`resolve_doi()` and friends), `fetch_fulltext.Rd`, and
  `krt_import_protocolsio.Rd` now use `\donttest{}`. All three contact only
  public, unauthenticated endpoints and degrade gracefully: offline or on any
  non-success status they return the normalized identifier with
  `resolved = FALSE`, `NULL`, or an empty table, and never signal an error, so
  they are safe to run on a machine without internet access.

  `\dontrun{}` is retained in exactly three places, in each case because the
  function calls `stop()` on its first line when no credential is present, so
  the example genuinely cannot be executed by a user or a check machine:

  - `krt_deposit_zenodo()` requires a Zenodo account and `ZENODO_TOKEN`;
  - `krt_deposit_figshare()` requires a Figshare account and `FIGSHARE_TOKEN`;
  - `krt_import_elabftw()` requires a private eLabFTW instance URL and
    `ELABFTW_TOKEN`.

  A comment inside each `\dontrun{}` block states the missing prerequisite.

* **Nothing is written to the user's home filespace.** No exported function has
  a default output path: every writing function takes `path = NULL`, which
  returns the content as a string instead of writing anywhere, so a file is
  created only at a location the user names explicitly. The optional attribution
  sidecar is written only beside a user-supplied `path`, and only when that path
  was given. Examples, tests, and vignettes now write exclusively to
  `tempfile()` / `tempdir()`; the two remaining relative paths in prose (the
  `README` and the "extending krt" vignette) were changed to
  `file.path(tempdir(), ...)` so that copying and pasting them cannot write to
  the working directory either.

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
  a large language model provider. All of them degrade gracefully: on any error
  or non-success status they return `NULL`/`NA` or an unresolved result and
  never abort. Identifier resolution only contacts the network when called with
  `resolve = TRUE`. No test or vignette contacts the network; live-network tests
  are guarded with `skip_on_cran()` and `skip_if_offline()`. The three
  `\donttest{}` examples that do contact a public endpoint are error-free
  offline, as described above.

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
