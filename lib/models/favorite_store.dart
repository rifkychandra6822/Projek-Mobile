class FavoriteStore {
  final int? id;
  final int? userId;
  final String storeName;
  final double latitude;
  final double longitude;
  final String? address;
  final DateTime addedAt;

  FavoriteStore({
    this.id,
    this.userId,
    required this.storeName,
    required this.latitude,
    required this.longitude,
    this.address,
    DateTime? addedAt,
  }) : addedAt = addedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'store_name': storeName,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'added_at': addedAt.toIso8601String(),
    };
  }

  factory FavoriteStore.fromMap(Map<String, dynamic> map) {
    return FavoriteStore(
      id: map['id'],
      userId: map['user_id'],
      storeName: map['store_name'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      address: map['address'],
      addedAt: DateTime.parse(map['added_at']),
    );
  }
} 