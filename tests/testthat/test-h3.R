
test_that("h3", {
  skip_if_offline() # needs to be able to load the spatial module
  skip_if_not_installed("sf")
  skip_on_cran()
  skip_on_os("windows") # h3 extension not built for windows(?)

  # start a fresh connection
  options("duckdbfs_autoload_extensions"=TRUE)
  close_connection()

  library(dplyr)
  load_h3()

  # requires json extension, autoload:


  path <- tempfile(fileext = ".h3j")
  ex <- system.file("extdata/spatial-test.csv", package="duckdbfs")

  zoom <- 9L # Zoom must be explicit integer, L
  query <- ex |>
    open_dataset(format = "csv") |>
    mutate(h3id = h3_latlng_to_cell_string(latitude, longitude, zoom))

  df <- collect(query)
  expect_s3_class(df, "data.frame")

  query |> to_h3j(path)
  expect_true(file.exists(path))

  # unset autoload
  options("duckdbfs_autoload_extensions"=TRUE)


})
