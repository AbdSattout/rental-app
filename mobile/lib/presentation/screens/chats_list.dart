import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../core/providers/auth.dart';
import '../../core/utils/asset.dart';
import '../../data/models/conversation.dart';
import '../../l10n/app_localizations.dart';
import '../providers/chat.dart';
import '../widgets/error_retry.dart';
import 'chat_conversation.dart';

class ChatsListScreen extends ConsumerStatefulWidget {
  const ChatsListScreen({super.key});

  @override
  ConsumerState<ChatsListScreen> createState() => _ChatsListScreenState();
}

class _ChatsListScreenState extends ConsumerState<ChatsListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        ref.read(conversationsProvider.notifier).loadMore();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final authState = ref.watch(authProvider);
    final conversationsAsync = ref.watch(conversationsProvider);

    if (authState.isGuest) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              spacing: 16,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                HugeIcon(icon: HugeIcons.strokeRoundedLock, size: 64),
                Text(
                  loc.guestModeChat,
                  style: TextTheme.of(context).headlineSmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(getConversations),
        child: Builder(
          builder: (context) {
            if (conversationsAsync.isLoading && !conversationsAsync.hasError) {
              return const _ConversationsListSkeleton();
            }

            if (conversationsAsync.hasError) {
              final error = conversationsAsync.error;
              String message;
              if (error is DioException && error.response == null) {
                message = loc.noInternetConnection;
              } else {
                message = error.toString();
              }
              return ErrorRetry(
                message: message,
                onRetry: () => ref.invalidate(conversationsProvider),
              );
            }

            final conversations = conversationsAsync.value?.$2 ?? [];
            if (conversations.isEmpty) {
              return ListView(
                padding: EdgeInsets.all(16),
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                  Center(
                    child: Column(
                      spacing: 16,
                      children: [
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedBubbleChat,
                          size: 64,
                        ),
                        Text(
                          loc.noConversations,
                          style: TextTheme.of(context).headlineSmall,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }

            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              controller: _scrollController,
              itemCount: conversations.length + 1,
              itemBuilder: (context, index) {
                if (index == conversations.length) {
                  if (conversationsAsync.value == null) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final (pagination, _) = conversationsAsync.value!;
                  return pagination.hasMore
                      ? const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : const SizedBox();
                }

                final conversation = conversations[index];
                return _ConversationTile(
                  conversation: conversation,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatConversationScreen(
                          conversationId: conversation.id,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _ConversationTile extends ConsumerWidget {
  const _ConversationTile({required this.conversation, required this.onTap});

  final Conversation conversation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;

    final otherUser = conversation.users.firstWhere(
      (u) => u.id != ref.read(authProvider).user!.id,
    );
    final lastMessage = conversation.lastMessage;
    final messagePreview =
        (lastMessage?.sender.id == ref.read(authProvider).user!.id &&
                lastMessage?.body != null
            ? '${loc.you}: '
            : '') +
        (lastMessage?.body ?? '');
    final messageTime = lastMessage?.createdAt;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const .symmetric(horizontal: 12, vertical: 8),
        child: Row(
          spacing: 12,
          children: [
            CircleAvatar(
              radius: 28,
              foregroundImage: CachedNetworkImageProvider(
                AssetUtil.getThumbnail(otherUser.profilePhoto),
              ),
              child: HugeIcon(icon: HugeIcons.strokeRoundedUser03),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: .start,
                spacing: 4,
                children: [
                  Row(
                    mainAxisAlignment: .spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          conversation.title ?? otherUser.name,
                          style: TextTheme.of(context).titleMedium,
                          overflow: .ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      if (messageTime != null)
                        Text(
                          DateFormat(
                            "EEE - MMM d",
                            Localizations.localeOf(context).languageCode,
                          ).format(messageTime),
                          style: TextTheme.of(context).bodySmall,
                        ),
                    ],
                  ),
                  Text(
                    messagePreview,
                    style: TextTheme.of(context).bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    overflow: .ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConversationsListSkeleton extends StatelessWidget {
  const _ConversationsListSkeleton();

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (rect) {
        return const LinearGradient(
          begin: .topCenter,
          end: .bottomCenter,
          colors: [Colors.black, Colors.transparent, Colors.transparent],
        ).createShader(rect);
      },
      blendMode: BlendMode.dstIn,
      child: ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) {
          return Skeletonizer(
            enabled: true,
            effect: PulseEffect(
              from: ColorScheme.of(context).secondary.withValues(alpha: 0.1),
              to: ColorScheme.of(context).secondary.withValues(alpha: 0.2),
            ),
            child: Padding(
              padding: const .symmetric(horizontal: 12, vertical: 8),
              child: Row(
                spacing: 12,
                children: [
                  Bone.circle(size: 56),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: .start,
                      spacing: 8,
                      children: [
                        Row(
                          mainAxisAlignment: .spaceBetween,
                          children: [
                            Bone(
                              width: 100,
                              height: 16,
                              borderRadius: .circular(4),
                            ),
                            Bone(
                              width: 50,
                              height: 12,
                              borderRadius: .circular(4),
                            ),
                          ],
                        ),
                        Bone(
                          width: 200,
                          height: 14,
                          borderRadius: .circular(4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
