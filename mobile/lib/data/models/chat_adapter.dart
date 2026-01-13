import 'package:flutter_chat_core/flutter_chat_core.dart' as chat;
import 'package:homio/core/utils/asset.dart';
import 'package:homio/data/models/conversation.dart';
import 'package:homio/data/models/message.dart';

chat.User toUser(ConversationUser user, {String? avatarUrl}) {
  return chat.User(
    id: user.id.toString(),
    name: user.name,
    imageSource: avatarUrl ?? AssetUtil.getThumbnail(user.profilePhoto),
  );
}

chat.Message toMessage(Message msg, int currentUserId) {
  switch (msg.type) {
    case .text:
      return chat.Message.text(
        id: msg.id.toString(),
        authorId: msg.sender.id.toString(),
        createdAt: msg.createdAt.toUtc(),
        text: msg.body!,
        status: msg.sender.id == currentUserId ? .sent : .seen,
      );
    case .image:
      return chat.Message.image(
        id: msg.id.toString(),
        authorId: msg.sender.id.toString(),
        createdAt: msg.createdAt.toUtc(),
        source: AssetUtil.getAssetUrl(msg.attachmentPath!),
        status: msg.sender.id == currentUserId ? .sent : .seen,
      );
    case .video:
      return chat.Message.video(
        id: msg.id.toString(),
        authorId: msg.sender.id.toString(),
        createdAt: msg.createdAt.toUtc(),
        source: AssetUtil.getAssetUrl(msg.attachmentPath!),
        status: msg.sender.id == currentUserId ? .sent : .seen,
      );
    case .file:
      return chat.Message.file(
        id: msg.id.toString(),
        name: msg.attachmentPath!.split('/').last,
        authorId: msg.sender.id.toString(),
        createdAt: msg.createdAt.toUtc(),
        source: AssetUtil.getAssetUrl(msg.attachmentPath!),
        status: msg.sender.id == currentUserId ? .sent : .seen,
      );
  }
}

chat.Message toPendingMessage({
  required String localId,
  required int senderId,
  required String body,
  required MessageType type,
}) {
  switch (type) {
    case .text:
      return chat.Message.text(
        id: localId,
        authorId: senderId.toString(),
        createdAt: DateTime.now().toUtc(),
        text: body,
        status: .sending,
      );
    case .image:
      return chat.Message.image(
        id: localId,
        authorId: senderId.toString(),
        createdAt: DateTime.now().toUtc(),
        source: AssetUtil.getAssetUrl(body),
        status: .sending,
      );
    case .video:
      return chat.Message.video(
        id: localId,
        authorId: senderId.toString(),
        createdAt: DateTime.now().toUtc(),
        source: AssetUtil.getAssetUrl(body),
        status: .sending,
      );
    case .file:
      return chat.Message.file(
        id: localId,
        name: body.split('/').last,
        authorId: senderId.toString(),
        createdAt: DateTime.now().toUtc(),
        source: AssetUtil.getAssetUrl(body),
        status: .sending,
      );
  }
}
