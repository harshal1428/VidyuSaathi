import 'package:flutter/material.dart';
import 'controllers/chat_controller.dart';
import 'services/chatbot_api_service.dart';
import 'ui/chat_screen.dart';

void main() {
  const baseUrl = String.fromEnvironment(
    'CHATBOT_BASE_URL',
    defaultValue: 'https://comparably-pyroligneous-del.ngrok-free.app',
  );
  const bearerToken = String.fromEnvironment(
    'CHATBOT_BEARER_TOKEN',
    defaultValue: 'dev-chat-token-123',
  );
  const userId = String.fromEnvironment(
    'CHATBOT_USER_ID',
    defaultValue: '1i3bNIaTn5aEPSyVEjni0QyaMyj2',
  );

  final service = ChatbotApiService(baseUrl: baseUrl, bearerToken: bearerToken);
  final controller = ChatController(service: service, userId: userId);

  runApp(MyApp(controller: controller));
}

class MyApp extends StatelessWidget {
  final ChatController controller;

  const MyApp({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NagarSetu Chatbot Demo',
      home: ChatScreen(controller: controller),
    );
  }
}
