# Key Resources Table field registry

The field registry declares every field a resource record may carry,
together with its group, type, cardinality, and the resource types it
applies to.

## Usage

``` r
all_fields()

field_spec(name)

fields_for_type(resource_type)

field_label(name, locale = NULL)
```

## Arguments

- name:

  A field name.

- resource_type:

  A resource type (one of
  [`krt_resource_types()`](https://choxos.github.io/krt/reference/krt_vocabularies.md)).

- locale:

  Optional locale (currently advisory; labels fall back to a title-cased
  field name).

## Value

`all_fields()` returns a named list of field specifications;
`field_spec()` returns one specification (or `NULL`);
`fields_for_type()` returns the names of fields that apply to a resource
type; `field_label()` returns a human-readable label.

## Examples

``` r
str(field_spec("rrid"))
#> List of 8
#>  $ name       : chr "rrid"
#>  $ group      : chr "identifier"
#>  $ type       : chr "string"
#>  $ cardinality: chr "one"
#>  $ applies_to : chr "all"
#>  $ enum       : NULL
#>  $ label_key  : chr "field.rrid"
#>  $ help       : chr "Research Resource Identifier."
fields_for_type("Antibody")
#>  [1] "resource_id"        "resource_type"      "display_name"      
#>  [4] "canonical_name"     "source_name"        "vendor"            
#>  [7] "catalog_number"     "lot_number"         "batch_number"      
#> [10] "rrid"               "doi"                "pmid"              
#> [13] "pmcid"              "accession"          "url"               
#> [16] "release_date"       "new_or_reuse"       "status"            
#> [19] "antibody_clone"     "antibody_host"      "antibody_clonality"
#> [22] "antibody_conjugate" "target"             "notes"             
```
