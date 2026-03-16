import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/gradient_scaffold.dart';
import '../../../models/entities.dart';
import '../../../providers/app_providers.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageCtrl = PageController();
  final _ageCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();

  int _step = 0;
  String _gender = 'Male';
  String _activity = 'Moderate';
  String _goal = 'Maintain weight';
  String _diet = 'Balanced';

  @override
  void dispose() {
    _pageCtrl.dispose();
    _ageCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    final profile = UserProfile(
      userId: user.uid,
      name: _nameCtrl.text.trim().isEmpty
          ? (user.displayName ?? 'User')
          : _nameCtrl.text.trim(),
      email: user.email ?? '',
      profilePhoto: user.photoURL,
      age: int.tryParse(_ageCtrl.text) ?? 0,
      height: double.tryParse(_heightCtrl.text) ?? 0,
      weight: double.tryParse(_weightCtrl.text) ?? 0,
      fitnessGoal: _goal,
      gender: _gender,
      activityLevel: _activity,
      dietPreference: _diet,
      createdAt: Timestamp.now(),
      onboardingCompleted: true,
    );
    await ref.read(firestoreServiceProvider).upsertProfile(profile);
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(title: const Text('Onboarding')),
      child: Column(
        children: [
          LinearProgressIndicator(value: (_step + 1) / 4),
          Expanded(
            child: PageView(
              controller: _pageCtrl,
              physics: const NeverScrollableScrollPhysics(),
              children: [_stepOne(), _stepTwo(), _stepThree(), _stepFour()],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (_step > 0)
                  TextButton(
                    onPressed: () {
                      setState(() => _step--);
                      _pageCtrl.previousPage(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: const Text('Back'),
                  ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () async {
                    if (_step < 3) {
                      setState(() => _step++);
                      await _pageCtrl.nextPage(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      await _finish();
                    }
                  },
                  child: Text(_step < 3 ? 'Next' : 'Finish'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepOne() {
    return _StepCard(
      title: 'Basic Profile',
      child: Column(
        children: [
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _ageCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Age'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _gender,
            items: const [
              'Male',
              'Female',
            ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) => setState(() => _gender = v ?? 'Male'),
            decoration: const InputDecoration(labelText: 'Gender'),
          ),
        ],
      ),
    );
  }

  Widget _stepTwo() {
    return _StepCard(
      title: 'Health Metrics',
      child: Column(
        children: [
          TextField(
            controller: _heightCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Height (cm)'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _weightCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Weight (kg)'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _activity,
            items: const [
              'Low',
              'Moderate',
              'High',
            ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) => setState(() => _activity = v ?? 'Moderate'),
            decoration: const InputDecoration(labelText: 'Activity level'),
          ),
        ],
      ),
    );
  }

  Widget _stepThree() {
    return _StepCard(
      title: 'Fitness Goal',
      child: DropdownButtonFormField<String>(
        initialValue: _goal,
        items: const [
          'Weight loss',
          'Weight gain',
          'Muscle gain',
          'Maintain weight',
        ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: (v) => setState(() => _goal = v ?? 'Maintain weight'),
        decoration: const InputDecoration(labelText: 'Goal'),
      ),
    );
  }

  Widget _stepFour() {
    return _StepCard(
      title: 'Diet Preference',
      child: DropdownButtonFormField<String>(
        initialValue: _diet,
        items: const [
          'Balanced',
          'High Protein',
          'Low Carb',
          'Vegetarian',
          'Vegan',
        ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: (v) => setState(() => _diet = v ?? 'Balanced'),
        decoration: const InputDecoration(labelText: 'Diet preference'),
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Card(
        color: Colors.white.withValues(alpha: 0.06),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 16),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
