import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homio/data/models/reservation.dart';
import 'package:homio/data/models/user.dart';
import 'package:homio/l10n/app_localizations.dart';
import 'package:homio/presentation/providers/profile.dart';
import 'package:homio/presentation/providers/reservation.dart';
import 'package:homio/presentation/screens/post_details.dart';
import 'package:homio/presentation/utils.dart';
import 'package:homio/presentation/widgets/empty.dart';
import 'package:homio/presentation/widgets/error_retry.dart';
import 'package:homio/presentation/widgets/reservation_dialog.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';

class ReservationsTab extends ConsumerWidget {
  final User? user;

  const ReservationsTab({super.key, required this.user});

  String _getStatusText(ReservationStatus status, AppLocalizations loc) {
    switch (status) {
      case .pending:
        return loc.pending;
      case .accepted:
        return loc.accepted;
      case .rejected:
        return loc.rejected;
      case .canceled:
        return loc.canceled;
      case .completed:
        return loc.completed;
    }
  }

  Color _getStatusColor(ReservationStatus status, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (status) {
      case .pending:
        return colorScheme.primary;
      case .accepted:
        return colorScheme.secondary;
      case .rejected:
        return colorScheme.error;
      case .canceled:
        return colorScheme.outline;
      case .completed:
        return colorScheme.tertiary;
    }
  }

  List<List<dynamic>> _getStatusIcon(ReservationStatus status) {
    switch (status) {
      case .pending:
        return HugeIcons.strokeRoundedLoading01;
      case .accepted:
        return HugeIcons.strokeRoundedCheckmarkCircle01;
      case .rejected:
        return HugeIcons.strokeRoundedCancelCircle;
      case .canceled:
        return HugeIcons.strokeRoundedHold03;
      case .completed:
        return HugeIcons.strokeRoundedTick03;
    }
  }

  String _formatDuration(
    DateTime startDate,
    DateTime endDate,
    BuildContext context,
  ) {
    final loc = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final format = DateFormat('d MMM', locale);

    return startDate == endDate
        ? format.format(startDate)
        : '${format.format(startDate)} ${loc.to} ${format.format(endDate)}';
  }

  Future<void> _showEditDialog(
    BuildContext context,
    WidgetRef ref,
    Reservation reservation,
  ) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.editReservation),
        content: ReservationDialog(
          postId: reservation.postId,
          reservation: reservation,
        ),
      ),
    );
  }

  Future<void> _cancelReservation(
    BuildContext context,
    WidgetRef ref,
    Reservation reservation,
  ) async {
    final loc = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.cancel),
        content: Text(loc.confirmCancelReservation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(loc.no),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(loc.yes),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await showBlockingLoadingUntil(
        context,
        action: () => cancelReservation(ref, reservation.id),
        onCompleted: (result) {
          if (result == null) {
            ref.invalidate(reservedDates(reservation.postId));
            ref.invalidate(myReservations);
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(loc.reservationCanceled)));
            return;
          }
          final message = switch (result.$1) {
            .networkError => loc.networkError,
            .badRequest => loc.checkYourRequest,
            .conflict => loc.reservationConflict,
            _ => result.$2,
          };
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
        },
      );
    }
  }

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(myReservations);
    ref.invalidate(getProfile);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;

    final isGuest = user == null || user!.role == .guest;
    final reservationsAsync = !isGuest ? ref.watch(myReservations) : null;

    if (isGuest) {
      return Center(child: Text(loc.guestMode));
    }

    if (reservationsAsync == null) {
      return const SizedBox.shrink();
    }

    if (reservationsAsync.isLoading && !reservationsAsync.hasError) {
      return const Center(child: CircularProgressIndicator());
    }

    if (reservationsAsync.hasError) {
      final error = reservationsAsync.error;
      String message;
      if (error is DioException && error.response == null) {
        message = loc.noInternetConnection;
      } else {
        message = error.toString();
      }
      return Center(
        child: ErrorRetry(message: message, onRetry: () => _refresh(ref)),
      );
    }

    final reservations = reservationsAsync.asData?.value ?? [];

    if (reservations.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => _refresh(ref),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: .symmetric(horizontal: 20),
              physics: AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Empty(
                  icon: HugeIcons.strokeRoundedCalendar03,
                  message: loc.noReservations,
                ),
              ),
            );
          },
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _refresh(ref),
      child: ListView.builder(
        itemCount: reservations.length,
        itemBuilder: (context, index) {
          final reservation = reservations[index];
          final statusText = _getStatusText(reservation.status, loc);
          final statusColor = _getStatusColor(reservation.status, context);
          final canEdit =
              reservation.status == .pending || reservation.status == .accepted;
          final canCancel =
              reservation.status == .pending || reservation.status == .accepted;

          return InkWell(
            borderRadius: const .all(.circular(16)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      PostDetailsScreen(postId: reservation.postId),
                ),
              );
            },
            child: Padding(
              padding: const .symmetric(vertical: 8, horizontal: 12),
              child: Row(
                crossAxisAlignment: .center,
                children: [
                  Expanded(
                    child: Row(
                      spacing: 10,
                      children: [
                        Container(
                          padding: const .all(6),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            borderRadius: .circular(8),
                          ),
                          child: HugeIcon(
                            icon: _getStatusIcon(reservation.status),
                            color: statusColor,
                            size: 20,
                          ),
                        ),
                        Column(
                          crossAxisAlignment: .start,
                          children: [
                            Text(
                              statusText,
                              style: TextTheme.of(context).labelLarge,
                            ),
                            Text(
                              _formatDuration(
                                reservation.requestCheckIn ??
                                    reservation.checkIn,
                                reservation.requestCheckOut ??
                                    reservation.checkOut,
                                context,
                              ),
                              style: TextTheme.of(context).bodySmall?.copyWith(
                                color: ColorScheme.of(context).secondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Row(
                    children: [
                      if (canEdit)
                        IconButton(
                          onPressed: () =>
                              _showEditDialog(context, ref, reservation),
                          icon: const HugeIcon(
                            icon: HugeIcons.strokeRoundedEdit01,
                            size: 20,
                          ),
                          color: ColorScheme.of(context).primary,
                          tooltip: loc.edit,
                        ),
                      if (canCancel)
                        IconButton(
                          onPressed: () =>
                              _cancelReservation(context, ref, reservation),
                          icon: const HugeIcon(
                            icon: HugeIcons.strokeRoundedCancelCircle,
                            size: 20,
                          ),
                          color: ColorScheme.of(context).error,
                          tooltip: loc.cancel,
                        ),
                    ],
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
