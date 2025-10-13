test_that("extensions installation", {
  # cran tests cannot fail if no network is available
  skip_on_cran()
  skip_if_offline()

  close_connection()
  duckdb_connect()

  load_httpfs(nightly = FALSE, force = FALSE)

  # core extensions only, don't test 'spatial' or 'h3'

  exts <- duckdb_extensions()
  status <- exts[exts$extension_name == "httpfs", ]
  expect_true(status$installed)
  expect_equal(status$installed_from, "core")

  exts <- duckdb_extensions()
  status <- exts[exts$extension_name == "httpfs", ]
  expect_true(status$installed)
  expect_equal(status$installed_from, "core")

  load_extension("json")
})
