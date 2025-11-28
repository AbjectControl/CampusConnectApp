import 'package:cconnect/data/models/friendshipModel.dart';
import 'package:cconnect/data/models/userModel.dart';
import 'package:cconnect/features/chat/controllers/chat_provider.dart';
import 'package:cconnect/features/chat/screens/friends/friends_chat_screen.dart';
import 'package:cconnect/utils/constraints/sizing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserInfoPopup extends StatefulWidget {
  final User user;

  const UserInfoPopup({super.key, required this.user});

  @override
  State<UserInfoPopup> createState() => _UserInfoPopupState();
}

class _UserInfoPopupState extends State<UserInfoPopup> {
  Friendship? _friendship;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkFriendshipStatus();
  }

  Future<void> _checkFriendshipStatus() async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final friendship = await chatProvider.getFriendship(widget.user.id);
    if (mounted) {
      setState(() {
        _friendship = friendship;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final currentUserId = chatProvider.currentUserId;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: widget.user.photoUrl != null
                    ? NetworkImage(widget.user.photoUrl!)
                    : null,
                child: widget.user.photoUrl == null
                    ? const Icon(Icons.person, size: 40)
                    : null,
              ),
              Sizing.h16,
              Text(
                widget.user.displayName,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              Sizing.h8,
              if (widget.user.studentId != null)
                Text(
                  "ID: ${widget.user.studentId}",
                  style: const TextStyle(color: Colors.grey),
                ),
              if (widget.user.department != null)
                Text(
                  "Dept: ${widget.user.department}",
                  style: const TextStyle(color: Colors.grey),
                ),
              if (widget.user.section != null)
                Text(
                  "Section: ${widget.user.section}",
                  style: const TextStyle(color: Colors.grey),
                ),
              Sizing.h8,
              Text(
                widget.user.email,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),

              Sizing.h24,
              if (_isLoading)
                const CircularProgressIndicator()
              else if (currentUserId != widget.user.id)
                _buildActionButtons(context, chatProvider),

              Sizing.h16,
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Report logic
                },
                child: const Text(
                  "Report User",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, ChatProvider chatProvider) {
    if (_friendship == null) {
      return ElevatedButton(
        onPressed: () async {
          await chatProvider.sendFriendRequest(widget.user.id);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Friend request sent")),
            );
            _checkFriendshipStatus();
          }
        },
        child: const Text("Add Friend"),
      );
    } else if (!_friendship!.accepted) {
      if (_friendship!.requesterId == chatProvider.currentUserId) {
        return const Text(
          "Request Pending",
          style: TextStyle(color: Colors.orange),
        );
      } else {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                await chatProvider.acceptFriendRequest(_friendship!.id);
                if (context.mounted) _checkFriendshipStatus();
              },
              child: const Text("Accept"),
            ),
            Sizing.w16,
            OutlinedButton(
              onPressed: () async {
                await chatProvider.rejectFriendRequest(_friendship!.id);
                if (context.mounted) _checkFriendshipStatus();
              },
              child: const Text("Reject"),
            ),
          ],
        );
      }
    } else {
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Friends",
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Sizing.w16,
              OutlinedButton(
                onPressed: () async {
                  await chatProvider.unfriend(_friendship!.id);
                  if (context.mounted) _checkFriendshipStatus();
                },
                style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                child: const Text("Unfriend"),
              ),
            ],
          ),
          Sizing.h8,
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FriendsChatScreen(targetUser: widget.user),
                ),
              );
            },
            icon: const Icon(Icons.message),
            label: const Text("Message"),
          ),
        ],
      );
    }
  }
}
