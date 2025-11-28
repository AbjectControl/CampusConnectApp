import 'package:cconnect/common/widgets/appbar/custom_appbar.dart';
import 'package:cconnect/data/models/event.dart';
import 'package:cconnect/features/community/controllers/event_provider.dart';
import 'package:cconnect/features/community/screens/communityEvents/add_event_dialog.dart';
import 'package:cconnect/features/personalization/controllers/userProvider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CommunityEventsScreen extends StatelessWidget {
  const CommunityEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Events",
        centerTitle: true,
        actions: [
          Consumer<UserProvider>(
            builder: (context, userProvider, child) {
              final eventProvider = Provider.of<EventProvider>(
                context,
                listen: false,
              );
              if (eventProvider.canCreateEvent(userProvider.user)) {
                return IconButton(
                  onPressed: () => _showAddEventDialog(context),
                  icon: const Icon(Icons.add),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<EventProvider>(
        builder: (context, provider, child) {
          return StreamBuilder<List<Event>>(
            stream: provider.getEvents(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final events = snapshot.data ?? [];

              if (events.isEmpty) {
                return const Center(child: Text('No upcoming events'));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: events.length,
                itemBuilder: (context, index) {
                  return _EventCard(event: events[index]);
                },
              );
            },
          );
        },
      ),
    );
  }

  void _showAddEventDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => const AddEventDialog());
  }
}

class _EventCard extends StatelessWidget {
  final Event event;

  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy · h:mm a');

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Event Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 80,
                height: 80,
                color: Colors.grey[200],
                child: event.imageUrl != null
                    ? Image.network(
                        event.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.event, color: Colors.grey),
                      )
                    : const Icon(Icons.event, color: Colors.grey, size: 32),
              ),
            ),
            const SizedBox(width: 16),

            // Event Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateFormat.format(event.startTime),
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.venue,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
