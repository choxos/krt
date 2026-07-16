# data-raw/07-update-po.R
#
# Extract translatable strings from the package into po/R-krt.pot, update any
# existing po/R-<lang>.po catalogs, and compile them into inst/po so that
# messages are localized when the user's locale has a translation. Requires the
# GNU gettext tools (xgettext, msgmerge, msgfmt) on the PATH.
#
# Usage (from the package root):
#   Rscript data-raw/07-update-po.R

tools::update_pkg_po(".")
message("Updated po/ and inst/po from the package's translatable strings.")
