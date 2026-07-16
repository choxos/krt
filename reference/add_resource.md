# Add, update, remove, or get a resource in a KRT

Add, update, remove, or get a resource in a KRT

## Usage

``` r
add_resource(x, ...)

update_resource(x, resource_id, ...)

remove_resource(x, resource_id)

get_resource(x, resource_id)
```

## Arguments

- x:

  A [krt_tbl](https://choxos.github.io/krt/reference/new_krt.md).

- ...:

  For `add_resource()`, either a single `krt_resource` (from
  [`new_resource()`](https://choxos.github.io/krt/reference/new_resource.md))
  or the arguments of
  [`new_resource()`](https://choxos.github.io/krt/reference/new_resource.md)
  (`resource_type`, `display_name`, and named fields).

- resource_id:

  The id of the resource to update, remove, or get.

## Value

`add_resource()`, `update_resource()`, and `remove_resource()` return
the modified `krt_tbl`; `get_resource()` returns a `krt_resource` or
`NULL`.

## Examples

``` r
k <- new_krt("Demo")
k <- add_resource(k, "Software/code", "R", version = "4.4.0",
                  new_or_reuse = "reuse", rrid = "RRID:SCR_001905")
get_resource(k, k$resources[[1]]$resource_id)
#> <krt_resource> [Software/code] R  (reuse)
#>   RRID: RRID:SCR_001905
```
