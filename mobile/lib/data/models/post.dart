class Photo {
  final int id;
  final String filePath;

  Photo({required this.id, required this.filePath});

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(id: json['id'], filePath: json['file_path']);
  }
}

enum PostType { house, apartment, villa, office }

class Post {
  final int id;
  final PostType type;
  final double price;
  final int rooms;
  final int bathrooms;
  final int space;
  final double latitude;
  final double longitude;
  final DateTime createdAt;
  final List<Photo> featured;
  final List<Photo> gallery;
  final bool isFavorited;
  final double averageRating;
  final int ratingsCount;

  Post({
    required this.id,
    required this.type,
    required this.price,
    required this.rooms,
    required this.bathrooms,
    required this.space,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
    required this.featured,
    required this.gallery,
    this.isFavorited = false,
    this.averageRating = 0.0,
    this.ratingsCount = 0,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      type: PostType.values.firstWhere(
        (t) => t.name == json['type'].toString().toLowerCase(),
        orElse: () => PostType.apartment,
      ),
      price: double.parse(json['price'].toString()),
      rooms: json['rooms'],
      bathrooms: json['bathrooms'],
      space: double.parse(json['space'].toString()).toInt(),
      latitude: double.parse(json['latitude'].toString()),
      longitude: double.parse(json['longitude'].toString()),
      createdAt: DateTime.parse(json['created_at']),
      featured: (json['outside_photos'] as List<dynamic>)
          .map((p) => Photo.fromJson(p))
          .toList(),
      gallery: (json['inside_photos'] as List<dynamic>)
          .map((p) => Photo.fromJson(p))
          .toList(),
      isFavorited: (json['favorited_by_count'] ?? 0) > 0,
      averageRating: double.parse((json['average_rating'] ?? 0).toString()),
      ratingsCount: json['ratings_count'] ?? 0,
    );
  }

  Post copyWith({
    int? id,
    PostType? type,
    double? price,
    int? rooms,
    int? bathrooms,
    int? space,
    double? latitude,
    double? longitude,
    DateTime? createdAt,
    List<Photo>? featured,
    List<Photo>? gallery,
    bool? isFavorited,
    double? averageRating,
    int? ratingsCount,
  }) {
    return Post(
      id: id ?? this.id,
      type: type ?? this.type,
      price: price ?? this.price,
      rooms: rooms ?? this.rooms,
      bathrooms: bathrooms ?? this.bathrooms,
      space: space ?? this.space,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
      featured: featured ?? this.featured,
      gallery: gallery ?? this.gallery,
      isFavorited: isFavorited ?? this.isFavorited,
      averageRating: averageRating ?? this.averageRating,
      ratingsCount: ratingsCount ?? this.ratingsCount,
    );
  }
}
