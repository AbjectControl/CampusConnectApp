import 'package:cconnect/common/widgets/appbar/custom_appbar.dart';
import 'package:cconnect/data/models/lost_found_item.dart';
import 'package:cconnect/features/community/controllers/lost_found_provider.dart';
import 'package:cconnect/features/personalization/controllers/userProvider.dart';
import 'package:cconnect/utils/helpers/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class LostFoundDetailScreen extends StatelessWidget {
  final LostFoundItem item;

  const LostFoundDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final isOwner = userProvider.user?.id == item.reportedBy;
    final isLost = item.type == LostFoundType.lost;

    return Scaffold(
      appBar: CustomAppBar(
        title: isLost ? "Lost Item" : "Found Item",
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Image
          if (item.imageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                item.imageUrl!,
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 250,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.image,
                      size: 60,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            )
          else
            Container(
              height: 250,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                isLost ? Icons.search : Icons.check_circle_outline,
                size: 80,
                color: Colors.grey,
              ),
            ),
          const SizedBox(height: 24),

          // Status Badge
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isLost
                    ? const Color(0xFFFFEBEE)
                    : const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isLost ? 'Lost' : 'Found',
                style: TextStyle(
                  color: isLost
                      ? const Color(0xFFD32F2F)
                      : const Color(0xFF388E3C),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            item.title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // Timestamp
          Text(
            'Reported ${_formatDate(item.reportedAt)}',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          const SizedBox(height: 24),

          // Description
          _buildInfoSection(
            icon: Icons.description,
            title: 'Description',
            content: item.description,
          ),
          const SizedBox(height: 16),

          // Location
          _buildInfoSection(
            icon: Icons.location_on,
            title: isLost ? 'Last Seen' : 'Found At',
            content: item.location,
          ),
          const SizedBox(height: 16),

          // Contact Info
          _buildInfoSection(
            icon: Icons.contact_phone,
            title: 'Contact Info',
            content: item.contactInfo,
          ),
          const SizedBox(height: 32),

          // Status Badge
          if (item.status == LostFoundStatus.resolved)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF388E3C)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Color(0xFF388E3C)),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'This item has been resolved',
                      style: TextStyle(
                        color: Color(0xFF388E3C),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Mark as Resolved Button (owner only)
          if (isOwner && item.status == LostFoundStatus.active)
            Consumer<LostFoundProvider>(
              builder: (context, provider, child) {
                return ElevatedButton.icon(
                  onPressed: provider.isLoading
                      ? null
                      : () => _markAsResolved(context),
                  icon: const Icon(Icons.check_circle),
                  label: provider.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Mark as Resolved'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF388E3C),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildInfoSection({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF2196F3)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(content, style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'just now';
        }
        return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
      }
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }

  Future<void> _markAsResolved(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark as Resolved?'),
        content: const Text(
          'Are you sure you want to mark this item as resolved? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF388E3C),
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        final provider = Provider.of<LostFoundProvider>(context, listen: false);
        await provider.markAsResolved(item.id);

        if (context.mounted) {
          SnackbarService.success('Item marked as resolved');
          Navigator.pop(context);
        }
      } catch (e) {
        if (context.mounted) {
          SnackbarService.error('Failed to update item: $e');
        }
      }
    }
  }
}
