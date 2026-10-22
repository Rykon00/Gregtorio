"""Spike #495: draw the resource dumps of control.lua (x y name per line) as map-like pictures."""
import sys
from pathlib import Path

from PIL import Image, ImageDraw

SRC = Path(sys.argv[1])
OUT = Path(sys.argv[2])
OUT.mkdir(exist_ok=True)
HALF = 256
SCALE = 2
COLORS = {
    "coal": (26, 26, 26), "lignite": (115, 77, 38), "magnetite": (89, 102, 140), "iron": (191, 204, 242),
    "vanadium-magnetite": (153, 51, 204), "chalcopyrite": (230, 128, 26), "pyrite": (242, 230, 51),
    "copper": (255, 64, 38),
}
GROUND = (96, 110, 70)


def hashcolor(s):
    h = 0
    for c in s:
        h = (h * 31 + ord(c)) % 16777216
    return (h % 256, (h // 256) % 256, (h // 65536) % 256)


def draw(name, cell, label):
    img = Image.new("RGB", (2 * HALF, 2 * HALF), GROUND)
    px = img.load()
    for line in (SRC / f"{name}.txt").read_text().split("\n"):
        if not line.strip():
            continue
        x, y, res = line.split()
        x, y = int(x) + HALF, int(y) + HALF
        if 0 <= x < 2 * HALF and 0 <= y < 2 * HALF:
            m = res.removeprefix("gt-spike-")
            px[x, y] = COLORS.get(m) or hashcolor(m)
    img = img.resize((2 * HALF * SCALE, 2 * HALF * SCALE), Image.NEAREST)
    d = ImageDraw.Draw(img)
    if cell:
        k = -(HALF // cell) - 1
        while k * cell <= HALF:
            p = (k * cell + HALF) * SCALE
            d.line([(p, 0), (p, 2 * HALF * SCALE)], fill=(120, 135, 95))
            d.line([(0, p), (2 * HALF * SCALE, p)], fill=(120, 135, 95))
            k += 1
    d.rectangle([0, 0, 2 * HALF * SCALE, 22], fill=(0, 0, 0))
    d.text((6, 5), label, fill=(255, 255, 255))
    d.ellipse([HALF * SCALE - 4, HALF * SCALE - 4, HALF * SCALE + 4, HALF * SCALE + 4], outline=(255, 255, 255))
    img.save(OUT / f"{name}.png")
    return img


pics = []
for size in (96, 128, 160):
    for empty, share in (("107", "25 %"), ("320", "50 %")):
        pics.append(draw(f"pic-{size}-{empty}", size,
                         f"cell {size}, empty weight {empty} ({share} of cells empty), GT fill; 512 x 512 tiles"))
draw("pic-128-107-fill3", 128, "cell 128, empty weight 107, fill x3; 512 x 512 tiles")
draw("pic-ow", 128, "Overworld: 21 GTNH veins, cell 128, empty weight 100; 512 x 512 tiles")
sheet = Image.new("RGB", (2 * 1024 + 16, 3 * 1024 + 32), (0, 0, 0))
for i, p in enumerate(pics):
    sheet.paste(p, ((i % 2) * (1024 + 16), (i // 2) * (1024 + 16)))
sheet.resize((sheet.width // 2, sheet.height // 2), Image.LANCZOS).save(OUT / "sheet.png")
print("ok")
