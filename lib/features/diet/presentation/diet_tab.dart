import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_constants.dart';
import '../../../models/entities.dart';
import '../../../providers/app_providers.dart';

class DietTab extends ConsumerWidget {
  const DietTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(dietLogsProvider).valueOrNull ?? const [];
    final waterLogs = ref.watch(waterLogsProvider).valueOrNull ?? const [];

    final todayCalories = logs
        .where((e) => _isToday(e.timestamp.toDate()))
        .fold<double>(0, (total, item) => total + item.calories);

    final todayWater = waterLogs
        .where((e) => _isToday(e.timestamp.toDate()))
        .fold<int>(0, (total, item) => total + item.amount);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        Row(
          children: [
            Text(
              'Diet Tracking',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const Spacer(),
            FilledButton(
              onPressed: () => _addFood(context, ref),
              child: const Text('Log Food'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            title: const Text('Daily calories'),
            subtitle: Text('${todayCalories.toStringAsFixed(0)} kcal'),
            trailing: CircularProgressIndicator(
              value: (todayCalories / 2200).clamp(0, 1),
            ),
          ),
        ),
        Card(
          child: ListTile(
            title: const Text('Water intake'),
            subtitle: Text(
              '$todayWater ml / ${AppConstants.defaultWaterGoalMl} ml',
            ),
            trailing: IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _addWater(ref, 250),
            ),
          ),
        ),
        for (final log in logs)
          Card(
            child: ListTile(
              title: Text('${log.mealType}: ${log.foodName}'),
              subtitle: Text(
                'C ${log.calories}, P ${log.protein}, Cb ${log.carbs}, F ${log.fat}',
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _addFood(BuildContext context, WidgetRef ref) async {
    final mealCtrl = TextEditingController(text: 'Breakfast');
    final foodCtrl = TextEditingController();
    final calCtrl = TextEditingController();
    final proteinCtrl = TextEditingController();
    final carbsCtrl = TextEditingController();
    final fatCtrl = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add food log'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: mealCtrl,
                decoration: const InputDecoration(labelText: 'Meal type'),
              ),
              TextField(
                controller: foodCtrl,
                decoration: const InputDecoration(labelText: 'Food name'),
              ),
              TextField(
                controller: calCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Calories'),
              ),
              TextField(
                controller: proteinCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Protein'),
              ),
              TextField(
                controller: carbsCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Carbs'),
              ),
              TextField(
                controller: fatCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Fat'),
              ),
            ],
          ),
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
              final log = DietLog(
                id: const Uuid().v4(),
                userId: uid,
                mealType: mealCtrl.text.trim(),
                foodName: foodCtrl.text.trim(),
                calories: double.tryParse(calCtrl.text) ?? 0,
                protein: double.tryParse(proteinCtrl.text) ?? 0,
                carbs: double.tryParse(carbsCtrl.text) ?? 0,
                fat: double.tryParse(fatCtrl.text) ?? 0,
                timestamp: Timestamp.now(),
              );
              await ref.read(firestoreServiceProvider).saveDietLog(log);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _addWater(WidgetRef ref, int amount) async {
    final uid = ref.read(userIdProvider);
    if (uid == null) return;
    await ref
        .read(firestoreServiceProvider)
        .saveWaterLog(
          WaterLog(
            id: const Uuid().v4(),
            userId: uid,
            amount: amount,
            timestamp: Timestamp.now(),
          ),
        );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}
