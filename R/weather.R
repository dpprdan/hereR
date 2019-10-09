#' HERE Destination Weather API: Observations, Forecast, Astronomy and Alerts
#'
#' Weather forecasts, reports on current weather conditions,
#' astronomical information and alerts at a specific location (coordinates or
#' location name) based on the 'Destination Weather API'.
#'
#' @references
#' \href{https://developer.here.com/documentation/weather/topics/example-weather-observation.html}{HERE Destination Weather API: Observation}
#'
#' @param poi \code{sf} object or character, Points of Interest (POIs) of geometry type \code{POINT} or location names (e.g. cities or regions).
#' @param product character, weather product of the 'Destination Weather API'. Supported products: \code{"observation"}, \code{"forecast_hourly"}, \code{"forecast_astronomy"} and \code{"alerts"}.
#' @param url_only boolean, only return the generated URLs (\code{default = FALSE})?
#'
#' @return
#' An \code{sf} object containing the requested weather information.
#' @export
#'
#' @examples
#' \donttest{
#' weather(poi = locations, product = "observation")
#' }
weather <- function(poi, product = "observation", url_only = FALSE) {

  # Checks
  .check_weather_product(product)

  # Add authentification
  url <- .add_auth(
    url = "https://weather.api.here.com/weather/1.0/report.json?"
  )

  # Add product
  url = paste0(
    url,
    "&product=",
    product
  )

  # Check and preprocess location
  # Character location
  if (is.character(poi)) {
    .check_addresses(poi)
    poi[poi == ""] = NA
    url = paste0(
      url,
      "&name=",
      poi
    )
  # sf POINTs
  } else if ("sf" %in% class(poi)) {
    .check_points(poi)
    poi <- sf::st_coordinates(
      sf::st_transform(poi, 4326)
    )
    poi <- paste0(
      "&longitude=", poi[, 1], "&latitude=", poi[, 2]
    )
    url = paste0(
      url,
      poi
    )
  # Not valid
  } else {
    stop("Invalid input for 'poi'")
  }

  # Return urls if chosen
  if (url_only) return(url)

  # Request and get content
  data <- .get_content(
    url = url
  )

  # Extract information
  if (product == "observation") {
    weather <- .extract_weather_observation(data)
  } else if (product == "forecast_hourly") {
    weather <- .extract_weather_forecast_hourly(data)
  } else if (product == "forecast_astronomy") {
    weather <- .extract_weather_forecast_astronomy(data)
  } else if (product == "alerts") {
    weather <- .extract_weather_alerts(data)
  }

  # Create sf, data.table, data.frame
  return(
    sf::st_set_crs(
      sf::st_as_sf(weather, coords = c("lng", "lat")),
    4326)
  )
}

.extract_weather_observation <- function(data) {
  observation <- data.table::rbindlist(
    lapply(data, function(con) {
      df <- jsonlite::fromJSON(con)
      station <- data.table::data.table(
        station = df$observations$location$city[1],
        lng = df$observations$location$longitude[1],
        lat = df$observations$location$latitude[1],
        distance = df$observations$location$distance[1] * 1000,
        timestamp = df$observations$location$observation[[1]]$utcTime,
        state = df$observations$location$state[1],
        country = df$observations$location$country[1])
      obs <- df$observations$location$observation[[1]]
      obs <- obs[, !names(obs) %in% c(
        "skyDescription", "airDescription", "precipitationDesc",
        "temperatureDesc", "iconName", "iconLink", "windDesc", "icon",
        "country", "state", "city", "latitude", "longitude", "distance",
        "utcTime", "elevation"), ]
      return(
        cbind(station, obs)
      )
    })
  )
  return(observation)
}

.extract_weather_forecast_hourly <- function(data) {
  dfs <- lapply(data, function(con) {jsonlite::fromJSON(con)})
  forecast <- data.table::rbindlist(
    lapply(dfs, function(df) {
      station <- data.table::data.table(
        city = df$hourlyForecasts$forecastLocation$city[1],
        lng = df$hourlyForecasts$forecastLocation$longitude[1],
        state = df$hourlyForecasts$forecastLocation$state[1],
        country = df$hourlyForecasts$forecastLocation$country[1],
        lat = df$hourlyForecasts$forecastLocation$latitude[1]
      )
    })
  )
  forecast$forecast <- lapply(dfs, function(df)
    {df$hourlyForecasts$forecastLocation$forecast})
  return(forecast)
}

.extract_weather_forecast_astronomy <- function(data) {
  dfs <- lapply(data, function(con) {jsonlite::fromJSON(con)})
  astronomy <- data.table::rbindlist(
    lapply(dfs, function(df) {
      station <- data.table::data.table(
        city = df$astronomy$city[1],
        state = df$astronomy$state[1],
        country = df$astronomy$country[1],
        lng = df$astronomy$longitude[1],
        lat = df$astronomy$latitude[1]
      )
    })
  )
  astronomy$astronomy <- lapply(dfs, function(df)
    {df$astronomy$astronomy})
  return(astronomy)
}

.extract_weather_alerts <- function(data) {
  dfs <- lapply(data, function(con) {jsonlite::fromJSON(con)})
  alerts <- data.table::rbindlist(
    lapply(dfs, function(df) {
      station <- data.table::data.table(
        city = df$alerts$city[1],
        state = df$alerts$state[1],
        country = df$alerts$country[1],
        lng = df$alerts$longitude[1],
        lat = df$alerts$latitude[1]
      )
    })
  )
  alerts$alerts <- lapply(dfs, function(df)
    {df$alerts$alerts})
  return(alerts)
}