import 'package:cconnect/common/widgets/appbar/custom_appbar.dart';
import 'package:cconnect/data/models/userModel.dart';
import 'package:cconnect/data/repositories/functions/FireBaseFunctions/friendship_repository.dart';
import 'package:cconnect/features/chat/controllers/chat_provider.dart';
import 'package:cconnect/features/chat/screens/friends/friends_chat_screen.dart';
import 'package:cconnect/features/personalization/controllers/userProvider.dart';
import 'package:cconnect/utils/constraints/sizing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ContactInfoScreen extends StatefulWidget {
  final User user;

  const ContactInfoScreen({super.key, required this.user});

  @override
  State<ContactInfoScreen> createState() => _ContactInfoScreenState();
}

class _ContactInfoScreenState extends State<ContactInfoScreen> {
  String? _friendshipStatus; // 'none', 'pending', 'accepted'
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFriendshipStatus();
  }

  Future<void> _loadFriendshipStatus() async {
    final currentUser = Provider.of<UserProvider>(context, listen: false).user;
    if (currentUser == null) return;

    try {
      final friendship = await FriendshipRepository().getFriendship(currentUser.id, widget.user.id);
      setState(() {
        _friendshipStatus = friendship?.status ?? 'none';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _friendshipStatus = 'none';
        _isLoading = false;
      });
    }
  }

  void _addFriend() async {
    final currentUser = Provider.of<UserProvider>(context, listen: false).user;
    if (currentUser == null) return;

    try {
      await FriendshipRepository().sendFriendRequest(currentUser.id, widget.user.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Friend request sent')),
      );
      _loadFriendshipStatus();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _unfriend() async {
    final currentUser = Provider.of<UserProvider>(context, listen: false).user;
    if (currentUser == null) return;

    try {
      await FriendshipRepository().unfriend(currentUser.id, widget.user.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unfriended')),
      );
      _loadFriendshipStatus();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _sendMessage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => FriendsChatScreen(targetUser: widget.user),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Contact Info',
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: Sizing.paddingAll16,
        child: Column(
          children: [
            Sizing.h24,
            // Avatar
            CircleAvatar(
              radius: 60,
              backgroundImage: widget.user.photoUrl != null ? NetworkImage(widget.user.photoUrl!) : null,
              child: widget.user.photoUrl == null ? const Icon(Icons.person, size: 60) : null,
            ),
            Sizing.h16,
            // Name
            Text(
              widget.user.displayName,
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            // Department
            if (widget.user.department != null)
              Text(
                widget.user.department!,
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
              ),
            Sizing.h32,

            // Info Card
            Container(
              padding: Sizing.paddingAll16,
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  if (widget.user.email.isNotEmpty)
                    _buildInfoRow(context, Icons.email, 'Email', widget.user.email),
                  if (widget.user.studentId != null && widget.user.studentId!.isNotEmpty) ...[
                    const Divider(height: 32),
                    _buildInfoRow(context, Icons.badge, 'Student ID', widget.user.studentId!),
                  ],
                  if (widget.user.department != null && widget.user.department!.isNotEmpty) ...[
                    const Divider(height: 32),
                    _buildInfoRow(context, Icons.school, 'Department', widget.user.department!),
                  ],
                  if (widget.user.section != null && widget.user.section!.isNotEmpty) ...[
                    const Divider(height: 32),
                    _buildInfoRow(context, Icons.class_, 'Section', widget.user.section!),
                  ],
                  if (widget.user.phone != null && widget.user.phone!.isNotEmpty) ...[
                    const Divider(height: 32),
                    _buildInfoRow(context, Icons.phone, 'Phone', widget.user.phone!),
                  ],
                ],
              ),
            ),
            Sizing.h32,

            // Action Buttons
            if (_isLoading)
              const CircularProgressIndicator()
            else ...[
              // Friendship button
              if (_friendshipStatus == 'none')
                ElevatedButton.icon(
                  onPressed: _addFriend,
                  icon: const Icon(Icons.person_add),
                  label: const Text('Add Friend'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              if (_friendshipStatus == 'accepted')
                OutlinedButton.icon(
                  onPressed: _unfriend,
                  icon: const Icon(Icons.person_remove),
                  label: const Text('Unfriend'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    foregroundColor: Colors.red,
                  ),
                ),
              if (_friendshipStatus == 'pending')
                OutlinedButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.hourglass_empty),
                  label: const Text('Request Pending'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              Sizing.h16,
              _buildActionTile(
                context,
                'Send Message',
                Icons.message,
                _sendMessage,
              ),
              const Divider(),
              _buildActionTile(
                context,
                'Block User',
                Icons.block,
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('User blocked')),
                  );
                },
                isDestructive: true,
              ),
              const Divider(),
              _buildActionTile(
                context,
                'Report User',
                Icons.report_problem,
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Report submitted')),
                  );
                },
                isDestructive: true,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.blue),
        ),
        Sizing.w16,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
              Text(value, style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionTile(BuildContext context, String title, IconData icon, VoidCallback onTap, {bool isDestructive = false}) {
    final color = isDestructive ? Colors.red : Theme.of(context).textTheme.bodyLarge?.color;
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
