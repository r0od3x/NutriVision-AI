"""
FastAPI backend — Nutritional Estimation API.
Charge le modèle EfficientNet-B3 v4.1 et expose un endpoint /predict.
"""

import io
import json
import time
from pathlib import Path

import numpy as np
import torch
from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from PIL import Image
from torchvision import transforms

from model import NutritionRegressorV41, load_model

# ── Config ────────────────────────────────────────────────────
BASE_DIR = Path(__file__).parent.parent  # PFA_Nutrition/
WEIGHTS_PATH = BASE_DIR / "best_model_v4_1.pth"
STATS_PATH = BASE_DIR / "backend" / "normalization_stats.json"

DEVICE = "cuda" if torch.cuda.is_available() else "cpu"
IMG_SIZE = 300
IMAGENET_MEAN = [0.485, 0.456, 0.406]
IMAGENET_STD = [0.229, 0.224, 0.225]

TARGET_NAMES = ["calories", "mass", "protein", "fat", "carb"]
TARGET_UNITS = ["kcal", "g", "g", "g", "g"]

# ── Chargement modèle + stats ────────────────────────────────
print(f"[*] Device: {DEVICE}")
print(f"[*] Chargement du modèle depuis {WEIGHTS_PATH} ...")
model = load_model(str(WEIGHTS_PATH), device=DEVICE)
print("[+] Modèle chargé.")

# Stats de normalisation (mean/std du train set)
if not STATS_PATH.exists():
    raise FileNotFoundError(
        f"Fichier {STATS_PATH} introuvable.\n"
        "Lance le script export_stats.py sur Kaggle pour le générer."
    )

with open(STATS_PATH) as f:
    stats = json.load(f)

target_mean = torch.tensor(stats["target_mean"], dtype=torch.float32).to(DEVICE)
target_std = torch.tensor(stats["target_std"], dtype=torch.float32).to(DEVICE)
print(f"[+] Stats de normalisation chargées: {STATS_PATH}")

# ── Transforms (évaluation) ──────────────────────────────────
eval_transform = transforms.Compose([
    transforms.Resize((IMG_SIZE, IMG_SIZE)),
    transforms.ToTensor(),
    transforms.Normalize(mean=IMAGENET_MEAN, std=IMAGENET_STD),
])

# ── FastAPI ───────────────────────────────────────────────────
app = FastAPI(
    title="PFA Nutrition API",
    description="Prédiction nutritionnelle par image — EfficientNet-B3 v4.1",
    version="1.0.0",
)

# CORS ouvert (pour Flutter et tests)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/health")
def health():
    return {"status": "ok", "device": DEVICE, "model": "v4.1"}


@app.post("/predict")
async def predict(file: UploadFile = File(...)):
    """
    Reçoit une image (JPEG/PNG), retourne les 5 valeurs nutritionnelles.
    """
    # Validation (content_type peut être absent en Flutter Web multipart)
    # On tente de lire l'image directement — PIL lèvera une exception si invalide

    try:
        contents = await file.read()
        image = Image.open(io.BytesIO(contents)).convert("RGB")
    except Exception:
        raise HTTPException(400, "Impossible de lire l'image.")

    # Prétraitement
    img_tensor = eval_transform(image).unsqueeze(0).to(DEVICE)  # (1, 3, 300, 300)

    # Inférence
    t0 = time.time()
    with torch.no_grad():
        preds_normalized = model(img_tensor)  # (1, 5) en espace Z-score

    # Dé-normalisation
    preds = preds_normalized * target_std + target_mean
    preds = preds.squeeze(0).cpu().numpy()

    # Clamp négatifs à 0
    preds = np.maximum(preds, 0.0)

    inference_ms = (time.time() - t0) * 1000

    # Réponse
    result = {
        "predictions": {
            name: {"value": round(float(preds[i]), 1), "unit": unit}
            for i, (name, unit) in enumerate(zip(TARGET_NAMES, TARGET_UNITS))
        },
        "inference_ms": round(inference_ms, 1),
    }
    return result


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
