# This file is part of the standard setup for testthat.
# It is recommended that you do not modify it.
#
# Where should you do additional test configuration?
# Learn more about the roles of various files in:
# * https://r-pkgs.org/tests.html
# * https://testthat.r-lib.org/reference/test_package.html#special-files

library(testthat)
library(duckdbfs)


# tests that don't need extensions loaded shouldn't access internet
options("duckdbfs_autoload_extensions"=FALSE)

test_check("duckdbfs")
