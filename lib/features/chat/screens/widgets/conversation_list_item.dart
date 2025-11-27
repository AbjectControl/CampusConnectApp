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

    // Try to get denormalized data first
    final userData = conversation['userData'] as Map<String, dynamic>?;
    final otherUserData = userData?[otherUserId] as Map<String, dynamic>?;

    if (otherUserData != null) {
      // Use denormalized data (FAST!)
      final displayName = otherUserData['displayName'] ?? 'Unknown';
      final photoUrl = otherUserData['photoUrl'];

      return ListTile(
        leading: CircleAvatar(
          backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
          child: photoUrl == null ? const Icon(Icons.person) : null,
        ),
        title: Text(
          displayName,
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
        onTap: () async {
          // We still need the full User object for the chat screen
          // But we can fetch it when tapped, which is fine.
          // Or we can construct a partial User object.
          final user = await chatProvider.getUser(otherUserId);
          if (context.mounted && user != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FriendsChatScreen(targetUser: user),
              ),
            );
          }
        },
      );
    }

    // Fallback to async fetch (Slow, but necessary for old conversations)
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
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatTime(conversation['lastMessageTime']),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              if (_getUnreadCount(conversation) > 0)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    "${_getUnreadCount(conversation)}",
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
            ],
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

  int _getUnreadCount(Map<String, dynamic> conversation) {
    final unreadCounts = conversation['unreadCounts'] as Map<String, dynamic>?;
    if (unreadCounts == null) return 0;
    return unreadCounts[chatProvider.currentUserId] ?? 0;
  }
}
