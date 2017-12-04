check_python_version <- function(python) {
    reference = "3"
    status <- TRUE
    pyver <- tryCatch(system2(python, "-V", stdout = TRUE), error = identity)
    if (inherits(pyver, "error"))
        pyver <- system2(file.path(python, "python.exe"), "-V", stdout = TRUE))
    pyver <- unlist(strsplit(pyver, split = " "))[2]
    if (compareVersion(pyver, reference) < 0) {
        warning("excerptr needs python version ", reference, ".")
        status  <- FALSE
    }
    return(status)
}
#' Forced Installation of CRAN Packages
#'
#' \code{\link[utils:install.packages]{install.packages}} will not let you
#' install packages that require a higher R version as yours or that are
#' specifica to an operating system. \pkg{excerptr} is such a case. 
#' This function lets you such a packages anyways. 
#' Of course you have to deal with dependencies yourself
#' (\pkg{rPython}, in this case).
#' @param repository The repository to use. 
#' @param package The package's name.
#' @param python Only evaluated if package is "rPython". Your python version. 
#' @param ignore_ostype Ignore operation system type required in the
#' DESCRIPTION?
#' @param ignore_r_version Ignore R version required in the DESCRIPTION?
#' @return The value of \code{\link[utils:install.packages]{install.packages}}.
#' @export 
install_cran <- function(package = "excerptr", 
                         repository = "http://cran.r-project.org",
                         ignore_ostype = TRUE, 
                         python = switch(.Platform[["OS.type"]], 
                                         windows = "C:/python/python34_x64", 
                                         Sys.which("python3")),
                         ignore_r_version = TRUE) {
    if (package == "rPython" && .Platform[["OS.type"]] != "windows") {
        Sys.setenv(RPYTHON_PYTHON_VERSION = as.numeric(sub("^python", "",
                                                           basename(python))))
        check_python_version(python)
    }
    old_options <- options(warn = 2) 
    res <- tryCatch(utils::install.packages(package, repos = repository), 
                    error = identity) 
    options(old_options)
    if (inherits(res, "error")) {
        root <- paste0(repository, "/src/contrib/")
        packages_list_file <- "PACKAGES.gz"
        package_list <- file.path(tempdir(), packages_list_file)
        utils::download.file(paste0(root, packages_list_file), package_list)
        packages <- read.dcf(package_list)
        i <- which(packages[TRUE, "Package"] == package)
        version <- as.character(packages[i, "Version"])
        tarball <- paste0(paste(package, version, sep = "_"), 
                          ".tar.gz")
        remote_tarball <- paste(root, tarball, sep = "/")
        local_tarball <- file.path(tempdir(), tarball)
        utils::download.file(remote_tarball, local_tarball)
        utils::untar(local_tarball, exdir = tempdir())

        path <- file.path(tempdir(), package)
        if (package == "rPython" && .Platform[["OS.type"]] == "windows") {
            check_python_version(python)
            configure <- file.path(path, "configure.win")
            conf <- readLines(configure)
            py_path_part <- sub("_x[468]{2}", "", basename(python))
            conf <- sub("C:/([Pp]ython)27", python, conf)
            conf <- sub("python27", py_path_part, conf)
            writeLines(conf, configure)
            if (! require("RJSONIO")) install.packages("RJSONIO")
        }
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

