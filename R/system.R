#' Is the System Running a Windows Machine?
#'
#' @return \code{\link{TRUE}} if so, \code{\link{FALSE}} otherwise.
#' @export
is_windows <- function() return(.Platform[["OS.type"]] == "windows")

#' Is the CPU Architecture R was build for 32 bit?
#'
#' @return \code{\link{TRUE}} if so, \code{\link{FALSE}} otherwise.
#' @export
is_32bit <- function() return(R.Version()[["arch"]] == "i386")


