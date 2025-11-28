enum SurveyStatus {
  active,
  closed,
  expired;

  String toJson() => name;

  static SurveyStatus fromJson(String json) {
    return SurveyStatus.values.firstWhere((e) => e.name == json);
  }
}

class Survey {
  final String id;
  final String title;
  final String description;
  final String surveyLink;
  final String createdBy;
  final DateTime createdAt;
  final DateTime endDateTime;
  final SurveyStatus status;
  final int reportCount;

  Survey({
    required this.id,
    required this.title,
    required this.description,
    required this.surveyLink,
    required this.createdBy,
    DateTime? createdAt,
    required this.endDateTime,
    this.status = SurveyStatus.active,
    this.reportCount = 0,
  }) : createdAt = createdAt ?? DateTime.now();

  // Check if survey is expired
  bool get isExpired => DateTime.now().isAfter(endDateTime);

  factory Survey.fromJson(Map<String, dynamic> json) {
    return Survey(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      surveyLink: json['surveyLink'] as String,
      createdBy: json['createdBy'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      endDateTime: DateTime.parse(json['endDateTime'] as String),
      status: SurveyStatus.fromJson(json['status'] as String),
      reportCount: json['reportCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'surveyLink': surveyLink,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'endDateTime': endDateTime.toIso8601String(),
      'status': status.toJson(),
      'reportCount': reportCount,
    };
  }

  Survey copyWith({
    String? id,
    String? title,
    String? description,
    String? surveyLink,
    String? createdBy,
    DateTime? createdAt,
    DateTime? endDateTime,
    SurveyStatus? status,
    int? reportCount,
  }) {
    return Survey(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      surveyLink: surveyLink ?? this.surveyLink,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      endDateTime: endDateTime ?? this.endDateTime,
      status: status ?? this.status,
      reportCount: reportCount ?? this.reportCount,
    );
  }
}
