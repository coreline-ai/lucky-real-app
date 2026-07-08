#!/usr/bin/env python3
"""Process generated imagegen files into contract-compliant final assets.

The script is intentionally conservative:
- It preserves aspect ratio.
- It uses cover+crop only for non-alpha backgrounds.
- It uses contain+transparent padding for alpha/cutout assets.
- It never stretches width and height independently.
"""

from __future__ import annotations

import argparse
import json
import shutil
import subprocess
import sys
from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[4]
CONTRACT = ROOT / "realapp/assets/imagegen_sources/full_hd_p0_contract.json"
MASTERS = ROOT / "realapp/assets/imagegen_sources/masters"
HELPER = (
    Path.home()
    / ".codex/skills/.system/imagegen/scripts/remove_chroma_key.py"
)


ALPHA_MODES = {"RGBA", "LA"}


def mode_for(entry: dict) -> str:
    if entry["alpha"]:
        return "contain"
    width, height = int(entry["width"]), int(entry["height"])
    if width == height:
        return "contain"
    return "cover"


def master_name(entry: dict) -> str:
    final = Path(entry["final_path"])
    stem = final.stem
    return f"{stem}_master.png"


def alpha_master_name(entry: dict) -> str:
    final = Path(entry["final_path"])
    stem = final.stem
    return f"{stem}_alpha_master.png"


def copy_master(source: Path, entry: dict) -> Path:
    MASTERS.mkdir(parents=True, exist_ok=True)
    out = MASTERS / master_name(entry)
    shutil.copy2(source, out)
    return out


def remove_key(source: Path, entry: dict) -> Path:
    out = MASTERS / alpha_master_name(entry)
    subprocess.run(
        [
            sys.executable,
            str(HELPER),
            "--input",
            str(source),
            "--out",
            str(out),
            "--auto-key",
            "border",
            "--soft-matte",
            "--transparent-threshold",
            "12",
            "--opaque-threshold",
            "220",
            "--despill",
            "--force",
        ],
        check=True,
    )
    return out


def process_image(source: Path, entry: dict) -> Path:
    final = ROOT / entry["final_path"]
    final.parent.mkdir(parents=True, exist_ok=True)
    target_w, target_h = int(entry["width"]), int(entry["height"])
    alpha = bool(entry["alpha"])
    resize_mode = mode_for(entry)

    with Image.open(source) as image:
        image = image.convert("RGBA" if alpha else "RGB")
        src_w, src_h = image.size

        if resize_mode == "cover":
            scale = max(target_w / src_w, target_h / src_h)
            resized_size = (round(src_w * scale), round(src_h * scale))
            resized = image.resize(resized_size, Image.Resampling.LANCZOS)
            left = max(0, (resized_size[0] - target_w) // 2)
            top = max(0, (resized_size[1] - target_h) // 2)
            out = resized.crop((left, top, left + target_w, top + target_h))
        else:
            scale = min(target_w / src_w, target_h / src_h)
            resized_size = (round(src_w * scale), round(src_h * scale))
            resized = image.resize(resized_size, Image.Resampling.LANCZOS)
            bg = Image.new(
                "RGBA" if alpha else "RGB",
                (target_w, target_h),
                (0, 0, 0, 0) if alpha else (255, 255, 255),
            )
            left = (target_w - resized_size[0]) // 2
            top = (target_h - resized_size[1]) // 2
            bg.paste(resized, (left, top), resized if resized.mode == "RGBA" else None)
            out = bg

        out.save(final, "PNG", optimize=True)

    return final


def load_contract() -> list[dict]:
    return json.loads(CONTRACT.read_text(encoding="utf-8"))


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--asset-id", required=True)
    parser.add_argument("--source", required=True, type=Path)
    parser.add_argument(
        "--contract",
        default=CONTRACT,
        type=Path,
        help="Contract path. Defaults to realapp P0 contract.",
    )
    args = parser.parse_args()

    entries = json.loads(args.contract.read_text(encoding="utf-8"))
    matches = [entry for entry in entries if entry["asset_id"] == args.asset_id]
    if not matches:
        raise SystemExit(f"Unknown asset id: {args.asset_id}")
    if len(matches) > 1:
        candidates = [entry for entry in matches if entry["status"] != "existing"]
        if len(candidates) == 1:
            entry = candidates[0]
        else:
            raise SystemExit(f"Ambiguous asset id {args.asset_id}; use unique derivative id")
    else:
        entry = matches[0]

    source = args.source.expanduser().resolve()
    if not source.exists():
        raise SystemExit(f"Missing source: {source}")

    master = copy_master(source, entry)
    process_source = remove_key(master, entry) if entry["alpha"] else master
    final = process_image(process_source, entry)
    print(f"{entry['asset_id']}\t{master.relative_to(ROOT)}\t{final.relative_to(ROOT)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
