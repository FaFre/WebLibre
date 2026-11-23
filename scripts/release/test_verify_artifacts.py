#!/usr/bin/env python3
"""Tests for the identity checks of verify_artifacts.py that need no SDK tools.

Run: python3 -m unittest discover -s scripts/release -p 'test_*.py'
"""

import contextlib
import io
import json
import sys
import tempfile
import unittest
import zipfile
from pathlib import Path
from unittest.mock import patch

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

    def test_badging_min_sdk_version(self) -> None:
        # Recent aapt2 versions renamed sdkVersion to minSdkVersion.
        output = BADGING.replace("sdkVersion:'26'", "minSdkVersion:'26'")
        self.assertEqual(va.parse_badging(output), va.parse_badging(BADGING))

    def test_badging_requires_a_minimum_sdk(self) -> None:
        # targetSdkVersion must never stand in for a missing minimum SDK.
        output = BADGING.replace("sdkVersion:'26'\n", "")
        with self.assertRaisesRegex(ValueError, "minimum SDK"):
            va.parse_badging(output)

    def test_badging_requires_a_numeric_minimum_sdk(self) -> None:
        for label in ("sdkVersion", "minSdkVersion"):
            with self.subTest(label=label):
                output = BADGING.replace("sdkVersion:'26'", f"{label}:'Preview'")
                with self.assertRaisesRegex(ValueError, "minimum SDK"):
                    va.parse_badging(output)

    def test_badging_requires_a_package(self) -> None:
        output = "\n".join(BADGING.splitlines()[1:])
        with self.assertRaisesRegex(ValueError, "package"):
            va.parse_badging(output)

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


class ReleaseVerification(unittest.TestCase):
    """Exercise the full verifier with real ZIP fixtures and mocked SDK tools."""

    def setUp(self) -> None:
        directory = tempfile.TemporaryDirectory()
        self.addCleanup(directory.cleanup)
        self.root = Path(directory.name)
        self.apks = self.root / "apks"
        self.apks.mkdir()
        self.out = self.root / "release.json"
        self.bundle = None
        self.prerelease = True
        self.minimum_sdk = "26"
        self.components = {
            "gecko": {"status": "known", "version": "159.0", "buildId": "20261030161337"},
            "androidComponents": {"status": "known", "version": "159.0"},
            "applicationServices": {"status": "known", "version": "147.0"},
            "tor": {"status": "known", "version": "0.4.8.21"},
            "singbox": {"status": "known", "version": "1.13.0", "revision": "a" * 40},
        }
        va.errors.clear()

    def write_manifest(self, path: Path, recorded: dict, *, bundle: bool = False) -> None:
        prefix = "base/" if bundle else ""
        with zipfile.ZipFile(path, "w") as archive:
            archive.writestr(prefix + va.MANIFEST_ENTRY, json.dumps(recorded))
            archive.writestr("base/dex/classes.dex" if bundle else "classes.dex", b"fixture dex")

    def create_release(self, *, prerelease: bool = True) -> None:
        self.prerelease = prerelease
        self.track = "alpha" if prerelease else "stable"
        self.tag = "v0.50.0-alpha-4" if prerelease else "v0.50.0"
        version = self.tag.removeprefix("v") + ("-alpha" if prerelease else "")
        recorded = {
            "packageId": va.PACKAGE_IDS[self.track],
            "versionName": version,
            "logicalReleaseSequence": 44,
            "components": self.components,
            "track": self.track,
            "distribution": "github",
        }
        for renderer in ("skia", "impeller"):
            flavor = self.track + ("Impeller" if renderer == "impeller" else "")
            for abi in ("armeabi-v7a", "arm64-v8a", "x86_64"):
                self.write_manifest(
                    self.apks / f"app-{flavor}-{abi}-release.apk",
                    {**recorded, "renderer": renderer},
                )
        if not prerelease:
            self.bundle = self.root / "app-stable-release.aab"
            self.write_manifest(
                self.bundle, {**recorded, "distribution": "play", "renderer": "skia"}, bundle=True
            )

    def tool_output(self, *args: str) -> str:
        if Path(args[0]).name == "apksigner":
            return f"Signer #1 certificate SHA-256 digest: {va.PRODUCTION_FINGERPRINT}\n"
        if Path(args[0]).name == "aapt2":
            apk = Path(args[-1])
            recorded = va.read_manifest(apk, va.MANIFEST_ENTRY)
            abi = va.APK_NAME.fullmatch(apk.name).group("abi")
            code = recorded["logicalReleaseSequence"] * 10 + va.ABI_DIGITS[abi]
            sdk = f"minSdkVersion:'{self.minimum_sdk}'\n" if self.minimum_sdk is not None else ""
            return (
                f"package: name='{recorded['packageId']}' versionCode='{code}' "
                f"versionName='{recorded['versionName']}'\n"
                f"{sdk}targetSdkVersion:'37'\nnative-code: '{abi}'\n"
            )
        if args[0] == "java":
            recorded = va.read_manifest(Path(args[-1]), "base/" + va.MANIFEST_ENTRY)
            return (
                f'<manifest xmlns:android="{va.ANDROID_NS}" package="{recorded["packageId"]}" '
                f'android:versionCode="{recorded["logicalReleaseSequence"]}" '
                f'android:versionName="{recorded["versionName"]}"><application/></manifest>'
            )
        if args[0] == "keytool":
            fingerprint = ":".join(
                va.PRODUCTION_FINGERPRINT[i:i + 2].upper()
                for i in range(0, len(va.PRODUCTION_FINGERPRINT), 2)
            )
            return f"SHA256: {fingerprint}\n"
        raise AssertionError(f"unexpected tool invocation: {args}")

    def verify(self) -> int:
        argv = [
            "verify_artifacts.py", "--tag", self.tag,
            "--prerelease", str(self.prerelease).lower(),
            "--apk-dir", str(self.apks), "--build-tools", str(self.root),
            "--out", str(self.out),
        ]
        if self.bundle is not None:
            argv += ["--bundle", str(self.bundle), "--bundletool", str(self.root / "bundletool.jar")]
        va.errors.clear()
        with (
            patch.object(sys, "argv", argv),
            patch.object(va, "run", side_effect=self.tool_output),
            contextlib.redirect_stdout(io.StringIO()),
            contextlib.redirect_stderr(io.StringIO()),
        ):
            return va.main()

    def assert_rejected(self, message: str) -> None:
        self.assertEqual(self.verify(), 1)
        self.assertFalse(self.out.exists())
        self.assertTrue(any(message in error for error in va.errors), va.errors)

    def test_complete_alpha_release(self) -> None:
        self.create_release()
        self.assertEqual(self.verify(), 0, va.errors)
        release = json.loads(self.out.read_text())
        self.assertEqual(len(release["targets"]), 6)
        self.assertEqual(release["components"], self.components)
        self.assertEqual({target["minSdk"] for target in release["targets"]}, {26})
        self.assertEqual({target["distribution"] for target in release["targets"]}, {"github"})

    def test_complete_stable_release(self) -> None:
        self.create_release(prerelease=False)
        self.assertEqual(self.verify(), 0, va.errors)
        release = json.loads(self.out.read_text())
        self.assertEqual(len(release["targets"]), 7)
        self.assertEqual(release["targets"][-1]["distribution"], "play")
        self.assertEqual(release["targets"][-1]["versionCode"], 44)

    def test_every_apk_is_required(self) -> None:
        self.create_release()
        names = sorted(path.name for path in self.apks.glob("*.apk"))
        for name in names:
            with self.subTest(name=name):
                self.create_release()
                (self.apks / name).unlink()
                self.assert_rejected(f"missing APKs: {name}")

    def test_a_single_apk_is_not_a_complete_release(self) -> None:
        self.create_release()
        for apk in sorted(self.apks.glob("*.apk"))[1:]:
            apk.unlink()
        self.assert_rejected("missing APKs:")

    def test_every_stable_apk_is_required(self) -> None:
        self.create_release(prerelease=False)
        names = sorted(path.name for path in self.apks.glob("*.apk"))
        for name in names:
            with self.subTest(name=name):
                self.create_release(prerelease=False)
                (self.apks / name).unlink()
                self.assert_rejected(f"missing APKs: {name}")

    def test_empty_apk_directory(self) -> None:
        self.create_release()
        for apk in self.apks.glob("*.apk"):
            apk.unlink()
        self.assert_rejected("missing APKs:")

    def test_unexpected_apk(self) -> None:
        self.create_release()
        (self.apks / "app-universal-release.apk").touch()
        self.assert_rejected("unexpected APKs: app-universal-release.apk")

    def test_wrong_track_apk(self) -> None:
        self.create_release()
        (self.apks / "app-stable-arm64-v8a-release.apk").touch()
        self.assert_rejected("unexpected APKs: app-stable-arm64-v8a-release.apk")

    def test_stable_requires_a_bundle_argument(self) -> None:
        self.create_release(prerelease=False)
        self.bundle = None
        self.assert_rejected("stable releases require a Play bundle")

    def test_stable_requires_the_bundle_file(self) -> None:
        self.create_release(prerelease=False)
        self.bundle.unlink()
        self.assert_rejected("Play bundle does not exist")

    def test_alpha_rejects_a_bundle(self) -> None:
        self.create_release()
        self.bundle = self.root / "app-stable-release.aab"
        self.bundle.touch()
        self.assert_rejected("bundle: given for an alpha release")

    def test_apk_components_must_match(self) -> None:
        self.create_release()
        apk = sorted(self.apks.glob("*.apk"))[-1]
        recorded = va.read_manifest(apk, va.MANIFEST_ENTRY)
        recorded["components"]["gecko"]["version"] = "158.0"
        self.write_manifest(apk, recorded)
        self.assert_rejected("components differ")

    def test_bundle_components_must_match_the_apks(self) -> None:
        self.create_release(prerelease=False)
        recorded = va.read_manifest(self.bundle, "base/" + va.MANIFEST_ENTRY)
        recorded["components"]["gecko"]["version"] = "158.0"
        self.write_manifest(self.bundle, recorded, bundle=True)
        self.assert_rejected("components differ")

    def test_an_unidentified_component_blocks_the_release(self) -> None:
        self.components["singbox"] = {"status": "unknown"}
        self.create_release()
        self.assert_rejected("component singbox is not identified")

    def test_an_unidentified_component_is_reported_once(self) -> None:
        self.components["singbox"] = {"status": "unknown"}
        self.create_release()
        self.assert_rejected("component singbox is not identified")
        self.assertEqual(
            sum("component singbox is not identified" in error for error in va.errors), 1
        )

    def test_a_missing_component_blocks_the_release(self) -> None:
        del self.components["tor"]
        self.create_release()
        self.assert_rejected("component tor is missing")

    def test_a_known_component_needs_a_version(self) -> None:
        self.components["singbox"] = {"status": "known", "version": ""}
        self.create_release()
        self.assert_rejected("component singbox is not identified")

    def test_a_component_that_is_not_bundled_is_identified(self) -> None:
        self.components["tor"] = {"status": "notBundled"}
        self.create_release()
        self.assertEqual(self.verify(), 0, va.errors)

    def test_empty_components_do_not_skip_consistency_checks(self) -> None:
        self.create_release()
        apk = sorted(self.apks.glob("*.apk"))[0]
        recorded = va.read_manifest(apk, va.MANIFEST_ENTRY)
        recorded["components"] = {}
        self.write_manifest(apk, recorded)
        self.assert_rejected("components differ")

    def test_invalid_badging_prevents_release_metadata(self) -> None:
        self.create_release()
        self.minimum_sdk = None
        self.assert_rejected("minimum SDK")


if __name__ == "__main__":
    unittest.main()
