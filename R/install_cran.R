install_cran <- function(package = "excerptr", 
                         repos = "http://cran.r-project.org",
                         ignore_ostype = TRUE, 
                         ignore_r_version = TRUE) {
    old_options <- options(warn = 2) 
    res <- tryCatch(utils::install.packages(package, repos = repos), 
                    error = identity) 
    options(old_options)
    if (inherits(res, "error")) {
        root <- paste0(repos, "/src/contrib/")
        packages_list_file <- "PACKAGES.gz"
        package_list <- file.path(tempdir(), packages_list_file)
        download.file(paste0(root, packages_list_file), package_list)
        packages <- read.dcf(package_list)
        i <- which(packages[TRUE, "Package"] == package)
        tarball <- paste0(paste(package, packages[i, "Version"], sep = "_"), 
                          ".tar.gz")
        message(tarball)
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

