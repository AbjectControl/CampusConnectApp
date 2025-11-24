import 'package:cconnect/common/widgets/appbar/custom_appbar.dart';
import 'package:cconnect/common/widgets/forms/custom_textformfield.dart';
import 'package:cconnect/data/models/userModel.dart';
import 'package:cconnect/features/chat/controllers/chat_provider.dart';
import 'package:cconnect/utils/constraints/appicons.dart';
import 'package:cconnect/utils/constraints/sizing.dart';
import 'package:cconnect/utils/constraints/strings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final List<String> _selectedUserIds = [];
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: "Create Group",
        actions: [
          TextButton(
            onPressed: _selectedUserIds.isEmpty || _groupNameController.text.trim().isEmpty
                ? null
                : () => _createGroup(chatProvider),
            child: const Text("Create"),
          ),
        ],
      ),
      body: Padding(
        padding: Sizing.paddingAll16,
        child: Column(
          children: [
            CustomTextFormField(
              controller: _groupNameController,
              hintText: "Group Name",
              labelText: "Group Name",
              svgIcon: userIcon, 
              onChanged: (val) => setState(() {}),
            ),
            Sizing.h16,
            const Text("Select Members", style: TextStyle(fontWeight: FontWeight.bold)),
            Sizing.h8,
            CustomTextFormField(
              controller: _searchController,
              hintText: "Search Users",
              labelText: "Search",
              svgIcon: searchIcon, 
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
            Sizing.h16,
            Expanded(
              child: StreamBuilder<List<User>>(
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

                      final isSelected = _selectedUserIds.contains(user.id);

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
                          child: user.photoUrl == null ? const Icon(Icons.person) : null,
                        ),
                        title: Text(user.displayName),
                        subtitle: Text(user.studentId ?? ''),
                        trailing: Checkbox(
                          value: isSelected,
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                _selectedUserIds.add(user.id);
                              } else {
                                _selectedUserIds.remove(user.id);
                              }
                            });
                          },
                        ),
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _selectedUserIds.remove(user.id);
                            } else {
                              _selectedUserIds.add(user.id);
                            }
                          });
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createGroup(ChatProvider provider) async {
    try {
      final groupId = await provider.createGroup(
        _groupNameController.text.trim(),
        _selectedUserIds,
      );
      if (groupId != null && mounted) {
        Navigator.pop(context); // Go back to chat list
        // Optionally navigate to the new group chat immediately
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error creating group: $e")),
      );
    }
  }
}
