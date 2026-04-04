class ChatbotRequest {
  final String userId;
  final String query;

  ChatbotRequest({required this.userId, required this.query});

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'query': query,
      };
}

class ChatbotResponse {
  final bool ok;
  final String answer;
  final Map<String, dynamic>? parsed;
  final Map<String, dynamic>? result;
  final String? error;

  ChatbotResponse({
    required this.ok,
    required this.answer,
    this.parsed,
    this.result,
    this.error,
  });

  factory ChatbotResponse.fromJson(Map<String, dynamic> json) {
    return ChatbotResponse(
      ok: json['ok'] == true,
      answer: (json['answer'] ?? '').toString(),
      parsed: json['parsed'] is Map<String, dynamic>
          ? json['parsed'] as Map<String, dynamic>
          : null,
      result: json['result'] is Map<String, dynamic>
          ? json['result'] as Map<String, dynamic>
          : null,
      error: json['error']?.toString(),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime time;

  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? time,
  }) : time = time ?? DateTime.now();
}
