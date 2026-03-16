import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../models/entities.dart';
import '../../../providers/app_providers.dart';

class TasksTab extends ConsumerWidget {
  const TasksTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(tasksProvider).valueOrNull ?? const [];

    return ReorderableListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: tasks.length + 1,
      onReorder: (oldIndex, newIndex) async {
        if (oldIndex == 0 || newIndex == 0) return;
        final mutable = [...tasks];
        final from = oldIndex - 1;
        var to = newIndex - 1;
        if (from < to) to -= 1;
        final item = mutable.removeAt(from);
        mutable.insert(to, item);
        await ref.read(firestoreServiceProvider).updateTaskOrder(mutable);
      },
      itemBuilder: (context, index) {
        if (index == 0) {
          return ListTile(
            key: const ValueKey('create_task'),
            title: const Text('Tasks'),
            subtitle: const Text('Drag to reorder priority queue'),
            trailing: FilledButton(
              onPressed: () => _taskDialog(context, ref),
              child: const Text('Add Task'),
            ),
          );
        }

        final task = tasks[index - 1];
        return Card(
          key: ValueKey(task.id),
          child: ListTile(
            leading: Checkbox(
              value: task.status == 'completed',
              onChanged: (v) async {
                final updated = TaskItem(
                  id: task.id,
                  userId: task.userId,
                  title: task.title,
                  description: task.description,
                  priority: task.priority,
                  deadline: task.deadline,
                  status: (v ?? false) ? 'completed' : 'pending',
                  createdAt: task.createdAt,
                  tags: task.tags,
                  subtasks: task.subtasks,
                  recurring: task.recurring,
                  order: task.order,
                );
                await ref.read(firestoreServiceProvider).saveTask(updated);
              },
            ),
            title: Text(task.title),
            subtitle: Text(
              '${task.priority} | ${task.deadline?.toDate().toIso8601String().split('T').first ?? 'No deadline'}\nTags: ${task.tags.join(', ')}',
            ),
            isThreeLine: true,
            trailing: PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'edit') {
                  await _taskDialog(context, ref, existing: task);
                }
                if (value == 'delete') {
                  await ref.read(firestoreServiceProvider).deleteTask(task.id);
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _taskDialog(
    BuildContext context,
    WidgetRef ref, {
    TaskItem? existing,
  }) async {
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final descCtrl = TextEditingController(text: existing?.description ?? '');
    final tagsCtrl = TextEditingController(
      text: existing?.tags.join(', ') ?? '',
    );
    final subtaskCtrl = TextEditingController(
      text: existing?.subtasks.join(', ') ?? '',
    );
    var priority = existing?.priority ?? 'Medium';
    var recurring = existing?.recurring ?? false;
    DateTime? deadline = existing?.deadline?.toDate();

    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(existing == null ? 'New Task' : 'Edit Task'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: priority,
                  items: const ['Low', 'Medium', 'High']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setState(() => priority = v ?? 'Medium'),
                  decoration: const InputDecoration(labelText: 'Priority'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: tagsCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Tags (comma-separated)',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: subtaskCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Subtasks (comma-separated)',
                  ),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: recurring,
                  onChanged: (v) => setState(() => recurring = v),
                  title: const Text('Recurring task'),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    deadline == null
                        ? 'Pick deadline'
                        : deadline!.toIso8601String().split('T').first,
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                      initialDate: deadline ?? DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() => deadline = picked);
                    }
                  },
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
                final id = existing?.id ?? const Uuid().v4();
                final order =
                    existing?.order ??
                    (ref.read(tasksProvider).valueOrNull?.length ?? 0);
                final task = TaskItem(
                  id: id,
                  userId: uid,
                  title: titleCtrl.text.trim(),
                  description: descCtrl.text.trim(),
                  priority: priority,
                  deadline: deadline == null
                      ? null
                      : Timestamp.fromDate(deadline!),
                  status: existing?.status ?? 'pending',
                  createdAt: existing?.createdAt ?? Timestamp.now(),
                  tags: tagsCtrl.text
                      .split(',')
                      .map((e) => e.trim())
                      .where((e) => e.isNotEmpty)
                      .toList(),
                  subtasks: subtaskCtrl.text
                      .split(',')
                      .map((e) => e.trim())
                      .where((e) => e.isNotEmpty)
                      .toList(),
                  recurring: recurring,
                  order: order,
                );
                await ref.read(firestoreServiceProvider).saveTask(task);
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
