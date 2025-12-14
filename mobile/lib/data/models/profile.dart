class Profile {
  final int id;
  final String firstName;
  final String lastName;
  final String dateOfBirth;
  final String profileImage;
  final String createdAt;
  final String updatedAt;

  Profile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.profileImage,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json["id"],
      firstName: json["first_name"],
      lastName: json["last_name"],
      dateOfBirth: json["Date_Of_Birth"],
      profileImage: json["profile_image"],
      createdAt: json["created_at"],
      updatedAt: json["updated_at"],
    );
  }

  Profile copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? dateOfBirth,
    String? profileImage,
    String? createdAt,
    String? updatedAt,
  }) {
    return Profile(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      profileImage: profileImage ?? this.profileImage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
