# This file is part of the standard setup for testthat.
# It is recommended that you do not modify it.
#
# Where should you do additional test configuration?
# Learn more about the roles of various files in:
# * https://r-pkgs.org/tests.html
# * https://testthat.r-lib.org/reference/test_package.html#special-files

library(testthat)
library(duckdbfs)

mc_config_get <- function(alias="play"){

  # this can fail tp parse on windows, stdout is not pure json
  # p <- minioclient::mc_alias_ls(paste(alias, "--json"))
  # config <- jsonlite::fromJSON(p$stdout)

  path <- getOption("minioclient.dir", tools::R_user_dir("minioclient", "data"))
  json <- jsonlite::read_json(file.path(path, "config.json"))
  config <- json$aliases[[alias]]
  config$alias <- alias
  config$URL <- config$url
  config
}


test_check("duckdbfs")
