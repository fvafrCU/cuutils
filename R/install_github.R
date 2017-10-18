install_github <- function(github_repo) {
    if (.Platform$OS.type == "windows") {
        devtools::install_github(github_repo)
    } else {
        repo <- unlist(strsplit(github_repo, split = "/"))
        local_directory <- tempdir()
        local_path <- file.path(local_directory, "master.zip")
        url <- paste0("https://github.com/", github_repo, "/archive/master.zip")
        download.file(url, local_path, method = "wininet", mode = "wb")
        unzip(local_path, exdir = local_directory)
        path <- file.path(local_directory, paste0(repo[2], "-master"))
        description <- file.path(path, "DESCRIPTION")
        my_r_version <- paste(R.Version()[["major"]], R.Version()[["minor"]], sep = ".")
        d <- readLines(description)
        d1 <- d[!grepl("^OS_type:", d)]
        d1[grepl("^ *R \\(", d1)] <- paste0("    R (>= ", my_r_version,")")
        writeLines(d1, description)
        install.packages(path, repos = NULL, type = "source")
    }
}
