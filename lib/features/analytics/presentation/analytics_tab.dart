import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/app_providers.dart';

class AnalyticsTab extends ConsumerWidget {
  const AnalyticsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(tasksProvider).valueOrNull ?? const [];
    final habits = ref.watch(habitsProvider).valueOrNull ?? const [];
    final diet = ref.watch(dietLogsProvider).valueOrNull ?? const [];
    final weight = ref.watch(weightLogsProvider).valueOrNull ?? const [];

    final completedTasks = tasks
        .where((t) => t.status == 'completed')
        .length
        .toDouble();
    final pendingTasks = (tasks.length - completedTasks).toDouble();
    final habitDone = habits
        .expand((h) => h.completionHistory.values)
        .where((v) => v)
        .length
        .toDouble();
    final habitMissed = habits
        .expand((h) => h.completionHistory.values)
        .where((v) => !v)
        .length
        .toDouble();
    final productivity = tasks.isEmpty
        ? 0
        : (completedTasks / tasks.length * 100);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Analytics', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 12),
        Card(
          child: SizedBox(
            height: 220,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(value: completedTasks, title: 'Done'),
                  PieChartSectionData(value: pendingTasks, title: 'Pending'),
                ],
              ),
            ),
          ),
        ),
        Card(
          child: SizedBox(
            height: 220,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(value: habitDone, title: 'Habit done'),
                  PieChartSectionData(
                    value: habitMissed == 0 ? 1 : habitMissed,
                    title: 'Habit missed',
                  ),
                ],
              ),
            ),
          ),
        ),
        Card(
          child: ListTile(
            title: const Text('Daily calorie intake entries'),
            subtitle: Text('${diet.length} logs tracked'),
          ),
        ),
        Card(
          child: ListTile(
            title: const Text('Weight trend points'),
            subtitle: Text('${weight.length} measurements'),
          ),
        ),
        Card(
          child: ListTile(
            title: const Text('Productivity score'),
            subtitle: Text('${productivity.toStringAsFixed(1)}%'),
          ),
        ),
      ],
    );
  }
}
