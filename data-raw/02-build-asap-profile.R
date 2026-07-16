# data-raw/02-build-asap-profile.R
#
# Generate inst/extdata/profiles/asap/template.xlsx: an independently generated
# workbook that follows the six-column ASAP Key Resource Table layout, with a
# controlled-vocabulary dropdown for RESOURCE TYPE and NEW/REUSE and an
# attribution worksheet. No content is copied from the ASAP source workbook; the
# column structure follows the public ASAP specification and the file carries
# the CC BY 4.0 attribution recorded in ATTRIBUTION.md / provenance.json.
#
# Usage (from the package root):
#   Rscript data-raw/02-build-asap-profile.R

stopifnot(requireNamespace("openxlsx", quietly = TRUE))

find_pkg_root <- function(start = getwd()) {
  d <- normalizePath(start, mustWork = FALSE)
  repeat {
    if (file.exists(file.path(d, "DESCRIPTION"))) return(d)
    parent <- dirname(d)
    if (identical(parent, d)) stop("Could not find package root.")
    d <- parent
  }
}
asap_dir <- file.path(find_pkg_root(), "inst", "extdata", "profiles", "asap")

cols <- c("RESOURCE TYPE", "RESOURCE NAME", "SOURCE", "IDENTIFIER",
          "NEW/REUSE", "ADDITIONAL INFORMATION")
resource_types <- c(
  "Antibody", "Bacterial strain", "Biological sample",
  "Chemical, peptide, or recombinant protein", "Critical commercial assay",
  "Dataset", "Experimental model: Cell line",
  "Experimental model: Organism/strain", "Oligonucleotide", "Other",
  "Protocol", "Recombinant DNA", "Software/code", "Viral vector")

wb <- openxlsx::createWorkbook()
openxlsx::addWorksheet(wb, "KRT")
hs <- openxlsx::createStyle(textDecoration = "bold")
openxlsx::writeData(wb, "KRT", t(cols), colNames = FALSE, headerStyle = hs)
openxlsx::addStyle(wb, "KRT", hs, rows = 1, cols = seq_along(cols), gridExpand = TRUE)
openxlsx::setColWidths(wb, "KRT", cols = seq_along(cols), widths = c(28, 30, 24, 40, 12, 40))

openxlsx::addWorksheet(wb, "Lists", visible = FALSE)
openxlsx::writeData(wb, "Lists", data.frame(resource_type = resource_types))
openxlsx::writeData(wb, "Lists", data.frame(new_or_reuse = c("new", "reuse")),
                    startCol = 2)

openxlsx::dataValidation(wb, "KRT", col = 1, rows = 2:1000, type = "list",
  value = sprintf("'Lists'!$A$2:$A$%d", length(resource_types) + 1),
  allowBlank = TRUE)
openxlsx::dataValidation(wb, "KRT", col = 5, rows = 2:1000, type = "list",
  value = "'Lists'!$B$2:$B$3", allowBlank = TRUE)

openxlsx::addWorksheet(wb, "ATTRIBUTION")
attribution <- readLines(file.path(asap_dir, "ATTRIBUTION.md"), warn = FALSE)
openxlsx::writeData(wb, "ATTRIBUTION", data.frame(Attribution = attribution),
                    colNames = FALSE)

out <- file.path(asap_dir, "template.xlsx")
openxlsx::saveWorkbook(wb, out, overwrite = TRUE)
message(sprintf("Wrote %s", out))
