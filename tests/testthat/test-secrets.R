
test_that("test secrets", {

skip_on_cran()
status <- duckdb_secrets()

expect_true(status == 1)
close_connection()

})

