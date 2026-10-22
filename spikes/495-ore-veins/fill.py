import collections, sys
rows = [l.split() for l in open(sys.argv[1]) if l.strip()]
agg = collections.defaultdict(lambda: [0, 0, 0.0])
for surf, name, r, n in rows:
    if not surf.startswith('big'):
        continue
    a = agg[(surf, name)]; r = float(r); a[0] += 1; a[1] += int(n); a[2] += 3.14159 * r * r
for (surf, name), (c, n, area) in sorted(agg.items()):
    print(f"{surf:14s} {name:18s} veins {c:2d}  ore tiles/vein {n/c:7.0f}  fill {100*n/area:5.1f}%")
for surf in ('big-ow-fill1', 'big-ow-fill3'):
    c = sum(v[0] for k, v in agg.items() if k[0] == surf); n = sum(v[1] for k, v in agg.items() if k[0] == surf)
    a = sum(v[2] for k, v in agg.items() if k[0] == surf)
    print(surf, 'all veins', c, 'avg ore tiles', round(n / c), 'avg area', round(a / c), 'fill', round(100 * n / a, 1))
