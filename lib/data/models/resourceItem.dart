import 'package:cconnect/utils/constraints/enums.dart';
import 'package:flutter/foundation.dart';

class ResourceItem {
  final String id;
  final String title;
  final String ownerId;
  final ResourceType type;
  final String storageUrl;
  final DateTime createdAt;
  final bool approved;
  final String? description;
  ResourceItem({
    required this.id,
    required this.title,
    required this.ownerId,
    required this.type,
    required this.storageUrl,
    DateTime? createdAt,
    this.approved = false,
    this.description,
  }) : createdAt = createdAt ?? DateTime.now();

  factory ResourceItem.fromJson(Map<String, dynamic> json) => ResourceItem(
    id: json['id'],
    title: json['title'],
    ownerId: json['ownerId'],
    type: _typeFromString(json['type'] as String?),
    storageUrl: json['storageUrl'],
    createdAt: json['createdAt'] != null
        ? DateTime.parse(json['createdAt'])
        : DateTime.now(),
    approved: json['approved'] ?? false,
    description: json['description'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'ownerId': ownerId,
    'type': describeEnum(type),
    'storageUrl': storageUrl,
    'createdAt': createdAt.toIso8601String(),
    'approved': approved,
    'description': description,
  };

  static ResourceType _typeFromString(String? s) {
    if (s == null) return ResourceType.other;
    return ResourceType.values.firstWhere(
      (r) => describeEnum(r) == s,
      orElse: () => ResourceType.other,
    );
  }
}
