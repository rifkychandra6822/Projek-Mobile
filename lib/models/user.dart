class User {
  final int? id;
  final String username;
  final String password;
  final String? email;
  final String? nim;
  final String? kesanPesan;
  final String? profilePicture;
  final DateTime createdAt;

  User({
    this.id,
    required this.username,
    required this.password,
    this.email,
    this.nim,
    this.kesanPesan,
    this.profilePicture,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'email': email,
      'nim': nim,
      'kesan_pesan': kesanPesan,
      'profile_picture': profilePicture,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      password: map['password'],
      email: map['email'],
      nim: map['nim'],
      kesanPesan: map['kesan_pesan'],
      profilePicture: map['profile_picture'],
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'].toString())
          : DateTime.now(),
    );
  }
}