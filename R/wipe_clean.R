#' Remove All Objects From an Environment
#'
#' @param environment The environment that should be wiped clean.
#' @return A character vector containing the names of objects removed.
#' @export
wipe_clean <- function(environment = .GlobalEnv) {
    objects <- ls(name = environment, all.names = TRUE)
    rm(list = objects, envir = environment)
    return(invisible(objects))
}

