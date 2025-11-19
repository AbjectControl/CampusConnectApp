class AdminAction {
  final String id;
  final String adminId;
  final String targetId; // e.g., content id or user id
  final String action; // e.g., 'approve_resource', 'ban_user'
  final String reason;
  final DateTime createdAt;

  AdminAction({
    required this.id,
    required this.adminId,
    required this.targetId,
    required this.action,
    this.reason = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'adminId': adminId,
    'targetId': targetId,
    'action': action,
    'reason': reason,
    'createdAt': createdAt.toIso8601String(),
  };
}
