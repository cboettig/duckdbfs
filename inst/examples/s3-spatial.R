
library(dplyr)
library(duckdbfs)
system.file("extdata/spatial-test.csv", package="duckdbfs") |>
  open_dataset(format = "csv") |>
  mutate(geometry = ST_Point(longitude, latitude)) |>
  to_sf()

library(dplyr)
library(sf)
library(spData)
library(duckdbfs)

gbif <- duckdbfs::open_dataset("s3://gbif-open-data-us-east-1/occurrence/2022-12-01/occurrence.parquet/**", tblname = "gbif")
duckdbfs::load_spatial()
con <- duckdbfs::cached_connection()

# let's filter the parquet data by spatial polygon!
# of course it would be much faster using x/y lims from bbox using vanilla SQL, this is just a proof-of-concept
costa_rica <- world |> filter(grepl("Costa Rica", name_long)) |> pull(geom) |> st_as_text()

## FIXME wrap this so we don't need cached_connection() call and sql_render() and st_read?

bench::bench_time({
sql <- gbif |>
  mutate(geometry = ST_Point(decimallongitude, decimallatitude),
         geom = ST_AsWKB(geometry)) |>
  filter(class == "Mammalia") |>
  filter(ST_Within(geometry, ST_GeomFromText({costa_rica}))) |>
  dbplyr::sql_render()

cr_species <- st_read(con, query=sql, geometry_column = "geom", EWKB=FALSE)
cr_species |> as_tibble()
})




devtools::load_all()
library(dplyr)
costa_rica <- spData::world |>
  dplyr::filter(grepl("Costa Rica", name_long)) |>
  dplyr::pull(geom) |>
  sf::st_as_text()

gbif <- duckdbfs::open_dataset("s3://gbif-open-data-us-east-1/occurrence/2022-12-01/occurrence.parquet/**", tblname = "gbif")
x <-
  gbif |>
  mutate(geometry = ST_Point(decimallongitude, decimallatitude)) |>
  filter(class == "Mammalia") |>
  filter(ST_Within(geometry, ST_GeomFromText({costa_rica})))
x |> to_sf()





con <- duckdbfs::cached_connection()
load_spatial(con)
sql <- x |>
  dplyr::mutate(wkb_geometry = ST_AsWKB(geometry)) |>
  dbplyr::sql_render()
sf::st_read(con, query=sql, geometry_column = "wkb_geometry")





## with helpers
species <- gbif |>
  mutate(geometry = ST_Point(decimallongitude, decimallatitude)) |>
  filter(class == "Mammalia") |>
  filter(ST_Within(geometry, ST_GeomFromText({costa_rica}))) |>
  to_sf()



## compare to:
bench::bench_time({
  ex <- gbif |>
    filter(class == "Mammalia",
           between(decimallongitude, -85.94, -82.55),
           between(decimallatitude, 8.22, 11.22)) |>
    collect()

})




## boilerplate setup
library(duckdb)
conn <- DBI::dbConnect(duckdb::duckdb())
status <- DBI::dbExecute(conn, "INSTALL 'spatial';")
status <- DBI::dbExecute(conn, "LOAD 'spatial';")
test <- data.frame(site = letters[1:10], latitude = 1:10, longitude = 1:10)
DBI::dbWriteTable(conn, "test", test)

## Here we go:
sql <- tbl(conn, "test") |>
  mutate(geom = ST_AsWKB(ST_Point(longitude, latitude))) |>
  dbplyr::sql_render()

ex <- st_read(conn, query=sql, geometry_column = "geom", EWKB=FALSE)

