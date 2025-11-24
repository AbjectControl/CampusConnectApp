import 'package:cconnect/data/models/userModel.dart';
import 'package:cconnect/features/chat/controllers/chat_provider.dart';
import 'package:cconnect/features/chat/screens/friends/friends_chat_screen.dart';
import 'package:flutter/material.dart';

class UserSearchItem extends StatelessWidget {
  final User user;
  final ChatProvider chatProvider;

  const UserSearchItem({
    super.key,
    required this.user,
    required this.chatProvider,
  });

  @override
  Widget build(BuildContext context) {
    if (user.id == chatProvider.currentUserId) return const SizedBox.shrink();

    return ListTile(
      leading: CircleAvatar(
        backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
        child: user.photoUrl == null ? const Icon(Icons.person) : null,
      ),
      title: Text(user.displayName),
      subtitle: Text(user.studentId ?? ''),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FriendsChatScreen(targetUser: user),
          ),
        );
      },
    );
  }
}
