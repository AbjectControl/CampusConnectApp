enum EventStatus {
  active,
  expired;

  String toJson() => name;
  static EventStatus fromJson(String json) =>
      values.firstWhere((e) => e.name == json);
}

class Event {
  final String id;
  final String title;
  final String venue;
  final String? imageUrl;
  final DateTime startTime;
  final DateTime endTime;
  final String createdBy;
  final DateTime createdAt;
  final EventStatus status;

  Event({
    required this.id,
    required this.title,
    required this.venue,
    this.imageUrl,
    required this.startTime,
    required this.endTime,
    required this.createdBy,
    DateTime? createdAt,
    this.status = EventStatus.active,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isExpired => DateTime.now().isAfter(endTime);

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] as String,
      title: json['title'] as String,
      venue: json['venue'] as String,
      imageUrl: json['imageUrl'] as String?,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      createdBy: json['createdBy'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      status: EventStatus.fromJson(json['status'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'venue': venue,
      'imageUrl': imageUrl,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'status': status.toJson(),
    };
  }

  Event copyWith({
    String? id,
    String? title,
    String? venue,
    String? imageUrl,
    DateTime? startTime,
    DateTime? endTime,
    String? createdBy,
    DateTime? createdAt,
    EventStatus? status,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      venue: venue ?? this.venue,
      imageUrl: imageUrl ?? this.imageUrl,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
    );
  }
}
