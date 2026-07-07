/// Résultat de prédiction nutritionnelle.
class NutrientValue {
  final String name;
  final double value;
  final String unit;

  NutrientValue({required this.name, required this.value, required this.unit});

  factory NutrientValue.fromJson(String name, Map<String, dynamic> json) {
    return NutrientValue(
      name: name,
      value: (json['value'] as num).toDouble(),
      unit: json['unit'] as String,
    );
  }
}

class PredictionResult {
  final List<NutrientValue> nutrients;
  final double inferenceMs;

  PredictionResult({required this.nutrients, required this.inferenceMs});

  factory PredictionResult.fromJson(Map<String, dynamic> json) {
    final preds = json['predictions'] as Map<String, dynamic>;
    final nutrients = preds.entries.map((e) {
      return NutrientValue.fromJson(e.key, e.value as Map<String, dynamic>);
    }).toList();

    return PredictionResult(
      nutrients: nutrients,
      inferenceMs: (json['inference_ms'] as num).toDouble(),
    );
  }

  NutrientValue get calories => nutrients.firstWhere((n) => n.name == 'calories');
  NutrientValue get mass => nutrients.firstWhere((n) => n.name == 'mass');
  NutrientValue get protein => nutrients.firstWhere((n) => n.name == 'protein');
  NutrientValue get fat => nutrients.firstWhere((n) => n.name == 'fat');
  NutrientValue get carb => nutrients.firstWhere((n) => n.name == 'carb');
}
