import 'package:cconnect/data/models/conversation.dart';
import 'package:cconnect/data/models/userModel.dart';
import 'package:cconnect/features/chat/controllers/chat_provider.dart';
import 'package:cconnect/features/chat/screens/groups/create_group_screen.dart';
import 'package:cconnect/data/models/groupCommunity.dart';
import 'package:cconnect/features/chat/screens/widgets/conversation_list_item.dart';
import 'package:cconnect/features/chat/screens/widgets/group_info_popup.dart';
import 'package:cconnect/features/chat/screens/widgets/user_search_item.dart';
import 'package:cconnect/features/personalization/controllers/userProvider.dart';
import 'package:cconnect/utils/constraints/appicons.dart';
import 'package:cconnect/utils/constraints/sizing.dart';
import 'package:cconnect/utils/constraints/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final currentUser = Provider.of<UserProvider>(context).user;

    if (currentUser == null) return const Center(child: CircularProgressIndicator());
    if (chatProvider.currentUserId == null) {
      chatProvider.setCurrentUser(currentUser.id);
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: Sizing.paddingAll16,
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.trim();
                  });
                },
                decoration: InputDecoration(
                  hintText: AppStrings.search,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                ),
              ),
            ),
            Expanded(
              child: _searchQuery.isEmpty
                  ? _buildConversationList(chatProvider)
                  : _buildSearchResults(chatProvider),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateGroupScreen()),
          );
        },
        child: const Icon(Icons.group_add),
      ),
    );
  }

  Widget _buildConversationList(ChatProvider chatProvider) {
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
          return const Center(child: Text(AppStrings.noChats));
        }

        final conversations = snapshot.data!;
        return ListView.builder(
          itemCount: conversations.length,
          itemBuilder: (context, index) {
            return ConversationListItem(
              conversation: conversations[index],
              chatProvider: chatProvider,
            );
          },
        );
      },
    );
  }

  Widget _buildSearchResults(ChatProvider chatProvider) {
    return FutureBuilder(
      future: Future.wait([
        chatProvider.searchGroups(_searchQuery),
        chatProvider.searchUsers(_searchQuery).first,
      ]),
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final groups = snapshot.data?[0] as List<dynamic>? ?? [];
        final users = snapshot.data?[1] as List<User>? ?? [];

        if (groups.isEmpty && users.isEmpty) {
          return const Center(child: Text("No results found"));
        }

        return CustomScrollView(
          slivers: [
            if (groups.isNotEmpty) ...[
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Groups", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final group = groups[index] as GroupCommunity;
                    return ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.group)),
                      title: Text(group.name),
                      subtitle: Text("${group.members.length} members"),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => GroupInfoPopup(group: group),
                        );
                      },
                    );
                  },
                  childCount: groups.length,
                ),
              ),
            ],
            if (users.isNotEmpty) ...[
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("People", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return UserSearchItem(
                      user: users[index],
                      chatProvider: chatProvider,
                    );
                  },
                  childCount: users.length,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
