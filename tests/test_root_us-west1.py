"""Test fixture for us-west1."""

import ipaddress
import pathlib
from collections import Counter
from collections.abc import Generator
from typing import Any

import pytest

from .conftest import run_tofu_in_workspace

FIXTURE_NAME = "us-west1"
REGIONS = [
    "us-west1",
]
EXPECTED_FIXED_RESULTS = {
    "us-west1": {
        "abbreviation": "us-we1",
        "display_name": "The Dalles, Oregon",
        "latitude": 45.609235,
        "longitude": -121.205447,
    },
}


@pytest.fixture(scope="module")
def fixture_output(
    root_fixture_dir: pathlib.Path,
) -> Generator[dict[str, Any], None, None]:
    """Create fixture for test case."""
    with run_tofu_in_workspace(
        fixture=root_fixture_dir,
        workspace=FIXTURE_NAME,
        tfvars={
            "regions": REGIONS,
        },
    ) as output:
        yield output


def test_output_values(fixture_output: dict[str, Any]) -> None:
    """Verify the fixture output meets expectations."""
    assert fixture_output
    results = fixture_output["results"]
    assert results is not None
    assert Counter(results.keys()) == Counter(REGIONS)
    for region, values in EXPECTED_FIXED_RESULTS.items():
        actual_values = results[region]
        assert actual_values is not None
        assert all(item in actual_values.items() for item in values.items())
        ipv4_cidrs = actual_values["ipv4"]
        assert len(ipv4_cidrs) > 0
        assert ipv4_cidrs is not None
        for cidr in ipv4_cidrs:
            assert ipaddress.IPv4Network(cidr)
        ipv6_cidrs = actual_values["ipv6"]
        assert ipv6_cidrs is not None
        assert len(ipv6_cidrs) > 0
        for cidr in ipv6_cidrs:
            assert ipaddress.IPv6Network(cidr)
