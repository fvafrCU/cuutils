git_status <- system("git status --porcelain", intern = TRUE)
modified_codes <- basename(sub(" M ", "", grep(" M R/", git_status,
                                               value = TRUE)))
if (length(modified_codes) > 0) {
    pattern <- paste0("\\.*", sub("\\.R", "", modified_codes), collapse = "|")
    devtools::test(filter = pattern)
} else {
    message("no code files with modified git status found.")
}
