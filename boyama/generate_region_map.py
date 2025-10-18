import numpy as np
import cv2
from PIL import Image

# === INPUT ===
path = "pikachu_outline.png"

# === LOAD IMAGE ===
img = Image.open(path).convert("RGBA")
rgba = np.array(img)
rgb = rgba[..., :3]
alpha = rgba[..., 3]

# === DETECT BLACK LINES ===
# use stronger threshold, combine alpha & luminance
gray = cv2.cvtColor(rgb, cv2.COLOR_RGB2GRAY)
mask_lines = ((gray < 200) & (alpha > 30)).astype(np.uint8)  # anything dark becomes line

# === CLOSE GAPS ===
# Dilate/erode to make borders watertight
kernel = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (5, 5))
lines_closed = cv2.morphologyEx(mask_lines, cv2.MORPH_CLOSE, kernel, iterations=3)
lines_dilated = cv2.dilate(lines_closed, kernel, iterations=2)

# === MAKE FILLABLE SPACE ===
fillable = cv2.bitwise_not(lines_dilated * 255)
cv2.imwrite("debug_fillable.png", fillable)

# === CONNECTED COMPONENT LABELING ===
num_labels, labels = cv2.connectedComponents(fillable)

# Remove outer background touching borders
outer_id = np.unique(np.concatenate([
    labels[0, :], labels[-1, :], labels[:, 0], labels[:, -1]
]))
mask = np.isin(labels, outer_id)
labels[mask] = 0  # set background to 0
_, labels = cv2.connectedComponents((labels > 0).astype(np.uint8))

print(f"Found {labels.max()} regions")

# === COLORIZED PREVIEW ===
colors = np.random.randint(0, 255, (labels.max() + 1, 3), dtype=np.uint8)
colored = colors[labels]
cv2.imwrite("region_preview_fixed.png", colored)

# === SAVE NUMERIC MAP ===
np.save("region_map_fixed.npy", labels)
