"""
============================================================
  SCRIPT À COLLER DANS UNE CELLULE KAGGLE
  Exporte les stats de normalisation (mean/std) en JSON.

  Après exécution, télécharge le fichier JSON généré
  et place-le dans : backend/normalization_stats.json
============================================================
"""

import json
import numpy as np
import pandas as pd

# ── Adapter ces chemins à ton notebook Kaggle ──
BASE_DIR = '/kaggle/input/datasets/gillesokhin/nutrition5k-dataset'
CSV_PATH = f'{BASE_DIR}/dish_nutrition_values.csv'

TARGET_COLS = ['calories', 'mass', 'protein', 'fat', 'carb']

# ── Charger le CSV ──
df = pd.read_csv(CSV_PATH)
print(f"Total dishes: {len(df)}")

# ── Même split que dans le notebook v4.1 ──
# Tu dois reproduire exactement le même train set.
# Si tu as utilisé train_test_split avec un random_state, utilise le même.
# Sinon, adapte cette section à ton code de split.

from sklearn.model_selection import train_test_split

# Split 70/15/15 — UTILISE LE MÊME random_state QUE DANS TON NOTEBOOK
train_df, temp_df = train_test_split(df, test_size=0.30, random_state=42)
val_df, test_df = train_test_split(temp_df, test_size=0.50, random_state=42)

print(f"Train: {len(train_df)}, Val: {len(val_df)}, Test: {len(test_df)}")

# ── Calculer mean/std sur le train set UNIQUEMENT ──
target_mean = train_df[TARGET_COLS].mean().values.astype(np.float64).tolist()
target_std = train_df[TARGET_COLS].std().values.astype(np.float64).tolist()

print("\nTarget normalization stats (train set):")
for i, col in enumerate(TARGET_COLS):
    print(f"  {col:<12} mean={target_mean[i]:>8.2f}  std={target_std[i]:>8.2f}")

# ── Exporter en JSON ──
stats = {
    "target_cols": TARGET_COLS,
    "target_mean": target_mean,
    "target_std": target_std,
}

output_path = "/kaggle/working/normalization_stats.json"
with open(output_path, "w") as f:
    json.dump(stats, f, indent=2)

print(f"\n[OK] Stats exportées dans : {output_path}")
print("Télécharge ce fichier et place-le dans backend/normalization_stats.json")
