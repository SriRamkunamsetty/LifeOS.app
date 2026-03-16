import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../models/entities.dart';
import '../../../providers/app_providers.dart';

class AiAssistantTab extends ConsumerStatefulWidget {
  const AiAssistantTab({super.key});

  @override
  ConsumerState<AiAssistantTab> createState() => _AiAssistantTabState();
}

class _AiAssistantTabState extends ConsumerState<AiAssistantTab> {
  final _ctrl = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _loading = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _send([String? forcedPrompt]) async {
    final prompt = (forcedPrompt ?? _ctrl.text).trim();
    if (prompt.isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessage(role: 'user', text: prompt, createdAt: DateTime.now()),
      );
      _loading = true;
      if (forcedPrompt == null) _ctrl.clear();
    });

    final ai = await ref.read(aiServiceProvider).chat(prompt);

    if (!mounted) return;
    setState(() {
      _messages.add(
        ChatMessage(role: 'assistant', text: ai, createdAt: DateTime.now()),
      );
      _loading = false;
    });
  }

  Future<void> _toggleVoice() async {
    final voice = ref.read(voiceServiceProvider);
    if (voice.isListening) {
      await voice.stop();
      return;
    }

    final ready = await voice.init();
    if (!ready) return;

    await voice.start((text) async {
      if (!mounted) return;
      setState(() => _ctrl.text = text);
      final parsed = voice.parseCommand(text);
      switch (parsed['type']) {
        case 'task':
          await _addQuickTask(parsed['payload'] ?? text);
          break;
        case 'diet':
          await _quickDiet(parsed['payload'] ?? 'Breakfast');
          break;
        case 'ai':
          await _send(parsed['payload']);
          break;
        default:
          break;
      }
    });
  }

  Future<void> _addQuickTask(String text) async {
    final uid = ref.read(userIdProvider);
    if (uid == null) return;
    final task = TaskItem(
      id: const Uuid().v4(),
      userId: uid,
      title: text,
      description: 'Created via voice command',
      priority: 'Medium',
      deadline: null,
      status: 'pending',
      createdAt: Timestamp.now(),
      order: (ref.read(tasksProvider).valueOrNull?.length ?? 0),
    );
    await ref.read(firestoreServiceProvider).saveTask(task);
  }

  Future<void> _quickDiet(String mealType) async {
    final uid = ref.read(userIdProvider);
    if (uid == null) return;
    final log = DietLog(
      id: const Uuid().v4(),
      userId: uid,
      mealType: mealType,
      foodName: 'Voice quick log',
      calories: 300,
      protein: 15,
      carbs: 30,
      fat: 8,
      timestamp: Timestamp.now(),
    );
    await ref.read(firestoreServiceProvider).saveDietLog(log);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final msg = _messages[index];
              final me = msg.role == 'user';
              return Align(
                alignment: me ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  padding: const EdgeInsets.all(12),
                  constraints: const BoxConstraints(maxWidth: 320),
                  decoration: BoxDecoration(
                    color: me
                        ? Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.2)
                        : Colors.white12,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(msg.text),
                ),
              );
            },
          ),
        ),
        if (_loading) const LinearProgressIndicator(),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              IconButton(onPressed: _toggleVoice, icon: const Icon(Icons.mic)),
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  decoration: const InputDecoration(
                    hintText:
                        'Plan my day / Suggest a diet / Summarize my notes',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: _loading ? null : _send,
                child: const Text('Send'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
