test_that("config", {

    skip_on_cran() # All examples must run on slow machine in 5 secs

    duckdb_config(threads = 1, memory_limit = '10GB')
    duckdb_config(threads = 10)

    threads = duckdb_get_config("threads")
    expect_equal(threads, '10')
    duckdb_reset("threads")
})
