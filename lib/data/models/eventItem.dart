import 'package:cconnect/utils/constraints/enums.dart';
import 'package:flutter/foundation.dart';

class EventItem {
  final String id;
  final String title;
  final String description;
  final DateTime start;
  final DateTime end;
  final String createdBy;
  final List<String> participants;
  final EventStatus status;

  EventItem({
    required this.id,
    required this.title,
    required this.description,
    required this.start,
    required this.end,
    required this.createdBy,
    this.participants = const [],
    this.status = EventStatus.upcoming,
  });

  factory EventItem.fromJson(Map<String, dynamic> json) => EventItem(
    id: json['id'],
    title: json['title'],
    description: json['description'] ?? '',
    start: DateTime.parse(json['start']),
    end: DateTime.parse(json['end']),
    createdBy: json['createdBy'],
    participants: List<String>.from(json['participants'] ?? []),
    status: _statusFromString(json['status'] as String?),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'start': start.toIso8601String(),
    'end': end.toIso8601String(),
    'createdBy': createdBy,
    'participants': participants,
    'status': describeEnum(status),
  };

  static EventStatus _statusFromString(String? s) {
    if (s == null) return EventStatus.upcoming;
    return EventStatus.values.firstWhere(
      (e) => describeEnum(e) == s,
      orElse: () => EventStatus.upcoming,
    );
  }
}
