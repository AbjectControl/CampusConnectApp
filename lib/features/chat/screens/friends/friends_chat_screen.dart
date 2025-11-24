import 'package:cconnect/common/widgets/appbar/custom_appbar.dart';
import 'package:cconnect/data/models/message.dart';
import 'package:flutter/services.dart';
import 'package:cconnect/data/models/userModel.dart';
import 'package:cconnect/features/chat/controllers/chat_controller.dart';
import 'package:cconnect/features/chat/controllers/chat_provider.dart';
import 'package:cconnect/features/chat/screens/contact_info/contact_info_screen.dart';
import 'package:cconnect/features/personalization/controllers/userProvider.dart';
import 'package:cconnect/utils/constraints/sizing.dart';
import 'package:cconnect/utils/constraints/strings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FriendsChatScreen extends StatefulWidget {
  final User targetUser;

  const FriendsChatScreen({super.key, required this.targetUser});

  @override
  State<FriendsChatScreen> createState() => _FriendsChatScreenState();
}

class _FriendsChatScreenState extends State<FriendsChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  late String _conversationId;

  @override
  void initState() {
    super.initState();
    final currentUser = Provider.of<UserProvider>(context, listen: false).user!;
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    
    // Initialize provider with current user if not set
    if (chatProvider.currentUserId == null) {
      chatProvider.setCurrentUser(currentUser.id);
    }
    
    _conversationId = chatProvider.getConversationId(widget.targetUser.id);
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    Provider.of<ChatProvider>(context, listen: false).sendMessage(_conversationId, _messageController.text);
    _messageController.clear();
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
            CircleAvatar(
              radius: 20,
              backgroundImage: widget.targetUser.photoUrl != null 
                  ? NetworkImage(widget.targetUser.photoUrl!) 
                  : null,
              child: widget.targetUser.photoUrl == null 
                  ? const Icon(Icons.person, size: 20) 
                  : null,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.targetUser.displayName,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Text(
                  'Online',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onSelected: (value) {
              if (value == 'info') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ContactInfoScreen(user: widget.targetUser),
                  ),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'info', child: Text('Contact Info')),
              const PopupMenuItem(value: 'mute', child: Text('Mute')),
              const PopupMenuItem(value: 'block', child: Text('Block')),
            ],
          ),
        ],
      ),
      body: Container(
        color: const Color(0xFFF5F5F5),
        child: Column(
          children: [
            Expanded(
              child: Consumer<ChatProvider>(
                builder: (context, chatProvider, child) {
                  return StreamBuilder<List<Message>>(
                    stream: chatProvider.getMessages(_conversationId),
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
                          
                          final bool isFirstInSequence = index == messages.length - 1 || 
                              messages[index + 1].senderId != message.senderId;
                          final bool isLastInSequence = index == 0 || 
                              messages[index - 1].senderId != message.senderId;

                          bool showDateDivider = false;
                          if (index == messages.length - 1) {
                            showDateDivider = true;
                          } else {
                            final currentDate = DateTime(message.sentAt.year, message.sentAt.month, message.sentAt.day);
                            final nextDate = DateTime(messages[index + 1].sentAt.year, messages[index + 1].sentAt.month, messages[index + 1].sentAt.day);
                            showDateDivider = !currentDate.isAtSameMomentAs(nextDate);
                          }

                          return Column(
                            children: [
                              if (showDateDivider) ...[
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  child: Text(
                                    _formatDate(message.sentAt),
                                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                                  ),
                                ),
                              ],
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                                children: [
                                  if (!isMe && isLastInSequence) ...[
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundImage: widget.targetUser.photoUrl != null 
                                          ? NetworkImage(widget.targetUser.photoUrl!) 
                                          : null,
                                      child: widget.targetUser.photoUrl == null 
                                          ? const Icon(Icons.person, size: 16) 
                                          : null,
                                    ),
                                    const SizedBox(width: 8),
                                  ] else if (!isMe) ...[
                                    const SizedBox(width: 40),
                                  ],
                                  Flexible(
                                    child: GestureDetector(
                                      onLongPress: () => _showMessageOptions(context, message, isMe),
                                      child: Container(
                                        margin: EdgeInsets.only(
                                          top: isFirstInSequence ? 4 : 2,
                                          bottom: isLastInSequence ? 4 : 2,
                                        ),
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        decoration: BoxDecoration(
                                          color: isMe ? const Color(0xFF2196F3) : const Color(0xFFF0F0F0),
                                          borderRadius: BorderRadius.only(
                                            topLeft: const Radius.circular(16),
                                            topRight: const Radius.circular(16),
                                            bottomLeft: isMe ? const Radius.circular(16) : (isLastInSequence ? const Radius.circular(4) : const Radius.circular(16)),
                                            bottomRight: isMe ? (isLastInSequence ? const Radius.circular(4) : const Radius.circular(16)) : const Radius.circular(16),
                                          ),
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
                                                if (isMe) ...[
                                                  const SizedBox(width: 4),
                                                  const Icon(Icons.done_all, size: 14, color: Colors.white70),
                                                ],
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: AppStrings.typeMessage,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send, color: Colors.blue),
                      onPressed: _sendMessage,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime date) {
    return "${date.hour > 12 ? date.hour - 12 : date.hour}:${date.minute.toString().padLeft(2, '0')} ${date.hour >= 12 ? 'PM' : 'AM'}";
  }

  void _showMessageOptions(BuildContext context, Message message, bool isMe) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildOptionItem(context, Icons.reply, "Reply", () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Reply coming soon")));
              }),
              _buildOptionItem(context, Icons.copy, "Copy", () {
                Navigator.pop(context);
                Clipboard.setData(ClipboardData(text: message.text));
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Copied")));
              }),
              _buildOptionItem(context, Icons.forward, "Forward", () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Forward coming soon")));
              }),
              if (isMe)
                _buildOptionItem(context, Icons.delete_outline, "Delete", () {
                  Navigator.pop(context);
                  Provider.of<ChatProvider>(context, listen: false).deleteMessage(message.id);
                }, color: Colors.redAccent),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOptionItem(BuildContext context, IconData icon, String label, VoidCallback onTap, {Color color = Colors.white}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: color, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return 'Today';
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
