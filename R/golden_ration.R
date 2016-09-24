#' Calculate the Golden Ratio
#'
#' @param value The value of the quantity.
#' @param quantity The quantity of which the value is known.
#' @return a numeric vector of lenght 2, containing the two quantites a and b, 
#' (a being the larger) and their sum.
#' @export
#' @examples
#' golden_ratio(10)
#' golden_ratio(golden_ratio(10)[["a"]], "a + b")
golden_ratio  <- function(value = 1, quantity = "a + b") {
    phi <- (1 + sqrt(5)) / 2
    switch(quantity,
           "a" = {
               a  <- value
               b <- a / phi
           },
           "b" = {
               b <- value
               a <- b * phi
           },
           "a + b" = {
               a <- value / phi
               b <- a * phi - a 
           },
           throw('quantity not in "a", "b" or "a + b"')
           )
    return(c("a" = a, "b" = b, "a + b" = a + b))
}

