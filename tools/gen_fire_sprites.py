#!/usr/bin/env python3
"""Fire sprites for the burner machines of the steam age (issue #137).

The stone furnace, the iron furnace and the small coal boiler were one static picture: the furnaces showed nothing while
they work, the boiler always showed its fire. Now each has an idle picture and a fire animation that the game draws only
while the machine works (`working_visualisations` of the furnaces, `pictures.<dir>.fire` of the boiler):

  graphics/entity/small-coal-boiler/small-coal-boiler-fire.png   4 frames of 96x96: the boiler's own fire pixels (the
                                       pixels that differ between steam-boiler-off.png and small-coal-boiler.png), flickering
  graphics/entity/furnace-fire.png, iron-furnace-fire.png        4 frames of 128x128: the dark opening under the smelting
                                       window filled with the same fire (found by flood fill from a seed point), drawn as glow

The boiler's idle picture is the existing graphics/entity/small-coal-boiler/steam-boiler-off.png (it was not used).

    python tools/gen_fire_sprites.py
"""
import random
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
ENT = ROOT / "graphics/entity"
FRAMES = 4
# the colours of the boiler's fire, dark to bright
PALETTE = [(200, 80, 10), (255, 130, 0), (255, 160, 0), (255, 205, 0), (255, 235, 90), (255, 250, 170)]
WEIGHTS = [1, 3, 3, 3, 2, 1]


def lum(p):
    return (p[0] * 299 + p[1] * 587 + p[2] * 114) // 1000


def fire_pixels(mask, size, seed, cell=4):
    """FRAMES frames, one strip; blocks of cell x cell pixels like the pixel art of the machines, brighter towards the
    bottom of the mask, a new random picture per frame"""
    rng = random.Random(seed)
    ys = [y for _, y in mask]
    top, bottom = min(ys), max(ys)
    strip = Image.new("RGBA", (size[0] * FRAMES, size[1]))
    px = strip.load()
    for f in range(FRAMES):
        colour = {}
        for x, y in mask:
            key = (x // cell, y // cell)
            if key not in colour:
                heat = (y - top) / max(1, bottom - top)             # 0 at the top, 1 at the bottom
                i = rng.choices(range(len(PALETTE)), WEIGHTS)[0]
                i = round(i * 0.5 + heat * (len(PALETTE) - 1) * 0.5 + rng.uniform(-1, 1))
                colour[key] = PALETTE[min(len(PALETTE) - 1, max(0, i))] + (255,)
            px[f * size[0] + x, y] = colour[key]
    return strip


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
    strip = fire_pixels(mask, on.size, 1)
    # the first frame is the boiler's own fire
    for x, y in mask:
        strip.putpixel((x, y), on.getpixel((x, y)))
    strip.save(d / "small-coal-boiler-fire.png", optimize=True)
    print("boiler fire:", len(mask), "pixels")


def furnace(name, seed_point, limit, box, seed):
    img = Image.open(ENT / f"{name}.png").convert("RGBA")
    mask = sorted(opening(img, seed_point, limit, box))
    fire_pixels(mask, img.size, seed).save(ENT / f"{name}-fire.png", optimize=True)
    print(name, "fire:", len(mask), "pixels")


def main():
    boiler()
    furnace("furnace", (64, 100), 35, (30, 78, 100, 116), 2)
    furnace("iron-furnace", (64, 100), 85, (20, 70, 108, 118), 3)


if __name__ == "__main__":
    main()
