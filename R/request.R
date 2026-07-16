# Shared HTTP layer. Every network call degrades gracefully: on any error or
# non-success status it returns NULL, so resolvers, suggest sources, deposit,
# and connectors never abort a session (and satisfy CRAN's internet policy).

#' @noRd
.krt_user_agent <- function() "krt R package (+https://github.com/choxos/krt)"

# Perform a request that never throws on HTTP status (req_error is disabled by
# the callers), then enforce this layer's contract: a non-success (>= 400)
# status returns NULL, so a caller testing `is.null()` cannot mistake a failed
# request for a successful one.
#' @noRd
.perform <- function(req) {
  resp <- httr2::req_perform(req)
  if (httr2::resp_status(resp) >= 400L) return(NULL)
  resp
}

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
    .perform(req)
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
    .perform(req)
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
    .perform(req)
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
    raw <- if (is.raw(data)) data else charToRaw(data)
    req <- httr2::req_body_raw(req, raw, type = type)
    if (length(headers)) req <- do.call(httr2::req_headers, c(list(req), headers))
    if (!is.null(token)) req <- httr2::req_auth_bearer_token(req, token)
    if (!is.null(query)) req <- do.call(httr2::req_url_query, c(list(req), query))
    req <- httr2::req_error(req, is_error = function(resp) FALSE)
    .perform(req)
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

#' May a credential be sent to this URL? Only over HTTPS, or to a loopback
#' address (for local model or ELN servers). Prevents leaking an API token, and
#' the payload it accompanies, over an unencrypted link.
#' @noRd
.credential_url_ok <- function(url, has_credential) {
  if (!isTRUE(has_credential)) return(TRUE)
  if (grepl("^https://", url, ignore.case = TRUE)) return(TRUE)
  grepl("^https?://(localhost|127\\.0\\.0\\.1|\\[::1\\])([:/]|$)", url,
        ignore.case = TRUE)
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
