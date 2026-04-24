"""
Extracts frames from MP4 videos for use with LaTeX animate package.
Produces one folder per video with zero-padded PNG frames.
"""
import cv2
import os

VIDEOS_DIR = "VIDEOS"
FRAMES_DIR = "frames"
TARGET_FPS = 10      # frames per second in the animation
MAX_DURATION = 12    # seconds max (keep PDFs manageable)
WIDTH = 480          # resize width in pixels

jobs = [
    ("Ejemplo_Visitante_Busqueda.mp4",              "visitante_busqueda"),
    ("Ejemplo_Estudiante_Horario_Navegacion.mp4",   "estudiante_horario"),
    ("Ejemplo_navegaciontentreplantas.mp4",         "navegacion_plantas"),
    ("Ejemplo_accesibilidad_modooscuro-texto.mp4",  "accesibilidad"),
    ("Ejemplo_Estudiante_tasks.mp4",                "estudiante_tasks"),
]

os.makedirs(FRAMES_DIR, exist_ok=True)

for mp4_name, folder_name in jobs:
    mp4_path = os.path.join(VIDEOS_DIR, mp4_name)
    out_dir  = os.path.join(FRAMES_DIR, folder_name)
    os.makedirs(out_dir, exist_ok=True)

    cap = cv2.VideoCapture(mp4_path)
    if not cap.isOpened():
        print(f"  ERROR: cannot open {mp4_path}")
        continue

    native_fps = cap.get(cv2.CAP_PROP_FPS) or 30
    total_frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
    duration = total_frames / native_fps
    cap_duration = min(duration, MAX_DURATION)
    step = max(1, round(native_fps / TARGET_FPS))   # take every Nth native frame

    print(f"{mp4_name}: {native_fps:.1f}fps, {duration:.1f}s → step={step}, "
          f"capped at {cap_duration:.1f}s")

    frame_idx = 0
    saved = 0
    max_frames = int(cap_duration * native_fps)

    while True:
        ret, frame = cap.read()
        if not ret or frame_idx >= max_frames:
            break
        if frame_idx % step == 0:
            # resize keeping aspect ratio
            h, w = frame.shape[:2]
            new_w = WIDTH
            new_h = int(h * new_w / w)
            frame = cv2.resize(frame, (new_w, new_h))
            out_path = os.path.join(out_dir, f"{saved:04d}.png")
            cv2.imwrite(out_path, frame)
            saved += 1
        frame_idx += 1

    cap.release()
    print(f"  → {saved} frames saved to {out_dir}/")

print("\nDone.")
