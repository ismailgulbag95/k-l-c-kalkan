"""Build compact, alpha-clean runtime atlases from the authored PNG masters."""

from pathlib import Path

from PIL import Image, ImageFilter


ROOT = Path(__file__).parent
ALPHA_CUTOFF = 12
FOREGROUND_CUTOFF = 160
MATTE_GROW_PIXELS = 9


def clean_alpha(image: Image.Image, columns: int, rows: int) -> Image.Image:
    image = image.convert("RGBA")
    source_alpha = image.getchannel("A")
    cleaned = Image.new("L", image.size, 0)
    cell_w = image.width // columns
    cell_h = image.height // rows
    grow_size = MATTE_GROW_PIXELS * 2 + 1
    for row in range(rows):
        for column in range(columns):
            box = (column * cell_w, row * cell_h, (column + 1) * cell_w, (row + 1) * cell_h)
            alpha = source_alpha.crop(box)
            core = alpha.point(lambda value: 255 if value >= FOREGROUND_CUTOFF else 0)
            matte = core.filter(ImageFilter.MaxFilter(grow_size))
            retained = Image.composite(alpha, Image.new("L", alpha.size, 0), matte)
            retained = retained.point(lambda value: 0 if value < ALPHA_CUTOFF else value)
            cleaned.paste(retained, (box[0], box[1]))
    image.putalpha(cleaned)
    return image


def main() -> None:
    gear = clean_alpha(Image.open(ROOT / "hero_equipment_layers_master.png"), 3, 4)
    gear.save(ROOT / "hero_equipment_layers.png", optimize=True)

    # Keep the face as a standalone layer so all eight existing hairstyles can replace it.
    face = Image.open(ROOT / "hero_head_base_master.png").convert("RGBA")
    face_alpha = face.getchannel("A")
    face_core = face_alpha.point(lambda value: 255 if value >= FOREGROUND_CUTOFF else 0)
    face_matte = face_core.filter(ImageFilter.MaxFilter(31))
    face_alpha = Image.composite(face_alpha, Image.new("L", face_alpha.size, 0), face_matte)
    face.putalpha(face_alpha.point(lambda value: 0 if value < ALPHA_CUTOFF else value))
    bounds = face.getchannel("A").getbbox()
    if bounds is None:
        raise ValueError("Head base has no visible pixels")
    face = face.crop(bounds)
    face.thumbnail((416, 460), Image.Resampling.LANCZOS)
    head = Image.new("RGBA", (512, 512), (0, 0, 0, 0))
    head.alpha_composite(face, ((512 - face.width) // 2, 512 - face.height - 20))
    head.save(ROOT / "hero_head_base.png", optimize=True)

    # This mask is only for the standalone head source; battle body masks need redrawn layers.
    mask = Image.new("RGBA", head.size, (255, 255, 255, 0))
    source = head.load()
    out = mask.load()
    for y in range(head.height):
        for x in range(head.width):
            r, g, b, a = source[x, y]
            if a >= 72 and r > g * 1.12 and g > b * 1.16 and r - g < 112:
                out[x, y] = (255, 255, 255, a)
    mask.save(ROOT / "hero_head_skin_mask.png", optimize=True)


if __name__ == "__main__":
    main()
