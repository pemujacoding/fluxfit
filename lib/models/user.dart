class User {
  late final int? userId;
  final String username;
  final String password;
  final String gender;
  final String tanggalLahir;

  User({
    this.userId,
    required this.username,
    required this.password,
    required this.gender,
    required this.tanggalLahir,
  });

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = {
      'username': username,
      'password': password,
      'gender': gender,
      'tanggal_lahir': tanggalLahir,
    };
    if (userId != null) map['user_id'] = userId!;
    return map;
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      userId: map['user_id'],
      username: map['username'],
      password: map['password'],
      gender: map['gender'],
      tanggalLahir: map['tanggal_lahir'],
    );
  }
}
