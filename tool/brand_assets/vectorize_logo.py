"""Trace the Utah View logo artwork into polygons and check the fit.

Reads the 4000x4000 RGBA source (red mark + opaque white counters on a
transparent canvas) and prints JSON: {"red": [...], "white": [...]} where each
entry is a list of rings (first = outer, rest = holes) in a 100x100 box, the
mark filling 92% of it (4..96), like the old mark.

The whole logo pipeline, from the master artwork (logo-source.png):

    python3 tool/brand_assets/vectorize_logo.py tool/brand_assets/logo-source.png > /tmp/logo.json
    python3 tool/brand_assets/emit_logo.py /tmp/logo.json /tmp
      # -> /tmp/logo.svg (assets/brand/logo.svg + the site/*.html inline SVGs)
      # -> /tmp/logo_data.dart (the generated block at the end of brand.dart)
    flutter test tool/brand_assets/generate_brand_assets_test.dart
    dart run flutter_launcher_icons && dart run flutter_native_splash:create

Needs Pillow, numpy and opencv-python.
"""
import json, sys
import cv2, numpy as np
from PIL import Image

src = np.asarray(Image.open(sys.argv[1]).convert("RGBA")).astype(int)
R, G, B, A = (src[..., i] for i in range(4))
opaque = (A > 127).astype(np.uint8)
red = ((R - G > 60) & (A > 127)).astype(np.uint8)

ys, xs = np.nonzero(opaque)
x0, x1, y0, y1 = xs.min(), xs.max() + 1, ys.min(), ys.max() + 1
side = max(x1 - x0, y1 - y0)
scale = 92.0 / side
ox = 4 + (92 - (x1 - x0) * scale) / 2
oy = 4 + (92 - (y1 - y0) * scale) / 2

def snap(vals, tol=3):
    """Cluster nearly equal coordinates so straight edges stay straight."""
    vals = sorted(set(vals)); groups, cur = [], [vals[0]]
    for v in vals[1:]:
        if v - cur[-1] <= tol: cur.append(v)
        else: groups.append(cur); cur = [v]
    groups.append(cur)
    return {v: round(sum(g) / len(g)) for g in groups for v in g}

def trace(mask):
    contours, hier = cv2.findContours(mask, cv2.RETR_CCOMP, cv2.CHAIN_APPROX_SIMPLE)
    polys = [cv2.approxPolyDP(c, 2.5, True)[:, 0, :] for c in contours]
    xs_ = [int(p[0]) for poly in polys for p in poly]; ys_ = [int(p[1]) for poly in polys for p in poly]
    sx, sy = snap(xs_), snap(ys_)
    shapes = []
    for i, (poly, h) in enumerate(zip(polys, hier[0])):
        if h[3] != -1: continue  # holes are attached to their parent below
        rings = [poly] + [polys[j] for j, hh in enumerate(hier[0]) if hh[3] == i]
        shapes.append([[(sx[int(x)], sy[int(y)]) for x, y in ring] for ring in rings])
    return shapes

def raster(shapes, shape):
    out = np.zeros(shape, np.uint8)
    for rings in shapes:
        cv2.fillPoly(out, [np.array(r, np.int32) for r in rings], 1)  # even-odd via rings
    return out

red_shapes = trace(red)
# White counters = opaque area that isn't red; draw the opaque silhouette white, red on top.
white_shapes = trace(opaque)

def iou(a, b):
    return (a & b).sum() / max((a | b).sum(), 1)
print(f"red IoU {iou(raster(red_shapes, red.shape), red):.5f}  opaque IoU {iou(raster(white_shapes, opaque.shape), opaque):.5f}", file=sys.stderr)
print(f"red shapes {len(red_shapes)} rings {sum(len(s) for s in red_shapes)} points {sum(len(r) for s in red_shapes for r in s)}; white shapes {len(white_shapes)}", file=sys.stderr)

norm = lambda shapes: [[[(round(ox + (x - x0) * scale, 3), round(oy + (y - y0) * scale, 3)) for x, y in ring] for ring in rings] for rings in shapes]
color = "#%02X%02X%02X" % tuple(np.median(src[red.astype(bool)][:, :3], axis=0).astype(int))
json.dump({"color": color, "red": norm(red_shapes), "white": norm(white_shapes)}, sys.stdout)
