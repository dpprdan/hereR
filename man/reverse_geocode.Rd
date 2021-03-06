% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/reverse_geocode.R
\name{reverse_geocode}
\alias{reverse_geocode}
\title{HERE Geocoder API: Reverse Geocode}
\usage{
reverse_geocode(poi, results = 1, sf = TRUE, url_only = FALSE)
}
\arguments{
\item{poi}{\code{sf} object, Points of Interest (POIs) of geometry type \code{POINT}.}

\item{results}{numeric, maximum number of results (Valid range: 1 and 100).}

\item{sf}{boolean, return an \code{sf} object (\code{default = TRUE}) or a
\code{data.frame}?}

\item{url_only}{boolean, only return the generated URLs (\code{default = FALSE})?}
}
\value{
If \code{sf = TRUE}, an \code{sf} object, containing the position coordinates
of the reverse geocoded POIs as geometry list column and the access
coordinates as well-known text (WKT).
If \code{sf = FALSE}, a \code{data.frame} containing the
coordinates of the reverse geocoded POIs as \code{lng}, \code{lat} columns.
}
\description{
Get addresses from locations using the HERE 'Geocoder' API.
The return value is an \code{sf} object, containing point geometries
with suggestions for addresses near the provided POIs.
}
\note{
If no addresses are found near a POI, \code{NULL} for this POI is returned.
In this case the rows corresponding to this particular POI are missing and merging the POIs by row is not possible.
However, in the returned \code{sf} object, the column \code{"id"} matches the rows of the input POIs.
The \code{"id"} column can be used to join the original POIs.
}
\examples{
# Provide an API Key for a HERE project
set_key("<YOUR API KEY>")

# Get addresses
addresses <- reverse_geocode(poi = poi, results = 3, url_only = TRUE)
}
\references{
\href{https://developer.here.com/documentation/geocoding-search-api/dev_guide/topics/endpoint-reverse-geocode-brief.html}{HERE Geocoder API: Reverse Geocode}
}
