import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:badges/badges.dart' as badges;
import 'package:buddygoapp/core/services/firebase_service.dart';
import 'package:buddygoapp/core/widgets/custom_button.dart';
import 'package:intl/intl.dart';

import '../../../core/services/notification_service.dart';

// ==================== CONSTANTS ====================
class AdminProfileColors {
  static const Color primary = Color(0xFF8B5CF6);     // Purple
  static const Color secondary = Color(0xFFFF6B6B);   // Coral
  static const Color tertiary = Color(0xFF4FD1C5);    // Teal
  static const Color accent = Color(0xFFFBBF24);      // Yellow
  static const Color lavender = Color(0xFF9F7AEA);    // Lavender
  static const Color success = Color(0xFF06D6A0);     // Mint Green
  static const Color error = Color(0xFFFF6B6B);       // Coral for errors
  static const Color warning = Color(0xFFFBBF24);      // Yellow for warnings
  static const Color background = Color(0xFFF0F2FE);  // Light purple tint
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF1A202C);
  static const Color textSecondary = Color(0xFF718096);
  static const Color border = Color(0xFFE2E8F0);

  // Status colors
  static const Color verified = Color(0xFF06D6A0);     // Mint
  static const Color unverified = Color(0xFF718096);    // Grey
}

class AdminUserProfileScreen extends StatefulWidget {
  final String userId;
  final bool isAdmin;

  const AdminUserProfileScreen({
    super.key,
    required this.userId,
    this.isAdmin = true,
  });

  @override
  State<AdminUserProfileScreen> createState() => _AdminUserProfileScreenState();
}

class _AdminUserProfileScreenState extends State<AdminUserProfileScreen> with TickerProviderStateMixin {
  final FirebaseService _firebaseService = FirebaseService();
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  // Real-time streams for counts
  late Stream<QuerySnapshot> _reportsStream;
  late Stream<QuerySnapshot> _tripsStream;
  late Stream<DocumentSnapshot> _userStream;

  // Animation controllers
  late AnimationController _pulseAnimationController;

  @override
  void initState() {
    super.initState();

    // Initialize streams for real-time updates
    _reportsStream = _firebaseService.reportsCollection
        .where('reporterId', isEqualTo: widget.userId)
        .snapshots();

    _tripsStream = _firebaseService.tripsCollection
        .where('hostId', isEqualTo: widget.userId)
        .snapshots();

    _userStream = _firebaseService.usersCollection
        .doc(widget.userId)
        .snapshots();

    _pulseAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _loadUserData();
  }

  @override
  void dispose() {
    _pulseAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);

    try {
      final userDoc = await _firebaseService.usersCollection
          .doc(widget.userId)
          .get();

      if (userDoc.exists) {
        _userData = userDoc.data() as Map<String, dynamic>;
      }
    } catch (e) {
      print('Error loading user data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleVerifiedBadge() async {
    final currentStatus = _userData?['isVerifiedTraveler'] ?? false;
    final newStatus = !currentStatus;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => _buildActionDialog(
        title: newStatus ? 'Verify User' : 'Remove Verification',
        message: newStatus
            ? 'Are you sure you want to mark this user as a Verified Traveler?'
            : 'Are you sure you want to remove the Verified Traveler badge from this user?',
        actionText: newStatus ? 'Verify' : 'Remove',
        actionColor: newStatus ? AdminProfileColors.verified : AdminProfileColors.error,
      ),
    );

    if (confirm != true) return;

    try {
      await _firebaseService.usersCollection.doc(widget.userId).update({
        'isVerifiedTraveler': newStatus,
        'verifiedAt': newStatus ? FieldValue.serverTimestamp() : null,
        'verifiedBy': newStatus ? FirebaseAuth.instance.currentUser?.uid : null,
      });

      await _firebaseService.sendVerifiedBadgeNotification(
        userId: widget.userId,
        userName: _userData!['name'] ?? 'User',
        isVerified: newStatus,
      );

      setState(() {
        _userData!['isVerifiedTraveler'] = newStatus;
      });

      _showSnackbar(
        newStatus
            ? 'User is now a Verified Traveler!'
            : 'Verified badge removed successfully',
        isSuccess: true,
      );
    } catch (e) {
      _showSnackbar('Error updating verification status: $e', isError: true);
    }
  }

  void _showSnackbar(String message, {bool isSuccess = false, bool isError = false}) {
    Color getColor() {
      if (isError) return AdminProfileColors.error;
      if (isSuccess) return AdminProfileColors.success;
      return AdminProfileColors.primary;
    }

    IconData getIcon() {
      if (isError) return Icons.error_outline;
      if (isSuccess) return Icons.check_circle;
      return Icons.info_outline;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(getIcon(), color: Colors.white, size: 16),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: getColor(),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminProfileColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AdminProfileColors.primary.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: AdminProfileColors.primary),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Text(
          'User Profile',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AdminProfileColors.textPrimary,
          ),
        ),
        actions: [
          if (widget.isAdmin)
            Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: AdminProfileColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: PopupMenuButton(
                icon: Icon(Icons.more_vert, color: AdminProfileColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'warn',
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AdminProfileColors.warning.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.warning, size: 16, color: AdminProfileColors.warning),
                        ),
                        const SizedBox(width: 12),
                        Text('⚠️ Send Warning'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'suspend',
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AdminProfileColors.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.block, size: 16, color: AdminProfileColors.error),
                        ),
                        const SizedBox(width: 12),
                        Text('⛔ Suspend Account'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'ban',
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AdminProfileColors.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.gpp_bad, size: 16, color: AdminProfileColors.error),
                        ),
                        const SizedBox(width: 12),
                        Text('🚫 Ban User'),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  switch (value) {
                    case 'warn':
                      _showWarningDialog();
                      break;
                    case 'suspend':
                      _showSuspendDialog();
                      break;
                    case 'ban':
                      _showBanDialog();
                      break;
                  }
                },
              ),
            ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingState()
          : _userData == null
          ? _buildErrorState('User not found')
          : StreamBuilder<DocumentSnapshot>(
        stream: _userStream,
        builder: (context, userSnapshot) {
          if (userSnapshot.hasData && userSnapshot.data!.exists) {
            _userData = userSnapshot.data!.data() as Map<String, dynamic>;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Header with Neon Glow
                _buildProfileHeader(),
                const SizedBox(height: 16),

                // Verified Badge Toggle Section
                Center(
                  child: _buildVerifiedBadgeToggle(),
                ),
                const SizedBox(height: 24),

                // User Details Card
                _buildInfoCard(
                  title: '📋 User Details',
                  icon: Icons.person,
                  gradientColors: [AdminProfileColors.primary, AdminProfileColors.secondary],
                  children: [
                    _buildInfoRow('User ID', widget.userId),
                    _buildInfoRow('Email', _userData!['email'] ?? 'N/A'),
                    _buildInfoRow('Phone', _userData!['phone'] ?? 'N/A'),
                    _buildInfoRow('Location', _userData!['location'] ?? 'N/A'),
                    _buildInfoRow('Bio', _userData!['bio'] ?? 'No bio'),
                  ],
                ),
                const SizedBox(height: 16),

                // Verification Status Card
                _buildInfoCard(
                  title: '✅ Verification Status',
                  icon: Icons.verified,
                  gradientColors: [AdminProfileColors.success, AdminProfileColors.tertiary],
                  children: [
                    _buildVerificationItem(
                      'Email',
                      _userData!['isEmailVerified'] == true,
                    ),
                    _buildVerificationItem(
                      'Phone',
                      _userData!['isPhoneVerified'] == true,
                    ),
                    _buildVerificationItem(
                      'Student',
                      _userData!['isStudentVerified'] == true,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Statistics Card with Real-time Counts
                _buildInfoCard(
                  title: '📊 Statistics',
                  icon: Icons.bar_chart,
                  gradientColors: [AdminProfileColors.lavender, AdminProfileColors.primary],
                  children: [
                    // Total Trips with StreamBuilder
                    StreamBuilder<QuerySnapshot>(
                      stream: _tripsStream,
                      builder: (context, snapshot) {
                        final tripCount = snapshot.data?.docs.length ?? 0;
                        return _buildStatRow(
                          'Total Trips',
                          '$tripCount',
                          color: AdminProfileColors.primary,
                        );
                      },
                    ),

                    // Reports Filed with StreamBuilder
                    StreamBuilder<QuerySnapshot>(
                      stream: _reportsStream,
                      builder: (context, snapshot) {
                        final reportCount = snapshot.data?.docs.length ?? 0;
                        return _buildStatRow(
                          'Reports Filed',
                          '$reportCount',
                          color: AdminProfileColors.warning,
                        );
                      },
                    ),

                    // Reports Against with StreamBuilder
                    StreamBuilder<QuerySnapshot>(
                      stream: _firebaseService.reportsCollection
                          .where('reportedUserId', isEqualTo: widget.userId)
                          .snapshots(),
                      builder: (context, snapshot) {
                        final reportAgainstCount = snapshot.data?.docs.length ?? 0;
                        return _buildStatRow(
                          'Reports Against',
                          '$reportAgainstCount',
                          color: reportAgainstCount > 0 ? AdminProfileColors.error : AdminProfileColors.textSecondary,
                        );
                      },
                    ),

                    _buildStatRow(
                      'Joined',
                      _formatDate(_userData!['createdAt']),
                      color: AdminProfileColors.success,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Recent Reports Section
                StreamBuilder<QuerySnapshot>(
                   stream: _firebaseService.reportsCollection
                    .where('reporterId', isEqualTo: widget.userId)
                    .limit(3)
                    .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const SizedBox();
                    }

                    final reports = snapshot.data!.docs;

                    return _buildInfoCard(
                      title: '⚠️ Recent Reports Filed',
                      icon: Icons.flag,
                      gradientColors: [AdminProfileColors.warning, AdminProfileColors.secondary],
                      children: reports.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return _buildReportTile(data);
                      }).toList(),
                    );
                  },
                ),

                const SizedBox(height: 16),

                // Recent Trips Section
                StreamBuilder<QuerySnapshot>(
                  stream: _firebaseService.reportsCollection
                      .where('reporterId', isEqualTo: widget.userId)
                      .limit(3)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const SizedBox();
                    }

                    final trips = snapshot.data!.docs;

                    return _buildInfoCard(
                      title: '✈️ Recent Trips',
                      icon: Icons.travel_explore,
                      gradientColors: [AdminProfileColors.success, AdminProfileColors.tertiary],
                      children: trips.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return _buildTripTile(data);
                      }).toList(),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Admin Actions
                if (widget.isAdmin) ...[
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AdminProfileColors.primary.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [AdminProfileColors.error, AdminProfileColors.secondary],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.gavel, color: Colors.white, size: 18),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '🔨 Admin Actions',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AdminProfileColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildActionButton(
                                text: 'Warn User',
                                color: AdminProfileColors.warning,
                                onPressed: _showWarningDialog,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildActionButton(
                                text: 'Suspend',
                                color: AdminProfileColors.error,
                                onPressed: _showSuspendDialog,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildDangerButton(
                          text: 'Delete Account',
                          onPressed: _showDeleteDialog,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AdminProfileColors.primary.withOpacity(0.1), AdminProfileColors.secondary.withOpacity(0.1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AdminProfileColors.primary),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Loading user profile...',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: AdminProfileColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AdminProfileColors.error.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.error_outline, size: 64, color: AdminProfileColors.error),
          ),
          const SizedBox(height: 24),
          Text(
            message,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AdminProfileColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Center(
      child: Column(
        children: [
          // Animated Avatar with Glow
          AnimatedBuilder(
            animation: _pulseAnimationController,
            builder: (context, child) {
              return Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AdminProfileColors.primary, AdminProfileColors.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AdminProfileColors.primary.withOpacity(0.3 * _pulseAnimationController.value),
                      blurRadius: 20,
                      spreadRadius: 5 * _pulseAnimationController.value,
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: AdminProfileColors.background,
                  backgroundImage: _userData!['photoUrl'] != null
                      ? CachedNetworkImageProvider(_userData!['photoUrl'])
                      : null,
                  child: _userData!['photoUrl'] == null
                      ? Text(
                    _userData!['name']?[0].toUpperCase() ?? '?',
                    style: GoogleFonts.poppins(
                      fontSize: 40,
                      fontWeight: FontWeight.w700,
                      color: AdminProfileColors.primary,
                    ),
                  )
                      : null,
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          Text(
            _userData!['name'] ?? 'Unknown User',
            style: GoogleFonts.poppins(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AdminProfileColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),

          Text(
            _userData!['email'] ?? '',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AdminProfileColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerifiedBadgeToggle() {
    final isVerified = _userData?['isVerifiedTraveler'] == true;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            isVerified ? AdminProfileColors.verified.withOpacity(0.1) : AdminProfileColors.unverified.withOpacity(0.1),
            isVerified ? AdminProfileColors.tertiary.withOpacity(0.05) : AdminProfileColors.unverified.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: isVerified ? AdminProfileColors.verified : AdminProfileColors.unverified,
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isVerified ? Icons.verified : Icons.verified_outlined,
            color: isVerified ? AdminProfileColors.verified : AdminProfileColors.unverified,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            isVerified ? 'Verified Traveler' : 'Not Verified',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isVerified ? AdminProfileColors.verified : AdminProfileColors.unverified,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            height: 30,
            width: 1,
            color: isVerified ? AdminProfileColors.verified.withOpacity(0.3) : AdminProfileColors.unverified.withOpacity(0.3),
          ),
          const SizedBox(width: 12),
          InkWell(
            onTap: _toggleVerifiedBadge,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    isVerified ? AdminProfileColors.error.withOpacity(0.1) : AdminProfileColors.verified.withOpacity(0.1),
                    isVerified ? AdminProfileColors.secondary.withOpacity(0.05) : AdminProfileColors.tertiary.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isVerified ? 'Remove Badge' : 'Add Badge',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isVerified ? AdminProfileColors.error : AdminProfileColors.verified,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Color> gradientColors,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradientColors.first.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white, size: 16),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AdminProfileColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AdminProfileColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AdminProfileColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationItem(String label, bool isVerified) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isVerified ? AdminProfileColors.verified.withOpacity(0.1) : AdminProfileColors.error.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isVerified ? Icons.check_circle : Icons.cancel,
              color: isVerified ? AdminProfileColors.verified : AdminProfileColors.error,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AdminProfileColors.textSecondary,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            isVerified ? 'Verified' : 'Not Verified',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isVerified ? AdminProfileColors.verified : AdminProfileColors.error,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, {required Color color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AdminProfileColors.textSecondary,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportTile(Map<String, dynamic> data) {
    final timestamp = data['createdAt'] as Timestamp?;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AdminProfileColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AdminProfileColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.warning, color: AdminProfileColors.warning, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['reason'] ?? 'Unknown',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AdminProfileColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Status: ${data['status'] ?? 'pending'}',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: _getStatusColor(data['status'] ?? 'pending'),
                  ),
                ),
              ],
            ),
          ),
          Text(
            _formatTimestamp(timestamp),
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: AdminProfileColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripTile(Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AdminProfileColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AdminProfileColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.travel_explore, color: AdminProfileColors.success, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['title'] ?? 'Untitled',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AdminProfileColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  data['destination'] ?? 'Unknown',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AdminProfileColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AdminProfileColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${data['currentMembers'] ?? 0}/${data['maxMembers'] ?? 0}',
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AdminProfileColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String text,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDangerButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 44,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AdminProfileColors.error, AdminProfileColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AdminProfileColors.error.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionDialog({
    required String title,
    required String message,
    required String actionText,
    required Color actionColor,
  }) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: actionColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  actionColor == AdminProfileColors.verified ? Icons.verified : Icons.warning,
                  color: actionColor,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AdminProfileColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AdminProfileColors.textSecondary,
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AdminProfileColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [actionColor, actionColor.withOpacity(0.8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: actionColor.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          actionText,
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return AdminProfileColors.warning;
      case 'dismissed':
        return AdminProfileColors.textSecondary;
      case 'warned':
        return AdminProfileColors.tertiary;
      case 'suspended':
        return AdminProfileColors.error;
      case 'resolved':
        return AdminProfileColors.success;
      default:
        return AdminProfileColors.textSecondary;
    }
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'Unknown';
    if (date is Timestamp) {
      return DateFormat('MMM dd, yyyy').format(date.toDate());
    }
    return 'Unknown';
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final date = timestamp.toDate();
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inMinutes}m ago';
    }
  }

  // Dialog Methods
  void _showWarningDialog() {
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AdminProfileColors.warning.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.warning, color: AdminProfileColors.warning, size: 32),
                ),
                const SizedBox(height: 20),
                Text(
                  'Warn User',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AdminProfileColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Are you sure you want to warn this user?',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AdminProfileColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: AdminProfileColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: reasonController,
                    style: GoogleFonts.poppins(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Reason (optional)',
                      hintStyle: GoogleFonts.poppins(color: AdminProfileColors.textSecondary),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    maxLines: 3,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AdminProfileColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AdminProfileColors.warning, AdminProfileColors.secondary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _showSnackbar('Warning sent successfully', isSuccess: true);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            'Send Warning',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSuspendDialog() {
    showDialog(
      context: context,
      builder: (context) => _buildActionDialog(
        title: 'Suspend User',
        message: 'Are you sure you want to suspend this user account?',
        actionText: 'Suspend',
        actionColor: AdminProfileColors.error,
      ),
    ).then((confirmed) {
      if (confirmed == true) {
        _showSnackbar('User suspended successfully', isSuccess: true);
      }
    });
  }

  void _showBanDialog() {
    showDialog(
      context: context,
      builder: (context) => _buildActionDialog(
        title: 'Ban User',
        message: 'Are you sure you want to permanently ban this user?',
        actionText: 'Ban',
        actionColor: AdminProfileColors.error,
      ),
    ).then((confirmed) {
      if (confirmed == true) {
        _showSnackbar('User banned successfully', isSuccess: true);
      }
    });
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => _buildActionDialog(
        title: 'Delete Account',
        message: 'Are you sure you want to permanently delete this user account? This action cannot be undone.',
        actionText: 'Delete',
        actionColor: AdminProfileColors.error,
      ),
    ).then((confirmed) {
      if (confirmed == true) {
        _showSnackbar('Account deletion requested', isSuccess: true);
      }
    });
  }
}