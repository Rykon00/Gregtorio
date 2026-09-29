#!/usr/bin/env python3
"""Builds thumbnail.png (144x144, the mod list / mod portal picture) from GT5-Unofficial
casing textures (LGPL-3.0): a 3x3 wall of fusion casing with a fusion coil and the fusion
glass in the middle, scaled up pixel-exact.

    python tools/gen_thumbnail.py --gt <GT5-Unofficial checkout>
"""
import argparse
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
ICONSETS = "src/main/resources/assets/gregtech/textures/blocks/iconsets"


def tile(gt, name):
    img = Image.open(gt / ICONSETS / f"{name}.png").convert("RGBA")
    img = img.crop((0, 0, 16, 16))                       # first animation frame
    return img.resize((48, 48), Image.NEAREST)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--gt", type=Path, required=True)
    a = ap.parse_args()
    layout = [
        ["MACHINE_CASING_FUSION", "MACHINE_CASING_FUSION_COIL", "MACHINE_CASING_FUSION"],
        ["MACHINE_CASING_FUSION_COIL", "MACHINE_CASING_FUSION_GLASS_YELLOW", "MACHINE_CASING_FUSION_COIL"],
        ["MACHINE_CASING_FUSION", "MACHINE_CASING_FUSION_COIL", "MACHINE_CASING_FUSION"],
    ]
    out = Image.new("RGBA", (144, 144))
    for y, row in enumerate(layout):
        for x, name in enumerate(row):
            out.alpha_composite(tile(a.gt, name), (x * 48, y * 48))
    out.convert("RGB").save(ROOT / "thumbnail.png")
    print("written: thumbnail.png")


if __name__ == "__main__":
    main()
