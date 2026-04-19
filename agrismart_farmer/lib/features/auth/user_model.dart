class User {
  final String? id;
  final String? name;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? role;
  final String? token;
  final String? profilePictureUrl;
  final String? phone;
  final String? location;
  final String? cropType;

  User({
    this.id,
    this.name,
    required this.email,
    this.firstName,
    this.lastName,
    this.role,
    this.token,
    this.profilePictureUrl,
    this.phone,
    this.location,
    this.cropType,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'] ?? '',
      firstName: json['firstName'],
      lastName: json['lastName'],
      role: json['role'],
      token: json['token'],
      profilePictureUrl: json['profilePictureUrl'],
      phone: json['phone'],
      location: json['location'],
      cropType: json['cropType'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'role': role,
      'token': token,
      'profilePictureUrl': profilePictureUrl,
      'phone': phone,
      'location': location,
      'cropType': cropType,
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? firstName,
    String? lastName,
    String? role,
    String? token,
    String? profilePictureUrl,
    String? phone,
    String? location,
    String? cropType,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      role: role ?? this.role,
      token: token ?? this.token,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      cropType: cropType ?? this.cropType,
    );
  }
}
