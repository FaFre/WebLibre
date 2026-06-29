#!/usr/bin/env python3
"""Build a SQLite database of popular websites for omnibar autocomplete.

Source of truth is the Tranco top-1M ranking (manipulation-resistant aggregate
of Umbrella/Majestic/Cloudflare/Farsight). Tranco ranks *domains by traffic*,
not "sites a human would open", so the head is polluted with adult/gambling
sites, ad/tracker endpoints and pure CDN/infra domains. We filter those out
using:

  * StevenBlack "gambling-porn-only" hosts  -> adult + gambling
  * Disconnect services.json (Advertising / Analytics / FingerprintingInvasive
    / Cryptomining categories only -- NOT Social/Content, which contain
    first-party sites people actually visit) -> ad/tracker/fingerprint domains
  * a small static denylist of well-known CDN / cloud / API registrable
    domains that the tracker lists don't classify

The survivors (first --limit by rank) are written to a single read-only table
consumed as a bundled asset, mirroring scripts/build_quotes_db.py.

Raw inputs are produced by `scripts/update-assets.sh --group popular-sites`.
"""

import argparse
import io
import json
import sqlite3
import zipfile
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
RAW_DIR = REPO_ROOT / "apps" / "weblibre" / "assets" / "sites" / "raw"
DEFAULT_TRANCO = RAW_DIR / "tranco-top-1m.csv.zip"
DEFAULT_BLOCKLIST = RAW_DIR / "stevenblack-gambling-porn.txt"
DEFAULT_DISCONNECT = RAW_DIR / "disconnect-services.json"
DEFAULT_OUTPUT = REPO_ROOT / "apps" / "weblibre" / "assets" / "sites" / "sites.db"
DEFAULT_TABLE = "sites"

# How many top-ranked Tranco domains to consider before filtering. Filtering
# removes a sizeable chunk of the head, so we scan well past --limit to still
# fill the quota with genuinely popular sites.
DEFAULT_SCAN_LIMIT = 250_000
# Final number of clean domains to keep.
DEFAULT_LIMIT = 25_000

# Disconnect categories to treat as noise. Social/Content/Email are excluded on
# purpose: they list first-party destinations (facebook.com, twitter.com, ...)
# that users legitimately want autocompleted.
DISCONNECT_BLOCK_CATEGORIES = (
    "Advertising",
    "Analytics",
    "FingerprintingInvasive",
    "Cryptomining",
)

# Pure CDN / cloud / DNS / registrar / API registrable domains that the tracker
# lists generally don't flag but which are never a navigation target. The
# Disconnect list is great for *trackers* but does not enumerate this infra
# (verified: gtld-servers.net, domaincontrol.com, googletagmanager.com,
# appsflyersdk.com aren't in it at all; googlevideo.com is only under the
# Content category we keep). Kept deliberately famous; the `cdn`-substring rule
# below sweeps the generic-CDN long tail.
STATIC_INFRA_DENYLIST = frozenset(
    {
        # CDN / cloud edge
        "fbcdn.net",
        "gstatic.com",
        "googleusercontent.com",
        "ggpht.com",
        "googleapis.com",
        "googlevideo.com",
        "gvt1.com",
        "gvt2.com",
        "akamai.net",
        "akamaihd.net",
        "akamaiedge.net",
        "akamaized.net",
        "akadns.net",
        "edgekey.net",
        "edgesuite.net",
        "cloudfront.net",
        "amazonaws.com",
        "azureedge.net",
        "windows.net",
        "trafficmanager.net",
        "fastly.net",
        "fastlylb.net",
        "llnwd.net",
        "stackpathdns.com",
        "aaplimg.com",
        "apple-dns.net",
        # DNS / registry / registrar infra
        "gtld-servers.net",
        "nstld.com",
        "domaincontrol.com",
        "ripn.net",
        # App SDK / measurement endpoints Disconnect misses
        "app-measurement.com",
        "googletagmanager.com",
        "appsflyersdk.com",
        # Device / IoT cloud phone-home (high DNS volume, not navigable)
        "ezviz7.com",
        "hicloudcam.com",
        "whatsapp.net",
    }
)

# Drop any registrable domain containing this token. Verified against the kept
# set: every match is a CDN backend (tiktokcdn, alicdn, spotifycdn, licdn,
# b-cdn, ...) with no first-party site among them, so a plain substring test is
# safe and avoids a broad multi-pattern infra regex.
INFRA_SUBSTRINGS = ("cdn",)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Build a SQLite popular-sites database from a Tranco list."
    )
    parser.add_argument("--tranco", default=str(DEFAULT_TRANCO))
    parser.add_argument("--blocklist", default=str(DEFAULT_BLOCKLIST))
    parser.add_argument("--disconnect", default=str(DEFAULT_DISCONNECT))
    parser.add_argument("--output", default=str(DEFAULT_OUTPUT))
    parser.add_argument("--table", default=DEFAULT_TABLE)
    parser.add_argument("--scan-limit", type=int, default=DEFAULT_SCAN_LIMIT)
    parser.add_argument("--limit", type=int, default=DEFAULT_LIMIT)
    return parser.parse_args()


def load_tranco(path: Path, scan_limit: int) -> list[tuple[int, str]]:
    """Return [(rank, domain)] for the first `scan_limit` Tranco rows.

    Accepts either the raw `rank,domain` CSV or the `.zip` it ships in.
    """
    if path.suffix == ".zip":
        with zipfile.ZipFile(path) as archive:
            csv_name = next(n for n in archive.namelist() if n.endswith(".csv"))
            raw = archive.read(csv_name)
        handle = io.TextIOWrapper(io.BytesIO(raw), encoding="utf-8")
    else:
        handle = path.open("r", encoding="utf-8")

    rows: list[tuple[int, str]] = []
    with handle:
        for line in handle:
            line = line.strip()
            if not line:
                continue
            rank_str, _, domain = line.partition(",")
            domain = domain.strip().lower()
            if not domain:
                continue
            try:
                rank = int(rank_str)
            except ValueError:
                continue
            rows.append((rank, domain))
            if len(rows) >= scan_limit:
                break
    return rows


def load_hosts_domains(path: Path) -> set[str]:
    """Parse a hosts-format file (`0.0.0.0 domain`) into a domain set."""
    domains: set[str] = set()
    with path.open("r", encoding="utf-8") as handle:
        for line in handle:
            line = line.strip()
            if not line or line.startswith("#"):
                continue
            parts = line.split()
            if len(parts) < 2:
                continue
            domain = parts[1].strip().lower()
            if domain and domain not in ("localhost", "localhost.localdomain"):
                domains.add(domain)
    return domains


def load_disconnect_domains(path: Path, categories: tuple[str, ...]) -> set[str]:
    """Collect tracker domains from the selected Disconnect categories.

    Structure: categories -> [ {Company: {homepage_url: [domain, ...]}}, ... ].
    Non-list property values (metadata flags) are skipped.
    """
    with path.open("r", encoding="utf-8") as handle:
        payload = json.load(handle)

    domains: set[str] = set()
    all_categories = payload.get("categories", {})
    for category in categories:
        for entry in all_categories.get(category, []):
            if not isinstance(entry, dict):
                continue
            for company_props in entry.values():
                if not isinstance(company_props, dict):
                    continue
                for value in company_props.values():
                    if isinstance(value, list):
                        domains.update(d.strip().lower() for d in value if d)
    return domains


def build_denylist(
    blocklist_path: Path, disconnect_path: Path
) -> set[str]:
    deny = set(STATIC_INFRA_DENYLIST)
    deny |= load_hosts_domains(blocklist_path)
    deny |= load_disconnect_domains(disconnect_path, DISCONNECT_BLOCK_CATEGORIES)
    return deny


def filter_domains(
    tranco: list[tuple[int, str]], deny: set[str], limit: int
) -> tuple[list[tuple[str, int]], int]:
    """Keep ranked domains not in the denylist, up to `limit`.

    Re-ranks survivors densely (1..N) so the stored rank is a contiguous
    popularity order for `ORDER BY rank` queries. Returns `(kept, scanned)`
    where `scanned` is how many Tranco rows were consumed to fill the quota,
    so the caller can report the real drop rate within the scanned head.
    """
    kept: list[tuple[str, int]] = []
    new_rank = 0
    scanned = 0
    for _, domain in tranco:
        scanned += 1
        if domain in deny:
            continue
        if any(token in domain for token in INFRA_SUBSTRINGS):
            continue
        new_rank += 1
        kept.append((domain, new_rank))
        if len(kept) >= limit:
            break
    return kept, scanned


def quote_identifier(name: str) -> str:
    return '"' + name.replace('"', '""') + '"'


def build_database(
    db_path: Path, table_name: str, rows: list[tuple[str, int]]
) -> None:
    db_path.parent.mkdir(parents=True, exist_ok=True)
    table = quote_identifier(table_name)

    connection = sqlite3.connect(db_path)
    try:
        cursor = connection.cursor()
        cursor.execute(f"DROP TABLE IF EXISTS {table}")
        cursor.execute(
            f"""
            CREATE TABLE {table} (
                domain TEXT NOT NULL PRIMARY KEY,
                rank INTEGER NOT NULL
            )
            """
        )
        cursor.executemany(
            f"INSERT OR IGNORE INTO {table} (domain, rank) VALUES (?, ?)",
            rows,
        )
        connection.commit()
        cursor.execute("VACUUM")
    finally:
        connection.close()


def main() -> None:
    args = parse_args()

    tranco_path = Path(args.tranco).expanduser().resolve()
    blocklist_path = Path(args.blocklist).expanduser().resolve()
    disconnect_path = Path(args.disconnect).expanduser().resolve()
    db_path = Path(args.output).expanduser().resolve()

    # The raw inputs live under assets/sites/raw/ and are gitignored — they are
    # produced by `melos run update-assets`. A clean checkout has the committed
    # sites.db but not the raw inputs, so `melos run build-components` must not
    # fail there: skip rebuilding and keep the committed artifact. Only error if
    # there is no committed DB to fall back on.
    missing = [p for p in (tranco_path, blocklist_path, disconnect_path) if not p.exists()]
    if missing:
        names = ", ".join(p.name for p in missing)
        if db_path.exists():
            print(
                f"Skipping sites.db rebuild: missing raw input(s) [{names}]. "
                f"Keeping committed {db_path}. Run "
                f"`melos run update-assets` to refresh from source."
            )
            return
        raise SystemExit(
            f"Cannot build {db_path}: missing raw input(s) [{names}] and no "
            f"committed DB to fall back on. Run "
            f"`melos run update-assets --no-select` first."
        )

    tranco = load_tranco(tranco_path, args.scan_limit)
    deny = build_denylist(blocklist_path, disconnect_path)
    rows, scanned = filter_domains(tranco, deny, args.limit)

    build_database(db_path, args.table, rows)

    dropped = scanned - len(rows)
    drop_pct = (dropped / scanned * 100) if scanned else 0
    print(
        f"Denylist={len(deny)} domains. Scanned top {scanned} Tranco ranks to "
        f"keep {len(rows)} sites (dropped {dropped}, {drop_pct:.0f}% of head). "
        f"Wrote {db_path}."
    )


if __name__ == "__main__":
    main()
