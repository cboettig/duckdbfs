test_that("spatial", {
  skip_if_offline() # needs to be able to load the spatial module
  skip_if_not_installed("sf")
  skip_on_cran()

  skip_if_not(has_spatial(), "spatial extension not available")

  library(dplyr)
  library(sf)
  ex <- system.file("extdata/spatial-test.csv", package = "duckdbfs") |>
    open_dataset(format = "csv") |>
    dplyr::mutate(geometry = ST_Point(longitude, latitude)) |>
    to_sf()

  expect_true(TRUE)
})

test_that("spatial vector read", {
  skip_if_not_installed("sf")
  skip_if_offline() # needs to be able to load the spatial module
  skip_on_cran()

  skip_if_not(has_spatial(), "spatial extension not available")

  # lazy-read external data ( urls work too!)
  path <- system.file("extdata/world.fgb", package = "duckdbfs")
  x <- open_dataset(path, format = "sf")

  # read into R
  y <- x |> to_sf()

  expect_s3_class(x, "tbl_lazy")
  expect_s3_class(x, "tbl")
  expect_s3_class(y, "sf")
})


test_that("to_sf() reads native GEOMETRY without WKB cast and picks up CRS", {
  skip_if_not_installed("sf")
  skip_if_offline()
  skip_on_cran()
  skip_if_not(has_spatial(), "spatial extension not available")

  path <- system.file("extdata/world.fgb", package = "duckdbfs")
  x <- open_dataset(path, format = "sf")

  # the source declares EPSG:4326; to_sf() should pick that up automatically
  y <- to_sf(x)
  expect_s3_class(y, "sf")
  expect_equal(sf::st_crs(y), sf::st_crs("EPSG:4326"))

  # explicit user-supplied crs should still win
  z <- to_sf(x, crs = "EPSG:3857")
  expect_equal(sf::st_crs(z), sf::st_crs("EPSG:3857"))
})


test_that("spatial_join", {
  skip_if_not_installed("sf")
  skip_if_offline() # needs to be able to load the spatial module
  skip_on_cran()
  skip_if_not(has_spatial(), "spatial extension not available")

  countries <-
    paste0(
      "https://github.com/cboettig/duckdbfs/",
      "raw/main/inst/extdata/world.fgb"
    ) |>
    open_dataset()

  cities <-
    paste0(
      "https://github.com/cboettig/duckdbfs/raw/",
      "main/inst/extdata/metro.fgb"
    ) |>
    open_dataset()

  out <-
    countries |>
    dplyr::filter(iso_a3 == "AUS") |>
    spatial_join(cities)

  expect_s3_class(out, "tbl_lazy")

  local <- to_sf(out)
  expect_s3_class(local, "sf")
  expect_true(all(local$iso_a3 == "AUS"))

  ## add examples of other types of spatial joins
})


## Test st_read_meta

test_that("st_read_meta", {
  skip_if_offline() # needs to be able to load the spatial module
  skip_if_not_installed("sf")
  skip_on_cran()
  skip_if_not(has_spatial(), "spatial extension not available")

  load_spatial()

  df <-
    "https://github.com/duckdb/duckdb_spatial/raw/main/test/data/amsterdam_roads.fgb" |>
    st_read_meta()
  expect_equal(df$code, "3857")
})
