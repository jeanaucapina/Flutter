import fitz
from pathlib import Path

pdf = Path(r"c:/Users/jeanj/Documents/GitHub/Flutter/diapositivas/conferencia_ucuenca.pdf")
outdir = Path(r"c:/Users/jeanj/Documents/GitHub/Flutter/diapositivas/tikz_png")
outdir.mkdir(exist_ok=True)

doc = fitz.open(pdf)

# Slide 5 = FLUJO (0-based index 4)
page = doc[4]
mat = fitz.Matrix(2.2, 2.2)

full_path = outdir / "slide_flujo_seleccion.png"
page.get_pixmap(matrix=mat, alpha=False).save(full_path)

# Crop where the central TikZ flow is located
w = page.rect.width
crop = fitz.Rect(20, 105, w - 20, 315)
crop_path = outdir / "tikz_flujo_seleccion_crop.png"
page.get_pixmap(matrix=mat, clip=crop, alpha=False).save(crop_path)

print(f"Saved: {full_path}")
print(f"Saved: {crop_path}")
print(f"Total pages: {len(doc)}")
