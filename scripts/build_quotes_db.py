#!/usr/bin/env python3

import argparse
import json
import sqlite3
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parent.parent
DEFAULT_TABLE_NAME = "quotes"
DEFAULT_INPUT_PATH = REPO_ROOT / "scripts" / "quotes" / "quotes.json"
DEFAULT_OUTPUT_PATH = REPO_ROOT / "apps" / "weblibre" / "assets" / "quotes" / "quotes.db"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Build a SQLite quotes database from a JSON file."
    )
    parser.add_argument(
        "--input",
        default=str(DEFAULT_INPUT_PATH),
        help="Path to the source JSON file (default: quotes.json)",
    )
    parser.add_argument(
        "--output",
        default=str(DEFAULT_OUTPUT_PATH),
        help="Path to the SQLite database file (default: quotes.db)",
    )
    parser.add_argument(
        "--table",
        default=DEFAULT_TABLE_NAME,
        help=f"Table name to create (default: {DEFAULT_TABLE_NAME})",
    )
    return parser.parse_args()


def load_quotes(json_path: Path) -> list[tuple[str, str, str | None, str | None]]:
    with json_path.open("r", encoding="utf-8") as handle:
        payload = json.load(handle)

    if not isinstance(payload, list):
        raise ValueError("Expected the JSON file to contain a top-level array.")

    rows = []
    for index, item in enumerate(payload, start=1):
        if not isinstance(item, dict):
            raise ValueError(f"Entry {index} is not a JSON object.")

        author = item.get("author")
        text = item.get("text")
        source = item.get("source")
        tags = item.get("tags")

        if not isinstance(author, str) or not author.strip():
            raise ValueError(f"Entry {index} is missing a valid 'author' string.")
        if not isinstance(text, str) or not text.strip():
            raise ValueError(f"Entry {index} is missing a valid 'text' string.")
        if source is not None and not isinstance(source, str):
            raise ValueError(f"Entry {index} has a non-string 'source' value.")
        if tags is not None and not isinstance(tags, str):
            raise ValueError(f"Entry {index} has a non-string 'tags' value.")

        rows.append((author, text, source, tags))

    return rows


def quote_identifier(name: str) -> str:
    return '"' + name.replace('"', '""') + '"'


def build_database(db_path: Path, table_name: str, rows: list[tuple[str, str, str | None, str | None]]) -> None:
    db_path.parent.mkdir(parents=True, exist_ok=True)
    table_identifier = quote_identifier(table_name)

    connection = sqlite3.connect(db_path)
    try:
        cursor = connection.cursor()
        cursor.execute(f"DROP TABLE IF EXISTS {table_identifier}")
        cursor.execute(
            f"""
            CREATE TABLE {table_identifier} (
                author TEXT NOT NULL,
                quote TEXT NOT NULL,
                source TEXT,
                tags TEXT
            )
            """
        )
        cursor.executemany(
            f"INSERT INTO {table_identifier} (author, quote, source, tags) VALUES (?, ?, ?, ?)",
            rows,
        )
        connection.commit()
        cursor.execute("VACUUM")
    finally:
        connection.close()


def main() -> None:
    args = parse_args()
    json_path = Path(args.input).expanduser().resolve()
    db_path = Path(args.output).expanduser().resolve()

    rows = load_quotes(json_path)
    build_database(db_path, args.table, rows)

    print(f"Created {db_path} with {len(rows)} rows in table '{args.table}'.")


if __name__ == "__main__":
    main()
