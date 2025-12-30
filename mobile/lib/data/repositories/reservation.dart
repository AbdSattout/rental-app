import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/service.dart';

final reservationRepositoryProvider = Provider<ReservationRepository>((ref) {
  return ReservationRepository(ref.read(apiServiceProvider).dio);
});

class ReservationRepository {
  final Dio _dio;

  ReservationRepository(this._dio);

  Future<Response> makeReservation({
    required int postId,
    required String checkIn,
    required String checkOut,
  }) async {
    return await _dio.post(
      '/post/$postId/reserve',
      data: {'check_in': checkIn, 'check_out': checkOut},
    );
  }

  Future<Response> myReservations({String? filter}) async {
    final queryParams = <String, dynamic>{};
    if (filter != null) {
      queryParams[filter] = 'true';
    }
    return await _dio.get(
      '/user/reservations',
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );
  }

  Future<Response> cancelReservation(int reservationId) async {
    return await _dio.put('/reservation/$reservationId/cancel');
  }

  Future<Response> updateReservation({
    required int reservationId,
    required String checkIn,
    required String checkOut,
  }) async {
    return await _dio.put(
      '/reservation/$reservationId/updateRequest',
      data: {'checkIn': checkIn, 'checkOut': checkOut},
    );
  }

  Future<Response> getReservedDates(int postId) async {
    return await _dio.get('/post/$postId/reserved');
  }
}
