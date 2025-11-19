import 'package:cconnect/utils/constraints/enums.dart';
import 'package:flutter/foundation.dart';

class Message {
  final String id;
  final String conversationId; // for 1-1: generated ID, for group: group id
  final String senderId;
  final String? replyToMessageId;
  final MessageType type;
  final String text; // text or URL (image/file)
  final DateTime sentAt;
  final List<String> readBy; // user IDs who have read message
  final Map<String, dynamic> metadata; // extra, e.g., fileName, size

  Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    this.replyToMessageId,
    this.type = MessageType.text,
    this.text = '',
    DateTime? sentAt,
    this.readBy = const [],
    this.metadata = const {},
  }) : sentAt = sentAt ?? DateTime.now();

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    id: json['id'],
    conversationId: json['conversationId'],
    senderId: json['senderId'],
    replyToMessageId: json['replyToMessageId'],
    type: _typeFromString(json['type'] as String?),
    text: json['text'] ?? '',
    sentAt: json['sentAt'] != null
        ? DateTime.parse(json['sentAt'])
        : DateTime.now(),
    readBy: List<String>.from(json['readBy'] ?? []),
    metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'conversationId': conversationId,
    'senderId': senderId,
    'replyToMessageId': replyToMessageId,
    'type': describeEnum(type),
    'text': text,
    'sentAt': sentAt.toIso8601String(),
    'readBy': readBy,
    'metadata': metadata,
  };

  static MessageType _typeFromString(String? s) {
    if (s == null) return MessageType.text;
    return MessageType.values.firstWhere(
      (m) => describeEnum(m) == s,
      orElse: () => MessageType.text,
    );
  }
}
