#!/usr/bin/env python3
"""Build the bundled Korean market instrument master.

The default source is the public KRX/KIND corporation list download. The script
also accepts CSV/JSON files with Data.go.kr-style field names so the app asset
can be regenerated from an API export without changing the Flutter code.
"""

from __future__ import annotations

import argparse
import csv
import json
import re
import sys
import urllib.request
from datetime import datetime, timezone
from html.parser import HTMLParser
from pathlib import Path
from typing import Iterable

KIND_URL = "https://kind.krx.co.kr/corpgeneral/corpList.do?method=download&searchType=13"

MARKET_MAP = {
    "유가": "KOSPI",
    "유가증권": "KOSPI",
    "KOSPI": "KOSPI",
    "코스닥": "KOSDAQ",
    "KOSDAQ": "KOSDAQ",
    "코넥스": "KONEX",
    "KONEX": "KONEX",
}

FIELD_ALIASES = {
    "baseDate": ["기준일자", "basDt", "baseDate", "BASE_DATE"],
    "symbol": ["단축코드", "종목코드", "srtnCd", "shortCode", "symbol"],
    "isin": ["ISIN코드", "isinCd", "isin", "ISIN"],
    "market": ["시장구분", "mrktCtg", "market", "mktTpNm"],
    "name": ["종목명", "회사명", "itmsNm", "name", "corpName"],
    "corpName": ["법인명", "회사명", "corpNm", "corpName", "itmsNm"],
}


class _TableParser(HTMLParser):
    def __init__(self) -> None:
        super().__init__()
        self._in_cell = False
        self._cell: list[str] = []
        self._row: list[str] = []
        self.rows: list[list[str]] = []

    def handle_starttag(self, tag: str, attrs: list[tuple[str, str | None]]) -> None:
        if tag == "tr":
            self._row = []
        if tag in {"td", "th"}:
            self._in_cell = True
            self._cell = []

    def handle_data(self, data: str) -> None:
        if self._in_cell:
            text = data.strip()
            if text:
                self._cell.append(text)

    def handle_endtag(self, tag: str) -> None:
        if tag in {"td", "th"} and self._in_cell:
            self._row.append(" ".join(self._cell).strip())
            self._in_cell = False
        if tag == "tr" and self._row:
            self.rows.append(self._row)


def _normalize_for_search(value: str) -> str:
    return re.sub(r"\s+", "", value).upper()


def _pick(row: dict[str, object], key: str) -> str:
    for alias in FIELD_ALIASES[key]:
        value = row.get(alias)
        if value is not None:
            return str(value).strip()
    return ""


def _market(value: str) -> str:
    return MARKET_MAP.get(value.strip(), value.strip().upper())


def _instrument_from_row(row: dict[str, object], base_date: str, source: str) -> dict[str, object] | None:
    symbol = _pick(row, "symbol")
    name = _pick(row, "name")
    market = _market(_pick(row, "market"))
    if not symbol or not name or not market:
        return None
    corp_name = _pick(row, "corpName") or name
    row_base_date = _pick(row, "baseDate") or base_date
    isin = _pick(row, "isin") or None
    return {
        "id": f"KRX:{market}:{symbol}",
        "symbol": symbol,
        "market": market,
        "name": name,
        "normalizedName": _normalize_for_search(name),
        "corpName": corp_name,
        "isin": isin,
        "baseDate": row_base_date,
        "source": source,
        "updatedAt": base_date,
    }


def _parse_kind_html(data: bytes) -> list[dict[str, object]]:
    html = data.decode("euc-kr", errors="replace")
    parser = _TableParser()
    parser.feed(html)
    if not parser.rows:
        return []
    headers = parser.rows[0]
    rows = []
    for raw in parser.rows[1:]:
        if len(raw) < len(headers):
            continue
        rows.append({headers[i]: raw[i] for i in range(len(headers))})
    return rows


def _read_rows(path: Path | None) -> tuple[list[dict[str, object]], str, str]:
    if path is None:
        with urllib.request.urlopen(KIND_URL, timeout=30) as response:
            data = response.read()
        return _parse_kind_html(data), "KRX_KIND_CORP_LIST", KIND_URL

    data = path.read_bytes()
    suffix = path.suffix.lower()
    if suffix in {".htm", ".html", ".xls"}:
        return _parse_kind_html(data), "KRX_KIND_CORP_LIST", str(path)
    if suffix == ".csv":
        text = data.decode("utf-8-sig")
        return list(csv.DictReader(text.splitlines())), "KRX_LISTED_SECURITIES_EXPORT", str(path)
    if suffix == ".json":
        raw = json.loads(data.decode("utf-8"))
        if isinstance(raw, dict):
            for key in ("items", "data", "instruments"):
                if isinstance(raw.get(key), list):
                    return raw[key], "KRX_LISTED_SECURITIES_EXPORT", str(path)
        if isinstance(raw, list):
            return raw, "KRX_LISTED_SECURITIES_EXPORT", str(path)
    raise SystemExit(f"Unsupported input format: {path}")


def _dedupe_sort(instruments: Iterable[dict[str, object]]) -> list[dict[str, object]]:
    by_id: dict[str, dict[str, object]] = {}
    for instrument in instruments:
        by_id[instrument["id"]] = instrument
    return sorted(
        by_id.values(),
        key=lambda item: (str(item["market"]), str(item["symbol"]), str(item["name"])),
    )


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", type=Path, help="Optional KRX/Data.go.kr export file")
    parser.add_argument("--output", type=Path, default=Path("assets/market/kr_instruments.json"))
    parser.add_argument(
        "--base-date",
        default=datetime.now(timezone.utc).date().isoformat(),
        help="Data version date written into records when the source has no base date",
    )
    args = parser.parse_args(argv)

    rows, source, source_url = _read_rows(args.input)
    instruments = _dedupe_sort(
        item
        for row in rows
        if (item := _instrument_from_row(row, args.base_date, source)) is not None
    )
    if not instruments:
        raise SystemExit("No instruments were produced")

    payload = {
        "schemaVersion": 1,
        "source": {
            "name": source,
            "url": source_url,
            "baseDate": args.base_date,
            "generatedAt": args.base_date,
        },
        "instruments": instruments,
    }

    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(
        json.dumps(payload, ensure_ascii=False, indent=2, sort_keys=True) + "\n",
        encoding="utf-8",
    )
    print(f"wrote {args.output} instruments={len(instruments)} source={source}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
