import os
from collections import deque
from PIL import Image

os.makedirs("sprites", exist_ok=True)
img = Image.open("Eggman.jpg").convert("RGBA")
w, h = img.size
px = img.load()
bg = px[(0, 0)]

def is_bg(c):
    return abs(c[0] - bg[0]) < 35 and abs(c[1] - bg[1]) < 35 and abs(c[2] - bg[2]) < 35

visited = [[False] * h for _ in range(w)]
idx = 1

for y in range(h):
    for x in range(w):
        if not visited[x][y] and not is_bg(px[(x, y)]):
            q = deque([(x, y)])
            visited[x][y] = True
            min_x = max_x = x
            min_y = max_y = y
            while q:
                cx, cy = q.popleft()
                if cx < min_x: min_x = cx
                if cx > max_x: max_x = cx
                if cy < min_y: min_y = cy
                if cy > max_y: max_y = cy
                for nx, ny in ((cx+1,cy),(cx-1,cy),(cx,cy+1),(cx,cy-1)):
                    if 0 <= nx < w and 0 <= ny < h and not visited[nx][ny] and not is_bg(px[(nx, ny)]):
                        visited[nx][ny] = True
                        q.append((nx, ny))
            bw = max_x - min_x + 1
            bh = max_y - min_y + 1
            if 14 <= bw <= 80 and 14 <= bh <= 80:
                crop = img.crop((min_x, min_y, max_x + 1, max_y + 1))
                cpx = crop.load()
                for cy in range(crop.height):
                    for cx in range(crop.width):
                        if is_bg(cpx[(cx, cy)]):
                            cpx[(cx, cy)] = (0, 0, 0, 0)
                crop.save(f"sprites/eggman_{idx:03d}.png")
                idx += 1
