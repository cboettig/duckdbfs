

test_that("spatial", {

  skip_if_not_installed("sf")
  skip_if_offline() # needs to be able to load the spatial module
  skip_on_cran()

  ex <- system.file("extdata/spatial-test.csv", package="duckdbfs") |>
  open_dataset(format = "csv") |>
  mutate(geometry = ST_Point(longitude, latitude)) |>
  to_sf()


})
