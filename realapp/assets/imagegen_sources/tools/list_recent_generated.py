#!/usr/bin/env python3
"""List recent built-in imagegen outputs for manual asset mapping."""

from __future__ import annotations

import argparse
import os
from pathlib import Path


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--limit", type=int, default=20)
    parser.add_argument(
        "--session",
        default="019f3b4e-e36f-7ad2-942b-89d8dea1794f",
        help="Generated image session directory name.",
    )
    args = parser.parse_args()

    base = (
        Path(os.environ.get("CODEX_HOME", str(Path.home() / ".codex")))
        / "generated_images"
        / args.session
    )
    files = sorted(base.glob("ig_*.png"), key=lambda path: path.stat().st_mtime)
    for idx, path in enumerate(files[-args.limit :], 1):
        print(f"{idx:03d}\t{path.stat().st_mtime:.0f}\t{path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

