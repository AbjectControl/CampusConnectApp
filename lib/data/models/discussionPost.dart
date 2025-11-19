class DiscussionPost {
  final String id;
  final String authorId;
  final String title;
  final String body;
  final DateTime createdAt;
  final List<String> repliesIds;
  final List<String> tags;

  DiscussionPost({
    required this.id,
    required this.authorId,
    required this.title,
    required this.body,
    DateTime? createdAt,
    this.repliesIds = const [],
    this.tags = const [],
  }) : createdAt = createdAt ?? DateTime.now();

  factory DiscussionPost.fromJson(Map<String, dynamic> json) => DiscussionPost(
    id: json['id'],
    authorId: json['authorId'],
    title: json['title'],
    body: json['body'],
    createdAt: json['createdAt'] != null
        ? DateTime.parse(json['createdAt'])
        : DateTime.now(),
    repliesIds: List<String>.from(json['repliesIds'] ?? []),
    tags: List<String>.from(json['tags'] ?? []),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'authorId': authorId,
    'title': title,
    'body': body,
    'createdAt': createdAt.toIso8601String(),
    'repliesIds': repliesIds,
    'tags': tags,
  };
}
