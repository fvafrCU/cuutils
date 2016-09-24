#' throw a condition
#'
#' throws a condition of class c("cuutils", "error", "condition").
#'
#' We use this condition as an error dedictated to \pkg{cuutils}.
#'
#' @author Dominik Cullmann, <dominik.cullmann@@forst.bwl.de>
#' @keywords internal
#' @param message_string The message to be thrown.
#' @param system_call The call to be thrown.
#' @param ... Arguments to be passed to \code{\link{structure}}.
#' @return FALSE. But it doesn't return anything, it stops with a
#' condition of class c("cuutils", "error", "condition").
#' @examples
#' tryCatch(cuutils:::throw("Hello error!"), 
#'          cuutils = function(e) return(e))
throw <- function(message_string, system_call = sys.call(-1), ...) {
    checkmate::qassert(message_string, "s*")
    condition <- structure(
                           class = c("cuutils", "error", "condition"),
                           list(message = message_string, call = system_call),
                           ...
                           )
    stop(condition)
    return(FALSE)
}

