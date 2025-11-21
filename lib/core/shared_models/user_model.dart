class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String userType; // 'rider' or 'driver'
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.userType,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      userType: json['user_type']?.toString() ?? 'rider',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'user_type': userType,
      'created_at': createdAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? userType,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      userType: userType ?? this.userType,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get isDriver => userType == 'driver';
  bool get isRider => userType == 'rider';

  String get displayName => name.isNotEmpty ? name : phone;
  String get initials => name.isNotEmpty 
      ? name.split(' ').map((n) => n[0]).take(2).join().toUpperCase()
      : phone.substring(0, 2).toUpperCase();

  @override
  String toString() => 'UserModel(id: $id, name: $name, type: $userType)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
