"""
Generate the Offline LAN Games Helper macOS icon.

The icon is original and generic: a monitor/gamepad with LAN nodes.
It uses no copyrighted game, launcher, platform, or store logos.
"""

from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw


BASE_DIR = Path(__file__).resolve().parent
ASSETS_DIR = BASE_DIR / "assets"
PNG_PATH = ASSETS_DIR / "offline_lan_helper.png"
ICNS_PATH = ASSETS_DIR / "offline_lan_helper.icns"


def draw_icon(size: int = 1024) -> Image.Image:
    scale = size / 256

    def s(value: int) -> int:
        return round(value * scale)

    image = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(image)

    draw.rounded_rectangle(
        (s(14), s(14), s(242), s(242)),
        radius=s(42),
        fill=(20, 83, 99, 255),
        outline=(103, 232, 249, 255),
        width=s(4),
    )
    draw.rounded_rectangle(
        (s(35), s(38), s(221), s(216)),
        radius=s(30),
        fill=(8, 145, 178, 255),
        outline=(207, 250, 254, 170),
        width=s(2),
    )

    # Monitor.
    draw.rounded_rectangle(
        (s(58), s(66), s(198), s(145)),
        radius=s(14),
        fill=(8, 47, 73, 255),
        outline=(236, 254, 255, 255),
        width=s(5),
    )
    draw.rectangle((s(112), s(146), s(144), s(166)), fill=(236, 254, 255, 255))
    draw.rounded_rectangle((s(89), s(165), s(167), s(177)), radius=s(6), fill=(236, 254, 255, 255))

    # LAN connections.
    center = (s(128), s(112))
    nodes = [(s(64), s(194)), (s(128), s(202)), (s(192), s(194))]
    for node in nodes:
        draw.line((center[0], center[1], node[0], node[1]), fill=(190, 242, 100, 255), width=s(5))
    for node in nodes:
        draw.ellipse(
            (node[0] - s(14), node[1] - s(14), node[0] + s(14), node[1] + s(14)),
            fill=(187, 247, 208, 255),
            outline=(22, 101, 52, 255),
            width=s(3),
        )

    # Generic gamepad.
    draw.rounded_rectangle(
        (s(76), s(96), s(180), s(136)),
        radius=s(19),
        fill=(15, 23, 42, 255),
        outline=(125, 211, 252, 255),
        width=s(3),
    )
    draw.rectangle((s(98), s(110), s(122), s(116)), fill=(240, 253, 250, 255))
    draw.rectangle((s(107), s(101), s(113), s(125)), fill=(240, 253, 250, 255))
    draw.ellipse((s(144), s(104), s(155), s(115)), fill=(240, 253, 250, 255))
    draw.ellipse((s(159), s(115), s(170), s(126)), fill=(240, 253, 250, 255))

    return image


def main() -> int:
    ASSETS_DIR.mkdir(exist_ok=True)
    image = draw_icon()
    image.save(PNG_PATH)
    image.save(ICNS_PATH, sizes=[(1024, 1024), (512, 512), (256, 256), (128, 128), (64, 64), (32, 32), (16, 16)])
    print(f"Wrote {PNG_PATH}")
    print(f"Wrote {ICNS_PATH}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
