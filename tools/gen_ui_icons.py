#!/usr/bin/env python3
"""Generates GUI icons derived from existing Gregtorio item icons.

Currently: the "manual labor" burner usage (see prototypes/190-fork-manual-labor.lua).
The fist is cut out of graphics/icons/manual-labor.png (flood fill of the dark background
from the border) and rendered as

  graphics/icons/fork/empty-manual-labor-slot.png   64x64, pale translucent silhouette shown
                                                    in the empty fuel slot (like vanilla's
                                                    empty-fuel-slot gas pump)
  graphics/icons/fork/manual-labor-icon-red.png     64x64, red with dark outline, shown as the
                                                    "no manual labor" alert over the entity

    python tools/gen_ui_icons.py
"""
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
SRC = ROOT / "graphics/icons/manual-labor.png"
OUT = ROOT / "graphics/icons/fork"
SIZE = 64


def lum(p):
    return (p[0] * 299 + p[1] * 587 + p[2] * 114) // 1000


def cut_out(img):
    """Returns the fist (without border and background) as a grayscale image with alpha."""
    img = img.convert("RGBA").crop((1, 1, img.width - 1, img.height - 1))   # drop the white frame
    w, h = img.size
    px = img.load()
    bg = set()
    stack = [(x, y) for x in range(w) for y in (0, h - 1)] + [(x, y) for y in range(h) for x in (0, w - 1)]
    while stack:
        x, y = stack.pop()
        if (x, y) in bg or not (0 <= x < w and 0 <= y < h) or lum(px[x, y]) >= 100:
            continue
        bg.add((x, y))
        stack += [(x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)]
    out = Image.new("LA", (w, h))
    o = out.load()
    for y in range(h):
        for x in range(w):
            if (x, y) not in bg:
                o[x, y] = (lum(px[x, y]), 255)
    return out.crop(out.getbbox())


def place(img, margin):
    """Scale up pixel-exact and center on a SIZE x SIZE canvas."""
    scale = max(1, (SIZE - 2 * margin) // max(img.size))
    img = img.resize((img.width * scale, img.height * scale), Image.NEAREST)
    canvas = Image.new("RGBA", (SIZE, SIZE))
    canvas.paste(img, ((SIZE - img.width) // 2, (SIZE - img.height) // 2), img)
    return canvas


def empty_slot(fist):
    """Pale gray, translucent; the dark finger lines stay visible as a darker gray."""
    img = Image.new("RGBA", fist.size)
    p, f = img.load(), fist.load()
    for y in range(fist.height):
        for x in range(fist.width):
            l, a = f[x, y]
            if a:
                g = 110 + l * 120 // 255
                p[x, y] = (g, g, g, 170)
    return place(img, 6)


def red_alert(fist):
    """Red fist with a dark outline, like vanilla's fuel-icon-red."""
    img = Image.new("RGBA", fist.size)
    p, f = img.load(), fist.load()
    for y in range(fist.height):
        for x in range(fist.width):
            l, a = f[x, y]
            if a:
                p[x, y] = (110 + l * 145 // 255, 20 + l * 30 // 255, 20 + l * 30 // 255, 255)
    img = place(img, 6)
    alpha = img.getchannel("A")
    outline = Image.new("RGBA", img.size)
    o, al = outline.load(), alpha.load()
    for y in range(SIZE):
        for x in range(SIZE):
            if any(0 <= x + dx < SIZE and 0 <= y + dy < SIZE and al[x + dx, y + dy]
                   for dx in range(-2, 3) for dy in range(-2, 3)):
                o[x, y] = (30, 10, 10, 255)
    outline.alpha_composite(img)
    return outline


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    fist = cut_out(Image.open(SRC))
    empty_slot(fist).save(OUT / "empty-manual-labor-slot.png")
    red_alert(fist).save(OUT / "manual-labor-icon-red.png")
    print("written: empty-manual-labor-slot.png, manual-labor-icon-red.png")


if __name__ == "__main__":
    main()
