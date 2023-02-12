# Google Compute Engine region details module

This Terraform module takes a list of Google Compute Engine region names, and
returns a map with each region name as a key to an object:

* a consistent 6 character abbreviation for the region of the format `xx-yyN`
* a display name that should match the value given in the [docs](https://cloud.google.com/compute/docs/regions-zones#available)
* an estimated latitude and longitude

No validation is performed to ensure a name represents an active or available Compute
Engine region; in the event the name is not recognized, the display name will be
`Unknown region` and the latitude and longitude fields will match those of the
US Geological Survey marker in Kansas that represents the [historical center of
the contiguous United States](https://www.google.com/maps/place/The+Geographic+Center+of+the+United+States/@39.8283459,-98.5816684,17z).

> NOTE: If you think this is in error for a given region, please open an issue
to get the region added.

## Examples

### `us-west` and `us-central1`

```hcl
module "regions" {
    source  = "memes/region-detail/google"
    version = "1.0.0"
    regions = ["us-west1", "us-central1"]
}
```

Output:

```hcl
results = {
  "us-central1" = {
    "abbreviation" = "us-ce1"
    "display_name" = "Council Bluffs, Iowa"
    "latitude" = 41.237085
    "longitude" = -96.868656
  }
  "us-west1" = {
    "abbreviation" = "us-we1"
    "display_name" = "The Dalles, Oregon"
    "latitude" = 45.609235
    "longitude" = -121.205447
  }
}
```

### Unknown region: `foo-bar1`

```hcl
module "regions" {
    source  = "memes/multi-region-private-network/google//modules/regions"
    version = "1.0.0"
    regions = ["foo-bar1"]
}
```

Output:

```hcl
results = {
  "foo-bar1" = {
    "abbreviation" = "fo-ba1"
    "display_name" = "Unknown region"
    "latitude" = 39.82835
    "longitude" = -98.5816737
  }
}
```

<!-- markdownlint-disable MD033 MD034-->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.2 |

## Modules

No modules.

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_regions"></a> [regions](#input\_regions) | A list of Google Compute region names for which to return details. The module<br>does not validate that any region name is valid, just that it matches a pattern<br>expected of Google Compute region names. | `list(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_results"></a> [results](#output\_results) | For each supplied region, return an abbreviation for the name in the form<br>`xx-yyN`, a display name that matches the value listed in Google's documentation,<br>and a reasonable latitude and longitude for the region. In the event of a<br>region being unknown to the module, the returned latitude and longitude will<br>be for the historical geographic center of the contiguous 48 United States. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- markdownlint-enable MD033 MD034 -->
