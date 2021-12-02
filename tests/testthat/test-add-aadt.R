test_data <- tibble::tribble(
  ~id,       ~lat,        ~lon,
  55001310120,         NA,          NA,
  55000100280,   39.19674,  -84.582601,
  55000100281,   39.28765,  -84.510173,
  55000100282,  39.158521,  -84.417572,
  55000100283,  39.158521,  -84.417572,
  55000100284, 39.2747872, -84.8203868,
  55000100285, 39.2810336, -84.8564059,
)

test_data2 <- tibble::tribble(
  ~id,	~lat,	~lon,
  55001310120,	NA,	NA,
  55000100280,	39.19674,	-84.582601,
  55000100281,	39.28765,	-84.510173,
  55000100282,	39.158521,	-84.417572,
  55000100283,	39.158521,	-84.417572
)

test_that("add_aadt() works", {
  expect_equal(
    add_aadt(test_data),
    test_data %>%
      dplyr::mutate(length_stop_go = c(NA, 0, 509, 1244, 1244, 736, 845),
                    length_moving = c(NA, 0, 0, 0, 0, 1071, 1221),
                    vehicle_meters_stop_go = c(NA, 0, 5900865, 28109695, 28109695, 3452560, 3075845),
                    vehicle_meters_moving = c(NA, 0, 0, 0, 0, 27182800, 27495131),
                    truck_meters_stop_go = c(NA, 0, 0, 0, 0, 144317, 172294),
                    truck_meters_moving = c(NA, 0, 0, 0, 0, 3602736, 6369242)))
})

test_that("add_aadt() works with provided aadt_path", {
  expect_equal(
    add_aadt(test_data),
    test_data %>%
      dplyr::mutate(length_stop_go = c(NA, 0, 509, 1244, 1244, 736, 845),
                    length_moving = c(NA, 0, 0, 0, 0, 1071, 1221),
                    vehicle_meters_stop_go = c(NA, 0, 5900865, 28109695, 28109695, 3452560, 3075845),
                    vehicle_meters_moving = c(NA, 0, 0, 0, 0, 27182800, 27495131),
                    truck_meters_stop_go = c(NA, 0, 0, 0, 0, 144317, 172294),
                    truck_meters_moving = c(NA, 0, 0, 0, 0, 3602736, 6369242)))
})

test_that("add_aadt() returns all aadt columns", {
  expect_equal(
    add_aadt(test_data2),
    test_data2 %>%
      dplyr::mutate(length_stop_go = c(NA, 0, 509, 1244, 1244),
                    length_moving = c(NA, 0, 0, 0, 0),
                    vehicle_meters_stop_go = c(NA, 0, 5900865, 28109695, 28109695),
                    vehicle_meters_moving = c(NA, 0, 0, 0, 0),
                    truck_meters_stop_go = c(NA, 0, 0, 0, 0),
                    truck_meters_moving = c(NA, 0, 0, 0, 0)))
})

