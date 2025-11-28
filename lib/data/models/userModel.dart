import 'package:flutter/foundation.dart';
import 'package:cconnect/utils/constraints/enums.dart';

class User {
  final String id;
  String displayName;
  final String email;
  String? photoUrl;
  String? about;
  DateTime? lastSeen;
  bool isOnline;
  final UserRole role;
  final String? studentId; // e.g., l230989
  final String? phone;
  String? department;
  String? section;
  Map<String, dynamic>? metadata; // e.g., semester, availability

  User({
    required this.id,
    required this.displayName,
    required this.email,
    this.photoUrl,
    this.about,
    this.lastSeen,
    this.isOnline = false,
    this.role = UserRole.student,
    this.studentId,
    this.phone,
    this.department,
    this.section,
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
    isOnline: json['isOnline'] as bool? ?? false,
    role: _roleFromString(json['role'] as String?),
    studentId: json['studentId'] as String?,
    phone: json['phone'] as String?,
    department: json['department'] as String?,
    section: json['section'] as String?,
    metadata: json['metadata'] as Map<String, dynamic>?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'displayName': displayName,
    'email': email,
    'photoUrl': photoUrl,
    'about': about,
    'lastSeen': lastSeen?.toIso8601String(),
    'isOnline': isOnline,
    'role': describeEnum(role),
    'studentId': studentId,
    'phone': phone,
    'department': department,
    'section': section,
    'metadata': metadata ?? {},
  };

  User copyWith({
    String? id,
    String? displayName,
    String? email,
    String? photoUrl,
    String? about,
    DateTime? lastSeen,
    bool? isOnline,
    UserRole? role,
    String? studentId,
    String? phone,
    String? department,
    String? section,
    Map<String, dynamic>? metadata,
  }) {
    return User(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      about: about ?? this.about,
      lastSeen: lastSeen ?? this.lastSeen,
      isOnline: isOnline ?? this.isOnline,
      role: role ?? this.role,
      studentId: studentId ?? this.studentId,
      phone: phone ?? this.phone,
      department: department ?? this.department,
      section: section ?? this.section,
      metadata: metadata ?? this.metadata,
    );
  }

  static UserRole _roleFromString(String? s) {
    if (s == null) return UserRole.student;
    return UserRole.values.firstWhere(
      (r) => describeEnum(r) == s,
      orElse: () => UserRole.student,
    );
  }
}
