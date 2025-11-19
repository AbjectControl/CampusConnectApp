class GroupCommunity {
  final String id;
  final String name;
  final String description;
  final String ownerId;
  final List<String> members;
  final bool requiresApproval;

  GroupCommunity({
    required this.id,
    required this.name,
    required this.description,
    required this.ownerId,
    this.members = const [],
    this.requiresApproval = true,
  });

  factory GroupCommunity.fromJson(Map<String, dynamic> json) => GroupCommunity(
    id: json['id'],
    name: json['name'],
    description: json['description'] ?? '',
    ownerId: json['ownerId'],
    members: List<String>.from(json['members'] ?? []),
    requiresApproval: json['requiresApproval'] ?? true,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'ownerId': ownerId,
    'members': members,
    'requiresApproval': requiresApproval,
  };
}
