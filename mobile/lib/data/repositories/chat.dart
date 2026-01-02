import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/service.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository(ref.read(apiServiceProvider).dio);
});

class ChatRepository {
  final Dio _dio;

  ChatRepository(this._dio);

  Future<Response> authenticate(String conversationId, String socketId) async {
    return await _dio.post(
      '/broadcasting/auth',
      data: {'socket_id': socketId, 'conversation_id': conversationId},
    );
  }

  Future<Response> getConversations({int page = 1}) async {
    return await _dio.get('/conversations', queryParameters: {'page': page});
  }

  Future<Response> createConversation({required int userId}) async {
    return await _dio.post('/conversations', data: {'user_id': userId});
  }

  Future<Response> getConversation(int conversationId) async {
    return await _dio.get('/conversations/$conversationId');
  }

  Future<Response> getMessages(int conversationId, {int? cursor}) async {
    final queryParams = <String, dynamic>{};
    if (cursor != null) queryParams['cursor'] = cursor;
    return await _dio.get(
      '/conversations/$conversationId/messages',
      queryParameters: queryParams,
    );
  }

  Future<Response> sendMessage({
    required int conversationId,
    required String? body,
    MultipartFile? attachment,
  }) async {
    final formData = FormData.fromMap({});
    if (body != null && body.isNotEmpty) {
      formData.fields.add(MapEntry('body', body));
    }
    if (attachment != null) {
      formData.files.add(MapEntry('attachment', attachment));
    }
    return await _dio.post(
      '/conversations/$conversationId/messages',
      data: formData,
    );
  }

  Future<Response> markAsRead({
    required int conversationId,
    required int lastReadMessageId,
  }) async {
    return await _dio.post(
      '/conversations/$conversationId/read',
      data: {'last_read_message_id': lastReadMessageId},
    );
  }
}
