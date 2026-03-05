import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:buddygoapp/core/services/firebase_service.dart';
import 'package:buddygoapp/features/auth/presentation/auth_controller.dart';
import 'package:buddygoapp/features/groups/data/group_model.dart';
import 'package:buddygoapp/features/user/presentation/user_profile_view_screen.dart';

class JoinRequestsScreen extends StatefulWidget {
  final String groupId;
  final String groupName;

  const JoinRequestsScreen({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  State<JoinRequestsScreen> createState() => _JoinRequestsScreenState();
}

class _JoinRequestsScreenState extends State<JoinRequestsScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  bool _isLoading = false;

  Future<void> _handleRequest({
    required String userId,
    required String userName,
    required bool approve,
    String? reason,
  }) async {
    setState(() => _isLoading = true);

    try {
      final authController = Provider.of<AuthController>(context, listen: false);
      final adminId = authController.currentUser?.id;
      final adminName = authController.currentUser?.name ?? 'Admin';

      if (adminId == null) throw Exception('Admin not found');

      if (approve) {
        await _firebaseService.approveJoinRequest(
          groupId: widget.groupId,
          userId: userId,
          adminId: adminId,
          adminName: adminName,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ $userName has been added to the group'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        await _firebaseService.rejectJoinRequest(
          groupId: widget.groupId,
          userId: userId,
          adminId: adminId,
          adminName: adminName,
          reason: reason,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Request from $userName has been rejected'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      // Refresh will happen automatically via StreamBuilder
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showRejectDialog(String userId, String userName) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Request'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Are you sure you want to reject $userName\'s request?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _handleRequest(
                userId: userId,
                userName: userName,
                approve: false,
                reason: reasonController.text.isNotEmpty ? reasonController.text : null,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join Requests'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _firebaseService.groupsCollection.doc(widget.groupId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Group not found'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final group = GroupModel.fromJson({...data, 'id': snapshot.data!.id});

          final pendingRequests = group.pendingRequests
              .where((req) => req.status == RequestStatus.pending)
              .toList();

          if (pendingRequests.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.how_to_reg_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Pending Requests',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'When someone requests to join, they\'ll appear here',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: pendingRequests.length,
            itemBuilder: (context, index) {
              final request = pendingRequests[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          // User Avatar
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UserProfileViewScreen(
                                    userId: request.userId,
                                  ),
                                ),
                              );
                            },
                            child: CircleAvatar(
                              radius: 28,
                              backgroundColor: const Color(0xFF7B61FF).withOpacity(0.1),
                              backgroundImage: request.userImage != null
                                  ? CachedNetworkImageProvider(request.userImage!)
                                  : null,
                              child: request.userImage == null
                                  ? Text(
                                request.userName[0].toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF7B61FF),
                                ),
                              )
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          // User Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  request.userName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Requested ${_formatTime(request.requestedAt)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                if (request.message.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      request.message,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[800],
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _isLoading
                                  ? null
                                  : () => _showRejectDialog(request.userId, request.userName),
                              icon: const Icon(Icons.close, size: 18),
                              label: const Text('Reject'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: const BorderSide(color: Colors.red),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _isLoading
                                  ? null
                                  : () => _handleRequest(
                                userId: request.userId,
                                userName: request.userName,
                                approve: true,
                              ),
                              icon: const Icon(Icons.check, size: 18),
                              label: const Text('Approve'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF7B61FF),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}