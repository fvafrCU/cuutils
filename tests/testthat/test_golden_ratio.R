context("golden ratio")
test_that("golden ratio stays the way it is", {
          reference <- structure(c(0.618033988749895, 0.381966011250105, 1), 
                                 .Names = c("a", "b", "a + b"))
          result <- golden_ratio(1)
          expect_equal(reference, result)
          result <- golden_ratio(value = 1, quantity = "a + b")
          expect_equal(reference, result)
          reference <- structure(c(1, 0.618033988749895, 1.61803398874989), 
                                   .Names = c("a", "b", "a + b"))
          result <- golden_ratio(value = 1, quantity = "a")
          expect_equal(reference, result)
          reference <- structure(c(1.61803398874989, 1, 2.61803398874989), 
                                 .Names = c("a", "b", "a + b"))
          result <- golden_ratio(value = 1, quantity = "b")
          expect_equal(reference, result)
})
