import 'package:cconnect/data/models/userModel.dart';
import 'package:cconnect/data/repositories/functions/FireBaseFunctions/admin_repository.dart';
import 'package:cconnect/data/repositories/functions/FireBaseFunctions/mentorship_repository.dart';
import 'package:cconnect/data/repositories/functions/FireBaseFunctions/user.dart';
import 'package:cconnect/data/repositories/interfaces/iuser.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.people), text: 'Users'),
            Tab(icon: Icon(Icons.school), text: 'Mentorship'),
            Tab(icon: Icon(Icons.analytics), text: 'Analytics'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _UsersTab(),
          _MentorshipTab(),
          _AnalyticsTab(),
        ],
      ),
    );
  }
}

// Users Tab
class _UsersTab extends StatelessWidget {
  const _UsersTab();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<User>>(
      stream: AdminRepository.instance.getAllUsers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No users found'));
        }

        final users = snapshot.data!;
        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
                child: user.photoUrl == null ? const Icon(Icons.person) : null,
              ),
              title: Text(user.displayName),
              subtitle: Text('${user.role.toString().split('.').last} • ${user.email}'),
              trailing: PopupMenuButton<String>(
                onSelected: (value) async {
                  try {
                    switch (value) {
                      case 'ban':
                        await AdminRepository.instance.banUser(user.id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${user.displayName} has been banned')),
                          );
                        }
                        break;
                      case 'unban':
                        await AdminRepository.instance.unbanUser(user.id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${user.displayName} has been unbanned')),
                          );
                        }
                        break;
                      case 'promote':
                        await AdminRepository.instance.promoteToAdmin(user.id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${user.displayName} promoted to Admin')),
                          );
                        }
                        break;
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'ban', child: Text('Ban User')),
                  const PopupMenuItem(value: 'unban', child: Text('Unban User')),
                  const PopupMenuItem(value: 'promote', child: Text('Promote to Admin')),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// Mentorship Requests Tab
class _MentorshipTab extends StatelessWidget {
  const _MentorshipTab();

  @override
  Widget build(BuildContext context) {
    final userRepository = Provider.of<IUserRepository>(context, listen: false);
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: MentorshipRepository.instance.getMentorshipRequests(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No pending requests'));
        }

        final requests = snapshot.data!;
        return ListView.builder(
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];
            final subjects = List<String>.from(request['subjects'] ?? []);
            
            return Card(
              margin: const EdgeInsets.all(8),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: FutureBuilder<User?>(
                  future: userRepository.fetchUser(request['userId']),
                  builder: (context, userSnapshot) {
                    final user = userSnapshot.data;
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (userSnapshot.connectionState == ConnectionState.waiting)
                          const CircularProgressIndicator()
                        else ...[
                          Text(
                            user?.displayName ?? 'Unknown User',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.email ?? 'No email',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          if (user?.studentId != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Roll No: ${user!.studentId}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                          const Divider(height: 24),
                          Text('Subjects: ${subjects.join(', ')}'),
                          const SizedBox(height: 4),
                          Text('Bio: ${request['bio']}'),
                          const SizedBox(height: 4),
                          Text('Availability: ${request['availability'].toString()}'),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () async {
                                  try {
                                    await MentorshipRepository.instance.rejectMentorshipRequest(request['id']);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Request rejected')),
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Error: $e')),
                                      );
                                    }
                                  }
                                },
                                child: const Text('Reject', style: TextStyle(color: Colors.red)),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () async {
                                  try {
                                    await MentorshipRepository.instance.approveMentorshipRequest(
                                      request['id'],
                                      request['userId'],
                                    );
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Request approved! User is now a mentor.')),
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Error: $e')),
                                      );
                                    }
                                  }
                                },
                                child: const Text('Approve'),
                              ),
                            ],
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// Analytics Tab
class _AnalyticsTab extends StatelessWidget {
  const _AnalyticsTab();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, int>>(
      future: AdminRepository.instance.getUserStats(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData) {
          return const Center(child: Text('No data available'));
        }

        final stats = snapshot.data!;
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Platform Statistics',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              _StatCard(
                icon: Icons.people,
                title: 'Total Users',
                value: stats['totalUsers'].toString(),
                color: Colors.blue,
              ),
              const SizedBox(height: 16),
              _StatCard(
                icon: Icons.pending,
                title: 'Pending Mentorship Requests',
                value: stats['pendingRequests'].toString(),
                color: Colors.orange,
              ),
              const SizedBox(height: 16),
              _StatCard(
                icon: Icons.group,
                title: 'Active Groups',
                value: stats['activeGroups'].toString(),
                color: Colors.green,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
