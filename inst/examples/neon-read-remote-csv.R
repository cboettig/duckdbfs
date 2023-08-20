
# remotes::install_github("duckdbfs")
library(duckdbfs)
library(neonstore)
library(dplyr)
df <-  neonstore:::neon_data(product = "DP1.20288.001",
                        start_date = "2023-06-01",
                        end_date = "2023-08-01",
                        type="basic"
                        )
  urls <- df |>
  dplyr::filter(grepl("waq_instantaneous", name)) |>
  pull(url)



ds <- duckdbfs::open_dataset(urls,
                             format="csv",
                             filename = TRUE)


sites <- duckdbfs::open_dataset("https://raw.githubusercontent.com/eco4cast/neon4cast-targets/main/NEON_Field_Site_Metadata_20220412.csv",
                                format = "csv")


aq <- ds |>
  mutate(field_site_id = regexp_extract(filename, "NEON.DOM.SITE.DP1.20288.001/(\\w{4})", 1L)) |>
  left_join(sites) |>
  mutate(geometry = ST_Point(field_longitude, field_latitude)) |>
  to_sf()

aq |> select(geometry) |> distinct() |> plot()



sites <- duckdbfs::open_dataset("https://raw.githubusercontent.com/eco4cast/neon4cast-targets/main/NEON_Field_Site_Metadata_20220412.csv",
                                format = "csv")
