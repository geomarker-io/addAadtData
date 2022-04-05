make_buffers <- function(d, buffer_radius) {
  d_buffers <- sf::st_buffer(d, dist = buffer_radius) %>%
    dplyr::mutate(buffer_index = 1:nrow(.)) %>%
    sf::st_join(states)
  return(d_buffers)
}

get_aadt_intersection <- function(d_buffers_by_state) {
  state_name <- unique(d_buffers_by_state$state)
  cli::cli_progress_message("Reading and joining data for {state_name}...")

  aadt <- system.file("extdata", glue::glue('{state_name}2017.qs'), package = 'addAadtData') %>%
    qs::qread() %>%
    dplyr::filter(road_type %in% c('Interstate',
                            'Principal Arterial - Other Freeways and Expressways',
                            'Principal Arterial - Other', 'Minor Arterial'))

    d_aadt <- suppressWarnings(sf::st_intersection(d_buffers_by_state, aadt))
    d_aadt <- dplyr::left_join(d_buffers_by_state %>% sf::st_drop_geometry(),
                               d_aadt,
                               by = c("row_index", "buffer_index", "state")) %>%
      sf::st_as_sf()
    return(d_aadt)
}

summarize_aadt_data <- function(d_aadt) {
  d_aadt %>%
    dplyr::mutate(length = as.numeric(sf::st_length(.)),
                  aadt = as.numeric(aadt),
                  aadt_length = aadt*length,
                  aadt_truck = as.numeric(aadt_single_unit) + as.numeric(aadt_combination),
                  aadt_truck_length = aadt_truck*length,
                  traffic_type = factor(road_type,
                                        levels = c('Interstate',
                                                   'Principal Arterial - Other Freeways and Expressways',
                                                   'Principal Arterial - Other', 'Minor Arterial'),
                                        labels = c('moving', 'moving', 'stop_go', 'stop_go'))) %>%
    sf::st_drop_geometry() %>%
    dplyr::group_by(buffer_index, traffic_type) %>%
    dplyr::summarize(length = round(sum(length, na.rm = TRUE)),
                     vehicle_meters = round(sum(aadt_length, na.rm = TRUE)),
                     truck_meters = round(sum(aadt_truck_length, na.rm = TRUE))) %>%
    dplyr::mutate_at(dplyr::vars(length, vehicle_meters, truck_meters), as.numeric) %>%
    tidyr::pivot_wider(names_from = traffic_type,
                       values_from = c(length, vehicle_meters, truck_meters))
}

#' add average annual daily traffic to geocoded data
#'
#' @param d data.frame or tibble with columns called 'lat', 'lon'
#' @param buffer_radius buffer radius in meters, defaults to 400 m
#'
#' @return the input dataframe, with lengths, vehicle meters for all vehicle
#'         types, and vehicle meters for trucks for both moving (interstates, freeways,
#'         and expressways) and stop-and-go (arterial roads) traffic.
#'
#' @examples
#' if (FALSE) {
#' d <- tibble::tribble(
#'      ~id,         ~lat,    ~lon,
#'      '55000100280', 39.2, -84.6,
#'      '55000100281', 39.2, -84.6,
#'      '55000100282', 39.2, -84.6)
#'
#'    add_aadt(d)
#' }
#' @export
add_aadt <- function(d, buffer_radius = 400) {
  dht::check_for_column(d, "lat", d$lat)
  dht::check_for_column(d, "lon", d$lon)

  d <- dplyr::mutate(d, row_index = 1:nrow(d))
  d_raw <- d

  d <- d %>%
    dplyr::select(row_index, lat, lon) %>%
    dplyr::filter(!is.na(lat),
           !is.na(lon)) %>%
    sf::st_as_sf(coords = c('lon', 'lat'), crs = 4326) %>%
    sf::st_transform(5072)

  d_buffers <- make_buffers(d, buffer_radius)
  d_buffers_by_state <- split(d_buffers, d_buffers$state)
  d_aadt <- purrr::map_dfr(d_buffers_by_state, get_aadt_intersection)
  d_aadt <- dplyr::arrange(d_aadt, buffer_index)

  d_aadt <- suppressMessages(summarize_aadt_data(d_aadt))

  # bind to row of zeros to ensure all columns make it to output
  d_aadt <- dplyr::bind_rows(tibble::tibble(buffer_index = 0, length_stop_go = 0, length_moving = 0,
                                            vehicle_meters_stop_go = 0,  vehicle_meters_moving = 0,
                                            truck_meters_stop_go = 0, truck_meters_moving = 0),
                             d_aadt) %>%
    dplyr::filter(buffer_index != 0) %>%
    dplyr::select(buffer_index, length_stop_go, length_moving,
                  vehicle_meters_stop_go, vehicle_meters_moving,
                  truck_meters_stop_go, truck_meters_moving)

  # replace all NAs with 0
  d_aadt[is.na(d_aadt)] = 0

  d_aadt <- d_buffers %>%
    sf::st_drop_geometry() %>%
    dplyr::select(-state) %>%
    dplyr::filter(!duplicated(buffer_index)) %>%
    dplyr::left_join(d_aadt, by = "buffer_index") %>%
    dplyr::select(-buffer_index)

  d_aadt <- dplyr::left_join(d_raw, d_aadt, by = 'row_index') %>%
    dplyr::select(-row_index)

  return(d_aadt)
}



