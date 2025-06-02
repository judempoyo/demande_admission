import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String user_id;
  final String email;
  final String? fullName;
  final String? phone;
  final String role; // 'admin', 'student', etc.
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const User({
    required this.user_id,
    required this.email,
    this.fullName,
    this.phone,
    this.role = 'student',
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      user_id: map['user_id'] as String,
      email: map['email'] as String,
      fullName: map['full_name']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      role: map['role']?.toString() ?? 'student',
      createdAt:
          map['created_at'] != null
              ? DateTime.parse(map['created_at'] as String)
              : null,
      updatedAt:
          map['updated_at'] != null
              ? DateTime.parse(map['updated_at'] as String)
              : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': user_id,
      'email': email,
      'full_name': fullName,
      'phone': phone,
      'role': role,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
    user_id,
    email,
    fullName,
    phone,
    role,
    createdAt,
    updatedAt,
  ];
}
