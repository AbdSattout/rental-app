import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/reservation.dart';
import '../../data/repositories/host.dart';

Duration? _retry(int count, Object error) {
  if (error is DioException && error.response == null) return null;
  if (count > 10) return null;
  return Duration(milliseconds: 200 * count);
}

List<Reservation> parseReservations(List list) =>
    list.map((e) => Reservation.fromJson(e)).toList();

final pendingReservationRequests = FutureProvider<List<Reservation>>(
  (ref) async {
    try {
      final repo = ref.read(hostRepositoryProvider);
      final response = await repo.getPendingReservationRequests();
      final reservationsJson = response.data ?? [];
      return parseReservations(reservationsJson);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return [];
      }
      rethrow;
    }
  },
  retry: _retry,
  isAutoDispose: true,
);

final pendingReservationUpdates = FutureProvider<List<Reservation>>(
  (ref) async {
    final repo = ref.read(hostRepositoryProvider);
    final response = await repo.getPendingReservationUpdates();
    final reservationsJson = response.data ?? [];
    return parseReservations(reservationsJson);
  },
  retry: _retry,
  isAutoDispose: true,
);

enum HostError { unknown, networkError, badRequest, conflict }

Future<(HostError, String)?> approveReservation(
  WidgetRef ref,
  int reservationId,
) async {
  final repo = ref.read(hostRepositoryProvider);
  try {
    try {
      await repo.approveReservation(reservationId);
      ref.invalidate(pendingReservationRequests);
      return null;
    } on DioException catch (e) {
      final res = e.response;
      if (res == null) {
        return (HostError.networkError, e.toString());
      }
      if (res.statusCode == 409) {
        return (HostError.conflict, e.toString());
      }
      if (res.statusCode != null &&
          res.statusCode! >= 400 &&
          res.statusCode! < 500) {
        return (HostError.badRequest, e.toString());
      }
      rethrow;
    }
  } catch (e) {
    return (HostError.unknown, e.toString());
  }
}

Future<(HostError, String)?> rejectReservation(
  WidgetRef ref,
  int reservationId,
) async {
  final repo = ref.read(hostRepositoryProvider);
  try {
    try {
      await repo.rejectReservation(reservationId);
      ref.invalidate(pendingReservationRequests);
      return null;
    } on DioException catch (e) {
      final res = e.response;
      if (res == null) {
        return (HostError.networkError, e.toString());
      }
      if (res.statusCode == 409) {
        return (HostError.conflict, e.toString());
      }
      if (res.statusCode != null &&
          res.statusCode! >= 400 &&
          res.statusCode! < 500) {
        return (HostError.badRequest, e.toString());
      }
      rethrow;
    }
  } catch (e) {
    return (HostError.unknown, e.toString());
  }
}

Future<(HostError, String)?> approveReservationUpdate(
  WidgetRef ref,
  int reservationId,
) async {
  final repo = ref.read(hostRepositoryProvider);
  try {
    try {
      await repo.approveReservationUpdate(reservationId);
      ref.invalidate(pendingReservationUpdates);
      return null;
    } on DioException catch (e) {
      final res = e.response;
      if (res == null) {
        return (HostError.networkError, e.toString());
      }
      if (res.statusCode != null &&
          res.statusCode! >= 400 &&
          res.statusCode! < 500) {
        return (HostError.badRequest, e.toString());
      }
      rethrow;
    }
  } catch (e) {
    return (HostError.unknown, e.toString());
  }
}

Future<(HostError, String)?> rejectReservationUpdate(
  WidgetRef ref,
  int reservationId,
) async {
  final repo = ref.read(hostRepositoryProvider);
  try {
    try {
      await repo.rejectReservationUpdate(reservationId);
      ref.invalidate(pendingReservationUpdates);
      return null;
    } on DioException catch (e) {
      final res = e.response;
      if (res == null) {
        return (HostError.networkError, e.toString());
      }
      if (res.statusCode == 409) {
        return (HostError.conflict, e.toString());
      }
      if (res.statusCode != null &&
          res.statusCode! >= 400 &&
          res.statusCode! < 500) {
        return (HostError.badRequest, e.toString());
      }
      rethrow;
    }
  } catch (e) {
    return (HostError.unknown, e.toString());
  }
}
