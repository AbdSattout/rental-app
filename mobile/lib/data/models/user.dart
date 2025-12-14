enum UserRole { guest, tenant, host, admin }

class User {
  final int id;
  final String phoneNumber;
  final UserRole role;
  final bool isApproved;
  final bool requestingHost;

  User({
    required this.id,
    required this.phoneNumber,
    required this.role,
    required this.isApproved,
    required this.requestingHost,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      phoneNumber: json['phone_number'],
      role: UserRole.values.firstWhere(
        (r) => r.name == json['role'],
        orElse: () => UserRole.guest,
      ),
      isApproved: json['is_approved'] ?? false,
      requestingHost: json['requesting_host'] ?? false,
    );
  }

  User copyWith({
    int? id,
    String? phoneNumber,
    UserRole? role,
    bool? isApproved,
    bool? requestingHost,
  }) {
    return User(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      isApproved: isApproved ?? this.isApproved,
      requestingHost: requestingHost ?? this.requestingHost,
    );
  }
}
