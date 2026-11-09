"""Share identical large inline CSS across the nine published course pages.

Run after a successful Quarto render: python scripts/optimize_embedded_css.py
Use --pilot to change only assignment/05-practico.html first.
This script never reads QMD files or executes R.
"""

from __future__ import annotations

import argparse
import hashlib
import os
import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
DOCS = ROOT / "docs"
PAGES = [
    "assignment/practico-positron.html",
    "assignment/03-practico.html",
    "assignment/04-practico.html",
    "assignment/05-practico.html",
    "assignment/06-practico.html",
    "assignment/07-practico.html",
    "assignment/08-practico.html",
    "assignment/09-practico.html",
    "content/13-content.html",
]
STYLE = re.compile(r'<style\b(?P<attrs>[^>]*)>(?P<body>.*?)</style\s*>', re.I | re.S)
MIN_BYTES = 100_000
SHARED_HASHES = {
    "a4dcc0b722b5dfa64d6ad9caca6178d1dd370879d569a9058ec66396f8f3c9a9",
    "cd81c0c40d3dcbd876230a0db332ca2442bad6630ca3972f1eb74830d7a6456b",
}


def optimize(page: Path, asset_dir: Path) -> tuple[int, int]:
    original = page.read_text(encoding="utf-8")
    changes: list[tuple[int, int, str]] = []
    for match in STYLE.finditer(original):
        # Only ordinary CSS style blocks. Keep blocks with IDs, media, nonce, or
        # other attributes in place since their semantics may depend on those.
        attrs = match.group("attrs").strip().lower()
        if attrs not in ("", 'type="text/css"', "type='text/css'"):
            continue
        css = match.group("body")
        if len(css.encode("utf-8")) < MIN_BYTES:
            continue
        digest = hashlib.sha256(css.encode("utf-8")).hexdigest()
        if digest not in SHARED_HASHES:
            continue
        asset = asset_dir / f"{digest}.css"
        if asset.exists() and asset.read_bytes() != css.encode("utf-8"):
            raise RuntimeError(f"Hash collision or corrupted asset: {asset}")
        asset_dir.mkdir(parents=True, exist_ok=True)
        if not asset.exists():
            asset.write_bytes(css.encode("utf-8"))
        href = Path(os.path.relpath(asset, page.parent)).as_posix()
        changes.append((match.start(), match.end(), f'<link rel="stylesheet" href="{href}">'))
    if not changes:
        return len(original.encode("utf-8")), len(original.encode("utf-8"))
    result = original
    for start, end, replacement in reversed(changes):
        result = result[:start] + replacement + result[end:]
    page.write_text(result, encoding="utf-8", newline="")
    return len(original.encode("utf-8")), len(result.encode("utf-8"))


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--pilot", action="store_true", help="Optimize only assignment/05-practico.html")
    args = parser.parse_args()
    asset_dir = DOCS / "optimized-assets"
    for relative in (["assignment/05-practico.html"] if args.pilot else PAGES):
        before, after = optimize(DOCS / relative, asset_dir)
        print(f"{relative}: {before:,} -> {after:,} bytes")


if __name__ == "__main__":
    main()
