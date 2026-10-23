#!/usr/bin/env python3
"""Check the Simplified Chinese catalog before a release.

Run from anywhere: `python3 scripts/check-localization.py`.

It fails when a catalog key has no zh-Hans translation, when a translation is
empty, when the format placeholders differ from the English source, or when an
`L("...")` call in the Swift sources has no catalog entry.
"""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CATALOG = ROOT / "Compositor" / "Localizable.xcstrings"
SOURCES = ROOT / "Compositor"

# Words that stay the same in Chinese: brands, file formats, color spaces.
SAME_AS_ENGLISH = {
    "Compositor", "Photoshop", "Adobe", "CMYK", "RGB", "HSL", "ICC", "sRGB",
    "Display P3", "PSD", "PSB", "PDF", "GIF", "PNG", "JPEG", "TIFF", "EXR",
    "HEIC", "WebP", "SVG", "DPI", "px", "K", "EV", "Camera Raw", "GPU",
    "ASCII", "Bayer 2 × 2", "Bayer 4 × 4", "Bayer 8 × 8", "Floyd–Steinberg",
}

PLACEHOLDER = re.compile(r"%(?:\d+\$)?(?:lld|llu|ld|lu|d|u|f|@|%)")


def placeholders(text: str) -> list[str]:
    """Format specifiers in `text`, ignoring the literal percent escape."""
    return [spec for spec in PLACEHOLDER.findall(text) if spec != "%%"]


def swift_literal_keys() -> set[str]:
    """The literal keys passed to `L("...")` anywhere in the app target."""
    keys: set[str] = set()
    pattern = re.compile(r'(?<![A-Za-z0-9_])L\(\s*"((?:[^"\\]|\\.)*)"')
    for source in SOURCES.rglob("*.swift"):
        text = source.read_text(encoding="utf-8")
        for match in pattern.finditer(text):
            key = match.group(1).replace('\\"', '"').replace("\\\\", "\\")
            if "\\(" not in key:
                keys.add(key)
    return keys


def main() -> int:
    catalog = json.loads(CATALOG.read_text(encoding="utf-8"))["strings"]
    problems: list[str] = []
    warnings: list[str] = []

    for key, entry in catalog.items():
        translation = (
            entry.get("localizations", {})
            .get("zh-Hans", {})
            .get("stringUnit", {})
            .get("value")
        )
        if not translation:
            problems.append(f"missing zh-Hans: {key!r}")
            continue
        if not translation.strip() and key.strip():
            problems.append(f"empty zh-Hans: {key!r}")
            continue
        if len(placeholders(key)) != len(placeholders(translation)):
            problems.append(
                f"placeholder mismatch: {key!r} -> {translation!r} "
                f"({placeholders(key)} vs {placeholders(translation)})"
            )
        if translation == key and key not in SAME_AS_ENGLISH:
            warnings.append(f"same as English: {key!r}")

    missing_runtime = sorted(swift_literal_keys() - set(catalog))
    for key in missing_runtime:
        problems.append(f"L() key not in catalog: {key!r}")

    print(f"catalog keys: {len(catalog)}")
    print(f"L() keys found: {len(swift_literal_keys())}")
    print(f"problems: {len(problems)}")
    for problem in problems:
        print("  ✗", problem)
    print(f"warnings: {len(warnings)}")
    for warning in warnings:
        print("  !", warning)
    return 1 if problems else 0


if __name__ == "__main__":
    sys.exit(main())
