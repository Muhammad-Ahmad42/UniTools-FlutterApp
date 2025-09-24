class UserModel {
  final String username;
  final String email;
  final List<String> listedProducts;

  UserModel({
    required this.username,
    required this.email,
    List<String>? listedProducts,
  }) : listedProducts = listedProducts ?? [];

  Map<String, dynamic> toJson() => {
    'Username': username,
    'Email': email,
    'ListedProducts': listedProducts,
  };

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      username: json['Username'] ?? '',
      email: json['Email'] ?? '',
      listedProducts: List<String>.from(json['ListedProducts'] ?? []),
    );
  }

  static UserModel empty() =>
      UserModel(username: '', email: '', listedProducts: []);
}
