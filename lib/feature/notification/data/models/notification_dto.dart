class NotificationDTO {
  final String notificationId;
  final String userId;
  final String title;
  final String? summary;
  final String message;
  final String? imageUrl;
  final String? actionType;
  final String? actionValue;
  final bool isRead;
  final DateTime? readAt;
  final String notificationType;
  final DateTime createdAt;

  NotificationDTO({
    required this.notificationId,
    required this.userId,
    required this.title,
    this.summary,
    required this.message,
    this.imageUrl,
    this.actionType,
    this.actionValue,
    required this.isRead,
    this.readAt,
    required this.notificationType,
    required this.createdAt,
  });

  NotificationDTO copyWith({
    String? notificationId,
    String? userId,
    String? title,
    String? summary,
    String? message,
    String? imageUrl,
    String? actionType,
    String? actionValue,
    bool? isRead,
    DateTime? readAt,
    String? notificationType,
    DateTime? createdAt,
  }) {
    return NotificationDTO(
      notificationId: notificationId ?? this.notificationId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      message: message ?? this.message,
      imageUrl: imageUrl ?? this.imageUrl,
      actionType: actionType ?? this.actionType,
      actionValue: actionValue ?? this.actionValue,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      notificationType: notificationType ?? this.notificationType,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory NotificationDTO.fromJson(Map<String, dynamic> json) {
    return NotificationDTO(
      notificationId: (json['notification_id'] ?? json['id'] ?? '') as String,
      userId: (json['user_id'] ?? '') as String,
      title: (json['title'] ?? '') as String,
      summary: json['summary'] as String?,
      message: (json['message'] ?? '') as String,
      imageUrl: json['image_url'] as String?,
      actionType: json['action_type'] as String?,
      actionValue: json['action_value'] as String?,
      isRead: (json['is_read'] as bool?) ?? false,
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at'] as String) : null,
      notificationType: (json['notification_type'] ?? 'general') as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notification_id': notificationId,
      'user_id': userId,
      'title': title,
      'summary': summary,
      'message': message,
      'image_url': imageUrl,
      'action_type': actionType,
      'action_value': actionValue,
      'is_read': isRead,
      'read_at': readAt?.toIso8601String(),
      'notification_type': notificationType,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
