class ChatMessageDTO {
  final String messageId;
  final String consultationId;
  final String senderId;
  final String messageText; // Base64 Ciphertext or Plaintext
  final bool isRead;
  final DateTime createdAt;

  ChatMessageDTO({
    required this.messageId,
    required this.consultationId,
    required this.senderId,
    required this.messageText,
    required this.isRead,
    required this.createdAt,
  });

  factory ChatMessageDTO.fromJson(Map<String, dynamic> json) {
    return ChatMessageDTO(
      messageId: (json['message_id'] ?? json['id'] ?? '') as String,
      consultationId: (json['consultation_id'] ?? '') as String,
      senderId: (json['sender_id'] ?? '') as String,
      messageText: (json['message_text'] ?? json['text'] ?? '') as String,
      isRead: (json['is_read'] as bool?) ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message_id': messageId,
      'consultation_id': consultationId,
      'sender_id': senderId,
      'message_text': messageText,
      'is_read': isRead,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
