import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/chatbot_models.dart';

class ChatbotApiService {
  final String baseUrl;
  final String bearerToken;
  final http.Client _client;

  ChatbotApiService({
    required this.baseUrl,
    required this.bearerToken,
    http.Client? client,
  }) : _client = client ?? http.Client();

  Uri _chatUri() {
    final normalized = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    return Uri.parse('$normalized/api/chat');
  }

  Map<String, dynamic>? _tryParseJsonMap(String rawBody) {
    if (rawBody.trim().isEmpty) return <String, dynamic>{};
    try {
      final decoded = jsonDecode(rawBody);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return null;
    } on FormatException {
      return null;
    }
  }

  String _friendlyOfflineError(String rawBody) {
    final lower = rawBody.toLowerCase();
    if (lower.contains('is offline') ||
        lower.contains('ngrok') ||
        lower.contains('tunnel')) {
      return 'Chatbot endpoint is offline. Start chatbot API and ngrok on host laptop, then retry.';
    }
    return 'Chatbot server returned an invalid response. Verify ngrok URL and backend status.';
  }

  Future<ChatbotResponse> ask(ChatbotRequest request) async {
    try {
      final response = await _client
          .post(
            _chatUri(),
            headers: {
              'Authorization': 'Bearer $bearerToken',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(request.toJson()),
          )
          .timeout(const Duration(seconds: 25));

      final body = _tryParseJsonMap(response.body);

      if (body == null) {
        return ChatbotResponse(
          ok: false,
          answer: '',
          error: _friendlyOfflineError(response.body),
        );
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ChatbotResponse.fromJson(body);
      }

      return ChatbotResponse(
        ok: false,
        answer: '',
        error: body['error']?.toString() ??
            'Request failed with status ${response.statusCode}',
        parsed: body['parsed'] is Map<String, dynamic>
            ? body['parsed'] as Map<String, dynamic>
            : null,
        result: body['result'] is Map<String, dynamic>
            ? body['result'] as Map<String, dynamic>
            : null,
      );
    } on TimeoutException {
      return ChatbotResponse(
        ok: false,
        answer: '',
        error: 'Connection timed out. Check chatbot server and ngrok tunnel.',
      );
    }
  }

  void dispose() {
    _client.close();
  }
}
