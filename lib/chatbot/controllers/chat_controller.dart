import 'package:flutter/foundation.dart';

import '../models/chatbot_models.dart';
import '../services/chatbot_api_service.dart';

class ChatController extends ChangeNotifier {
  final ChatbotApiService service;
  final String userId;

  ChatController({required this.service, required this.userId}) {
    _messages.add(
      ChatMessage(
        text: 'Welcome to NagarSetu Assistant. Ask about complaint trends, teams, or department insights.',
        isUser: false,
      ),
    );
  }

  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _lastError;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  String? get lastError => _lastError;

  Future<void> sendQuery(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty || _isLoading) return;

    _messages.add(ChatMessage(text: trimmed, isUser: true));
    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      final response = await service.ask(
        ChatbotRequest(userId: userId, query: trimmed),
      );

      if (response.ok) {
        _messages.add(
          ChatMessage(
            text: response.answer.isNotEmpty
                ? response.answer
                : 'No answer returned from server.',
            isUser: false,
          ),
        );
      } else {
        _lastError = response.error ?? 'Unknown error from chatbot server.';
        _messages.add(ChatMessage(text: 'Error: $_lastError', isUser: false));
      }
    } catch (e) {
      _lastError = e.toString();
      _messages.add(ChatMessage(text: 'Error: $_lastError', isUser: false));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    service.dispose();
    super.dispose();
  }
}
