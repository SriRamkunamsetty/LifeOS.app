import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../models/entities.dart';
import '../../../providers/app_providers.dart';

class NotesTab extends ConsumerWidget {
  const NotesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(notesProvider).valueOrNull ?? const [];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        Row(
          children: [
            Text(
              'Knowledge Vault',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const Spacer(),
            FilledButton(
              onPressed: () => _openEditor(context, ref),
              child: const Text('New Note'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        for (final note in notes)
          Card(
            child: ExpansionTile(
              title: Text(note.title),
              subtitle: Text(note.tags.join(', ')),
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: MarkdownBody(data: note.content),
                ),
                Wrap(
                  spacing: 8,
                  children: [
                    TextButton(
                      onPressed: () =>
                          _openEditor(context, ref, existing: note),
                      child: const Text('Edit'),
                    ),
                    TextButton(
                      onPressed: () => ref
                          .read(firestoreServiceProvider)
                          .deleteNote(note.id),
                      child: const Text('Delete'),
                    ),
                    TextButton(
                      onPressed: () => _runAi(
                        context,
                        ref,
                        'Summarize this note:\n${note.content}',
                      ),
                      child: const Text('Summarize'),
                    ),
                    TextButton(
                      onPressed: () => _runAi(
                        context,
                        ref,
                        'Create flashcards from this note:\n${note.content}',
                      ),
                      child: const Text('Flashcards'),
                    ),
                    TextButton(
                      onPressed: () => _runAi(
                        context,
                        ref,
                        'Create a quiz from this note:\n${note.content}',
                      ),
                      child: const Text('Quiz'),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  Future<void> _openEditor(
    BuildContext context,
    WidgetRef ref, {
    NoteItem? existing,
  }) async {
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final contentCtrl = TextEditingController(text: existing?.content ?? '');
    final tagsCtrl = TextEditingController(
      text: existing?.tags.join(', ') ?? '',
    );

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existing == null ? 'Create Note' : 'Edit Note'),
        content: SizedBox(
          width: 520,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: contentCtrl,
                  maxLines: 8,
                  decoration: const InputDecoration(
                    labelText: 'Markdown content',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: tagsCtrl,
                  decoration: const InputDecoration(labelText: 'Tags'),
                ),
              ],
            ),
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
              final note = NoteItem(
                id: existing?.id ?? const Uuid().v4(),
                userId: uid,
                title: titleCtrl.text.trim(),
                content: contentCtrl.text,
                tags: tagsCtrl.text
                    .split(',')
                    .map((e) => e.trim())
                    .where((e) => e.isNotEmpty)
                    .toList(),
                createdAt: existing?.createdAt ?? Timestamp.now(),
              );
              await ref.read(firestoreServiceProvider).saveNote(note);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _runAi(
    BuildContext context,
    WidgetRef ref,
    String prompt,
  ) async {
    final response = await ref.read(aiServiceProvider).chat(prompt);
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('AI Output'),
        content: SingleChildScrollView(child: Text(response)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
