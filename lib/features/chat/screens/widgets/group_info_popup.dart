import 'package:cconnect/data/models/groupCommunity.dart';
import 'package:cconnect/features/chat/controllers/chat_provider.dart';
import 'package:cconnect/utils/constraints/sizing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GroupInfoPopup extends StatelessWidget {
  final GroupCommunity group;

  const GroupInfoPopup({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 40,
              child: Icon(Icons.group, size: 40),
            ),
            Sizing.h16,
            Text(
              group.name,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            Sizing.h8,
            Text(
              "${group.members.length} members",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
            Sizing.h16,
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("About", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Sizing.h8,
            Text(
              group.description.isNotEmpty ? group.description : "No description available.",
              textAlign: TextAlign.center,
            ),
            Sizing.h24,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // TODO: Implement join group logic
                    // chatProvider.joinGroup(group.id);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Join request sent (Mock)")),
                    );
                  },
                  child: const Text("Join Group"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Report logic
                  },
                  child: const Text("Report", style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
