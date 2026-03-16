import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/calorie_calculator.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../providers/app_providers.dart';

class HomeDashboardTab extends ConsumerStatefulWidget {
  const HomeDashboardTab({super.key});

  @override
  ConsumerState<HomeDashboardTab> createState() => _HomeDashboardTabState();
}

class _HomeDashboardTabState extends ConsumerState<HomeDashboardTab> {
  List<String> _layout = [
    'tasks',
    'habits',
    'calories',
    'water',
    'weight',
    'ai',
  ];

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_loadLayout);
  }

  Future<void> _loadLayout() async {
    final prefs = await ref.read(sharedPrefsProvider.future);
    final raw = prefs.getString('dashboard_layout');
    if (raw == null) return;
    final decoded = List<String>.from(jsonDecode(raw) as List<dynamic>);
    if (!mounted || decoded.isEmpty) return;
    setState(() => _layout = decoded);
  }

  Future<void> _saveLayout() async {
    final prefs = await ref.read(sharedPrefsProvider.future);
    await prefs.setString('dashboard_layout', jsonEncode(_layout));
  }

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(tasksProvider).valueOrNull ?? const [];
    final habits = ref.watch(habitsProvider).valueOrNull ?? const [];
    final diet = ref.watch(dietLogsProvider).valueOrNull ?? const [];
    final water = ref.watch(waterLogsProvider).valueOrNull ?? const [];
    final weights = ref.watch(weightLogsProvider).valueOrNull ?? const [];
    final profile = ref.watch(userProfileStreamProvider).valueOrNull;

    final caloriesToday = diet
        .where((d) => _isToday(d.timestamp.toDate()))
        .fold<double>(0, (sum, item) => sum + item.calories);
    final waterToday = water
        .where((w) => _isToday(w.timestamp.toDate()))
        .fold<int>(0, (sum, item) => sum + item.amount);
    final completedTasks = tasks.where((t) => t.status == 'completed').length;
    final completedHabits = habits
        .where((h) => h.completionHistory[_todayKey()] == true)
        .length;

    final bmr = profile == null
        ? 0.0
        : calculateBmr(
            gender: profile.gender,
            age: profile.age,
            weightKg: profile.weight,
            heightCm: profile.height,
          );
    final calorieTarget = profile == null
        ? 2000.0
        : calculateCalorieTarget(bmr: bmr, fitnessGoal: profile.fitnessGoal);

    final cards = <String, Widget>{
      'tasks': _metricCard(
        'Today\'s tasks',
        '$completedTasks/${tasks.length} done',
        Icons.checklist,
      ),
      'habits': _metricCard(
        'Habit progress',
        '$completedHabits/${habits.length} complete',
        Icons.repeat,
      ),
      'calories': _progressCard('Calories', caloriesToday, calorieTarget),
      'water': _progressCard(
        'Water intake',
        waterToday.toDouble(),
        AppConstants.defaultWaterGoalMl.toDouble(),
        suffix: 'ml',
      ),
      'weight': _metricCard(
        'Weight progress',
        weights.isEmpty
            ? 'No logs yet'
            : '${weights.last.weight.toStringAsFixed(1)} kg',
        Icons.monitor_weight,
      ),
      'ai': _metricCard(
        'AI suggestions',
        'Ask AI to optimize your day',
        Icons.smart_toy,
      ),
    };

    return ReorderableListView(
      padding: const EdgeInsets.all(16),
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (oldIndex < newIndex) newIndex -= 1;
          final item = _layout.removeAt(oldIndex);
          _layout.insert(newIndex, item);
        });
        _saveLayout();
      },
      children: [
        for (var i = 0; i < _layout.length; i++)
          Container(
            key: ValueKey(_layout[i]),
            child: cards[_layout[i]]!
                .animate()
                .fadeIn(delay: (i * 80).ms)
                .slideY(begin: 0.12),
          ),
      ],
    );
  }

  Widget _metricCard(String title, String value, IconData icon) {
    return GlassCard(
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        subtitle: Text(value),
      ),
    );
  }

  Widget _progressCard(
    String title,
    double value,
    double target, {
    String suffix = 'kcal',
  }) {
    final progress = target == 0
        ? 0.0
        : (value / target).clamp(0.0, 1.0).toDouble();
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: progress),
          const SizedBox(height: 8),
          Text(
            '${value.toStringAsFixed(0)} / ${target.toStringAsFixed(0)} $suffix',
          ),
        ],
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }
}
