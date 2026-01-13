import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart' as chat;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homio/data/models/conversation.dart';
import 'package:homio/data/models/message.dart';
import 'package:homio/data/repositories/chat.dart';

Duration? _retry(int count, Object error) {
  if (count > 10) return null;
  return Duration(milliseconds: 200 * count);
}

List<Conversation> parseConversations(List list) =>
    list.map((e) => Conversation.fromJson(e)).toList();

List<Message> parseMessages(List list) =>
    list.map((e) => Message.fromJson(e)).toList();

class PaginationInfo {
  final int currentPage;
  final int lastPage;
  final bool hasMore;

  PaginationInfo({
    required this.currentPage,
    required this.lastPage,
    required this.hasMore,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
      hasMore: json['next_page_url'] != null,
    );
  }
}

final getConversations = FutureProvider.autoDispose
    .family<(PaginationInfo, List<Conversation>), int>((ref, int page) async {
      final repo = ref.read(chatRepositoryProvider);
      final response = await repo.getConversations(page: page);
      final conversationsJson = response.data;
      final pagination = PaginationInfo.fromJson(conversationsJson['meta']);
      final conversations = parseConversations(conversationsJson['data']);
      return (pagination, conversations);
    }, retry: _retry);

class ConversationsNotifier
    extends AsyncNotifier<(PaginationInfo, List<Conversation>)> {
  bool _isLoading = false;

  @override
  build() async {
    return await ref.watch(getConversations(1).future);
  }

  Future<void> loadMore() async {
    if (state.value == null || _isLoading) return;
    final (pagination, conversations) = state.value!;
    if (!pagination.hasMore) return;

    (PaginationInfo, List<Conversation>)? next;

    _isLoading = true;
    while (next == null) {
      try {
        next = await ref.read(
          getConversations(pagination.currentPage + 1).future,
        );
        if (next == null) continue;
        state = AsyncData((next.$1, [...conversations, ...next.$2]));
      } catch (_) {
        await Future.delayed(Duration(seconds: 1));
        ref.invalidate(getConversations(pagination.currentPage + 1));
      }
    }
    _isLoading = false;
  }
}

final conversationsProvider = AsyncNotifierProvider.autoDispose(
  ConversationsNotifier.new,
  retry: (_, _) => null,
);

final getConversationDetails = FutureProvider.autoDispose
    .family<Conversation, int>((ref, int conversationId) async {
      final repo = ref.read(chatRepositoryProvider);
      final response = await repo.getConversation(conversationId);
      return Conversation.fromJson(response.data['data']);
    }, retry: _retry);

enum ConversationError { unknown, networkError, badRequest }

Future<(Conversation?, ConversationError?)> createConversation(
  WidgetRef ref,
  int userId,
) async {
  try {
    final repo = ref.read(chatRepositoryProvider);
    final response = await repo.createConversation(userId: userId);
    return (Conversation.fromJson(response.data['data']), null);
  } on DioException catch (e) {
    final res = e.response;
    if (res == null) {
      return (null, ConversationError.networkError);
    }
    if (res.statusCode != null &&
        res.statusCode! >= 400 &&
        res.statusCode! < 500) {
      return (null, ConversationError.badRequest);
    }
    rethrow;
  } catch (e) {
    return (null, ConversationError.unknown);
  }
}

final getMessages = FutureProvider.autoDispose.family((
  ref,
  ({int conversationId, String? cursor}) params,
) async {
  final repo = ref.read(chatRepositoryProvider);
  final response = await repo.getMessages(
    params.conversationId,
    cursor: params.cursor,
  );
  final messagesJson = response.data;
  final messages = parseMessages(messagesJson['data']).reversed.toList();
  return (
    nextCursor: messagesJson['meta']['next_cursor'] as String?,
    hasMore: messagesJson['meta']['next_cursor'] != null,
    messages: messages,
  );
}, retry: _retry);

typedef MessagesState = ({
  Map<String, chat.Message> errorMessages,
  bool hasMore,
  List<Message> messages,
  String? nextCursor,
  Map<String, chat.Message> pendingMessages,
});

class MessagesNotifier extends AsyncNotifier<MessagesState> {
  final int _conversationId;
  bool _isLoading = false;

  MessagesNotifier(this._conversationId);

  @override
  build() async {
    final initial = await ref.watch(
      getMessages((conversationId: _conversationId, cursor: null)).future,
    );
    return (
      errorMessages: <String, chat.Message>{},
      hasMore: initial.hasMore,
      messages: initial.messages,
      nextCursor: initial.nextCursor,
      pendingMessages: <String, chat.Message>{},
    );
  }

  void addPendingMessage(String localId, Map<String, dynamic> message) {
    state.whenData((current) {
      state = AsyncData((
        nextCursor: current.nextCursor,
        hasMore: current.hasMore,
        messages: current.messages,
        pendingMessages: {
          ...current.pendingMessages,
          localId: message['message'],
        },
        errorMessages: current.errorMessages,
      ));
    });
  }

  void removePendingMessage(String localId) {
    state.whenData((current) {
      final newPending = Map<String, chat.Message>.from(
        current.pendingMessages,
      );
      newPending.remove(localId);
      state = AsyncData((
        nextCursor: current.nextCursor,
        hasMore: current.hasMore,
        messages: current.messages,
        pendingMessages: newPending,
        errorMessages: current.errorMessages,
      ));
    });
  }

  Future<void> loadMore() async {
    if (state.value == null || _isLoading) return;
    final current = state.value!;
    if (!current.hasMore) return;

    ({String? nextCursor, bool hasMore, List<Message> messages})? next;

    while (next == null) {
      try {
        _isLoading = true;
        next = await ref.read(
          getMessages((
            conversationId: _conversationId,
            cursor: current.nextCursor,
          )).future,
        );
        if (next == null) continue;
        state = AsyncData((
          nextCursor: next.nextCursor,
          hasMore: next.hasMore,
          messages: [...next.messages, ...current.messages],
          pendingMessages: current.pendingMessages,
          errorMessages: current.errorMessages,
        ));
      } catch (_) {
        await Future.delayed(Duration(seconds: 1));
        ref.invalidate(
          getMessages((
            conversationId: _conversationId,
            cursor: current.nextCursor,
          )),
        );
      } finally {
        _isLoading = false;
      }
    }
  }

  void addMessage(Message message) {
    state.whenData((current) {
      if (current.messages.any((m) => m.id == message.id)) {
        return;
      }
      state = AsyncData((
        nextCursor: current.nextCursor,
        hasMore: current.hasMore,
        messages: [...current.messages, message],
        pendingMessages: current.pendingMessages,
        errorMessages: current.errorMessages,
      ));
    });
  }

  void replacePendingMessage(String localId, Message message) {
    state.whenData((current) {
      final pending = Map<String, chat.Message>.from(current.pendingMessages);
      pending.remove(localId);
      final existingIndex = current.messages.indexWhere(
        (m) => m.id == message.id,
      );
      final messages = existingIndex >= 0
          ? [
              ...current.messages.sublist(0, existingIndex),
              message,
              ...current.messages.sublist(existingIndex + 1),
            ]
          : [...current.messages, message];
      state = AsyncData((
        nextCursor: current.nextCursor,
        hasMore: current.hasMore,
        messages: messages,
        pendingMessages: pending,
        errorMessages: current.errorMessages,
      ));
    });
  }

  void markPendingMessageAsFailed(String localId) {
    state.whenData((current) {
      final pending = Map<String, chat.Message>.from(current.pendingMessages);
      final errorMessage = pending[localId];
      if (errorMessage != null) {
        pending.remove(localId);
        final id = 'local_${DateTime.now().millisecondsSinceEpoch}';
        state = AsyncData((
          nextCursor: current.nextCursor,
          hasMore: current.hasMore,
          messages: current.messages,
          pendingMessages: pending,
          errorMessages: {
            ...current.errorMessages,
            id: errorMessage.copyWith(status: .error, id: id),
          },
        ));
      }
    });
  }

  String? getFailedMessage(String localId) {
    state.whenData((current) {
      if (!current.errorMessages.containsKey(localId)) {
        return null;
      }
      return (current.errorMessages[localId] as chat.TextMessage).text;
    });
    return null;
  }

  void removeFailedMessage(String localId) {
    state.whenData((current) {
      final errorMessages = Map<String, chat.Message>.from(
        current.errorMessages,
      );
      errorMessages.remove(localId);
      state = AsyncData((
        nextCursor: current.nextCursor,
        hasMore: current.hasMore,
        messages: current.messages,
        pendingMessages: current.pendingMessages,
        errorMessages: errorMessages,
      ));
    });
  }
}

final messagesProvider = AsyncNotifierProvider.autoDispose.family(
  MessagesNotifier.new,
  retry: (_, _) => null,
);
