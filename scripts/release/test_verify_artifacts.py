#!/usr/bin/env python3
"""Tests for the identity checks of verify_artifacts.py that need no SDK tools.

Run: python3 -m unittest discover -s scripts/release -p 'test_*.py'
"""

import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

import verify_artifacts as va  # noqa: E402

BADGING = (
    "package: name='eu.weblibre.gecko' versionCode='433' versionName='0.50.0' "
    "platformBuildVersionName='16' platformBuildVersionCode='36'\n"
    "sdkVersion:'26'\n"
    "targetSdkVersion:'36'\n"
    "native-code: 'arm64-v8a'\n"
)

BUNDLE_XML = (
    '<manifest xmlns:android="http://schemas.android.com/apk/res/android" '
    'package="eu.weblibre.gecko" android:versionCode="43" android:versionName="0.50.0">'
    "<application/></manifest>"
)


def manifest(package: str = "eu.weblibre.gecko", version_name: str = "0.50.0") -> dict:
    return {"packageId": package, "versionName": version_name}


class Checks(unittest.TestCase):
    def setUp(self) -> None:
        va.errors.clear()

    def check(self, package: str, version_name: str | None, recorded: dict, *, tag: str, track: str) -> list[str]:
        va.check_package_and_name("x.apk", package, version_name, recorded, tag=tag, track=track)
        return list(va.errors)

    def test_badging(self) -> None:
        info = va.parse_badging(BADGING)
        self.assertEqual(info["package"], "eu.weblibre.gecko")
        self.assertEqual(info["versionCode"], 433)
        self.assertEqual(info["versionName"], "0.50.0")
        self.assertEqual(info["minSdk"], 26)
        self.assertEqual(info["abis"], ["arm64-v8a"])

    def test_bundle_manifest(self) -> None:
        self.assertEqual(
            va.bundle_manifest(BUNDLE_XML),
            {"package": "eu.weblibre.gecko", "versionCode": 43, "versionName": "0.50.0"},
        )

    def test_stable_artifact_passes(self) -> None:
        self.assertEqual(self.check("eu.weblibre.gecko", "0.50.0", manifest(), tag="v0.50.0", track="stable"), [])

    def test_alpha_artifact_passes(self) -> None:
        recorded = manifest("eu.weblibre.gecko.alpha", "0.50.0-alpha-2-alpha")
        errors = self.check("eu.weblibre.gecko.alpha", "0.50.0-alpha-2-alpha", recorded, tag="v0.50.0-alpha-2", track="alpha")
        self.assertEqual(errors, [])

    def test_the_package_must_be_the_tracks(self) -> None:
        # Consistent with its own manifest, but the other track's package.
        errors = self.check(
            "eu.weblibre.gecko.alpha", "0.50.0", manifest("eu.weblibre.gecko.alpha"), tag="v0.50.0", track="stable"
        )
        self.assertEqual(len(errors), 2)

    def test_the_manifest_package_is_checked_on_its_own(self) -> None:
        errors = self.check("eu.weblibre.gecko", "0.50.0", manifest("eu.weblibre.other"), tag="v0.50.0", track="stable")
        self.assertEqual(len(errors), 1)
        self.assertIn("packageId", errors[0])

    def test_the_declared_version_name_must_be_the_tags(self) -> None:
        errors = self.check("eu.weblibre.gecko", "0.49.0", manifest(), tag="v0.50.0", track="stable")
        self.assertEqual(len(errors), 1)
        self.assertIn("versionName 0.49.0", errors[0])

    def test_a_missing_version_name_fails(self) -> None:
        self.assertEqual(len(self.check("eu.weblibre.gecko", None, manifest(), tag="v0.50.0", track="stable")), 1)

    def test_a_tag_prefix_is_not_enough(self) -> None:
        recorded = manifest("eu.weblibre.gecko.alpha", "0.50.0-alpha-12-alpha")
        errors = self.check(
            "eu.weblibre.gecko.alpha", "0.50.0-alpha-12-alpha", recorded, tag="v0.50.0-alpha-1", track="alpha"
        )
        self.assertEqual(len(errors), 2)


if __name__ == "__main__":
    unittest.main()
