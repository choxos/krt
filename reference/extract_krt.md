# Extract a Key Resources Table from a manuscript

Reads a manuscript (PDF, JATS/NISO XML, DOCX, or text), extracts
candidate resources with the deterministic regex engine (default) or an
LLM, and returns them as a validated
[krt_tbl](https://choxos.github.io/krt/reference/new_krt.md). Every
result is provenance-stamped with the engine used.

## Usage

``` r
extract_krt(
  input,
  engine = c("regex", "llm"),
  format = NULL,
  profile = "generic",
  llm = NULL,
  resolve = FALSE,
  existing = c("detect", "ignore"),
  title = NULL
)
```

## Arguments

- input:

  A file path or text string.

- engine:

  `"regex"` (deterministic, offline) or `"llm"` (requires a configured
  provider and API key).

- format:

  Optional explicit input format.

- profile:

  Profile to assign to the extracted table.

- llm:

  A [`krt_llm()`](https://choxos.github.io/krt/reference/krt_llm.md)
  configuration (for the LLM engine).

- resolve:

  Whether to resolve identifiers during validation.

- existing:

  `"detect"` to also parse an embedded KRT, or `"ignore"`.

- title:

  Optional title for the extracted table.

## Value

A list with `krt` (the extracted
[krt_tbl](https://choxos.github.io/krt/reference/new_krt.md)),
`candidates` (the raw resource candidates), `existing_krt` (a parsed
embedded table or `NULL`), and `report` (a validation report).

## Examples

``` r
res <- extract_krt("Anti-TH (RRID:AB_390204); FIJI (RRID:SCR_002285).")
nrow(as.data.frame(res$krt))
#> [1] 2
```
