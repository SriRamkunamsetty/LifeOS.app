import 'dart:convert';

import 'package:http/http.dart' as http;

class AiService {
  AiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const _baseUrl = String.fromEnvironment(
    'AI_API_BASE_URL',
    defaultValue: 'https://api.openai.com/v1/chat/completions',
  );
  static const _apiKey = String.fromEnvironment('AI_API_KEY');
  static const _model = String.fromEnvironment(
    'AI_MODEL',
    defaultValue: 'gpt-4o-mini',
  );

  Future<String> chat(String prompt) async {
    if (_apiKey.isEmpty) {
      return 'AI is not configured. Set --dart-define=AI_API_KEY=<key> to enable assistant and note tools.';
    }

    final response = await _client.post(
      Uri.parse(_baseUrl),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': _model,
        'messages': [
          {
            'role': 'system',
            'content':
                'You are LifeOS AI assistant. Give practical, concise guidance for productivity and health.',
          },
          {'role': 'user', 'content': prompt},
        ],
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      return 'AI request failed (${response.statusCode}): ${response.body}';
    }

    final map = jsonDecode(response.body) as Map<String, dynamic>;
    final choices = map['choices'] as List<dynamic>?;
    if (choices == null || choices.isEmpty) {
      return 'AI returned no response.';
    }

    final content =
        (choices.first as Map<String, dynamic>)['message']
            as Map<String, dynamic>;
    return (content['content'] as String?) ?? 'No content.';
  }
}
