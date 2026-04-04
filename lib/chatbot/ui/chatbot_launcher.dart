import 'package:flutter/material.dart';

import '../config/chatbot_config.dart';
import '../controllers/chat_controller.dart';
import '../services/chatbot_api_service.dart';
import 'chatbot_screen.dart';

void openOfficerChatbot(BuildContext context, String userId) {
  if (userId.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Unable to open chatbot: officer user session not found.'),
      ),
    );
    return;
  }

  final service = ChatbotApiService(
    baseUrl: ChatbotConfig.baseUrl,
    bearerToken: ChatbotConfig.bearerToken,
  );

  final controller = ChatController(
    service: service,
    userId: userId,
  );

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ChatbotScreen(controller: controller),
    ),
  );
}
