import 'package:flutter/foundation.dart';
import 'package:cconnect/utils/constraints/enums.dart';

class User {
  final String id;
  String displayName;
  final String email;
  String? photoUrl;
  String? about;
  DateTime? lastSeen;
  final UserRole role;
  Map<String, dynamic>? metadata; // e.g., department, semester, availability

  User({
    required this.id,
    required this.displayName,
    required this.email,
    this.photoUrl,
    this.about,
    this.lastSeen,
    this.role = UserRole.student,
    this.metadata,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'] as String,
    displayName: json['displayName'] as String,
    email: json['email'] as String,
    photoUrl: json['photoUrl'] as String?,
    about: json['about'] as String?,
    lastSeen: json['lastSeen'] != null
        ? DateTime.parse(json['lastSeen'] as String)
        : null,
    role: _roleFromString(json['role'] as String?),
    metadata: json['metadata'] as Map<String, dynamic>?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'displayName': displayName,
    'email': email,
    'photoUrl': photoUrl,
    'about': about,
    'lastSeen': lastSeen?.toIso8601String(),
    'role': describeEnum(role),
    'metadata': metadata ?? {},
  };

  static UserRole _roleFromString(String? s) {
    if (s == null) return UserRole.student;
    return UserRole.values.firstWhere(
      (r) => describeEnum(r) == s,
      orElse: () => UserRole.student,
    );
  }
}
