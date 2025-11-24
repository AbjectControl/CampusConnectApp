import 'package:cconnect/data/models/userModel.dart';
import 'package:cconnect/features/chat/controllers/chat_provider.dart';
import 'package:cconnect/features/chat/screens/friends/friends_chat_screen.dart';
import 'package:cconnect/features/chat/screens/groups/group_chat_screen.dart';
import 'package:flutter/material.dart';

class ConversationListItem extends StatelessWidget {
  final Map<String, dynamic> conversation;
  final ChatProvider chatProvider;

  const ConversationListItem({
    super.key,
    required this.conversation,
    required this.chatProvider,
  });

  @override
  Widget build(BuildContext context) {
    final isGroup = conversation['isGroup'] == true;

    if (isGroup) {
      return _buildGroupTile(context);
    }

    return _buildDirectMessageTile(context);
  }

  Widget _buildGroupTile(BuildContext context) {
    return ListTile(
      leading: const CircleAvatar(
        child: Icon(Icons.group),
      ),
      title: Text(
        conversation['name'] ?? 'Group',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        conversation['lastMessage'] ?? '',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        _formatTime(conversation['lastMessageTime']),
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => GroupChatScreen(
              groupId: conversation['id'],
              groupName: conversation['name'] ?? 'Group',
            ),
          ),
        );
      },
    );
  }

  Widget _buildDirectMessageTile(BuildContext context) {
    final participants = List<String>.from(conversation['participants'] ?? []);
    final otherUserId = participants.firstWhere(
      (id) => id != chatProvider.currentUserId,
      orElse: () => 'Unknown',
    );

    return FutureBuilder<User?>(
      future: chatProvider.getUser(otherUserId),
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData) return const SizedBox.shrink();
        final user = userSnapshot.data!;

        return ListTile(
          leading: CircleAvatar(
            backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
            child: user.photoUrl == null ? const Icon(Icons.person) : null,
          ),
          title: Text(
            user.displayName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            conversation['lastMessage'] ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Text(
            _formatTime(conversation['lastMessageTime']),
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FriendsChatScreen(targetUser: user),
              ),
            );
          },
        );
      },
    );
  }

  String _formatTime(String? isoString) {
    if (isoString == null) return '';
    final date = DateTime.parse(isoString);
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return "${date.hour}:${date.minute.toString().padLeft(2, '0')}";
    }
    return "${date.day}/${date.month}";
  }
}
