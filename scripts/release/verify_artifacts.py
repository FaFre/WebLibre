#!/usr/bin/env python3
"""Verifies signed release artifacts and writes release.json.

plans/APP_UPDATER_IMPLEMENTATION_PLAN.md, 9.1 (`verify` job) and 9.3. Runs on
the artifacts as they will be published, after re-signing:

- every APK: signer equals the production fingerprint; package, version
  code, version name and native ABI from `aapt2 dump badging`; the embedded
  build manifest's identity matches the variant that was built and the tag;
- the bundle (stable only): package, version code and version name from
  bundletool, the base module's build manifest (`distribution == play`), its
  signer;
- the package is the track's (`eu.weblibre.gecko`, `.alpha`) and the version
  name is the tag's, both as the artifact declares them and in its build
  manifest;
- exactly six GitHub APKs (two renderers times three ABIs), plus a Play bundle
  for stable releases only; all artifacts agree on their component identities;
- isolation (9.3): no updater receiver or confirmation-free install
  permission in Play's manifest. The dex checks here (no Play Core in GitHub
  APKs, no installer or apksig in the Play bundle) only catch an unminified
  build: R8 renames what it keeps. The `build` job checks each variant's R8
  mapping, which lists the original name of every class left in it;
- release-note summaries within the limits of 5.2.

Then writes release.json for the updates repository, which reads it as data
only (9.2): the Play target there comes from the bundle, not from the tag.

Usage:
  verify_artifacts.py --tag v0.50.0 --apk-dir out/apks [--bundle out/app.aab]
      --build-tools $ANDROID_HOME/build-tools/37.0.0 [--bundletool bundletool.jar]
      --out release.json
"""

import argparse
import hashlib
import json
import re
import subprocess
import sys
import zipfile
import xml.etree.ElementTree as ET
from pathlib import Path

PRODUCTION_FINGERPRINT = (
    "8f526e1e53d6bd4dfbf4f4b93c2a91ecb5cb8da5e14ad94c2570e1e3c713527f"
)
REPO_DOWNLOAD = "https://github.com/FaFre/WebLibre/releases/download"
REPO_TAG = "https://github.com/FaFre/WebLibre/releases/tag"
ABI_DIGITS = {"x86_64": 1, "armeabi-v7a": 2, "arm64-v8a": 3}
# The catalogue the updates repository signs is per package (5.2).
PACKAGE_IDS = {"stable": "eu.weblibre.gecko", "alpha": "eu.weblibre.gecko.alpha"}
# Published names, unchanged by the distribution dimension (F4).
APK_NAME = re.compile(
    r"^app-(?P<flavor>stable|stableImpeller|alpha|alphaImpeller)-(?P<abi>x86_64|armeabi-v7a|arm64-v8a)-release\.apk$"
)
MANIFEST_ENTRY = "assets/weblibre/build_manifest.json"
ANDROID_NS = "http://schemas.android.com/apk/res/android"
SHIPPED_LANGUAGES = {"en", "de", "es", "id", "ru", "zh"}
MAX_SUMMARY_CHARS = 2000
MAX_SUMMARY_BYTES = 3 * 1024

errors: list[str] = []


def fail(message: str) -> None:
    errors.append(message)
    print(f"FAIL: {message}", file=sys.stderr)


def run(*args: str) -> str:
    return subprocess.run(args, check=True, capture_output=True, text=True).stdout


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            digest.update(chunk)
    return digest.hexdigest()


def dex_bytes(zip_path: Path, prefix: str = "") -> bytes:
    with zipfile.ZipFile(zip_path) as z:
        return b"".join(
            z.read(n) for n in z.namelist() if re.fullmatch(rf"{prefix}classes\d*\.dex", n)
        )


def apk_signers(apksigner: Path, apk: Path) -> list[str]:
    out = run(str(apksigner), "verify", "--print-certs", str(apk))
    return re.findall(r"certificate SHA-256 digest: ([0-9a-f]{64})", out)


def badging(aapt2: Path, apk: Path) -> dict:
    return parse_badging(run(str(aapt2), "dump", "badging", str(apk)))


def parse_badging(out: str) -> dict:
    package = re.search(r"package: name='([^']+)' versionCode='(\d+)'", out)
    name = re.search(r" versionName='([^']*)'", out)
    # Recent aapt2 versions call this minSdkVersion; older tools use sdkVersion.
    sdk = re.search(r"^(?:minSdkVersion|sdkVersion):\s*'(\d+)'", out, re.MULTILINE)
    abis = re.search(r"native-code: (.+)", out)
    if package is None:
        raise ValueError("aapt2 badging has no package name and numeric versionCode")
    if sdk is None:
        raise ValueError("aapt2 badging has no numeric minimum SDK (minSdkVersion or sdkVersion)")
    return {
        "package": package.group(1),
        "versionCode": int(package.group(2)),
        "versionName": name.group(1) if name else None,
        "minSdk": int(sdk.group(1)),
        "abis": sorted(re.findall(r"'([^']+)'", abis.group(1))) if abis else [],
    }


def expected_version_name(tag: str, track: str) -> str:
    # Exactly the tag's version plus the track's suffix: a prefix would let
    # alpha-1 accept alpha-12.
    return tag.removeprefix("v") + ("-alpha" if track == "alpha" else "")


def check_package_and_name(
    name: str, package: str, version_name: str | None, manifest: dict, *, tag: str, track: str
) -> None:
    """The package and version name, as the artifact declares them and as its
    build manifest records them, against what the tag and track mean."""
    expected_package = PACKAGE_IDS[track]
    if package != expected_package:
        fail(f"{name}: package {package}, expected {expected_package}")
    if manifest.get("packageId") != expected_package:
        fail(f"{name}: build manifest packageId {manifest.get('packageId')}, expected {expected_package}")
    expected_name = expected_version_name(tag, track)
    if version_name != expected_name:
        fail(f"{name}: versionName {version_name} is not {expected_name} ({tag})")
    if manifest.get("versionName") != expected_name:
        fail(f"{name}: build manifest versionName {manifest.get('versionName')} is not {expected_name} ({tag})")


def bundle_manifest(xml: str) -> dict:
    """Package, version code and version name from `bundletool dump manifest`."""
    root = ET.fromstring(xml)
    code = root.get(f"{{{ANDROID_NS}}}versionCode")
    return {
        "package": root.get("package"),
        "versionCode": int(code) if code and code.isdigit() else None,
        "versionName": root.get(f"{{{ANDROID_NS}}}versionName"),
    }


def check_identity(name: str, manifest: dict, expected: dict[str, str]) -> None:
    for key, value in expected.items():
        if manifest.get(key) != value:
            fail(f"{name}: build manifest {key}={manifest.get(key)}, expected {value}")


def check_artifact_set(apks: list[Path], track: str, bundle: Path | None) -> None:
    expected = {
        f"app-{track}{suffix}-{abi}-release.apk"
        for suffix in ("", "Impeller")
        for abi in ABI_DIGITS
    }
    actual = {apk.name for apk in apks}
    if missing := expected - actual:
        fail(f"missing APKs: {', '.join(sorted(missing))}")
    if unexpected := actual - expected:
        fail(f"unexpected APKs: {', '.join(sorted(unexpected))}")

    if track == "stable":
        if bundle is None:
            fail("stable releases require a Play bundle (--bundle)")
        elif not bundle.is_file():
            fail(f"Play bundle does not exist: {bundle}")
    elif bundle is not None:
        fail("bundle: given for an alpha release")


def check_components(name: str, actual: dict, expected: dict | None) -> dict:
    # release.json has one shared component map, so no target may silently
    # inherit the identities of a different build. An empty map still counts.
    if expected is None:
        return actual
    if actual != expected:
        fail(f"{name}: build manifest components differ from the other release artifacts")
    return expected


def read_manifest(zip_path: Path, entry: str) -> dict:
    with zipfile.ZipFile(zip_path) as z:
        return json.loads(z.read(entry))


def summaries(notes_dir: Path) -> dict[str, str]:
    result = {}
    for file in sorted(notes_dir.glob("summary.*.md")):
        locale = file.name.removeprefix("summary.").removesuffix(".md")
        text = file.read_text(encoding="utf-8").strip()
        if locale not in SHIPPED_LANGUAGES:
            fail(f"{file}: {locale} is not a shipped language")
            continue
        # The app counts UTF-16 code units, as Dart's String.length does.
        chars = len(text.encode("utf-16-le")) // 2
        if chars > MAX_SUMMARY_CHARS or len(text.encode()) > MAX_SUMMARY_BYTES:
            fail(f"{file}: over {MAX_SUMMARY_CHARS} characters or {MAX_SUMMARY_BYTES} bytes")
            continue
        result[locale] = text
    if result and "en" not in result:
        fail(f"{notes_dir}: summaries need an en version")
    return result


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--tag", required=True)
    # The workflow's build type, so the two never disagree.
    parser.add_argument("--prerelease", required=True, choices=["true", "false"])
    parser.add_argument("--apk-dir", required=True, type=Path)
    parser.add_argument("--bundle", type=Path)
    parser.add_argument("--build-tools", required=True, type=Path)
    parser.add_argument("--bundletool", type=Path)
    parser.add_argument("--notes-dir", type=Path)
    parser.add_argument("--out", required=True, type=Path)
    args = parser.parse_args()

    tag = args.tag
    app_version = tag.removeprefix("v")
    prerelease = args.prerelease == "true"
    track = "alpha" if prerelease else "stable"
    apksigner = args.build_tools / "apksigner"
    aapt2 = args.build_tools / "aapt2"

    targets = []
    components = None
    sequence = None

    apks = sorted(args.apk_dir.glob("*.apk"))
    check_artifact_set(apks, track, args.bundle)
    if errors:
        print(f"{len(errors)} check(s) failed", file=sys.stderr)
        return 1
    for apk in apks:
        match = APK_NAME.match(apk.name)
        if not match:
            fail(f"{apk.name}: not a published APK name")
            continue
        flavor, abi = match.group("flavor"), match.group("abi")
        renderer = "impeller" if flavor.endswith("Impeller") else "skia"
        if not flavor.startswith(track):
            fail(f"{apk.name}: {flavor} APK in a {track} release")

        signers = apk_signers(apksigner, apk)
        if signers != [PRODUCTION_FINGERPRINT]:
            fail(f"{apk.name}: signed by {signers}, expected the production certificate")

        try:
            info = badging(aapt2, apk)
        except ValueError as error:
            fail(f"{apk.name}: {error}")
            continue
        manifest = read_manifest(apk, MANIFEST_ENTRY)
        check_identity(apk.name, manifest, {"distribution": "github", "track": track, "renderer": renderer})
        seq = manifest["logicalReleaseSequence"]
        if info["versionCode"] != seq * 10 + ABI_DIGITS[abi]:
            fail(f"{apk.name}: versionCode {info['versionCode']} != {seq}*10+{ABI_DIGITS[abi]}")
        if info["abis"] != [abi]:
            fail(f"{apk.name}: native code {info['abis']}, expected {abi}")
        check_package_and_name(
            apk.name, info["package"], info["versionName"], manifest, tag=tag, track=track
        )
        if b"Lcom/google/android/play/core/appupdate/" in dex_bytes(apk):
            fail(f"{apk.name}: GitHub APK contains Play Core")

        if sequence is not None and seq != sequence:
            fail(f"{apk.name}: release sequence {seq} differs from {sequence}")
        sequence = seq
        components = check_components(apk.name, manifest["components"], components)

        targets.append({
            "id": f"{tag}/github/{track}/{renderer}/{abi}",
            "distribution": "github",
            "track": track,
            "renderer": renderer,
            "abi": abi,
            "versionCode": info["versionCode"],
            "minSdk": info["minSdk"],
            "artifact": {
                "url": f"{REPO_DOWNLOAD}/{tag}/{apk.name}",
                "byteLength": apk.stat().st_size,
                "sha256": sha256(apk),
            },
        })

    if args.bundle:
        if not args.bundletool:
            fail("--bundle needs --bundletool")
        elif prerelease:
            # Play gets stable releases only (9.1).
            fail("bundle: given for an alpha release")
        else:
            xml = run("java", "-jar", str(args.bundletool), "dump", "manifest", "--bundle", str(args.bundle))
            declared = bundle_manifest(xml)
            code = declared["versionCode"]
            manifest = read_manifest(args.bundle, f"base/{MANIFEST_ENTRY}")
            check_identity("bundle", manifest, {"distribution": "play", "track": "stable", "renderer": "skia"})
            check_package_and_name(
                "bundle", declared["package"], declared["versionName"], manifest, tag=tag, track="stable"
            )
            if code != manifest["logicalReleaseSequence"]:
                fail(f"bundle: versionCode {code} != sequence {manifest['logicalReleaseSequence']}")
            if sequence is not None and code != sequence:
                fail(f"bundle: sequence {code} differs from the APKs' {sequence}")
            components = check_components("bundle", manifest["components"], components)
            for forbidden in ("UPDATE_PACKAGES_WITHOUT_USER_ACTION", "InstallStatusReceiver"):
                if forbidden in xml:
                    fail(f"bundle: manifest contains {forbidden}")
            dex = dex_bytes(args.bundle, "base/dex/")
            for forbidden in (b"Lcom/android/apksig/", b"Leu/weblibre/gecko/update/SessionInstaller;"):
                if forbidden in dex:
                    fail(f"bundle: dex contains {forbidden.decode()}")
            certs = run("keytool", "-printcert", "-jarfile", str(args.bundle))
            fingerprints = [f.replace(":", "").lower() for f in re.findall(r"SHA256: ([0-9A-F:]+)", certs)]
            if fingerprints != [PRODUCTION_FINGERPRINT]:
                fail(f"bundle: signed by {fingerprints}")
            targets.append({
                "id": f"{tag}/play/stable/skia",
                "distribution": "play",
                "track": "stable",
                "renderer": "skia",
                "versionCode": code,
                "minSdk": targets[0]["minSdk"] if targets else 26,
            })

    notes = {"url": f"{REPO_TAG}/{tag}"}
    if args.notes_dir and args.notes_dir.is_dir():
        summary = summaries(args.notes_dir)
        if summary:
            notes["summary"] = summary

    if errors:
        print(f"{len(errors)} check(s) failed", file=sys.stderr)
        return 1

    release = {
        "schemaVersion": 1,
        "packageId": PACKAGE_IDS[track],
        "releaseId": tag,
        "appVersion": app_version,
        "logicalReleaseSequence": sequence,
        "prerelease": prerelease,
        "targets": targets,
        "components": components,
        "releaseNotes": notes,
    }
    args.out.write_text(json.dumps(release, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print(f"wrote {args.out} with {len(targets)} targets")
    return 0


if __name__ == "__main__":
    sys.exit(main())
