import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../models/entities.dart';
import '../../../providers/app_providers.dart';

class HabitsTab extends ConsumerWidget {
  const HabitsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitsProvider).valueOrNull ?? const [];
    final todayKey = _todayKey();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        Row(
          children: [
            Text('Habits', style: Theme.of(context).textTheme.headlineMedium),
            const Spacer(),
            FilledButton(
              onPressed: () => _createHabit(context, ref),
              child: const Text('Add Habit'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        for (final habit in habits)
          Card(
            child: ListTile(
              title: Text(habit.habitName),
              subtitle: Text(
                'Streak: ${habit.streak} days | ${habit.frequency}',
              ),
              leading: SizedBox(
                height: 44,
                width: 44,
                child: CircularProgressIndicator(
                  value: _completionRate(habit),
                  backgroundColor: Colors.white12,
                ),
              ),
              trailing: Checkbox(
                value: habit.completionHistory[todayKey] ?? false,
                onChanged: (v) async {
                  final map = Map<String, bool>.from(habit.completionHistory);
                  map[todayKey] = v ?? false;
                  final updated = HabitItem(
                    id: habit.id,
                    userId: habit.userId,
                    habitName: habit.habitName,
                    frequency: habit.frequency,
                    streak: _computeStreak(map),
                    completionHistory: map,
                  );
                  await ref.read(firestoreServiceProvider).saveHabit(updated);
                },
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _createHabit(BuildContext context, WidgetRef ref) async {
    final ctrl = TextEditingController();
    var frequency = 'Daily';
    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('New Habit'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: ctrl,
                decoration: const InputDecoration(labelText: 'Habit name'),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: frequency,
                items: const ['Daily', 'Weekly']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => frequency = v ?? 'Daily'),
                decoration: const InputDecoration(labelText: 'Frequency'),
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
                final habit = HabitItem(
                  id: const Uuid().v4(),
                  userId: uid,
                  habitName: ctrl.text.trim(),
                  frequency: frequency,
                  streak: 0,
                  completionHistory: const {},
                );
                await ref.read(firestoreServiceProvider).saveHabit(habit);
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }

  int _computeStreak(Map<String, bool> map) {
    var streak = 0;
    var date = DateTime.now();
    while (true) {
      final key = '${date.year}-${date.month}-${date.day}';
      if (map[key] == true) {
        streak++;
        date = date.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  double _completionRate(HabitItem habit) {
    if (habit.completionHistory.isEmpty) return 0;
    final done = habit.completionHistory.values.where((v) => v).length;
    return done / habit.completionHistory.length;
  }
}
