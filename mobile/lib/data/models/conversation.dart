import 'package:homio/data/models/message.dart';

enum ConversationType { direct, group }

enum MessageType { text, image, video, file }

class ConversationUser {
  final int id;
  final String name;
  final String profilePhoto;

  ConversationUser({
    required this.id,
    required this.name,
    required this.profilePhoto,
  });

  factory ConversationUser.fromJson(Map<String, dynamic> json) {
    return ConversationUser(
      id: json['id'],
      name: json['name'],
      profilePhoto: json['profile photo'],
    );
  }

  ConversationUser copyWith({int? id, String? name, String? profilePhoto}) {
    return ConversationUser(
      id: id ?? this.id,
      name: name ?? this.name,
      profilePhoto: profilePhoto ?? this.profilePhoto,
    );
  }
}

class Conversation {
  final int id;
  final ConversationType type;
  final String? title;
  final List<ConversationUser> users;
  final Message? lastMessage;
  final DateTime updatedAt;

  Conversation({
    required this.id,
    required this.type,
    this.title,
    required this.users,
    this.lastMessage,
    required this.updatedAt,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'],
      type: ConversationType.values.firstWhere(
        (t) => t.name == json['type']?.toString().toLowerCase(),
        orElse: () => ConversationType.direct,
      ),
      title: json['title'],
      users:
          (json['users'] as List<dynamic>?)
              ?.map((u) => ConversationUser.fromJson(u))
              .toList() ??
          [],
      lastMessage: json['last_message'] != null
          ? Message.fromJson(json['last_message'])
          : null,
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Conversation copyWith({
    int? id,
    ConversationType? type,
    String? title,
    List<ConversationUser>? users,
    Message? lastMessage,
    DateTime? updatedAt,
  }) {
    return Conversation(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      users: users ?? this.users,
      lastMessage: lastMessage ?? this.lastMessage,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
