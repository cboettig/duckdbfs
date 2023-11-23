library(duckdbfs)
library(dplyr)
library(DBI)

#load_spatial()
#con <- cached_connection()

devtools::install_github("cboettig/duckdbfs@spatial-read")
countries <- open_dataset("/vsicurl/https://github.com/cboettig/duckdbfs/raw/spatial-read/inst/extdata/world.gpkg",
                          format = "sf", tblname = "countries")

cities <- open_dataset("/vsicurl/https://github.com/cboettig/duckdbfs/raw/spatial-read/inst/extdata/metro.fgb",
                          format = "sf", tblname = "cities")

con <- cached_connection()
## We can count number of cities in each country with a bit of SQL
x <- DBI::dbGetQuery(con, "
SELECT countries.iso_a3, count(cities.geom) AS total
FROM countries
LEFT JOIN cities
ON st_contains(countries.geom, cities.geom)
GROUP BY countries.iso_a3
ORDER BY total DESC
LIMIT 6
")

# in dplyr this could be nice and pretty, but `join_by` refuses the syntax
countries |>
  left_join(cities, join_by(st_contains(geom, geom))) |>
  count(iso_a3, sort=TRUE)


# other dplyr functions have no difficulty passing on these arguments:
melbourne <- st_point(c(144.9633, -37.814)) |> st_as_text()
countries |> filter(st_contains(geom, ST_GeomFromText({melbourne})))


# Aside: left_join() without count() looks like this in SQL .. much more verbose than dplyr
x <- DBI::dbGetQuery(con,"
SELECT countries.iso_a3, cities.geom, countries.geom AS geometry
FROM countries
LEFT JOIN cities
ON st_contains(countries.geom, cities.geom)
") |> as_tibble()






## accessing secure data with credentials

KBAs <- "/vsis3/biodiversity/KBAsGlobal_2023_March_01_POL.shp"
kba_pts <- "/vsis3/biodiversity/KBAsGlobal_2023_March_01_PNT.shp"
Sys.setenv("AWS_ACCESS_KEY_ID"=Sys.getenv("NVME_KEY"))
Sys.setenv("AWS_SECRET_ACCESS_KEY"=Sys.getenv("NVME_SECRET"))
Sys.setenv("AWS_S3_ENDPOINT"="minio.carlboettiger.info")
Sys.setenv("AWS_VIRTUAL_HOSTING"=FALSE)
x <- sf::read_sf(kba_pts)
kbas <- open_dataset(kba_pts, format="sf", tblname="kbas")

