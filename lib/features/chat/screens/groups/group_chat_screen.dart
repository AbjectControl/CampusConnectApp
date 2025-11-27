import 'package:cconnect/common/widgets/appbar/custom_appbar.dart';
import 'package:cconnect/data/models/message.dart';
import 'package:cconnect/data/models/userModel.dart';
import 'package:cconnect/data/models/groupCommunity.dart';
import 'package:cconnect/features/chat/controllers/chat_provider.dart';
import 'package:cconnect/features/chat/screens/widgets/group_info_popup.dart';
import 'package:cconnect/features/personalization/controllers/userProvider.dart';
import 'package:cconnect/utils/constraints/sizing.dart';
import 'package:cconnect/utils/constraints/strings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GroupChatScreen extends StatefulWidget {
  final String groupId;
  final String groupName;

  const GroupChatScreen({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final currentUser = Provider.of<UserProvider>(context, listen: false).user;
    if (chatProvider.currentUserId == null && currentUser != null) {
      chatProvider.setCurrentUser(currentUser.id);
    }
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    Provider.of<ChatProvider>(context, listen: false).sendMessage(widget.groupId, _messageController.text);
    _messageController.clear();
  }

  String _formatTime(DateTime time) {
    return "${time.hour}:${time.minute.toString().padLeft(2, '0')}";
  }

  void _showGroupInfo() async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    // Fetch group details - assuming it's stored in conversations
    // For now, create a basic GroupCommunity object
    final group = GroupCommunity(
      id: widget.groupId,
      name: widget.groupName,
      description: 'Group chat',
      ownerId: '',
      members: [],
    );
    
    showDialog(
      context: context,
      builder: (_) => GroupInfoPopup(group: group),
    );
  }

  void _exitGroup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Group'),
        content: Text('Are you sure you want to exit "${widget.groupName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to chat list
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Left group successfully')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            const CircleAvatar(
              radius: 20,
              child: Icon(Icons.group, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.groupName,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onSelected: (value) {
              if (value == 'info') {
                _showGroupInfo();
              } else if (value == 'exit') {
                _exitGroup();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'info', child: Text('Group Info')),
              const PopupMenuItem(value: 'exit', child: Text('Exit Group')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chatProvider, child) {
                return StreamBuilder<List<Message>>(
                  stream: chatProvider.getMessages(widget.groupId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text(AppStrings.noChats));
                    }

                    final messages = snapshot.data!;
                    return ListView.builder(
                      reverse: true,
                      itemCount: messages.length,
                      padding: Sizing.paddingAll16,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        // Always get current user from UserProvider to ensure accuracy
                        final currentUserId = Provider.of<UserProvider>(context, listen: false).user?.id;
                        final isMe = message.senderId == currentUserId;
                        
                        // Check if previous message was from same sender
                        final bool isFirstInSequence = index == messages.length - 1 || 
                            messages[index + 1].senderId != message.senderId;
                        
                        // Unread message logic for group
                        bool isUnreadByMe = !isMe && !message.readBy.contains(currentUserId);
                        
                        // Read receipts - count how many have read
                        int readCount = message.readBy.length;

                        return Align(
                          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                            children: [
                              if (!isMe && isFirstInSequence) ...[
                                FutureBuilder<User?>(
                                  future: chatProvider.getUser(message.senderId),
                                  builder: (context, userSnapshot) {
                                    if (userSnapshot.hasData) {
                                      return Padding(
                                        padding: const EdgeInsets.only(left: 12, bottom: 2),
                                        child: Text(
                                          userSnapshot.data!.displayName,
                                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                                        ),
                                      );
                                    }
                                    return const SizedBox.shrink();
                                  },
                                ),
                              ],
                              Container(
                                margin: const EdgeInsets.symmetric(vertical: 2),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: isMe 
                                      ? const Color(0xFF2196F3) 
                                      : (isUnreadByMe 
                                          ? const Color(0xFFE3F2FD) 
                                          : Colors.white),
                                  border: isUnreadByMe 
                                      ? Border.all(color: const Color(0xFF2196F3), width: 1.5)
                                      : null,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 5,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      message.text,
                                      style: TextStyle(
                                        color: isMe ? Colors.white : Colors.black87,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          _formatTime(message.sentAt),
                                          style: TextStyle(
                                            color: isMe ? Colors.white70 : Colors.grey,
                                            fontSize: 11,
                                          ),
                                        ),
                                        if (isMe && readCount > 0) ...[
                                          const SizedBox(width: 4),
                                          Icon(
                                            Icons.done_all,
                                            size: 14,
                                            color: readCount > 1 ? Colors.blueAccent : Colors.white70,
                                          ),
                                          const SizedBox(width: 2),
                                          Text(
                                            '$readCount',
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          
          // Input Area
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    offset: const Offset(0, -2),
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: AppStrings.typeMessage,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white, size: 20),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
