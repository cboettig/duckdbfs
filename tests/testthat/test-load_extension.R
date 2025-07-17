
test_that("extensions installation", {

  # cran tests cannot fail if no network is available
  skip_on_cran()
  skip_if_offline()

  load_httpfs(nightly=FALSE, force = FALSE)

  exts <- duckdb_extensions()
  status <- exts[exts$extension_name == "httpfs",]
  expect_true(status$installed)
  expect_equal(status$installed_from, "core")

  load_spatial(nightly = FALSE, force = TRUE)
  exts <- duckdb_extensions()
  status <- exts[exts$extension_name == "httpfs",]
  expect_true(status$installed)
  expect_equal(status$installed_from, "core")

  load_extension("json")


})
