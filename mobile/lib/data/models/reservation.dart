enum ReservationStatus { pending, accepted, rejected, canceled, completed }

class Reservation {
  final int id;
  final int userId;
  final int postId;
  final ReservationStatus status;
  final DateTime checkIn;
  final DateTime checkOut;
  final DateTime? requestCheckIn;
  final DateTime? requestCheckOut;
  final DateTime createdAt;
  final DateTime updatedAt;

  Reservation({
    required this.id,
    required this.userId,
    required this.postId,
    required this.status,
    required this.checkIn,
    required this.checkOut,
    this.requestCheckIn,
    this.requestCheckOut,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'],
      userId: json['user_id'],
      postId: json['post_id'],
      status: ReservationStatus.values.firstWhere(
        (s) => s.name.toLowerCase() == json['status'].toString().toLowerCase(),
        orElse: () => ReservationStatus.pending,
      ),
      checkIn: DateTime.parse(json['check_in']),
      checkOut: DateTime.parse(json['check_out']),
      requestCheckIn: json['request_check_in'] != null
          ? DateTime.parse(json['request_check_in'])
          : null,
      requestCheckOut: json['request_check_out'] != null
          ? DateTime.parse(json['request_check_out'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
