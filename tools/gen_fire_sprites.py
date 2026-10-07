#!/usr/bin/env python3
"""Fire sprites for the burner machines of the steam age (issues #137 and #147).

The stone furnace, the iron furnace and the small coal boiler were one static picture: the furnaces showed nothing while
they work, the boiler always showed its fire. Now each has an idle picture and a fire animation that the game draws only
while the machine works (`working_visualisations` of the furnaces, `pictures.<dir>.fire` of the boiler):

  graphics/entity/small-coal-boiler/small-coal-boiler-fire.png   FRAMES frames of 96x96: the boiler's own fire pixels (the
                                       pixels that differ between steam-boiler-off.png and small-coal-boiler.png)
  graphics/entity/furnace-fire.png, iron-furnace-fire.png        FRAMES frames of 128x128: the dark opening under the
                                       smelting window filled with fire (found by flood fill from a seed point), drawn as glow

Each sheet has LINE_LENGTH frames per row. The frames are one loop (issue #147): a field of smooth noise that repeats
vertically scrolls up through the fire by exactly one period over the loop, a second, finer octave by two periods, and
every block flickers on a sine with a whole number of cycles per loop. So each frame is a small step from the one before
and the last one leads back into the first; the blocks of 4x4 pixels and the palette keep the pixel art look. The seeds
are fixed, so the files are the same on every run. The boiler's fire keeps its shape: the brightness of its own pixels is
the base of the field, the noise moves on top of it.

The boiler's idle picture is the existing graphics/entity/small-coal-boiler/steam-boiler-off.png (it was not used).
The contact sheet docs/graphics-review/burner-fire.png shows every frame over the idle picture, in playing order (12 per
row: boiler, stone furnace, iron furnace).

    python tools/gen_fire_sprites.py
"""
import math
import random
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
ENT = ROOT / "graphics/entity"
FRAMES = 48          # prototypes/191-fork-burner-fire.lua: frame_count
LINE_LENGTH = 8      # frames per row of the sheet (6 rows)
CELL = 4             # pixels per block
# the colours of the boiler's fire, dark to bright
PALETTE = [(200, 80, 10), (255, 130, 0), (255, 160, 0), (255, 205, 0), (255, 235, 90), (255, 250, 170)]


def lum(p):
    return (p[0] * 299 + p[1] * 587 + p[2] * 114) // 1000


def smooth(t):
    return t * t * (3 - 2 * t)


class LoopNoise:
    """value noise on a lattice of `step` blocks that repeats every `period` lattice rows"""

    def __init__(self, rng, width, period, step):
        self.period, self.step = period, step
        self.v = [[rng.random() for _ in range(period)] for _ in range(width // step + 2)]

    def at(self, x, y):
        gx, gy = x / self.step, y / self.step
        x0, y0 = int(math.floor(gx)), int(math.floor(gy))
        tx, ty = smooth(gx - x0), smooth(gy - y0)
        p = self.period
        a, b = self.v[x0][y0 % p], self.v[x0 + 1][y0 % p]
        c, d = self.v[x0][(y0 + 1) % p], self.v[x0 + 1][(y0 + 1) % p]
        return (a * (1 - tx) + b * tx) * (1 - ty) + (c * (1 - tx) + d * tx) * ty


def fire_frames(mask, size, seed, base):
    """FRAMES frames in a sheet of LINE_LENGTH columns. `base(x, y)` is the heat of a pixel without the noise (0 to 1)"""
    rng = random.Random(seed)
    cols = max(x for x, _ in mask) // CELL + 1
    coarse = LoopNoise(rng, cols, 4, 3)          # 12 blocks per period, one period per loop
    fine = LoopNoise(rng, cols, 4, 2)            # 8 blocks per period, two periods per loop
    cells = sorted({(x // CELL, y // CELL) for x, y in mask})
    phase = {c: (rng.random(), rng.choice((1, 2))) for c in cells}
    heat0 = {}
    for x, y in mask:
        heat0.setdefault((x // CELL, y // CELL), []).append(base(x, y))
    heat0 = {c: sum(v) / len(v) for c, v in heat0.items()}
    rows = (FRAMES + LINE_LENGTH - 1) // LINE_LENGTH
    sheet = Image.new("RGBA", (size[0] * LINE_LENGTH, size[1] * rows))
    px = sheet.load()
    for f in range(FRAMES):
        t = f / FRAMES
        ox, oy = (f % LINE_LENGTH) * size[0], (f // LINE_LENGTH) * size[1]
        colour = {}
        for cx, cy in cells:
            # sampling further down as t grows moves the pattern up: the flames rise
            n = 0.65 * coarse.at(cx, cy + t * 12) + 0.35 * fine.at(cx, cy + t * 16)
            ph, k = phase[(cx, cy)]
            flick = 0.08 * math.sin(2 * math.pi * (k * t + ph))
            v = 0.55 * heat0[(cx, cy)] + 0.6 * (n - 0.5) + 0.25 + flick
            i = round(min(1.0, max(0.0, v)) * (len(PALETTE) - 1))
            colour[(cx, cy)] = PALETTE[i] + (255,)
        for x, y in mask:
            px[ox + x, oy + y] = colour[(x // CELL, y // CELL)]
    return sheet


def opening(img, seed_point, limit, box):
    """the connected dark pixels around a point inside box (x0, y0, x1, y1)"""
    px = img.load()
    todo, seen = [seed_point], set()
    while todo:
        x, y = todo.pop()
        if (x, y) in seen or not (box[0] <= x <= box[2] and box[1] <= y <= box[3]):
            continue
        if lum(px[x, y]) > limit or px[x, y][3] == 0:
            continue
        seen.add((x, y))
        todo += [(x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)]
    return seen


def boiler():
    d = ENT / "small-coal-boiler"
    on = Image.open(d / "small-coal-boiler.png").convert("RGBA")
    off = Image.open(d / "steam-boiler-off.png").convert("RGBA")
    # the fire of the picture with fire: the warm pixels that differ from the one without
    mask = [(x, y) for y in range(on.height) for x in range(on.width)
            if on.getpixel((x, y)) != off.getpixel((x, y)) and on.getpixel((x, y))[3]
            and on.getpixel((x, y))[0] > 150 and on.getpixel((x, y))[0] > on.getpixel((x, y))[2] + 80]
    lo = min(lum(on.getpixel(p)) for p in mask)
    hi = max(lum(on.getpixel(p)) for p in mask)
    sheet = fire_frames(mask, on.size, 1, lambda x, y: (lum(on.getpixel((x, y))) - lo) / max(1, hi - lo))
    sheet.save(d / "small-coal-boiler-fire.png", optimize=True)
    print("boiler fire:", len(mask), "pixels,", FRAMES, "frames")


def furnace(name, seed_point, limit, box, seed):
    img = Image.open(ENT / f"{name}.png").convert("RGBA")
    mask = sorted(opening(img, seed_point, limit, box))
    ys = [y for _, y in mask]
    top, bottom = min(ys), max(ys)
    # brighter towards the bottom of the opening, where the fuel burns
    sheet = fire_frames(mask, img.size, seed, lambda x, y: (y - top) / max(1, bottom - top))
    sheet.save(ENT / f"{name}-fire.png", optimize=True)
    print(name, "fire:", len(mask), "pixels,", FRAMES, "frames")


def contact_sheet(out, per_row=12, zoom=2):
    """every frame over the idle picture, cut to the fire and its surroundings: one block of rows per machine"""
    machines = [(ENT / "small-coal-boiler/steam-boiler-off.png", ENT / "small-coal-boiler/small-coal-boiler-fire.png"),
                (ENT / "furnace.png", ENT / "furnace-fire.png"), (ENT / "iron-furnace.png", ENT / "iron-furnace-fire.png")]
    tiles = []
    for idle_path, fire_path in machines:
        idle = Image.open(idle_path).convert("RGBA")
        sheet = Image.open(fire_path).convert("RGBA")
        w, h = idle.size
        frames = [sheet.crop(((f % LINE_LENGTH) * w, (f // LINE_LENGTH) * h, (f % LINE_LENGTH + 1) * w,
                              (f // LINE_LENGTH + 1) * h)) for f in range(FRAMES)]
        box = frames[0].getbbox()
        box = (max(0, box[0] - 8), max(0, box[1] - 8), min(w, box[2] + 8), min(h, box[3] + 8))
        tiles.append([Image.alpha_composite(idle, fr).crop(box) for fr in frames])
    gap = 4
    width = max(per_row * (t[0].width * zoom + gap) for t in tiles) + gap
    height = gap + sum(((FRAMES + per_row - 1) // per_row) * (t[0].height * zoom + gap) + gap for t in tiles)
    img = Image.new("RGBA", (width, height), (48, 48, 48, 255))
    y = gap
    for t in tiles:
        tw, th = t[0].width * zoom, t[0].height * zoom
        for f, tile in enumerate(t):
            img.paste(tile.resize((tw, th), Image.NEAREST), (gap + (f % per_row) * (tw + gap), y + (f // per_row) * (th + gap)))
        y += ((FRAMES + per_row - 1) // per_row) * (th + gap) + gap
    img.save(out, optimize=True)
    print("contact sheet:", out)


def main():
    boiler()
    furnace("furnace", (64, 100), 35, (30, 78, 100, 116), 2)
    furnace("iron-furnace", (64, 100), 85, (20, 70, 108, 118), 3)
    contact_sheet(ROOT / "docs/graphics-review/burner-fire.png")


if __name__ == "__main__":
    main()
