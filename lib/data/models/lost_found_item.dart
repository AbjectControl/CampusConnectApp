import 'package:flutter/foundation.dart';

enum LostFoundType { lost, found }

enum LostFoundStatus { active, resolved }

class LostFoundItem {
  final String id;
  final String title;
  final String description;
  final LostFoundType type;
  final String location;
  final String? imageUrl;
  final String contactInfo;
  final String reportedBy;
  final DateTime reportedAt;
  final LostFoundStatus status;

  LostFoundItem({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.location,
    this.imageUrl,
    required this.contactInfo,
    required this.reportedBy,
    DateTime? reportedAt,
    this.status = LostFoundStatus.active,
  }) : reportedAt = reportedAt ?? DateTime.now();

  factory LostFoundItem.fromJson(Map<String, dynamic> json) => LostFoundItem(
    id: json['id'] as String,
    title: json['title'] as String,
    description: json['description'] as String,
    type: _typeFromString(json['type'] as String?),
    location: json['location'] as String,
    imageUrl: json['imageUrl'] as String?,
    contactInfo: json['contactInfo'] as String,
    reportedBy: json['reportedBy'] as String,
    reportedAt: json['reportedAt'] != null
        ? DateTime.parse(json['reportedAt'] as String)
        : DateTime.now(),
    status: _statusFromString(json['status'] as String?),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'type': describeEnum(type),
    'location': location,
    'imageUrl': imageUrl,
    'contactInfo': contactInfo,
    'reportedBy': reportedBy,
    'reportedAt': reportedAt.toIso8601String(),
    'status': describeEnum(status),
  };

  static LostFoundType _typeFromString(String? s) {
    if (s == null) return LostFoundType.lost;
    return LostFoundType.values.firstWhere(
      (e) => describeEnum(e) == s,
      orElse: () => LostFoundType.lost,
    );
  }

  static LostFoundStatus _statusFromString(String? s) {
    if (s == null) return LostFoundStatus.active;
    return LostFoundStatus.values.firstWhere(
      (e) => describeEnum(e) == s,
      orElse: () => LostFoundStatus.active,
    );
  }

  LostFoundItem copyWith({
    String? id,
    String? title,
    String? description,
    LostFoundType? type,
    String? location,
    String? imageUrl,
    String? contactInfo,
    String? reportedBy,
    DateTime? reportedAt,
    LostFoundStatus? status,
  }) {
    return LostFoundItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      location: location ?? this.location,
      imageUrl: imageUrl ?? this.imageUrl,
      contactInfo: contactInfo ?? this.contactInfo,
      reportedBy: reportedBy ?? this.reportedBy,
      reportedAt: reportedAt ?? this.reportedAt,
      status: status ?? this.status,
    );
  }
}
