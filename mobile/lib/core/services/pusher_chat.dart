import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homio/data/models/message.dart';
import 'package:homio/data/repositories/chat.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

typedef MessageCallback = void Function(Message message);

class PusherChatService {
  final ChatRepository _repo;
  final int conversationId;
  PusherChannelsFlutter? _pusher;
  MessageCallback? _messageCallback;

  PusherChatService(this._repo, this.conversationId);

  Future<void> initialize() async {
    _pusher = PusherChannelsFlutter.getInstance();
    await _pusher!.init(
      apiKey: _getPusherKey(),
      cluster: _getPusherCluster(),
      onAuthorizer: (channelName, socketId, options) async {
        try {
          final response = await _repo.authenticate(channelName, socketId);
          return response.data;
        } catch (e) {
          return '';
        }
      },
    );
    await _pusher!.connect();
  }

  String _getPusherKey() {
    return const String.fromEnvironment('PUSHER_APP_KEY', defaultValue: '');
  }

  String _getPusherCluster() {
    return const String.fromEnvironment(
      'PUSHER_APP_CLUSTER',
      defaultValue: 'mt1',
    );
  }

  Future<PusherChannel?> subscribe(MessageCallback onMessage) async {
    final channelName = 'private-conversation.$conversationId';

    _messageCallback = onMessage;

    if (_pusher == null) return null;

    final channel = await _pusher!.subscribe(
      channelName: channelName,
      onEvent: (event) {
        if (event.eventName == "message.sent" && event.data != null) {
          final data = jsonDecode(event.data) as Map<String, dynamic>;
          final messageData = data.containsKey('message')
              ? data['message'] as Map<String, dynamic>
              : data;
          final message = Message.fromJson(messageData);
          _messageCallback?.call(message);
        }
      },
    );

    return channel;
  }

  void unsubscribe() {
    final channelName = 'private-conversation.$conversationId';
    _pusher?.unsubscribe(channelName: channelName);
  }

  void disconnect() {
    _pusher?.disconnect();
    _pusher = null;
  }
}

final pusherChatServiceProvider = Provider.autoDispose
    .family<PusherChatService, int>((ref, conversationId) {
      final repo = ref.watch(chatRepositoryProvider);
      final service = PusherChatService(repo, conversationId);
      return service;
    });
