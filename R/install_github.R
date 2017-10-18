#' Install packages from github at fvafr
#'
#' At fvafr curl under windows doesn't work properly. Maybe the proxy isn't set
#' properly. So this functions uses
#' \code{\link[utils:download.file]{download.file}}, which works.
#' @param github_repo A string of form "user/repo", "hadley/devtools" for
#' example.
#' @param ignore_ostype Ignore operation system type required in the
#' DESCRIPTION?
#' @param ignore_r_version Ignore R version required in the DESCRIPTION?
#' @return The value of \code{\link[utils:install.packages]{install.packages}}.
#' @export 
install_github <- function(github_repo, ignore_ostype = TRUE, 
                           ignore_r_version = TRUE) {
    if (.Platform$OS.type != "windows") {
        res <- devtools::install_github(github_repo)
    } else {
        old_wd <- setwd(tempdir())
        on.exit(setwd(old_wd))
        repo <- unlist(strsplit(github_repo, split = "/"))
        local_directory <- tempdir()
        local_path <- file.path(local_directory, "master.zip")
        url <- paste0("https://github.com/", github_repo, 
                      "/archive/master.zip")
        utils::download.file(url, local_path, method = "wininet", mode = "wb")
        utils::unzip(local_path, exdir = local_directory)
        path <- file.path(local_directory, paste0(repo[2], "-master"))
        description <- file.path(path, "DESCRIPTION")
        d <- readLines(description)
        if (isTRUE(ignore_ostype)) d <- d[!grepl("^OS_type:", d)]
        if (any(grepl("^.*R \\(>=", d)) && isTRUE(ignore_r_version)) {
            my_r_version <- paste(R.Version()[["major"]], 
                                  R.Version()[["minor"]], sep = ".")
            Rdep <- d[grepl("^(.*R \\(>=)", d)]
            Rdep <- sub("^(.*R \\(>= ).*(\\)$)", 
                        paste0("\\1", my_r_version, "\\2"), Rdep)
            d[grepl("^(.*R \\(>=)", d)] <- Rdep
        }
        writeLines(d, description)
        res <- utils::install.packages(path, repos = NULL, type = "source")
    }
    return(res)
}
