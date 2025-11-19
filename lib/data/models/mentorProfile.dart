class MentorProfile {
  final String userId;
  final List<String> subjects;
  final String bio;
  final Map<String, dynamic> availability; // e.g., { "mon": ["18:00-19:00"] }
  final bool approved;
  MentorProfile({
    required this.userId,
    this.subjects = const [],
    this.bio = '',
    this.availability = const {},
    this.approved = false,
  });

  factory MentorProfile.fromJson(Map<String, dynamic> json) => MentorProfile(
    userId: json['userId'] as String,
    subjects: List<String>.from(json['subjects'] ?? []),
    bio: json['bio'] ?? '',
    availability: Map<String, dynamic>.from(json['availability'] ?? {}),
    approved: json['approved'] ?? false,
  );

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'subjects': subjects,
    'bio': bio,
    'availability': availability,
    'approved': approved,
  };
}
