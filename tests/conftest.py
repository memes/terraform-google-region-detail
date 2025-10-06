"""Common testing fixtures."""

import json
import os
import pathlib
import subprocess
import tempfile
from collections.abc import Generator
from contextlib import contextmanager
from typing import Any

import pytest


@pytest.fixture(scope="session")
def root_fixture_dir() -> pathlib.Path:
    """Return the fully-qualified directory at the fixture to exercise the root module."""
    root_fixture_dir = pathlib.Path(__file__).parent.joinpath("fixtures/root").resolve()
    assert root_fixture_dir.exists()
    assert root_fixture_dir.is_dir()
    assert root_fixture_dir.joinpath("main.tf").exists()
    assert root_fixture_dir.joinpath("outputs.tf").exists()
    assert root_fixture_dir.joinpath("variables.tf").exists()
    return root_fixture_dir


def skip_destroy_phase() -> bool:
    """Determine if tofu destroy phase should be skipped for successful fixtures."""
    return os.getenv("TEST_SKIP_DESTROY_PHASE", "False").lower() in ["true", "t", "yes", "y", "1"]


@contextmanager
def run_tofu_in_workspace(
    fixture: pathlib.Path,
    workspace: str | None,
    tfvars: dict[str, Any] | None,
) -> Generator[dict[str, Any], None, None]:
    """Execute tofu init/apply/destroy lifecycle for a fixture in an optional workspace, yielding the output post-apply.

    NOTE: Resources will not be destroyed if the test case raises an error.
    """
    if tfvars is None:
        tfvars = {}
    tf_command = os.getenv("TEST_TF_COMMAND", "tofu")
    if workspace is not None and workspace != "":
        subprocess.run(
            [
                tf_command,
                f"-chdir={fixture!s}",
                "workspace",
                "select",
                "-or-create",
                workspace,
            ],
            check=True,
            capture_output=True,
        )
    subprocess.run(
        [
            tf_command,
            f"-chdir={fixture!s}",
            "init",
            "-no-color",
        ],
        check=True,
        capture_output=True,
    )
    with tempfile.NamedTemporaryFile(
        mode="w",
        prefix="tfvars",
        suffix=".json",
        encoding="utf-8",
        delete_on_close=False,
        delete=True,
    ) as tfvar_file:
        json.dump(tfvars, tfvar_file, ensure_ascii=False, indent=2)
        tfvar_file.close()
        subprocess.run(
            [
                tf_command,
                f"-chdir={fixture!s}",
                "apply",
                "-no-color",
                "-auto-approve",
                f"-var-file={tfvar_file.name}",
            ],
            check=True,
            capture_output=True,
        )
        output = subprocess.run(
            [
                tf_command,
                f"-chdir={fixture!s}",
                "output",
                "-no-color",
                "-json",
            ],
            check=True,
            capture_output=True,
        )
        try:
            yield {k: v["value"] for k, v in json.loads(output.stdout).items()}
            if not skip_destroy_phase():
                subprocess.run(
                    [
                        tf_command,
                        f"-chdir={fixture!s}",
                        "destroy",
                        "-no-color",
                        "-auto-approve",
                        f"-var-file={tfvar_file.name}",
                    ],
                    check=True,
                    capture_output=True,
                )
        finally:
            subprocess.run(
                [
                    tf_command,
                    f"-chdir={fixture!s}",
                    "workspace",
                    "select",
                    "default",
                ],
                check=True,
                capture_output=True,
            )
