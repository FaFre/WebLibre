#!/usr/bin/env python3
"""Merge per-feature ARB fragments into the single template ARB gen-l10n reads.

`flutter gen-l10n` only accepts one ARB file per locale, but this repo keeps
translatable strings feature-scoped (`lib/features/**/<feature>_en.arb`) to
match its feature-isolation convention. This script concatenates every
fragment into `lib/l10n/app_en.arb`, which is generated output — never
hand-edit it.

Translations live beside their English source as `<stem>_<locale>.arb`
(`tabs_de.arb` next to `tabs_en.arb`) and merge the same way into
`lib/l10n/app_<locale>.arb`. Only their messages are merged — descriptions and
placeholder types come from the English fragment, and the locale comes from
the file name (`@@locale` may be omitted, as Weblate does). A translation may lag
behind (gen-l10n falls back to English for missing keys), but it may not
contain keys the English fragment no longer has, and every placeholder and
`<tag>` of the English message must survive translation.

Also enforces the key convention: every key in `foo_bar_en.arb` is
`fooBar_<camelCaseName>`, so a key's owner is readable from its name. Metadata
may only describe keys that exist.

    python3 scripts/merge_l10n_arb.py          # write lib/l10n/app_en.arb
    python3 scripts/merge_l10n_arb.py --check  # fail if it is out of date
"""

import json
import re
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
APP_ROOT = REPO_ROOT / "apps" / "weblibre"
# Explicit per-directory globs, not a blanket `lib/**/*_en.arb` — that would
# also match the generated `lib/l10n/app_en.arb` output and try to merge it
# into itself.
FRAGMENT_GLOBS = [
    "lib/features/**/*_en.arb",
    "lib/utils/*_en.arb",
    "lib/core/**/*_en.arb",
    "lib/presentation/**/*_en.arb",
    "lib/domain/**/*_en.arb",
]
OUTPUT_DIR = APP_ROOT / "lib" / "l10n"
SOURCE_LOCALE = "en"
KEY_PATTERN = re.compile(r"[a-z][A-Za-z0-9]*_[a-z][A-Za-z0-9]*")
# `de`, `pt_BR`, `zh_Hant` — the suffix gen-l10n expects on `app_<locale>.arb`.
LOCALE_PATTERN = re.compile(r"[a-z]{2,3}(_(?:[A-Z]{2}|[A-Z][a-z]{3}))?")
TAG_PATTERN = re.compile(r"</?([A-Za-z][A-Za-z0-9]*)>")


def expected_prefix(path: Path) -> str:
    """`profile_copy_en.arb` -> `profileCopy`."""
    stem = path.name.removesuffix("_en.arb")
    head, *rest = stem.split("_")
    return head + "".join(part.capitalize() for part in rest)


def read_json(path: Path) -> dict:
    try:
        with path.open(encoding="utf-8") as f:
            return json.load(f)
    except json.JSONDecodeError as error:
        sys.exit(f"error: {path.relative_to(REPO_ROOT)} is not valid JSON: {error}")


def load_fragment(path: Path) -> dict:
    data = read_json(path)

    locale = data.get("@@locale")
    if locale is not None and locale != "en":
        sys.exit(
            f"error: {path.relative_to(REPO_ROOT)} declares @@locale "
            f"'{locale}', expected 'en' (fragments are the English source)"
        )

    for key in data:
        if key == "@@locale":
            continue
        if key.startswith("@"):
            if key[1:] not in data:
                sys.exit(
                    f"error: {path.relative_to(REPO_ROOT)} has metadata '{key}' "
                    f"but no '{key[1:]}' message"
                )
            continue
        if not KEY_PATTERN.fullmatch(key):
            sys.exit(
                f"error: {path.relative_to(REPO_ROOT)} key '{key}' does not match "
                "<prefix>_<camelCaseName>"
            )
        prefix = expected_prefix(path)
        if key.split("_", 1)[0] != prefix:
            sys.exit(
                f"error: {path.relative_to(REPO_ROOT)} key '{key}' must start "
                f"with '{prefix}_' — keys belong to the fragment they are named "
                "after"
            )

    return data


def find_translations(source_path: Path) -> dict[str, Path]:
    """Locale -> `<stem>_<locale>.arb` beside the English fragment."""
    stem = source_path.name.removesuffix("_en.arb")
    translations = {}
    for path in source_path.parent.glob(f"{stem}_*.arb"):
        locale = path.name.removeprefix(f"{stem}_").removesuffix(".arb")
        if locale != SOURCE_LOCALE and LOCALE_PATTERN.fullmatch(locale):
            translations[locale] = path
    return translations


def uses_placeholder(message: str, name: str) -> bool:
    return re.search(r"\{\s*" + re.escape(name) + r"\s*[,}]", message) is not None


def load_translation(path: Path, locale: str, source: dict) -> dict:
    """Messages of a translated fragment, checked against its English source."""
    data = read_json(path)
    rel = path.relative_to(REPO_ROOT)

    # The file name decides the locale. Weblate creates new translations from
    # the English fragment, which has no `@@locale`, so it may be missing —
    # but one that names another locale means the file is misnamed.
    declared = data.get("@@locale", locale)
    if declared != locale:
        sys.exit(
            f"error: {rel} declares \"@@locale\": {json.dumps(declared)}, "
            f"but its file name says '{locale}'"
        )

    messages = {}
    for key, value in data.items():
        if key.startswith("@"):
            # Metadata is the English fragment's job; tolerate what
            # translation tools copy over, but never merge it.
            continue
        if key not in source:
            sys.exit(
                f"error: {rel} translates '{key}', which its English fragment "
                "does not define — delete the stale key"
            )
        if not isinstance(value, str):
            sys.exit(f"error: {rel} key '{key}' is not a string")

        english = source[key]
        placeholders = source.get(f"@{key}", {}).get("placeholders", {})
        for name in placeholders:
            if uses_placeholder(english, name) != uses_placeholder(value, name):
                sys.exit(
                    f"error: {rel} key '{key}' must use placeholder '{{{name}}}' "
                    "exactly where the English message does"
                )
        if sorted(TAG_PATTERN.findall(english)) != sorted(TAG_PATTERN.findall(value)):
            sys.exit(
                f"error: {rel} key '{key}' must keep the English message's "
                "<tags> (they mark tap targets for localizedSpans)"
            )
        messages[key] = value

    return messages


def main() -> None:
    fragments = sorted(
        {path for pattern in FRAGMENT_GLOBS for path in APP_ROOT.glob(pattern)}
    )
    if not fragments:
        sys.exit(f"error: no ARB fragments found under {FRAGMENT_GLOBS}")

    merged: dict[str, object] = {"@@locale": "en"}
    contributed_by: dict[str, Path] = {}

    sources: dict[Path, dict] = {}

    for fragment_path in fragments:
        data = load_fragment(fragment_path)
        sources[fragment_path] = data

        for key, value in data.items():
            if key == "@@locale":
                continue

            # Metadata keys (`@keyName`) travel with their sibling message key;
            # a collision on the plain key already catches a metadata clash too.
            base_key = key[1:] if key.startswith("@") else key
            owner = contributed_by.get(base_key)
            if owner is not None and owner != fragment_path:
                sys.exit(
                    f"error: key '{base_key}' is defined in both "
                    f"{owner.relative_to(REPO_ROOT)} and "
                    f"{fragment_path.relative_to(REPO_ROOT)} — ARB keys must be "
                    "unique across every feature fragment"
                )
            contributed_by[base_key] = fragment_path
            merged[key] = value

    outputs: dict[str, dict[str, object]] = {SOURCE_LOCALE: merged}
    for fragment_path, source in sources.items():
        for locale, path in sorted(find_translations(fragment_path).items()):
            translated = load_translation(path, locale, source)
            outputs.setdefault(locale, {"@@locale": locale}).update(translated)

    stale = False
    for locale, data in sorted(outputs.items()):
        output_path = OUTPUT_DIR / f"app_{locale}.arb"
        output = json.dumps(data, indent=2, ensure_ascii=False) + "\n"
        rel = output_path.relative_to(REPO_ROOT)

        if "--check" in sys.argv[1:]:
            current = (
                output_path.read_text(encoding="utf-8") if output_path.exists() else ""
            )
            if current != output:
                print(f"error: {rel} is out of date", file=sys.stderr)
                stale = True
            continue

        output_path.parent.mkdir(parents=True, exist_ok=True)
        output_path.write_text(output, encoding="utf-8")
        messages = sum(not key.startswith("@") for key in data)
        summary = (
            f"{messages} keys"
            if locale == SOURCE_LOCALE
            else f"{messages} of {len(contributed_by)} keys translated"
        )
        print(f"Merged {rel} ({summary})")

    if stale:
        sys.exit("error: run `melos run build-l10n --no-select`")
    if "--check" in sys.argv[1:]:
        print("Merged ARB files are up to date")


if __name__ == "__main__":
    main()
