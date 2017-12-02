#' Forced Installation of CRAN Packages
#'
#' \code{\link[utils:install.packages]{install.packages} will not let you
#' install packages that require a higher R version as yours or that are
#' specifica to an operating system. \pkg{excerptr} is such a case. 
#' This function lets you such a packages anyways. 
#' Of course you have to deal with dependencies yourself
#' (\pkg{rPython}, in this case).
#' @param repository The repository to use. 
#' @param package The package's name.
#' @param ignore_ostype Ignore operation system type required in the
#' DESCRIPTION?
#' @param ignore_r_version Ignore R version required in the DESCRIPTION?
#' @return The value of \code{\link[utils:install.packages]{install.packages}}.
#' @export 
install_cran <- function(package = "excerptr", 
                         repository = "http://cran.r-project.org",
                         ignore_ostype = TRUE, 
                         ignore_r_version = TRUE) {
    old_options <- options(warn = 2) 
    res <- tryCatch(utils::install.packages(package, repos = repository), 
                    error = identity) 
    options(old_options)
    if (inherits(res, "error")) {
        root <- paste0(repository, "/src/contrib/")
        packages_list_file <- "PACKAGES.gz"
        package_list <- file.path(tempdir(), packages_list_file)
        download.file(paste0(root, packages_list_file), package_list)
        packages <- read.dcf(package_list)
        i <- which(packages[TRUE, "Package"] == package)
        version <- as.character(packages[i, "Version"])
        tarball <- paste0(paste(package, version, sep = "_"), 
                          ".tar.gz")
        remote_tarball <- paste(root, tarball, sep = "/")
        local_tarball <- file.path(tempdir(), tarball)
        download.file(remote_tarball, local_tarball)
        utils::untar(local_tarball, exdir = tempdir())

        path <- file.path(tempdir(), package)
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

