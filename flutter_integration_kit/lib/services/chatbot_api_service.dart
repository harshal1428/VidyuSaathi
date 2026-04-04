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

  Future<ChatbotResponse> ask(ChatbotRequest request) async {
    final response = await _client.post(
      _chatUri(),
      headers: {
        'Authorization': 'Bearer $bearerToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(request.toJson()),
    );

    final body = response.body.isEmpty
        ? <String, dynamic>{}
        : (jsonDecode(response.body) as Map<String, dynamic>);

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
  }

  void dispose() {
    _client.close();
  }
}
