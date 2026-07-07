"""
NutritionRegressorV41 — EfficientNet-B3 + tête de régression simplifiée.
Identique à la classe du notebook v4.1.
"""

import torch
import torch.nn as nn
from torchvision import models


class NutritionRegressorV41(nn.Module):
    """
    EfficientNet-B3 + head simplifié.
    Head: GAP (built-in) -> Dropout(0.3) -> Dense(5)
    5 targets: calories, mass, protein, fat, carb
    """

    def __init__(self, num_targets=5, dropout=0.3):
        super().__init__()
        base = models.efficientnet_b3(weights=None)  # pas besoin des poids ImageNet ici
        in_features = base.classifier[1].in_features  # 1536
        base.classifier = nn.Identity()
        self.backbone = base

        self.head = nn.Sequential(
            nn.Dropout(dropout),
            nn.Linear(in_features, num_targets),
        )

    def forward(self, x):
        features = self.backbone(x)
        return self.head(features)


def load_model(weights_path: str, device: str = "cpu") -> NutritionRegressorV41:
    """Charge le modèle depuis un fichier .pth."""
    model = NutritionRegressorV41(num_targets=5, dropout=0.3)
    state_dict = torch.load(weights_path, map_location=device, weights_only=True)
    model.load_state_dict(state_dict)
    model.to(device)
    model.eval()
    return model
