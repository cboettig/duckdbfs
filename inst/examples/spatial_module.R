st_read <- function() {

}

st_write <- function() {

}

st_perimeter <- function() {
  # no sf equivalent
}

# functions that operate on geometries already work within `mutate` calls
st_area <- function() {

}


st_intersection <- function(x, y, ...) {
  sf::st_intersection(x, y, ...)
}

st_intersects <- function(x, y, ...) {
  if(inherits(x, "sf")) {
    sf::st_intersection(x, y, ...)
  }

}


st_union <- function(x, y, ...,
                     by_feature = by_feature, is_coverage = is_coverage) {
  if(inherits(x, "sf")) {
    sf::st_union(x, y, ..., by_feature = by_feature, is_coverage = is_coverage)
  }
}
