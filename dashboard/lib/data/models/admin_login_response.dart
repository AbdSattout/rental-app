class AdminLoginResponse {
  final String token;
  final AdminUser admin;

  AdminLoginResponse({required this.token, required this.admin});

  factory AdminLoginResponse.fromJson(Map<String, dynamic> json) {
    return AdminLoginResponse(
      token: json['token'] as String? ?? '',
      admin: AdminUser.fromJson(json['user'] ?? {}),
    );
  }
}

class AdminUser {
  final int id;
  final String name;
  final String number;

  AdminUser({required this.id, required this.name, required this.number});

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      number: json['phone_number'] as String? ?? '',
    );
  }
}
