#!/usr/bin/env python3
"""Fails unless the tag's pubspec build number is greater than every earlier tag's.

plans/APP_UPDATER_IMPLEMENTATION_PLAN.md, D4: the build number (`+N`) rises on
every published tag, alphas included, because the updater orders releases by
it and never installs an equal version code.

"Earlier" is every tag created before this one, on any branch, and every tag
on its history: the version code orders releases across branches, so a tag on
a hotfix or release branch counts as much as one on main. Tags created after
this one are left out, so re-running an old tag's build still passes.

The tag checked must be annotated (`git tag -a`). A lightweight tag carries no
creation time: git reports its commit's date, and a maintenance tag on an old
commit would then sort before releases published long before it and pass
with a lower build number. Earlier tags may be lightweight: their commit date
is never later than when they were tagged, so they are never left out.

Usage: check_build_number.py <tag>
"""

import re
import subprocess
import sys

PUBSPEC = "apps/weblibre/pubspec.yaml"
VERSION = re.compile(r"^version:\s*\S+\+(\d+)\s*$", re.MULTILINE)


def git(*args: str) -> str:
    return subprocess.run(["git", *args], check=True, capture_output=True, text=True).stdout


def build_number(ref: str) -> int | None:
    try:
        text = git("show", f"{ref}:{PUBSPEC}")
    except subprocess.CalledProcessError:
        return None
    match = VERSION.search(text)
    return int(match.group(1)) if match else None


def is_annotated(tag: str) -> bool:
    return git("cat-file", "-t", f"refs/tags/{tag}").strip() == "tag"


def earlier_tags(tag: str) -> set[str]:
    # creatordate: the tagger date of an annotated tag, the commit date of a
    # lightweight one.
    created = {}
    for line in git(
        "for-each-ref", "--format=%(refname:short) %(creatordate:unix)", "refs/tags/v*"
    ).splitlines():
        name, _, stamp = line.rpartition(" ")
        created[name] = int(stamp)
    if tag not in created:
        raise SystemExit(f"{tag}: not a tag")
    before = {t for t, stamp in created.items() if stamp < created[tag]}
    ancestors = set(git("tag", "--list", "v*", "--merged", f"{tag}^").split())
    return (before | ancestors) - {tag}


def main() -> int:
    if len(sys.argv) != 2:
        print(__doc__, file=sys.stderr)
        return 2
    tag = sys.argv[1]
    if not is_annotated(tag):
        print(
            f"{tag}: a lightweight tag has no creation time to order it among published "
            f"tags. Tag with: git tag -a {tag} -m {tag}",
            file=sys.stderr,
        )
        return 1
    current = build_number(tag)
    if current is None:
        print(f"{tag}: no build number in {PUBSPEC}", file=sys.stderr)
        return 1

    numbers = {t: n for t in sorted(earlier_tags(tag)) if (n := build_number(t)) is not None}
    if not numbers:
        print(f"{tag}: +{current} (no earlier tags)")
        return 0

    highest_tag = max(numbers, key=numbers.__getitem__)
    highest = numbers[highest_tag]
    if current <= highest:
        print(
            f"{tag}: build number +{current} is not greater than +{highest} of {highest_tag}. "
            "Every tag needs a higher build number (D4).",
            file=sys.stderr,
        )
        return 1
    print(f"{tag}: +{current} > +{highest} ({highest_tag})")
    return 0


if __name__ == "__main__":
    sys.exit(main())
