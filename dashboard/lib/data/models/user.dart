class User {
  final int id;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String profileImage;
  final String idImage;
  final String dateOfBirth;

  const User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.profileImage,
    required this.idImage,
    required this.dateOfBirth,
  });

  String get fullName => '$firstName $lastName';

  factory User.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? profile = (json['profile'] is Map)
        ? Map<String, dynamic>.from(json['profile'])
        : null;

    String _s(dynamic a, dynamic b, [String fallback = '']) {
      if (a != null) return a.toString();
      if (b != null) return b.toString();
      return fallback;
    }

    int _toInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      final parsed = int.tryParse(v.toString());
      return parsed ?? 0;
    }

    final firstName = _s(
      profile?['first_name'] ?? profile?['firstName'],
      json['first_name'] ?? json['firstName'],
      '',
    );

    final lastName = _s(
      profile?['last_name'] ?? profile?['lastName'],
      json['last_name'] ?? json['lastName'],
      '',
    );

    final phoneNumber = _s(
      json['phone_number'] ?? json['phoneNumber'],
      profile?['phone_number'] ?? profile?['phoneNumber'],
      '',
    );

    final profileImage = _s(
      profile?['profile_image'] ?? profile?['profileImage'],
      json['profile_image'] ?? json['profileImage'],
      '',
    );

    final idImage = _s(
      profile?['ID_image'] ?? profile?['id_image'] ?? profile?['idImage'],
      json['ID_image'] ?? json['id_image'] ?? json['idImage'],
      '',
    );

    final dateOfBirth = _s(
      profile?['Date_Of_Birth'] ??
          profile?['date_of_birth'] ??
          profile?['dateOfBirth'],
      json['Date_Of_Birth'] ?? json['date_of_birth'] ?? json['dateOfBirth'],
      '',
    );

    final email = (profile?['email'] ?? json['email'])?.toString();

    // `is_host` may be represented as bool or string/int.
    bool _bool(dynamic v) {
      if (v == null) return false;
      if (v is bool) return v;
      final s = v.toString().toLowerCase();
      return s == '1' || s == 'true' || s == 'yes';
    }

    final isHost = _bool(
      profile?['is_host'] ??
          json['is_host'] ??
          json['isHost'] ??
          profile?['isHost'],
    );

    final status = (json['status'] ?? profile?['status'])?.toString();

    final id = _toInt(json['id'] ?? json['user_id'] ?? json['userId']);

    return User(
      id: id,
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
      profileImage: profileImage,
      idImage: idImage,
      dateOfBirth: dateOfBirth,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'phone_number': phoneNumber,
      'profile_image': profileImage,
      'ID_image': idImage,
      'date_of_birth': dateOfBirth,
    };
  }

  User copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? profileImage,
    String? idImage,
    String? dateOfBirth,
  }) {
    return User(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImage: profileImage ?? this.profileImage,
      idImage: idImage ?? this.idImage,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, name: $fullName, phone: $phoneNumber, dob: $dateOfBirth)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
