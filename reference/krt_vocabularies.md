# KRT controlled vocabularies

Convenience accessors for the controlled vocabularies used across the
package.

## Usage

``` r
krt_resource_types()

krt_new_or_reuse()

krt_statuses()

krt_approval_types()

krt_roles()

krt_redaction_levels()
```

## Value

A character vector of allowed values.

## Examples

``` r
krt_resource_types()
#>  [1] "Antibody"                                 
#>  [2] "Bacterial strain"                         
#>  [3] "Biological sample"                        
#>  [4] "Chemical, peptide, or recombinant protein"
#>  [5] "Critical commercial assay"                
#>  [6] "Dataset"                                  
#>  [7] "Experimental model: Cell line"            
#>  [8] "Experimental model: Organism/strain"      
#>  [9] "Oligonucleotide"                          
#> [10] "Other"                                    
#> [11] "Protocol"                                 
#> [12] "Recombinant DNA"                          
#> [13] "Software/code"                            
#> [14] "Viral vector"                             
krt_new_or_reuse()
#> [1] "new"   "reuse"
```
