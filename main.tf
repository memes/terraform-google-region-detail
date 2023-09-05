terraform {
  required_version = ">= 1.2"
  required_providers {
    http = {
      source  = "hashicorp/http"
      version = ">= 3.2"
    }
  }
}

data "http" "cloud_json" {
  url = "https://www.gstatic.com/ipranges/cloud.json"
  lifecycle {
    postcondition {
      condition     = self.status_code == 200
      error_message = "Failed to retrieve GCP CIDRs."
    }
  }
}

locals {
  regions = var.regions == null ? [] : var.regions
  # Note: these values are either the location of a known Google data center
  # (as published at https://www.google.com/about/datacenters/json/locations.json) or
  # the lat/long returned by Google Maps when looking up the city associated
  # with the region.
  known_locations = {
    # Changhua County, Taiwan - JSON
    asia-east1 = {
      name      = "Changhua County, Taiwan"
      latitude  = 23.941487
      longitude = 120.465852
    }
    # Hong Kong - estimated
    asia-east2 = {
      name      = "Hong Kong"
      latitude  = 22.3529805
      longitude = 113.9872732
    }
    # Tokyo, Japan - estimated
    asia-northeast1 = {
      name      = "Tokyo, Japan"
      latitude  = 35.5090563
      longitude = 139.2080248
    }
    # Osaka, Japan - estimated
    asia-northeast2 = {
      name      = "Osaka, Japan"
      latitude  = 34.6777191
      longitude = 135.4158261
    }
    # Seoul, South Korea - estimated
    asia-northeast3 = {
      name      = "Seoul, South Korea"
      latitude  = 37.5640451
      longitude = 126.8336605
    }
    # Mumbai, India - estimated
    asia-south1 = {
      name      = "Mumbai, India"
      latitude  = 19.0825221
      longitude = 72.7407593
    }
    # Delhi, India - estimated
    asia-south2 = {
      name      = "Delhi, India"
      latitude  = 28.6471944
      longitude = 76.952837
    }
    # Jourong West, Singapore - JSON
    asia-southeast1 = {
      name      = "Jourong West, Singapore"
      latitude  = 1.361362
      longitude = 103.880629
    }
    # Jakarta, Indonesia - estimated
    asia-southeast2 = {
      name      = "Jakarta, Indonesia"
      latitude  = -6.2293277
      longitude = 106.5427753
    }
    # Sydney, Australia - estimated
    australia-southeast1 = {
      name      = "Sydney, Australia"
      latitude  = -33.8473552
      longitude = 150.6511121
    }
    # Melbourne, Australia - estimated
    australia-southeast2 = {
      name      = "Melbourne, Australia"
      latitude  = -37.9716913
      longitude = 144.7722745
    }
    # Warsaw, Poland - estimated
    europe-central2 = {
      name      = "Warsaw, Poland"
      latitude  = 52.2330649
      longitude = 20.9207697
    }
    # Hamina, Finland - JSON
    europe-north1 = {
      name      = "Hamina, Finland"
      latitude  = 60.571442
      longitude = 27.187255
    }
    # Madrid, Spain - estimated
    europe-southwest1 = {
      name      = "Madrid, Spain"
      latitude  = 40.4378615
      longitude = -3.9662634
    }
    # St. Ghislan, Belgium - JSON
    europe-west1 = {
      name      = "St. Ghislan, Belgium"
      latitude  = 50.481086
      longitude = 3.816501
    }
    # London, England - estimated
    europe-west2 = {
      name      = "London, England"
      latitude  = 51.5287714
      longitude = -0.2420231
    }
    # Frankfurt, Germany - estimated
    europe-west3 = {
      name      = "Frankfurt, Germany"
      latitude  = 50.1213009
      longitude = 8.5663529
    }
    # Eemshaven, Netherlands - JSON
    europe-west4 = {
      name      = "Eemshaven, Netherlands"
      latitude  = 53.442801
      longitude = 6.809751
    }
    # Zurich, Switzerland - estimated
    europe-west6 = {
      name      = "Zurich, Switzerland"
      latitude  = 47.3774945
      longitude = 8.5016304
    }
    # Milan, Italy - estimated
    europe-west8 = {
      name      = "Milan, Italy"
      latitude  = 45.4628327
      longitude = 9.1075212
    }
    # Paris, France - estimated
    europe-west9 = {
      name      = "Paris, France"
      latitude  = 48.8588789
      longitude = 2.2036864
    }
    # Berlin, Germany - estimated
    europe-west10 = {
      name      = "Berlin, Germany"
      latitude  = 52.5068042
      longitude = 13.0950963
    }
    # Turin, Italy - estimated
    europe-west12 = {
      name      = "Turin, Italy"
      latitude  = 45.0702306
      longitude = 7.5876877
    }
    # Doha, Qatar - estimated
    me-central1 = {
      name      = "Doha, Qatar"
      latitude  = 25.284228
      longitude = 51.3471815
    }
    # Tel Aviv, Israel - estimated
    me-west1 = {
      name      = "Tel Aviv, Israel"
      latitude  = 32.0879994
      longitude = 34.7621408
    }
    # Montréal, Québec - estimated
    northamerica-northeast1 = {
      name      = "Montréal, Québec"
      latitude  = 45.5593371
      longitude = -73.8522984
    }
    # Toronto, Ontario - estimated
    northamerica-northeast2 = {
      name      = "Toronto, Ontario"
      latitude  = 43.7184034
      longitude = -79.5184833
    }
    # Osasco, São Paulo - estimated
    southamerica-east1 = {
      name      = "Osasco, São Paulo"
      latitude  = -23.5346662
      longitude = -46.8196789
    }
    # Santiago (Quilicura), Chile - JSON
    southamerica-west1 = {
      name      = "Santiago, Chile"
      latitude  = -33.351494
      longitude = -70.754686
    }
    # Council Bluffs, Iowa - JSON
    us-central1 = {
      name      = "Council Bluffs, Iowa"
      latitude  = 41.237085
      longitude = -96.868656
    }
    # Moncks Corner (Berkeley County), South Carolina - JSON
    us-east1 = {
      name      = "Moncks Corner, South Carolina"
      latitude  = 33.194921
      longitude = -80.074502
    }
    # Ashburn (Loudoun County), Virgnia - JSON
    us-east4 = {
      name      = "Ashburn, Virginia"
      latitude  = 39.18847
      longitude = -77.677198
    }
    # Colombus (New Albany), Ohio - JSON
    us-east5 = {
      name      = "Columbus, Ohio"
      latitude  = 40.084001
      longitude = -82.809395
    }
    # Dallas (Midlothian), Texas - JSON
    us-south1 = {
      name      = "Dallas, Texas"
      latitude  = 32.492608
      longitude = -96.989049
    }
    # The Dalles, Oregon - JSON
    us-west1 = {
      name      = "The Dalles, Oregon"
      latitude  = 45.609235
      longitude = -121.205447
    }
    # Los Angeles, California - estimated
    us-west2 = {
      name      = "Los Angeles, California"
      latitude  = 34.0207289
      longitude = -118.6925988
    }
    # Salt Lake City, Utah - estimated
    us-west3 = {
      name      = "Salt Lake City, Utah"
      latitude  = 40.7767167
      longitude = -111.9906962
    }
    # Las Vegas (Henderson), Nevada - JSON
    us-west4 = {
      name      = "Las Vegas, Nevada"
      latitude  = 36.021648
      longitude = -115.049574
    }
  }
  cloud_json = jsondecode(data.http.cloud_json.response_body)
  locations = { for k, v in local.known_locations : k => merge(v, {
    ipv4 = compact([for prefix in lookup(local.cloud_json, "prefixes", []) : try(prefix.ipv4Prefix, "") if try(prefix.scope, "") == k])
    ipv6 = compact([for prefix in lookup(local.cloud_json, "prefixes", []) : try(prefix.ipv6Prefix, "") if try(prefix.scope, "") == k])
  }) }
}
