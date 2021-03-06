test_that("route works", {
  # Set dummy key
  set_key("dummy_api_key")

  # Load package example data
  data(poi)

  # Input checks
  expect_error(route(origin = c(1, 2, 3), destination = poi), "'origin' must be an sf object.")
  expect_error(route(origin = c("character", NA), destination = poi), "'origin' must be an sf object.")
  expect_error(route(origin = poi, destination = poi, mode = "not_a_mode"))
  expect_error(route(origin = poi, destination = poi, type = "not_a_type"))
  expect_error(route(origin = poi, destination = poi, vehicle_type = "not_a_vehicle_type"))
  expect_error(route(origin = poi, destination = poi, traffic = "not_a_bool"), "'traffic' must be a 'boolean' value.")
  expect_error(route(origin = poi, destination = poi, url_only = "not_a_bool"), "'url_only' must be a 'boolean' value.")

  # Test with API response mock
  with_mock(
    "hereR:::.get_content" = function(url) {hereR:::mock$route_response},
    routes <- route(origin = poi[1:2, ], destination = poi[3:4, ]),

    # Tests
    expect_equal(any(sf::st_geometry_type(routes) != "LINESTRING"), FALSE),
    expect_equal(nrow(routes), nrow(poi[1:2, ]))
  )
})
