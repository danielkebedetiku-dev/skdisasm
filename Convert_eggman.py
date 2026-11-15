import os
import struct
import zipfile
from collections import Counter
from PIL import Image, ImageFilter

with zipfile.ZipFile("eggman-sprites 3.zip", "r") as z:
    z.extractall("sprites_raw")

PALETTE = [
    (0, 0, 0),
    (224, 0, 0),
    (160, 0, 0),
    (96, 0, 0),
    (16, 16, 16),
    (64, 64, 64),
    (128, 128, 128),
    (224, 224, 224),
    (224, 192, 0),
    (160, 128, 0),
    (224, 160, 128),
    (192, 128, 96),
    (128, 64, 32),
    (0, 96, 224),
    (0, 192, 224),
    (224, 96, 0),
]

def nearest_color(rgb):
    r, g, b = rgb
    best_i = 1
    best_d = 999999
    for i in range(1, 16):
        pr, pg, pb = PALETTE[i]
        d = (r - pr) ** 2 + (g - pg) ** 2 + (b - pb) ** 2
        if d < best_d:
            best_d = d
            best_i = i
    return best_i

def clean_sprite(img):
    img = img.filter(ImageFilter.ModeFilter(size=3))
    w, h = img.size
    px = img.load()
    grid = {}
    for y in range(h):
        for x in range(w):
            r, g, b, a = px[(x, y)]
            if a < 220 or (b > 110 and r > 70 and g < 90):
                grid[(x, y)] = 0
            else:
                grid[(x, y)] = nearest_color((r, g, b))

    cleaned = {}
    for y in range(h):
        for x in range(w):
            if grid[(x, y)] == 0:
                cleaned[(x, y)] = 0
                continue
            neighbors = []
            for nx, ny in ((x-1,y),(x+1,y),(x,y-1),(x,y+1)):
                if grid.get((nx, ny), 0) != 0:
                    neighbors.append(grid[(nx, ny)])
            if len(neighbors) == 0:
                cleaned[(x, y)] = 0
            elif len(neighbors) < 4:
                cleaned[(x, y)] = 4
            else:
                cleaned[(x, y)] = Counter(neighbors).most_common(1)[0][0]
    return cleaned

frames = (1, 13, 14, 15, 44, 52, 51)
os.makedirs("eggman_bin", exist_ok=True)

pal_bytes = bytearray()
for r, g, b in PALETTE:
    md_val = ((b >> 5) << 9) | ((g >> 5) << 5) | ((r >> 5) << 1)
    pal_bytes += struct.pack(">H", md_val)

with open("eggman_bin/pal_eggman.bin", "wb") as f:
    f.write(pal_bytes)

all_tiles = bytearray()
dplc_entries = []
map_entries = []
tile_offset = 0

for idx in frames:
    path = None
    for root, _, files in os.walk("sprites_raw"):
        target = f"eggman_{idx:03d}.png"
        if target in files:
            path = os.path.join(root, target)
            break
    raw = Image.open(path).convert("RGBA")
    grid = clean_sprite(raw)
    w, h = raw.size
    tw = (w + 7) // 8
    th = (h + 7) // 8
    ox = (tw * 8 - w) // 2
    oy = (th * 8 - h) // 2

    canvas = {}
    for y in range(h):
        for x in range(w):
            canvas[(ox + x, oy + y)] = grid[(x, y)]

    frame_tiles = bytearray()
    for tx in range(tw):
        for ty in range(th):
            for py in range(8):
                for px_x in range(0, 8, 2):
                    i1 = canvas.get((tx * 8 + px_x, ty * 8 + py), 0)
                    i2 = canvas.get((tx * 8 + px_x + 1, ty * 8 + py), 0)
                    frame_tiles.append((i1 << 4) | i2)

    num_tiles = len(frame_tiles) // 32
    dplc_entries.append((tile_offset, num_tiles))
    map_entries.append((tw, th))
    all_tiles += frame_tiles
    tile_offset += num_tiles

with open("eggman_bin/art_eggman.bin", "wb") as f:
    f.write(all_tiles)

with open("eggman_bin/eggman_tables.asm", "w") as f:
    f.write("Map_Eggman:\n")
    for i in range(len(frames)):
        f.write(f"\tdc.w .frame{i}-Map_Eggman\n")
    for i, (tw, th) in enumerate(map_entries):
        f.write(f".frame{i}:\n")
        pieces = []
        t_idx = 0
        x_start = -(tw * 4)
        y_start = -(th * 4)
        for tx in range(0, tw, 4):
            cw = min(4, tw - tx)
            for ty in range(0, th, 4):
                ch = min(4, th - ty)
                size_byte = ((cw - 1) << 2) | (ch - 1)
                pieces.append((y_start + ty * 8, size_byte, t_idx, x_start + tx * 8))
                t_idx += cw * ch
        f.write(f"\tdc.w {len(pieces)}\n")
        for yp, sb, ti, xp in pieces:
            f.write(f"\tdc.b {yp}, {sb}\n\tdc.w {ti}, {xp}\n")

    f.write("DPLC_Eggman:\n")
    for i in range(len(frames)):
        f.write(f"\tdc.w .dplc{i}-DPLC_Eggman\n")
    for i, (toff, tnum) in enumerate(dplc_entries):
        f.write(f".dplc{i}:\n\tdc.w 1\n\tdc.w ${(tnum-1)<<12 | toff:04X}\n")
