import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../models/entities.dart';
import '../../../providers/app_providers.dart';

class FitnessTab extends ConsumerWidget {
  const FitnessTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fitness = ref.watch(fitnessLogsProvider).valueOrNull ?? const [];
    final weights = ref.watch(weightLogsProvider).valueOrNull ?? const [];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        Row(
          children: [
            Text('Fitness', style: Theme.of(context).textTheme.headlineMedium),
            const Spacer(),
            FilledButton(
              onPressed: () => _addActivity(context, ref),
              child: const Text('Add Activity'),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: () => _addWeight(context, ref),
              child: const Text('Log Weight'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          child: SizedBox(
            height: 220,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        for (var i = 0; i < weights.length; i++)
                          FlSpot(i.toDouble(), weights[i].weight),
                      ],
                      isCurved: true,
                      dotData: const FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        for (final item in fitness)
          Card(
            child: ListTile(
              title: Text(item.activityType),
              subtitle: Text(
                '${item.duration} min | ${item.caloriesBurned} kcal',
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _addActivity(BuildContext context, WidgetRef ref) async {
    final typeCtrl = TextEditingController(text: 'Running');
    final durationCtrl = TextEditingController();
    final calCtrl = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add fitness log'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: typeCtrl,
              decoration: const InputDecoration(labelText: 'Activity type'),
            ),
            TextField(
              controller: durationCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Duration (min)'),
            ),
            TextField(
              controller: calCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Calories burned'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final uid = ref.read(userIdProvider);
              if (uid == null) return;
              final log = FitnessLog(
                id: const Uuid().v4(),
                userId: uid,
                activityType: typeCtrl.text.trim(),
                duration: int.tryParse(durationCtrl.text) ?? 0,
                caloriesBurned: double.tryParse(calCtrl.text) ?? 0,
                timestamp: Timestamp.now(),
              );
              await ref.read(firestoreServiceProvider).saveFitnessLog(log);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _addWeight(BuildContext context, WidgetRef ref) async {
    final ctrl = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log weight'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Weight (kg)'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final uid = ref.read(userIdProvider);
              if (uid == null) return;
              final log = WeightLog(
                id: const Uuid().v4(),
                userId: uid,
                weight: double.tryParse(ctrl.text) ?? 0,
                timestamp: Timestamp.now(),
              );
              await ref.read(firestoreServiceProvider).saveWeightLog(log);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
