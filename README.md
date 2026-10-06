# NutriVision AI

**Estimate calories and macronutrients from a single photo of a meal.**

NutriVision AI is a deep learning system that looks at a picture of a dish and directly predicts its
**calories, mass, protein, fat and carbohydrates**, with no food database lookup. A fine-tuned
**EfficientNet-B3** trained on the **Nutrition5K** dataset is served by a **FastAPI** backend and used
from a **Flutter** mobile app.

> Final-year project (PFA) at EMSI — 4IIR AI/Data Science, by **Mohamed Reda Ghalbi** and **Aymane Abounay**.
> The full report is available in [`PFA_Food_Final.pdf`](PFA_Food_Final.pdf).

---

## How it works

```
 Flutter app ──(photo, multipart)──▶ FastAPI /predict ──▶ EfficientNet-B3 regressor ──▶ 5 values
 (camera / gallery)                    resize 300×300        backbone + Dropout + Dense(5)   kcal, g, g, g, g
                                       ImageNet normalise    de-normalise (z-score)
```

| Output | Unit |
|---|---|
| Calories | kcal |
| Mass | g |
| Protein | g |
| Fat | g |
| Carbohydrates | g |

---

## Model (v4.1)

| | |
|---|---|
| Dataset | [Nutrition5K](https://github.com/google-research-datasets/Nutrition5k) — real cafeteria dishes with lab-measured nutrition |
| Backbone | EfficientNet-B3 (ImageNet pre-trained), input 300×300 |
| Head | Global average pooling → Dropout(0.3) → Dense(5) |
| Targets | 5 values, z-score normalised on the training set (multi-task: mass helps predict calories) |
| Loss | Huber (δ = 1.0), robust to very high-calorie outliers |
| Optimiser | AdamW, weight decay 1e-4, gradient clipping (max norm 1.0) |
| Schedule | 3-epoch linear warm-up, then cosine annealing |
| Training | Phase 1: head only, 20 epochs, lr 1e-3 · Phase 2: selective fine-tuning of the last 100 backbone layers, 20 epochs, lr 1e-4 · early stopping |
| Split | 70 / 15 / 15 (train / validation / test), seed 42 |

The full training pipeline is in [`PFA_Nutrition5K_v4_1.ipynb`](PFA_Nutrition5K_v4_1.ipynb) (built for Kaggle GPUs).
The trained weights are [`best_model_v4_1.pth`](best_model_v4_1.pth); the target normalisation statistics
are in [`backend/normalization_stats.json`](backend/normalization_stats.json)
(regenerate them with [`backend/export_stats.py`](backend/export_stats.py) if you retrain).

---

## Project structure

```
├── backend/
│   ├── app.py                    # FastAPI server (/health, /predict)
│   ├── model.py                  # NutritionRegressorV41 + weight loading
│   ├── normalization_stats.json  # target mean / std from the training set
│   ├── export_stats.py           # script to regenerate the stats on Kaggle
│   ├── requirements.txt
│   └── .env.example
├── mobile_app/                   # Flutter app (camera / gallery → results with charts)
│   ├── lib/
│   │   ├── main.dart
│   │   ├── screens/              # home_screen.dart, result_screen.dart
│   │   ├── services/api_service.dart
│   │   └── models/prediction.dart
│   └── pubspec.yaml
├── best_model_v4_1.pth           # trained weights (~43 MB)
├── PFA_Nutrition5K_v4_1.ipynb    # training notebook
└── PFA_Food_Final.pdf            # project report (FR)
```

---

## Getting started

### 1. Backend

Requires Python 3.10+.

```bash
cd backend
python -m venv venv
venv\Scripts\activate             # Windows  (source venv/bin/activate on Linux/macOS)
pip install -r requirements.txt
python app.py                     # → http://localhost:8000  (docs: /docs)
```

Optional settings (environment variables, see [`backend/.env.example`](backend/.env.example)):

| Variable | Default | Description |
|---|---|---|
| `MODEL_WEIGHTS` | `best_model_v4_1.pth` at the repo root | Path to the weights |
| `NORMALIZATION_STATS` | `backend/normalization_stats.json` | Target mean / std |
| `HOST` / `PORT` | `0.0.0.0` / `8000` | Server address |
| `CORS_ORIGINS` | `*` | Allowed origins, comma-separated |

Test it:

```bash
curl -F "file=@meal.jpg" http://localhost:8000/predict
```

Example response (values are illustrative):

```json
{
  "predictions": {
    "calories": { "value": 412.3, "unit": "kcal" },
    "mass":     { "value": 285.0, "unit": "g" },
    "protein":  { "value": 24.1,  "unit": "g" },
    "fat":      { "value": 18.6,  "unit": "g" },
    "carb":     { "value": 35.2,  "unit": "g" }
  },
  "inference_ms": 98.7
}
```

### 2. Mobile app

Requires the [Flutter SDK](https://docs.flutter.dev/get-started/install) (Dart ≥ 3.0).

```bash
cd mobile_app
flutter create --platforms=android,ios .   # generates the native android/ and ios/ folders
flutter pub get
```

Then add the permissions the app needs:

- **Android**: in `android/app/src/main/AndroidManifest.xml`, add before `<application>`:
  ```xml
  <uses-permission android:name="android.permission.INTERNET"/>
  <uses-permission android:name="android.permission.CAMERA"/>
  ```
  and `android:usesCleartextTraffic="true"` on the `<application>` tag to allow HTTP on a local network.
- **iOS**: in `ios/Runner/Info.plist`, add `NSCameraUsageDescription` and `NSPhotoLibraryUsageDescription`.

Run it, pointing the app at your backend:

```bash
flutter run                                              # Android emulator (uses http://10.0.2.2:8000)
flutter run --dart-define=API_URL=http://localhost:8000  # iOS simulator
flutter run --dart-define=API_URL=http://192.168.1.20:8000  # real phone: your PC's LAN IP
```

---

## Tech stack

**AI** — PyTorch, torchvision, EfficientNet-B3, scikit-learn, Kaggle GPUs ·
**Backend** — FastAPI, Uvicorn, Pillow, NumPy ·
**Mobile** — Flutter, `image_picker`, `http`, `fl_chart`, Google Fonts

## Authors

- **Mohamed Reda Ghalbi** — [@r0od3x](https://github.com/r0od3x)
- **Aymane Abounay**

> NutriVision AI gives estimates for informational purposes only and is not a substitute for professional dietary advice.
