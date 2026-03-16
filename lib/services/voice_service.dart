import 'package:speech_to_text/speech_to_text.dart';

class VoiceService {
  VoiceService({SpeechToText? speech}) : _speech = speech ?? SpeechToText();

  final SpeechToText _speech;

  Future<bool> init() => _speech.initialize();

  bool get isListening => _speech.isListening;

  Future<void> start(void Function(String text) onResult) async {
    await _speech.listen(
      onResult: (result) => onResult(result.recognizedWords),
      listenOptions: SpeechListenOptions(
        listenMode: ListenMode.confirmation,
        partialResults: true,
      ),
    );
  }

  Future<void> stop() => _speech.stop();

  Map<String, String> parseCommand(String input) {
    final text = input.toLowerCase();
    if (text.contains('plan my day')) {
      return {'type': 'ai', 'payload': 'Plan my day'};
    }
    if (text.contains('log breakfast')) {
      return {'type': 'diet', 'payload': 'Breakfast'};
    }
    if (text.contains('add task')) {
      return {'type': 'task', 'payload': input};
    }
    return {'type': 'unknown', 'payload': input};
  }
}
