class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final String token;
  final String? imageUrl;
  final Map<String, String>? address;
  final String status;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.token,
    this.imageUrl,
    this.address,
    required this.status,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      token: json['token'] as String,
      imageUrl: json['imageUrl'] as String?,
      address: json['address'] != null
          ? Map<String, String>.from(json['address'] as Map)
          : null,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'token': token,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (address != null) 'address': address,
      'status': status,
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? token,
    String? imageUrl,
    Map<String, String>? address,
    String? status,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      token: token ?? this.token,
      imageUrl: imageUrl ?? this.imageUrl,
      address: address ?? this.address,
      status: status ?? this.status,
    );
  }
} 