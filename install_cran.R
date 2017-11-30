package  <- "document"
download.file("https://cran.r-project.org/src/contrib/PACKAGES.rds", tmpf <- tempfile())
packages <- readRDS(tmpf)
i <- which(packages[TRUE, "Package"] == package)
packages[i, TRUE]
tarball <- paste(package, packages[i, "Version"], sep = "_")
download.file
