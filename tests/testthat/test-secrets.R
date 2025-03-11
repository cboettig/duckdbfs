
test_that("test secrets", {

status <- duckdb_secrets()

expect_true(status == 1)

})

