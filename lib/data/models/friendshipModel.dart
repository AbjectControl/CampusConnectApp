class Friendship {
  final String id;
  final String requesterId;
  final String recipientId;
  final DateTime createdAt;
  final bool accepted;

  Friendship({
    required this.id,
    required this.requesterId,
    required this.recipientId,
    DateTime? createdAt,
    this.accepted = false,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Friendship.fromJson(Map<String, dynamic> json) => Friendship(
    id: json['id'],
    requesterId: json['requesterId'],
    recipientId: json['recipientId'],
    createdAt: json['createdAt'] != null
        ? DateTime.parse(json['createdAt'])
        : DateTime.now(),
    accepted: json['accepted'] ?? false,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'requesterId': requesterId,
    'recipientId': recipientId,
    'createdAt': createdAt.toIso8601String(),
    'accepted': accepted,
  };
}
