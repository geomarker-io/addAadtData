
<!-- README.md is generated from README.Rmd. Please edit that file -->

# addAadtData

<!-- badges: start -->

[![R-CMD-check](https://github.com/geomarker-io/addAadtData/workflows/R-CMD-check/badge.svg)](https://github.com/geomarker-io/addAadtData/actions)
<!-- badges: end -->

The goal of `addAadtData` is to add Average Annual Daily Traffic (AADT)
data from the U.S. Department of Transportation [Federal Highway
Administration](https://www.fhwa.dot.gov/policyinformation/hpms/shapefiles_2017.cfm)
to geocoded data.

Input data should have columns called `lat` and `lon` that contain
geographic coordinates. `addAadtData` estimates the exposure to traffic
within a user-specified radius (defaults to 400 m) around the input
coordinates. Specifically, the `length` of roads (in meters), the
average daily number of vehicles multiplied by the length of the roads
(`vehicle_meters`), and the average daily number of trucks multiplied by
the length of the roads (`truck_meters`) are calculated.

Each of these variables is broken down by traffic type, as defined
below:

| **traffic type** | **types of roads**                          | **FHA F\_System Classification**                                       |
|------------------|---------------------------------------------|------------------------------------------------------------------------|
| `moving`         | interstates, expressways, and freeways      | `Interstate` and `Principal Arterial - Other Freeways and Expressways` |
| `stop_go`        | arterial roads (frequent stops lights, etc) | `Principal Arterial - Other` and `Minor Arterial`                      |

## Installation

Because this package contains all the aadt data, it takes a few minutes
to install.

``` r
# adjust options to allow for longer download
options(timeout = 300)

# install.packages("remotes")
devtools::install_github("geomarker-io/addAadtData")
```

## Example

``` r
library(addAadtData) 

d <- tibble::tribble(
  ~id,       ~lat,        ~lon,
  55001310120,         NA,          NA,
  55000100280,   39.19674,  -84.582601,
  55000100281,   39.28765,  -84.510173,
  55000100282,  39.158521,  -84.417572,
  55000100283,  39.158521,  -84.417572,
  55000100284, 39.2747872, -84.8203868,
  55000100285, 39.2810336, -84.8564059,
)

add_aadt(d)
#> Reading and joining data for indiana...
#> Joining, by = c("row_index", "buffer_index", "state")
#> Reading and joining data for ohio...
#> Joining, by = c("row_index", "buffer_index", "state")
#> # A tibble: 7 × 9
#>            id   lat   lon length_stop_go length_moving vehicle_meters_stop_go
#>         <dbl> <dbl> <dbl>          <dbl>         <dbl>                  <dbl>
#> 1 55001310120  NA    NA               NA            NA                     NA
#> 2 55000100280  39.2 -84.6              0             0                      0
#> 3 55000100281  39.3 -84.5            509             0                5900865
#> 4 55000100282  39.2 -84.4           1244             0               28109695
#> 5 55000100283  39.2 -84.4           1244             0               28109695
#> 6 55000100284  39.3 -84.8            736          1071                3452560
#> 7 55000100285  39.3 -84.9            845          1221                3075845
#> # … with 3 more variables: vehicle_meters_moving <dbl>,
#> #   truck_meters_stop_go <dbl>, truck_meters_moving <dbl>
```
