output "results" {
  value = { for region in toset(local.regions) : region => {
    abbreviation = join("", regex("^([^-]{2})[^-]*(-)([^1-9]{2})[^1-9]*([1-9]+)$", replace(replace(replace(replace(replace(replace(region, "/^northamerica/", "na"), "/^southamerica/", "sa"), "/southeast/", "se"), "/northeast/", "ne"), "/southwest/", "sw"), "/northwest/", "nw")))
    display_name = try(local.locations[region].name, "Unknown region")
    # If the region is unknown, default to the geographic center of the
    # contiguous United States marker.
    latitude  = try(local.locations[region].latitude, 39.82835)
    longitude = try(local.locations[region].longitude, -98.5816737)
  } }
  description = <<-EOD
    For each supplied region, return an abbreviation for the name in the form
    `xx-yyN`, a display name that matches the value listed in Google's documentation,
    and a reasonable latitude and longitude for the region. In the event of a
    region being unknown to the module, the returned latitude and longitude will
    be for the historical geographic center of the contiguous 48 United States.
    EOD
}
