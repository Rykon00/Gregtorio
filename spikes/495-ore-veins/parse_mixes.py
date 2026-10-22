"""Spike #495: parse GT5-Unofficial's OreMixes.java into JSON (one entry per mix)."""
import json
import re
import sys

src = open(sys.argv[1], encoding="utf8").read()
body = src[src.index("public enum OreMixes {"):]
starts = list(re.finditer(r"^    (\w+)\(new OreMixBuilder\(\)", body, re.M))
entries = [(m.group(1), body[m.end():(starts[i + 1].start() if i + 1 < len(starts) else len(body))])
           for i, m in enumerate(starts)]


def mat(call, text):
    m = re.search(r"\." + call + r"\(([^()]*?)\)", text)
    if not m:
        return None
    return m.group(1).strip().split(".")[-1]


out = []
for i, e in enumerate(entries, 1):
    name, text = e
    dims = []
    for d in re.finditer(r"\.enableInDim\((.*?)\)", text, re.S):
        dims += [x.strip() for x in d.group(1).split(",") if x.strip()]
    rec = {
        "id": i,
        "name": name,
        "weight": int(re.search(r"\.weight\((\d+)\)", text).group(1)),
        "density": int(re.search(r"\.density\((\d+)\)", text).group(1)),
        "size": int(re.search(r"\.size\((\d+)\)", text).group(1)),
        "dims": dims,
        "primary": mat("primary", text),
        "secondary": mat("secondary", text),
        "between": mat("inBetween", text),
        "sporadic": mat("sporadic", text),
    }
    out.append(rec)
json.dump(out, open(sys.argv[2], "w", encoding="utf8"), indent=1)
print(len(out), "mixes")
for d in ["OW", "NETHER", "TWILIGHT_FOREST", "THE_END"]:
    vs = [r for r in out if d in r["dims"]]
    print(d, len(vs), [r["name"] for r in vs])
