import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart' as chat;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flyer_chat_image_message/flyer_chat_image_message.dart';
import 'package:homio/core/providers/auth.dart';
import 'package:homio/core/utils/asset.dart';
import 'package:homio/l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/services/pusher_chat.dart';
import '../../data/models/chat_adapter.dart';
import '../../data/models/conversation.dart';
import '../../data/models/message.dart';
import '../../data/repositories/chat.dart';
import '../providers/chat.dart';

class ChatConversationScreen extends ConsumerStatefulWidget {
  final int conversationId;

  const ChatConversationScreen({super.key, required this.conversationId});

  @override
  ConsumerState<ChatConversationScreen> createState() =>
      _ChatConversationScreenState();
}

class _ChatConversationScreenState
    extends ConsumerState<ChatConversationScreen> {
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();
  chat.InMemoryChatController? _chatController;
  int _currentUserId = 0;
  bool _isInitialized = false;

  void _onPusherMessage(Message message) {
    ref
        .read(messagesProvider(widget.conversationId).notifier)
        .addMessage(message);
    // last message changed
    ref.invalidate(getConversations);
  }

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  void _initializeChat() async {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) return;
    _currentUserId = currentUser.id;

    _chatController = chat.InMemoryChatController();

    final pusherService = ref.read(
      pusherChatServiceProvider(widget.conversationId),
    );
    await pusherService.initialize();
    await pusherService.subscribe(_onPusherMessage);

    setState(() {
      _isInitialized = true;
    });
  }

  @override
  void deactivate() {
    ref.read(pusherChatServiceProvider(widget.conversationId)).unsubscribe();
    ref.read(pusherChatServiceProvider(widget.conversationId)).disconnect();
    super.deactivate();
  }

  @override
  void dispose() {
    _chatController?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleSendPressed(String text) async {
    final localId = 'local_${DateTime.now().millisecondsSinceEpoch}';
    final pendingMessage = toPendingMessage(
      localId: localId,
      senderId: _currentUserId,
      body: text,
      type: MessageType.text,
    );

    ref
        .read(messagesProvider(widget.conversationId).notifier)
        .addPendingMessage(localId, {'message': pendingMessage});

    try {
      final repo = ref.read(chatRepositoryProvider);
      final response = await repo.sendMessage(
        conversationId: widget.conversationId,
        body: text,
      );
      final serverMessage = Message.fromJson(response.data['message']);

      ref
          .read(messagesProvider(widget.conversationId).notifier)
          .replacePendingMessage(localId, serverMessage);

      ref
          .read(messagesProvider(widget.conversationId).notifier)
          .removeFailedMessage(localId);
    } catch (e) {
      ref
          .read(messagesProvider(widget.conversationId).notifier)
          .markPendingMessageAsFailed(localId);
    }
  }

  void _handleAttachmentPressed(AppLocalizations loc) async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
    );

    if (image == null) return;

    try {
      final bytes = await image.readAsBytes();

      final repo = ref.read(chatRepositoryProvider);
      final response = await repo.sendMessage(
        conversationId: widget.conversationId,
        attachment: MultipartFile.fromBytes(bytes, filename: image.name),
      );

      final serverMessage = Message.fromJson(response.data['message']);

      ref
          .read(messagesProvider(widget.conversationId).notifier)
          .addMessage(serverMessage);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(loc.messageFailed)));
      }
    }
  }

  void _handleMessageRetry(
    BuildContext context,
    chat.Message message, {
    required TapUpDetails details,
    required int index,
  }) {
    final messagesAsync = ref.watch(messagesProvider(widget.conversationId));
    final isErrorMessage =
        messagesAsync.value?.errorMessages.containsKey(message.id) == true;

    if (!isErrorMessage) {
      return;
    }

    if (message is chat.TextMessage) {
      _handleSendPressed(message.text);
      ref
          .read(messagesProvider(widget.conversationId).notifier)
          .removeFailedMessage(message.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    final currentUser = ref.watch(currentUserProvider);
    final conversationAsync = ref.watch(
      getConversationDetails(widget.conversationId),
    );
    final messagesAsync = ref.watch(messagesProvider(widget.conversationId));

    if (_chatController != null &&
        messagesAsync.hasValue &&
        !messagesAsync.isLoading) {
      final messages = messagesAsync.requireValue.messages;
      final pendingMessages = messagesAsync.requireValue.pendingMessages.values;
      final errorMessages = messagesAsync.requireValue.errorMessages.values;

      final uiMessages = messages
          .map((m) => toMessage(m, _currentUserId))
          .toList();
      final pendingUiMessages = pendingMessages.toList();
      final errorUiMessages = errorMessages.toList();

      _chatController!.setMessages([
        ...uiMessages,
        ...pendingUiMessages,
        ...errorUiMessages,
      ]);
    }

    if (currentUser == null ||
        !_isInitialized ||
        _chatController == null ||
        (conversationAsync.isLoading && !conversationAsync.hasError) ||
        (messagesAsync.isLoading && !messagesAsync.hasError)) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Builder(
          builder: (context) {
            if (conversationAsync.hasValue && conversationAsync.hasValue) {
              final conv = conversationAsync.requireValue;
              return Text(
                conv.users.firstWhere((u) => u.id != _currentUserId).name,
              );
            }
            return const SizedBox();
          },
        ),
      ),
      body: Chat(
        chatController: _chatController!,
        currentUserId: _currentUserId.toString(),
        onAttachmentTap: () => _handleAttachmentPressed(loc),
        onMessageSend: _handleSendPressed,
        onMessageTap: _handleMessageRetry,
        backgroundColor: ColorScheme.of(context).surface,
        theme: chat.ChatTheme(
          colors: .fromThemeData(Theme.of(context)),
          typography: .fromThemeData(Theme.of(context)),
          shape: .circular(12),
        ),
        resolveUser: (userId) async {
          final user = conversationAsync.requireValue.users.firstWhere(
            (u) => u.id == int.parse(userId),
          );
          return chat.User(
            id: userId,
            name: user.name,
            imageSource: AssetUtil.getThumbnail(user.profilePhoto),
          );
        },
        builders: chat.Builders(
          chatAnimatedListBuilder: (context, itemBuilder) {
            // FIXME: load more on large screens where end cannot be reached
            return ChatAnimatedListReversed(
              itemBuilder: itemBuilder,
              onEndReached: ref
                  .read(messagesProvider(widget.conversationId).notifier)
                  .loadMore,
              physics: const AlwaysScrollableScrollPhysics(),
            );
          },
          loadMoreBuilder: (context) => Padding(
            padding: const .all(8),
            child: const Center(
              child: SizedBox(
                width: 15,
                height: 15,
                child: CircularProgressIndicator(strokeWidth: 1.5),
              ),
            ),
          ),
          chatMessageBuilder:
              (
                context,
                message,
                index,
                animation,
                child, {
                bool? isRemoved,
                required bool isSentByMe,
                chat.MessageGroupStatus? groupStatus,
              }) {
                final isFirstInGroup = groupStatus?.isFirst ?? true;
                final isLastInGroup = groupStatus?.isLast ?? true;
                final shouldShowAvatar = isLastInGroup && isRemoved != true;
                final isCurrentUser =
                    message.authorId == _currentUserId.toString();
                final shouldShowUsername = isFirstInGroup && isRemoved != true;

                Widget? avatar;
                if (shouldShowAvatar) {
                  avatar = Padding(
                    padding: .directional(
                      start: isCurrentUser ? 8 : 0,
                      end: isCurrentUser ? 0 : 8,
                    ),
                    child: Avatar(userId: message.authorId),
                  );
                } else {
                  avatar = const SizedBox(width: 40);
                }

                return ChatMessage(
                  message: message,
                  index: index,
                  animation: animation,
                  isRemoved: isRemoved,
                  groupStatus: groupStatus,
                  topWidget: shouldShowUsername
                      ? Padding(
                          padding: .directional(
                            start: isCurrentUser ? 0 : 48,
                            end: isCurrentUser ? 48 : 0,
                            bottom: 4,
                          ),
                          child: Username(userId: message.authorId),
                        )
                      : null,
                  leadingWidget: !isCurrentUser ? avatar : null,
                  trailingWidget: isCurrentUser ? avatar : null,
                  receivedMessageScaleAnimationAlignment: .centerLeft,
                  receivedMessageAlignment: AlignmentDirectional.centerStart,
                  horizontalPadding: 8,
                  child: child,
                );
              },
          imageMessageBuilder:
              (
                context,
                message,
                index, {
                required bool isSentByMe,
                groupStatus,
              }) => FlyerChatImageMessage(message: message, index: index),
        ),
      ),
    );
  }
}
