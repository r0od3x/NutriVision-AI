import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/prediction.dart';

class ResultScreen extends StatelessWidget {
  final File image;
  final PredictionResult result;

  const ResultScreen({super.key, required this.image, required this.result});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Résultats'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image ──
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(
                image,
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Inférence: ${result.inferenceMs.toStringAsFixed(0)} ms',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── Calories (card principale) ──
            _CalorieCard(calories: result.calories),
            const SizedBox(height: 16),

            // ── Masse ──
            _NutrientTile(
              icon: Icons.scale,
              label: 'Masse estimée',
              value: result.mass.value,
              unit: result.mass.unit,
              color: Colors.grey.shade600,
            ),
            const SizedBox(height: 16),

            // ── Macronutriments ──
            Text(
              'Macronutriments',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _MacroCard(
                    label: 'Protéines',
                    value: result.protein.value,
                    unit: 'g',
                    color: const Color(0xFF42A5F5),
                    icon: Icons.fitness_center,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MacroCard(
                    label: 'Lipides',
                    value: result.fat.value,
                    unit: 'g',
                    color: const Color(0xFFFFA726),
                    icon: Icons.water_drop,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MacroCard(
                    label: 'Glucides',
                    value: result.carb.value,
                    unit: 'g',
                    color: const Color(0xFF66BB6A),
                    icon: Icons.grain,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Pie chart répartition énergétique ──
            Text(
              'Répartition énergétique',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: _EnergyPieChart(result: result),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ── Widgets privés ──────────────────────────────────────────

class _CalorieCard extends StatelessWidget {
  final NutrientValue calories;
  const _CalorieCard({required this.calories});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade600, Colors.deepOrange.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(Icons.local_fire_department, color: Colors.white, size: 36),
          const SizedBox(height: 8),
          Text(
            '${calories.value.toStringAsFixed(0)}',
            style: theme.textTheme.displaySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'kilocalories',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}

class _NutrientTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final double value;
  final String unit;
  final Color color;

  const _NutrientTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 12),
          Text(label, style: theme.textTheme.bodyLarge),
          const Spacer(),
          Text(
            '${value.toStringAsFixed(1)} $unit',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _MacroCard extends StatelessWidget {
  final String label;
  final double value;
  final String unit;
  final Color color;
  final IconData icon;

  const _MacroCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value.toStringAsFixed(1),
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(unit, style: theme.textTheme.bodySmall),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _EnergyPieChart extends StatelessWidget {
  final PredictionResult result;
  const _EnergyPieChart({required this.result});

  @override
  Widget build(BuildContext context) {
    // Calories par macro : Prot=4 kcal/g, Fat=9 kcal/g, Carb=4 kcal/g
    final protKcal = result.protein.value * 4;
    final fatKcal = result.fat.value * 9;
    final carbKcal = result.carb.value * 4;
    final total = protKcal + fatKcal + carbKcal;

    if (total == 0) return const Center(child: Text('Pas de données'));

    return Row(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sectionsSpace: 3,
              centerSpaceRadius: 40,
              sections: [
                PieChartSectionData(
                  value: protKcal,
                  color: const Color(0xFF42A5F5),
                  title: '${(protKcal / total * 100).toStringAsFixed(0)}%',
                  titleStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  radius: 50,
                ),
                PieChartSectionData(
                  value: fatKcal,
                  color: const Color(0xFFFFA726),
                  title: '${(fatKcal / total * 100).toStringAsFixed(0)}%',
                  titleStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  radius: 50,
                ),
                PieChartSectionData(
                  value: carbKcal,
                  color: const Color(0xFF66BB6A),
                  title: '${(carbKcal / total * 100).toStringAsFixed(0)}%',
                  titleStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  radius: 50,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _LegendItem(color: const Color(0xFF42A5F5), label: 'Protéines'),
            const SizedBox(height: 8),
            _LegendItem(color: const Color(0xFFFFA726), label: 'Lipides'),
            const SizedBox(height: 8),
            _LegendItem(color: const Color(0xFF66BB6A), label: 'Glucides'),
          ],
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}
