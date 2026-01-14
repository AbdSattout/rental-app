import 'conversation.dart';

class Message {
  final int id;
  final int conversationId;
  final ConversationUser sender;
  final String? body;
  final MessageType type;
  final String? attachmentPath;
  final DateTime createdAt;

  Message({
    required this.id,
    required this.conversationId,
    required this.sender,
    this.body,
    required this.type,
    this.attachmentPath,
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      conversationId: json['conversation_id'],
      sender: ConversationUser.fromJson(json['sender'] ?? {}),
      body: json['body'],
      type: MessageType.values.firstWhere(
        (t) => t.name == json['type']?.toString().toLowerCase(),
        orElse: () => MessageType.text,
      ),
      attachmentPath: json['attachment_path'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Message copyWith({
    int? id,
    int? conversationId,
    ConversationUser? sender,
    String? body,
    MessageType? type,
    String? attachmentPath,
    DateTime? createdAt,
  }) {
    return Message(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      sender: sender ?? this.sender,
      body: body ?? this.body,
      type: type ?? this.type,
      attachmentPath: attachmentPath ?? this.attachmentPath,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
