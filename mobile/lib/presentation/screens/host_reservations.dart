import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homio/core/providers/navigator_key.dart';
import 'package:homio/data/models/reservation.dart';
import 'package:homio/l10n/app_localizations.dart';
import 'package:homio/presentation/providers/chat.dart';
import 'package:homio/presentation/providers/host.dart';
import 'package:homio/presentation/screens/chat_conversation.dart';
import 'package:homio/presentation/utils.dart';
import 'package:homio/presentation/widgets/empty.dart';
import 'package:homio/presentation/widgets/error_retry.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';

class HostReservationsScreen extends ConsumerStatefulWidget {
  const HostReservationsScreen({super.key});

  @override
  ConsumerState<HostReservationsScreen> createState() =>
      _HostReservationsScreenState();
}

class _HostReservationsScreenState extends ConsumerState<HostReservationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // TODO: move to utils
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

  Future<void> _approveRequest(
    BuildContext context,
    WidgetRef ref,
    Reservation reservation,
    bool isUpdate,
  ) async {
    final loc = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.accept),
        content: Text(isUpdate ? loc.confirmApproveUpdate : loc.confirmApprove),
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
        ref.read(navigatorKeyProvider),
        action: () => isUpdate
            ? approveReservationUpdate(ref, reservation.id)
            : approveReservation(ref, reservation.id),
        onCompleted: (result) {
          if (result == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  isUpdate ? loc.updateApproved : loc.reservationApproved,
                ),
              ),
            );
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

  Future<void> _rejectRequest(
    BuildContext context,
    WidgetRef ref,
    Reservation reservation,
    bool isUpdate,
  ) async {
    final loc = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.reject),
        content: Text(isUpdate ? loc.confirmRejectUpdate : loc.confirmReject),
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
        ref.read(navigatorKeyProvider),
        action: () => isUpdate
            ? rejectReservationUpdate(ref, reservation.id)
            : rejectReservation(ref, reservation.id),
        onCompleted: (result) {
          if (result == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  isUpdate ? loc.updateRejected : loc.reservationRejected,
                ),
              ),
            );
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

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(loc.manageReservations),
          bottom: TabBar(
            controller: _tabController,
            dividerColor: Colors.transparent,
            tabs: [
              Tab(
                text: loc.pendingRequests,
                icon: HugeIcon(icon: HugeIcons.strokeRoundedLoading01),
              ),
              Tab(
                text: loc.updateRequests,
                icon: HugeIcon(icon: HugeIcons.strokeRoundedEdit01),
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildPendingRequestsTab(context, ref, loc),
            _buildUpdateRequestsTab(context, ref, loc),
          ],
        ),
      ),
    );
  }

  void _openChat(BuildContext context, int userId) async {
    final loc = AppLocalizations.of(context)!;

    await showBlockingLoadingUntil(
      context,
      ref.read(navigatorKeyProvider),
      action: () => createConversation(ref, userId),
      onCompleted: (result) {
        final (conversation, error) = result;
        if (error != null) {
          final message = switch (error) {
            .networkError => loc.networkError,
            .badRequest => loc.checkYourRequest,
            _ => loc.anErrorOccurred,
          };
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
          return;
        }
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ChatConversationScreen(conversationId: conversation!.id),
          ),
        );
      },
    );
  }

  Widget _buildPendingRequestsTab(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations loc,
  ) {
    final requestsAsync = ref.watch(pendingReservationRequests);

    if (requestsAsync.isLoading && !requestsAsync.hasError) {
      return const Center(child: CircularProgressIndicator());
    }

    if (requestsAsync.hasError) {
      final error = requestsAsync.error;
      String message;
      if (error is DioException && error.response == null) {
        message = loc.noInternetConnection;
      } else {
        message = error.toString();
      }
      return Center(
        child: ErrorRetry(
          message: message,
          onRetry: () => ref.invalidate(pendingReservationRequests),
        ),
      );
    }

    final requests = requestsAsync.asData?.value ?? [];

    if (requests.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async => ref.invalidate(pendingReservationRequests),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: .symmetric(horizontal: 20),
              physics: AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Empty(
                  icon: HugeIcons.strokeRoundedCalendar03,
                  message: loc.noPendingRequests,
                ),
              ),
            );
          },
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(pendingReservationRequests),
      child: ListView.builder(
        padding: const .fromLTRB(12, 12, 12, 0),
        itemCount: requests.length,
        itemBuilder: (context, index) {
          final reservation = requests[index];
          final statusText = _getStatusText(reservation.status, loc);
          final statusColor = _getStatusColor(reservation.status, context);

          return InkWell(
            borderRadius: const .all(.circular(16)),
            onTap: () => _openChat(context, reservation.userId),
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
                            Text(
                              '${loc.checkIn}: ${_formatDuration(reservation.checkIn, reservation.checkIn, context)}',
                              style: TextTheme.of(context).bodySmall?.copyWith(
                                color: ColorScheme.of(context).outline,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () =>
                            _approveRequest(context, ref, reservation, false),
                        icon: const HugeIcon(
                          icon: HugeIcons.strokeRoundedCheckmarkCircle01,
                          size: 20,
                        ),
                        color: ColorScheme.of(context).primary,
                        tooltip: loc.accept,
                      ),
                      IconButton(
                        onPressed: () =>
                            _rejectRequest(context, ref, reservation, false),
                        icon: const HugeIcon(
                          icon: HugeIcons.strokeRoundedCancelCircle,
                          size: 20,
                        ),
                        color: ColorScheme.of(context).error,
                        tooltip: loc.reject,
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

  Widget _buildUpdateRequestsTab(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations loc,
  ) {
    final updatesAsync = ref.watch(pendingReservationUpdates);

    if (updatesAsync.isLoading && !updatesAsync.hasError) {
      return const Center(child: CircularProgressIndicator());
    }

    if (updatesAsync.hasError) {
      final error = updatesAsync.error;
      String message;
      if (error is DioException && error.response == null) {
        message = loc.noInternetConnection;
      } else {
        message = error.toString();
      }
      return Center(
        child: ErrorRetry(
          message: message,
          onRetry: () => ref.invalidate(pendingReservationUpdates),
        ),
      );
    }

    final updates = updatesAsync.asData?.value ?? [];

    if (updates.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async => ref.invalidate(pendingReservationUpdates),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: .symmetric(horizontal: 20),
              physics: AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Empty(
                  icon: HugeIcons.strokeRoundedCalendar03,
                  message: loc.noUpdateRequests,
                ),
              ),
            );
          },
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(pendingReservationUpdates),
      child: ListView.builder(
        padding: const .fromLTRB(12, 12, 12, 0),
        itemCount: updates.length,
        itemBuilder: (context, index) {
          final reservation = updates[index];
          final statusText = _getStatusText(reservation.status, loc);
          final statusColor = _getStatusColor(reservation.status, context);

          return InkWell(
            borderRadius: const .all(.circular(16)),
            onTap: () => _openChat(context, reservation.userId),
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
                        Expanded(
                          child: Column(
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
                                style: TextTheme.of(context).bodySmall
                                    ?.copyWith(
                                      color: ColorScheme.of(context).secondary,
                                    ),
                              ),
                              Text(
                                '${loc.checkIn}: ${_formatDuration(reservation.checkIn, reservation.checkIn, context)}',
                                style: TextTheme.of(context).bodySmall
                                    ?.copyWith(
                                      color: ColorScheme.of(context).outline,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () =>
                            _approveRequest(context, ref, reservation, true),
                        icon: const HugeIcon(
                          icon: HugeIcons.strokeRoundedCheckmarkCircle01,
                          size: 20,
                        ),
                        color: ColorScheme.of(context).primary,
                        tooltip: loc.accept,
                      ),
                      IconButton(
                        onPressed: () =>
                            _rejectRequest(context, ref, reservation, true),
                        icon: const HugeIcon(
                          icon: HugeIcons.strokeRoundedCancelCircle,
                          size: 20,
                        ),
                        color: ColorScheme.of(context).error,
                        tooltip: loc.reject,
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
