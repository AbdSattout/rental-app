import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/service.dart';

final hostRepositoryProvider = Provider<HostRepository>((ref) {
  return HostRepository(ref.read(apiServiceProvider).dio);
});

class HostRepository {
  final Dio _dio;

  HostRepository(this._dio);

  Future<Response> getPendingReservationRequests() async {
    return await _dio.get('/host/pending-reservation-requests');
  }

  Future<Response> approveReservation(int reservationId) async {
    return await _dio.put('/host/reservation/$reservationId/approve');
  }

  Future<Response> rejectReservation(int reservationId) async {
    return await _dio.put('/host/reservation/$reservationId/reject');
  }

  Future<Response> getPendingReservationUpdates() async {
    return await _dio.get('/host/reservation/updates');
  }

  Future<Response> approveReservationUpdate(int reservationId) async {
    return await _dio.put('/host/reservation/$reservationId/approveUpdate');
  }

  Future<Response> rejectReservationUpdate(int reservationId) async {
    return await _dio.put('/host/reservation/$reservationId/rejectUpdate');
  }
}
