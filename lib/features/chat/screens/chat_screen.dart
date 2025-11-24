import 'package:cconnect/common/widgets/appbar/custom_appbar.dart';
import 'package:cconnect/common/widgets/forms/custom_textformfield.dart';
import 'package:cconnect/data/models/userModel.dart';

import 'package:cconnect/features/chat/controllers/chat_provider.dart';
import 'package:cconnect/features/chat/screens/friends/friends_chat_screen.dart';
import 'package:cconnect/features/chat/screens/groups/create_group_screen.dart';
import 'package:cconnect/features/chat/screens/groups/group_chat_screen.dart';
import 'package:cconnect/features/personalization/controllers/userProvider.dart';
import 'package:cconnect/utils/constraints/appicons.dart';
import 'package:cconnect/utils/constraints/enums.dart';
import 'package:cconnect/utils/constraints/sizing.dart';
import 'package:cconnect/utils/constraints/strings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = '';

  @override
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final chatProvider = Provider.of<ChatProvider>(context);
    final currentUser = userProvider.user;

    if (currentUser == null) return const Center(child: CircularProgressIndicator());

    // Ensure current user is set in provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (chatProvider.currentUserId == null) {
        chatProvider.setCurrentUser(currentUser.id);
      }
    });

    return Scaffold(
      appBar: CustomAppBar(
        title: AppStrings.chat,
        centerTitle: true,
        actions: [
          // Only show Create Group for mentor, manager, admin
          if (currentUser.role == UserRole.mentor || 
              currentUser.role == UserRole.manager || 
              currentUser.role == UserRole.admin)
            IconButton(
              icon: const Icon(Icons.group_add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreateGroupScreen()),
                );
              },
            ),
        ],
      ),
      body: Padding(
        padding: Sizing.paddingAll16,
        child: Column(
          children: [
            // Search Bar
            CustomTextFormField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              hintText: AppStrings.search,
              labelText: AppStrings.search,
              svgIcon: searchIcon, 
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
            ),
            Sizing.h16,
            
            // Content
            Expanded(
              child: _searchQuery.isNotEmpty
                  ? _buildSearchResults(chatProvider)
                  : _buildRecentChats(chatProvider),
            ),
          ],
        ),
      ),

    );
  }

  Widget _buildSearchResults(ChatProvider chatProvider) {
    return StreamBuilder<List<User>>(
      stream: chatProvider.searchUsers(_searchQuery),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No users found"));
        }

        final users = snapshot.data!;
        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
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
          },
        );
      },
    );
  }

  Widget _buildRecentChats(ChatProvider chatProvider) {
    // We use the passed chatProvider

    
    // Ensure current user is set
    if (chatProvider.currentUserId == null) {
       final currentUser = Provider.of<UserProvider>(context, listen: false).user;
       if (currentUser != null) {
         chatProvider.setCurrentUser(currentUser.id);
       }
    }

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: chatProvider.getConversations(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(AppStrings.startConversation, style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        final conversations = snapshot.data!;
        return ListView.builder(
          itemCount: conversations.length,
          itemBuilder: (context, index) {
            final conversation = conversations[index];
            final isGroup = conversation['isGroup'] == true;
            
            if (isGroup) {
              return ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.group),
                ),
                title: Text(conversation['name'] ?? 'Group', style: const TextStyle(fontWeight: FontWeight.bold)),
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
                  title: Text(user.displayName, style: const TextStyle(fontWeight: FontWeight.bold)),
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
