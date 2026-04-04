class ChatbotConfig {
  static const String baseUrl = String.fromEnvironment(
    'CHATBOT_BASE_URL',
    defaultValue: 'https://comparably-pyroligneous-del.ngrok-free.app',
  );

  static const String bearerToken = String.fromEnvironment(
    'CHATBOT_BEARER_TOKEN',
    defaultValue: 'dev-chat-token-123',
  );
}
