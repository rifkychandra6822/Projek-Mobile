class User {
  String username;
  String password;
  String feedback;

  User({
    required this.username,
    required this.password,
    this.feedback = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'password': password,
      'feedback': feedback,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      username: map['username'] ?? '',
      password: map['password'] ?? '',
      feedback: map['feedback'] ?? '',
    );
  }
} 