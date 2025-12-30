import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homio/data/models/reservation.dart';
import 'package:homio/l10n/app_localizations.dart';
import 'package:homio/presentation/providers/reservation.dart';
import 'package:homio/presentation/utils.dart';
import 'package:homio/presentation/widgets/error_retry.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class ReservationDialog extends ConsumerWidget {
  const ReservationDialog({super.key, required this.postId, this.reservation});

  final int postId;
  final Reservation? reservation;

  Future<void> _submit(
    PickerDateRange? selectedRange,
    BuildContext context,
    WidgetRef ref,
  ) async {
    final loc = AppLocalizations.of(context)!;
    if (selectedRange == null || selectedRange.startDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(loc.checkYourRequest)));
      return;
    }

    await showBlockingLoadingUntil(
      context,
      action: () => reservation == null
          ? makeReservation(
              ref,
              postId: postId,
              checkIn: DateFormat(
                'yyyy-MM-dd',
              ).format(selectedRange.startDate!),
              checkOut: DateFormat(
                'yyyy-MM-dd',
              ).format((selectedRange.endDate ?? selectedRange.startDate)!),
            )
          : updateReservation(
              ref,
              reservationId: reservation!.id,
              checkIn: DateFormat(
                'yyyy-MM-dd',
              ).format(selectedRange.startDate!),
              checkOut: DateFormat(
                'yyyy-MM-dd',
              ).format((selectedRange.endDate ?? selectedRange.startDate)!),
            ),
      onCompleted: (result) {
        if (result == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                reservation == null
                    ? loc.reservationSuccess
                    : loc.reservationUpdated,
              ),
            ),
          );
          Navigator.of(context).pop();
          ref.invalidate(reservedDates(postId));
          ref.invalidate(myReservations);
          return;
        }

        final error = result;
        final message = switch (error.$1) {
          .networkError => loc.networkError,
          .badRequest => loc.checkYourRequest,
          .conflict => loc.reservationConflict,
          _ => error.$2,
        };
        Navigator.of(context).pop();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final isRTL = Directionality.of(context) == .rtl;

    return SizedBox(
      height: 420,
      width: .maxFinite,
      child: ref
          .watch(reservedDates(postId))
          .when(
            data: (dates) {
              final reservedDates = dates
                  .map((d) => DateTime.parse(d))
                  .toList();
              if (reservation != null) {
                reservedDates.removeWhere(
                  (date) =>
                      date == reservation!.checkIn ||
                      date == reservation!.checkOut,
                );
              }
              final initialRange = reservation != null
                  ? PickerDateRange(
                      reservation!.requestCheckIn ?? reservation!.checkIn,
                      reservation!.requestCheckOut ?? reservation!.checkOut,
                    )
                  : null;

              return SfDateRangePicker(
                headerStyle: .new(backgroundColor: Colors.transparent),
                backgroundColor: Colors.transparent,
                view: .month,
                selectionMode: .range,
                showActionButtons: true,
                enablePastDates: false,
                showNavigationArrow: true,
                initialSelectedRange: initialRange,
                monthViewSettings: .new(
                  blackoutDates: reservedDates,
                  viewHeaderStyle: .new(
                    textStyle: isRTL ? TextTheme.of(context).labelSmall : null,
                  ),
                ),
                confirmText: reservation == null ? loc.reserve : loc.update,
                onSubmit: (value) {
                  if (value is PickerDateRange?) {
                    _submit(value, context, ref);
                  }
                },
                cancelText: loc.cancel,
                onCancel: () {
                  Navigator.of(context).pop();
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) {
              String message;
              if (error is DioException && error.response == null) {
                message = loc.noInternetConnection;
              } else {
                message = error.toString();
              }
              return ErrorRetry(
                message: message,
                onRetry: () {
                  ref.invalidate(reservedDates(postId), asReload: true);
                },
              );
            },
          ),
    );
  }
}
