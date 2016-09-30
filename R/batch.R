#' get the path of the R code file in case of an R CMD BATCH run.
#'
#' @export
#' @return a vector of \code{\link{mode}} character giving the name of the R
#' code file. Will be character(0) if not in an R CMD BATCH run.
#' @examples
#' get_R_CMD_BATCH_script_path()
get_R_CMD_BATCH_script_path <- function() {
    r_call <- commandArgs(trailingOnly = FALSE)
    path <- r_call[which(r_call == "-f") + 1]
    return(path)
}

#' get the path of the R code file in case of an Rscript run.
#'
#' @export
#' @return a vector of \code{\link{mode}} character giving the name of the R
#' code file. Will be character(0) if not in an Rscript run.
#' @examples
#' get_Rscript_script_path()
get_Rscript_script_path <- function() {
    r_call <- commandArgs(trailingOnly = FALSE)
    path <- sub("--file=", "", r_call[grep("--file", r_call)])
    return(path)
}

#' get the path of the R code file.
#'
#' This is just a wrapper for \code{\link{get_Rscript_script_path}} and 
#' \code{\link{get_R_CMD_BATCH_script_path}}.
#' @export
#' @return a vector of \code{\link{length}} 1 and \code{\link{mode}} 
#' character giving the name of the R code file if R was run via R CMD BATCH or
#' Rscript.
#' @examples
#' get_script_path()
get_script_path <- function() {
    path <- c(get_R_CMD_BATCH_script_path(), get_Rscript_script_path())
    return(path)
}

#' get the name of the R code file or set it to \code{default}.
#'
#' The code file name is retrieved only for R CMD BATCH and Rscript,
#' if R is used interactively, the name is set to \code{default}, 
#' even if you're working with code stored in a (named) file on disk.
#' @param default the name to return if R is run interactively.
#' @export
#' @return a vector of \code{\link{length}} 1 and \code{\link{mode}} 
#' character giving the name of the R code file if R was run via R CMD BATCH or
#' Rscript, the given default otherwise.
#' @examples
#' get_script_name(default = 'foobar.R')
get_script_name <- function(default = "interactive_R_session") {
    path <- get_script_path()
    if (as.logical(length(path))) {
        name <- basename(path)
    } else {
        name <- default
    }
    return(name)
}

#' is R run in batch mode (via R CMD BATCH or Rscript)?
#'
#' @export
#' @return a boolean.
#' @examples
#' is_batch()
is_batch <- function() {
    is_batch <- ! interactive()
    return(is_batch)
}

#' provide an output directory and a variable containing its name.
#'
#' create directories of path '\code{path}/\code{scriptName}_type' and store
#' this path in an object called '\code{type}_directory'.
#'
#' @note This functions creates the character vector \code{type}_directory with
#' content  '\code{path}/\code{scriptName}_type' in .GlobalEnv and the directory
#' '\code{path}/\code{scriptName}_type' on disk.
#' @param path a \code{\link{file.path}}, defaults to '.'.
#' @param type a character vector of length 1 giving the a name postfix.
#' Defaults to 'graphics'.
#' @export
#' @return TRUE on success, FALSE otherwise. 
#' @examples
#' provide_output_directory()
provide_output_directory <- function(type = "graphics", path  = ".") {
    checkmate::assertString(type)
    checkmate::assertString(path)
    status <- FALSE
    directory <- file.path(path, paste(get_script_name(), type, sep = "_"))
    directory_name <- paste(type, "directory", sep = "_")
    assign(directory_name, directory, envir = parent.frame())
    if (! file.exists(directory)) dir.create(directory)
    status <- TRUE
    return(invisible(status))
}
