# Shared HTTP layer. Every network call degrades gracefully: on any error or
# non-success status it returns NULL, so resolvers, suggest sources, deposit,
# and connectors never abort a session (and satisfy CRAN's internet policy).

#' @noRd
.krt_user_agent <- function() "krt R package (+https://github.com/choxos/krt)"

#' @noRd
http_get <- function(url, accept = "application/json", timeout = 15,
                     headers = list(), token = NULL, query = NULL) {
  tryCatch({
    req <- httr2::request(url)
    req <- httr2::req_user_agent(req, .krt_user_agent())
    req <- httr2::req_timeout(req, timeout)
    req <- httr2::req_headers(req, Accept = accept)
    if (length(headers)) req <- do.call(httr2::req_headers, c(list(req), headers))
    if (!is.null(token)) req <- httr2::req_auth_bearer_token(req, token)
    if (!is.null(query)) req <- do.call(httr2::req_url_query, c(list(req), query))
    req <- httr2::req_error(req, is_error = function(resp) FALSE)
    httr2::req_perform(req)
  }, error = function(e) NULL)
}

#' @noRd
http_post_json <- function(url, body, headers = list(), token = NULL,
                           timeout = 30, query = NULL) {
  tryCatch({
    req <- httr2::request(url)
    req <- httr2::req_user_agent(req, .krt_user_agent())
    req <- httr2::req_timeout(req, timeout)
    req <- httr2::req_body_json(req, body)
    if (length(headers)) req <- do.call(httr2::req_headers, c(list(req), headers))
    if (!is.null(token)) req <- httr2::req_auth_bearer_token(req, token)
    if (!is.null(query)) req <- do.call(httr2::req_url_query, c(list(req), query))
    req <- httr2::req_error(req, is_error = function(resp) FALSE)
    httr2::req_perform(req)
  }, error = function(e) NULL)
}

#' @noRd
http_put_json <- function(url, body, headers = list(), token = NULL,
                          timeout = 30, query = NULL) {
  tryCatch({
    req <- httr2::request(url)
    req <- httr2::req_user_agent(req, .krt_user_agent())
    req <- httr2::req_timeout(req, timeout)
    req <- httr2::req_method(req, "PUT")
    req <- httr2::req_body_json(req, body)
    if (length(headers)) req <- do.call(httr2::req_headers, c(list(req), headers))
    if (!is.null(token)) req <- httr2::req_auth_bearer_token(req, token)
    if (!is.null(query)) req <- do.call(httr2::req_url_query, c(list(req), query))
    req <- httr2::req_error(req, is_error = function(resp) FALSE)
    httr2::req_perform(req)
  }, error = function(e) NULL)
}

#' @noRd
http_put_bytes <- function(url, data, type = "application/octet-stream",
                           headers = list(), token = NULL, timeout = 60,
                           query = NULL) {
  tryCatch({
    req <- httr2::request(url)
    req <- httr2::req_user_agent(req, .krt_user_agent())
    req <- httr2::req_timeout(req, timeout)
    req <- httr2::req_method(req, "PUT")
    req <- httr2::req_body_raw(req, charToRaw(data), type = type)
    if (length(headers)) req <- do.call(httr2::req_headers, c(list(req), headers))
    if (!is.null(token)) req <- httr2::req_auth_bearer_token(req, token)
    if (!is.null(query)) req <- do.call(httr2::req_url_query, c(list(req), query))
    req <- httr2::req_error(req, is_error = function(resp) FALSE)
    httr2::req_perform(req)
  }, error = function(e) NULL)
}

#' Parse a response body as JSON, or NULL on failure or error status.
#' @noRd
.resp_json <- function(resp) {
  if (is.null(resp)) return(NULL)
  if (httr2::resp_status(resp) >= 400L) return(NULL)
  tryCatch(httr2::resp_body_json(resp, simplifyVector = FALSE),
           error = function(e) NULL)
}

#' Is a host reachable? Used to skip live tests offline.
#' @noRd
is_online <- function(host = "https://doi.org") {
  resp <- http_get(host, accept = "*/*", timeout = 5)
  !is.null(resp)
}

#' @noRd
endpoint <- function(key) {
  e <- ref_data("resolver_endpoints")[[key]]
  if (is.null(e)) stop(sprintf("Unknown endpoint '%s'.", key), call. = FALSE)
  e
}
