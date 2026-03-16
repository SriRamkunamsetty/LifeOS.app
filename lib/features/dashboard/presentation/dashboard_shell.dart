import 'package:flutter/material.dart';

import '../../../core/widgets/gradient_scaffold.dart';
import '../../ai_assistant/presentation/ai_assistant_tab.dart';
import '../../analytics/presentation/analytics_tab.dart';
import '../../diet/presentation/diet_tab.dart';
import '../../fitness/presentation/fitness_tab.dart';
import '../../habits/presentation/habits_tab.dart';
import '../../notes/presentation/notes_tab.dart';
import '../../settings/presentation/profile_tab.dart';
import '../../tasks/presentation/tasks_tab.dart';
import 'home_dashboard_tab.dart';

class DashboardShell extends StatefulWidget {
  const DashboardShell({super.key});

  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell> {
  int _index = 0;

  static const _tabs = [
    HomeDashboardTab(),
    TasksTab(),
    HabitsTab(),
    NotesTab(),
    DietTab(),
    FitnessTab(),
    AnalyticsTab(),
    AiAssistantTab(),
    ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(title: const Text('LifeOS')),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.checklist), label: 'Tasks'),
          NavigationDestination(icon: Icon(Icons.repeat), label: 'Habits'),
          NavigationDestination(icon: Icon(Icons.note), label: 'Notes'),
          NavigationDestination(icon: Icon(Icons.restaurant), label: 'Diet'),
          NavigationDestination(
            icon: Icon(Icons.fitness_center),
            label: 'Fitness',
          ),
          NavigationDestination(icon: Icon(Icons.insights), label: 'Analytics'),
          NavigationDestination(icon: Icon(Icons.smart_toy), label: 'AI'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
      child: IndexedStack(index: _index, children: _tabs),
    );
  }
}
