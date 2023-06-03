
# remotes::install_github("duckdbfs")
library(duckdbfs)
library(neonstore)
library(dplyr)
df <-  neonstore:::neon_data(product = "DP1.20288.001",
                        start_date = "2020-01-01",
                        end_date = "2021-01-01",
                        site = c("BARC", "POSE"),
                        type="basic"
                        )
  urls <- df |>
  dplyr::filter(grepl("waq_instantaneous", name)) |>
  pull(url)


bench::bench_time({
ds <- duckdbfs::open_dataset(urls,
                             format="csv",
                             filename = TRUE,
                             unify_schemas = FALSE)
})
ds
