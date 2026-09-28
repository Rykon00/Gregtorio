#!/usr/bin/env python3
"""Ergänzt fehlende englische Namen in locale/en/fork.cfg.

Liest eine Namensliste (eine Zeile pro Eintrag: "<section>\t<name>", section = item-name,
entity-name, fluid-name, technology-name, recipe-name) und schreibt für alle Einträge, die in
keiner locale/en/*.cfg stehen, einen aus der ID abgeleiteten Namen:
    luv-motor -> "LuV Motor", hsss-plate -> "HSS-S Plate", iv-industrial-mixer -> "Industrial Mixer (IV)"

    python tools/gen_locale.py namen.tsv
"""
import re, sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
LOC = ROOT / "locale/en"
OUT = LOC / "fork.cfg"

WORDS = {
    "ulv": "ULV", "lv": "LV", "mv": "MV", "hv": "HV", "ev": "EV", "iv": "IV", "luv": "LuV", "zpm": "ZPM",
    "uv": "UV", "uhv": "UHV", "uev": "UEV", "uiv": "UIV", "umv": "UMV", "uxv": "UXV",
    "hsss": "HSS-S", "hssg": "HSS-G", "hsse": "HSS-E", "rtm": "RTM", "ptfe": "PTFE", "me": "ME",
    "uhpic": "UHPIC", "hpic": "HPIC", "smd": "SMD", "cpu": "CPU", "ram": "RAM", "nand": "NAND", "nor": "NOR",
    "n": "N", "mk1": "MK1", "mk2": "MK2", "mk3": "MK3", "mk4": "MK4", "mk5": "MK5", "16x": "16x", "4x": "4x",
    "180k": "180k", "540k": "540k", "1080k": "1080k", "ii": "II", "itbtc": "ITBTC", "eic": "EIC",
}


SPECIAL = {"slice-n-splice": "Slice'n'Splice"}


def pretty(name):
    if name in SPECIAL:
        return SPECIAL[name]
    tok = name.split("-")
    suffix = ""
    # IV-Multiblocks heißen im Spiel nach der Maschine, das Tier kommt in Klammern
    if len(tok) > 2 and tok[0] in ("iv", "hv", "ev", "luv") and tok[1] in ("industrial", "large", "hyper", "magnetic",
                                                                         "fluid", "chemical", "turbocan", "zyngen"):
        suffix = f" ({WORDS[tok[0]]})"
        tok = tok[1:]
    words = [WORDS.get(t, t[:1].upper() + t[1:]) for t in tok]
    s = " ".join(words)
    return s + suffix


def existing_keys():
    keys = {}
    for f in LOC.glob("*.cfg"):
        if f == OUT:
            continue
        section = None
        for line in f.read_text(encoding="utf-8").splitlines():
            m = re.match(r"^\[(.+)\]$", line.strip())
            if m:
                section = m.group(1)
            elif "=" in line and section:
                keys.setdefault(section, set()).add(line.split("=", 1)[0].strip())
    return keys


def main():
    have = existing_keys()
    want = {}
    for line in Path(sys.argv[1]).read_text().splitlines():
        if "\t" not in line:
            continue
        sec, name = line.split("\t", 1)
        if name not in have.get(sec, set()):
            want.setdefault(sec, set()).add(name)
    out = ["# Automatisch erzeugt von tools/gen_locale.py (Namen aus den IDs abgeleitet).",
           "# Einträge hier dürfen gern von Hand verbessert werden; das Skript überschreibt nur fehlende."]
    old = {}
    if OUT.exists():
        section = None
        for line in OUT.read_text(encoding="utf-8").splitlines():
            m = re.match(r"^\[(.+)\]$", line.strip())
            if m:
                section = m.group(1)
            elif "=" in line and section and not line.startswith("#"):
                k, v = line.split("=", 1)
                old.setdefault(section, {})[k] = v
    total = 0
    for sec in sorted(set(want) | set(old)):
        entries = dict(old.get(sec, {}))
        for n in want.get(sec, ()):
            entries.setdefault(n, pretty(n))
        entries = {k: v for k, v in entries.items() if k not in have.get(sec, set())}
        if not entries:
            continue
        out.append(f"\n[{sec}]")
        for k in sorted(entries):
            out.append(f"{k}={entries[k]}")
            total += 1
    OUT.write_text("\n".join(out) + "\n", encoding="utf-8")
    print(f"{total} Einträge in {OUT.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
