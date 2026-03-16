import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/app_providers.dart';

class ProfileTab extends ConsumerStatefulWidget {
  const ProfileTab({super.key});

  @override
  ConsumerState<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends ConsumerState<ProfileTab> {
  bool _taskReminders = true;
  bool _habitReminders = true;
  bool _dietReminders = true;
  bool _waterReminders = true;

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileStreamProvider).valueOrNull;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        ListTile(
          title: Text(profile?.name ?? 'User'),
          subtitle: Text(profile?.email ?? ''),
          leading: CircleAvatar(
            backgroundImage: profile?.profilePhoto == null
                ? null
                : NetworkImage(profile!.profilePhoto!),
            child: profile?.profilePhoto == null
                ? const Icon(Icons.person)
                : null,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Notification Preferences',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        SwitchListTile(
          value: _taskReminders,
          onChanged: (v) => setState(() => _taskReminders = v),
          title: const Text('Task reminders'),
        ),
        SwitchListTile(
          value: _habitReminders,
          onChanged: (v) => setState(() => _habitReminders = v),
          title: const Text('Habit reminders'),
        ),
        SwitchListTile(
          value: _dietReminders,
          onChanged: (v) => setState(() => _dietReminders = v),
          title: const Text('Diet reminders'),
        ),
        SwitchListTile(
          value: _waterReminders,
          onChanged: (v) => setState(() => _waterReminders = v),
          title: const Text('Water reminders'),
        ),
        const SizedBox(height: 16),
        FilledButton.tonal(
          onPressed: () => ref.read(authServiceProvider).signOut(),
          child: const Text('Logout'),
        ),
      ],
    );
  }
}
