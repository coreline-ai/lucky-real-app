#!/usr/bin/env python3
"""Create a contact sheet for Full HD asset QA."""

from __future__ import annotations

import json
import sys
from pathlib import Path

from PIL import Image, ImageDraw


ROOT = Path(__file__).resolve().parents[4]
CONTRACT = ROOT / "realapp/assets/imagegen_sources/full_hd_p0_contract.json"
OUT = ROOT / "realapp/assets/imagegen_sources/QA_CONTACT_SHEET.png"


def checkerboard(size: tuple[int, int], block: int = 32) -> Image.Image:
    image = Image.new("RGBA", size, (32, 34, 38, 255))
    draw = ImageDraw.Draw(image)
    for y in range(0, size[1], block):
        for x in range(0, size[0], block):
            color = (64, 68, 74, 255) if ((x // block + y // block) % 2) else (38, 42, 48, 255)
            draw.rectangle((x, y, x + block, y + block), fill=color)
    return image


def main() -> int:
    entries = json.loads(CONTRACT.read_text(encoding="utf-8"))
    existing = [entry for entry in entries if (ROOT / entry["final_path"]).exists()]
    if not existing:
        print("No assets found for contact sheet")
        return 1

    thumb_w, thumb_h, label_h = 180, 260, 24
    cols = 5
    rows = (len(existing) + cols - 1) // cols
    sheet = Image.new("RGB", (cols * thumb_w, rows * (thumb_h + label_h)), (24, 26, 30))
    draw = ImageDraw.Draw(sheet)

    for idx, entry in enumerate(existing):
        path = ROOT / entry["final_path"]
        with Image.open(path) as src:
            image = src.convert("RGBA")
            if image.getextrema()[3][0] < 255:
                bg = checkerboard(image.size)
                bg.alpha_composite(image)
                image = bg
            scale = min(thumb_w / image.width, thumb_h / image.height)
            thumb = image.convert("RGB").resize(
                (round(image.width * scale), round(image.height * scale)),
                Image.Resampling.LANCZOS,
            )
        cell_x = (idx % cols) * thumb_w
        cell_y = (idx // cols) * (thumb_h + label_h)
        x = cell_x + (thumb_w - thumb.width) // 2
        y = cell_y + (thumb_h - thumb.height) // 2
        sheet.paste(thumb, (x, y))
        draw.text((cell_x + 6, cell_y + thumb_h + 4), entry["asset_id"][:24], fill=(232, 235, 241))

    OUT.parent.mkdir(parents=True, exist_ok=True)
    sheet.save(OUT)
    print(OUT)
    return 0


if __name__ == "__main__":
    sys.exit(main())

