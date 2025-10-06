"""Test fixture for identify published regions that are unknown to the module."""

import pathlib
from collections.abc import Generator
from typing import Any

import pytest
import requests

from .conftest import run_tofu_in_workspace

FIXTURE_NAME = "published"
EXPECTED_UNKNOWN_REGIONS = frozenset(
    {
        "northamerica-south1",  # TODO(memes): #113
        "asia-southeast3",  # TODO(memes): #112
        "europe-north2",  # TODO(memes): #78
        "us-west8",  # TODO(memes): #60
        "us-east7",  # TODO(memes): #43
        "us-central2",  # TODO(memes): #42
    },
)


@pytest.fixture(scope="module")
def published_regions() -> frozenset[str]:
    """Return a list of regions published by Google Cloud."""
    resp = requests.get("https://www.gstatic.com/ipranges/cloud.json")
    assert resp.status_code == requests.codes.OK
    regions = frozenset({entry["scope"] for entry in resp.json()["prefixes"] if entry["scope"] != "global"})
    assert regions is not None
    assert len(regions) > 0
    return regions


@pytest.fixture(scope="module")
def fixture_output(
    root_fixture_dir: pathlib.Path,
    published_regions: frozenset[str],
) -> Generator[dict[str, Any], None, None]:
    """Create fixture for test case."""
    with run_tofu_in_workspace(
        fixture=root_fixture_dir,
        workspace=FIXTURE_NAME,
        tfvars={
            "regions": list(published_regions),
        },
    ) as output:
        yield output


def test_output_values(fixture_output: dict[str, Any]) -> None:
    """Verify the fixture output meets expectations."""
    assert fixture_output
    results = fixture_output["results"]
    assert results is not None
    unknown_regions = frozenset([k for (k, v) in results.items() if v["display_name"] == "Unknown region"])
    assert unknown_regions is not None
    for region in EXPECTED_UNKNOWN_REGIONS:
        assert region in unknown_regions, f"Expected {region} to be a known unknown"
    unexpected_unknown_regions = unknown_regions.difference(EXPECTED_UNKNOWN_REGIONS)
    assert unexpected_unknown_regions is not None
    assert len(unexpected_unknown_regions) == 0, (
        f"Expected no additional unidentified regions, found {unexpected_unknown_regions}"
    )
