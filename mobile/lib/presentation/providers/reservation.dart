import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/reservation.dart';
import '../../data/repositories/reservation.dart';

Duration? _retry(int count, Object error) {
  if (error is DioException && error.response == null) return null;
  if (count > 10) return null;
  return Duration(milliseconds: 200 * count);
}

List<Reservation> parseReservations(List list) =>
    list.map((e) => Reservation.fromJson(e)).toList();

final myReservations = FutureProvider<List<Reservation>>((ref) async {
  try {
    final repo = ref.read(reservationRepositoryProvider);
    final response = await repo.myReservations();
    final reservationsJson = response.data["data"] ?? [];
    return parseReservations(reservationsJson);
  } on DioException catch (e) {
    if (e.response != null && e.response!.statusCode == 404) return [];
    rethrow;
  }
}, retry: _retry);

final reservedDates = FutureProvider.family<List<String>, int>((
  ref,
  int postId,
) async {
  final repo = ref.read(reservationRepositoryProvider);
  final response = await repo.getReservedDates(postId);
  return List<String>.from(response.data);
}, retry: _retry);

enum ReservationError { unknown, networkError, badRequest, conflict }

Future<(ReservationError, String)?> makeReservation(
  WidgetRef ref, {
  required int postId,
  required String checkIn,
  required String checkOut,
}) async {
  final repo = ref.read(reservationRepositoryProvider);
  try {
    await repo.makeReservation(
      postId: postId,
      checkIn: checkIn,
      checkOut: checkOut,
    );
    return null;
  } on DioException catch (e) {
    final res = e.response;
    if (res == null) {
      return (ReservationError.networkError, e.toString());
    }
    if (res.statusCode == 409) {
      return (ReservationError.conflict, e.toString());
    }
    if (res.statusCode != null &&
        res.statusCode! >= 400 &&
        res.statusCode! < 500) {
      return (ReservationError.badRequest, e.toString());
    }
    rethrow;
  } catch (e) {
    return (ReservationError.unknown, e.toString());
  }
}

Future<(ReservationError, String)?> updateReservation(
  WidgetRef ref, {
  required int reservationId,
  required String checkIn,
  required String checkOut,
}) async {
  final repo = ref.read(reservationRepositoryProvider);
  try {
    await repo.updateReservation(
      reservationId: reservationId,
      checkIn: checkIn,
      checkOut: checkOut,
    );
    return null;
  } on DioException catch (e) {
    final res = e.response;
    if (res == null) {
      return (ReservationError.networkError, e.toString());
    }
    if (res.statusCode == 409) {
      return (ReservationError.conflict, e.toString());
    }
    if (res.statusCode != null &&
        res.statusCode! >= 400 &&
        res.statusCode! < 500) {
      return (ReservationError.badRequest, e.toString());
    }
    rethrow;
  } catch (e) {
    return (ReservationError.unknown, e.toString());
  }
}

Future<(ReservationError, String)?> cancelReservation(
  WidgetRef ref,
  int reservationId,
) async {
  final repo = ref.read(reservationRepositoryProvider);
  try {
    await repo.cancelReservation(reservationId);
    return null;
  } on DioException catch (e) {
    final res = e.response;
    if (res == null) {
      return (ReservationError.networkError, e.toString());
    }
    if (res.statusCode != null &&
        res.statusCode! >= 400 &&
        res.statusCode! < 500) {
      return (ReservationError.badRequest, e.toString());
    }
    rethrow;
  } catch (e) {
    return (ReservationError.unknown, e.toString());
  }
}
