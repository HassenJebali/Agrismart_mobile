class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final String? intent;
  final List<String>? suggestedPages;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    this.intent,
    this.suggestedPages,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}
