#!/usr/bin/env python3
"""Validate Full HD imagegen asset contract.

This checks exact final pixel sizes, alpha requirements, file presence, and
prompt presence. It intentionally treats a one-pixel mismatch as a failure.
"""

from __future__ import annotations

import json
import sys
from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[4]
CONTRACT = ROOT / "realapp/assets/imagegen_sources/full_hd_p0_contract.json"
FORBIDDEN_PROMPT_TERMS = ("광고", "결제", "유료", "프리미엄", "구독", "가격표")


def has_alpha(image: Image.Image) -> bool:
    return image.mode in ("RGBA", "LA") or "transparency" in image.info


def main() -> int:
    entries = json.loads(CONTRACT.read_text(encoding="utf-8"))
    problems: list[str] = []

    seen_final_paths: set[str] = set()
    for entry in entries:
        asset_id = entry["asset_id"]
        final_path = ROOT / entry["final_path"]
        prompt_path = ROOT / entry["prompt_path"]
        expected_size = (int(entry["width"]), int(entry["height"]))

        if entry["final_path"] in seen_final_paths:
            problems.append(f"{asset_id}: duplicate final_path {entry['final_path']}")
        seen_final_paths.add(entry["final_path"])

        if not prompt_path.exists():
            problems.append(f"{asset_id}: missing prompt {entry['prompt_path']}")
        else:
            text = prompt_path.read_text(encoding="utf-8")
            found = [term for term in FORBIDDEN_PROMPT_TERMS if term in text]
            if found:
                problems.append(f"{asset_id}: forbidden prompt terms {', '.join(found)}")

        if not final_path.exists():
            problems.append(f"{asset_id}: missing final asset {entry['final_path']}")
            continue

        try:
            with Image.open(final_path) as image:
                if image.size != expected_size:
                    problems.append(
                        f"{asset_id}: size {image.size[0]}x{image.size[1]} "
                        f"!= {expected_size[0]}x{expected_size[1]}"
                    )
                image_has_alpha = has_alpha(image)
                if bool(entry["alpha"]) != image_has_alpha:
                    problems.append(
                        f"{asset_id}: alpha {image_has_alpha} != {bool(entry['alpha'])}"
                    )
        except Exception as exc:  # pragma: no cover - diagnostic path
            problems.append(f"{asset_id}: cannot inspect image: {exc}")

    if problems:
        print("FAIL full_hd_asset_validation")
        for problem in problems:
            print(f"- {problem}")
        return 1

    print(f"PASS full_hd_asset_validation entries={len(entries)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())

