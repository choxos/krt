# Extracting a KRT from a manuscript

``` r

library(krt)
#> krt 0.1.0: author, validate, and export Key Resources Tables.
#>   Start with new_krt(); see https://choxos.github.io/krt/
```

`krt` can extract candidate resources from a manuscript with a
deterministic regex engine (the default, fully offline) or an optional
LLM.

## Scan text for identifiers

``` r

txt <- "We stained with anti-TH (RRID:AB_390204) from Millipore (Cat# AB152)
        and analyzed images in Fiji (RRID:SCR_002285). Data: GEO GSE12345."
scan_identifiers(txt)
#>        value          field          type confidence
#> 1  AB_390204           rrid      Antibody       high
#> 2 SCR_002285           rrid Software/code       high
#> 3      AB152 catalog_number          <NA>     medium
#> 4   GSE12345      accession       Dataset       high
```

## Extract a table

``` r

res <- extract_krt(txt)
as.data.frame(res$krt)[, c("resource_type", "display_name", "rrid")]
#>   resource_type display_name            rrid
#> 1      Antibody    AB_390204  RRID:AB_390204
#> 2 Software/code   SCR_002285 RRID:SCR_002285
#> 3       Dataset     GSE12345            <NA>
```

The result is a normalized, validated `krt_tbl` plus a validation
report; every extraction is provenance-stamped with the engine used.

## Read structured documents

[`read_input_text()`](https://choxos.github.io/krt/reference/read_input_text.md)
handles PDF, JATS/NISO XML, DOCX, and plain text, and
[`detect_existing_krt()`](https://choxos.github.io/krt/reference/detect_existing_krt.md)
parses a Key Resources Table already present in the document.

``` r

jats <- system.file("extdata", "examples", "sample.jats.xml", package = "krt")
res <- extract_krt(jats)
res$existing_krt
#> <krt_tbl> (untitled)
#>   profile: asap | schema: 1.0.0 | resources: 2
#>     Antibody                                   1 (new 0, reuse 1)
#>     Software/code                              1 (new 0, reuse 1)
```

## LLM extraction (optional)

The LLM engine is opt-in and requires a provider and API key. It is
non-deterministic, so it is never the default, and its output is
funneled through the same normalize + validate pipeline as every other
import path.

``` r

cfg <- krt_llm("openai", model = "gpt-4o-mini")   # reads OPENAI_API_KEY
res <- extract_krt("path/to/manuscript.pdf", engine = "llm", llm = cfg)
```

You can register a custom or local provider:

``` r

register_llm_provider("local", function(prompt, llm) {
  # call your local server, return the model's text output
})
extract_krt(txt, engine = "llm",
            llm = structure(list(provider = "local"), class = "krt_llm"))
```
