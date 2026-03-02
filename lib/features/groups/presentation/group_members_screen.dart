import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:badges/badges.dart' as badges;
import 'package:buddygoapp/core/services/firebase_service.dart';
import 'package:buddygoapp/features/auth/presentation/auth_controller.dart';
import 'package:buddygoapp/features/groups/data/group_model.dart';
import 'package:buddygoapp/features/user/presentation/user_profile_view_screen.dart';

// ==================== CONSTANTS ====================
class MemberColors {
  static const Color primary = Color(0xFF8B5CF6);     // Purple
  static const Color secondary = Color(0xFFFF6B6B);   // Coral
  static const Color tertiary = Color(0xFF4FD1C5);    // Teal
  static const Color accent = Color(0xFFFBBF24);      // Yellow
  static const Color success = Color(0xFF06D6A0);     // Mint Green
  static const Color error = Color(0xFFFF6B6B);       // Coral for errors
  static const Color background = Color(0xFFF0F2FE);  // Light purple tint
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF1A202C);
  static const Color textSecondary = Color(0xFF718096);

  // Role colors
  static const Color adminColor = Color(0xFF8B5CF6);     // Purple
  static const Color moderatorColor = Color(0xFFFBBF24); // Yellow
  static const Color memberColor = Color(0xFF4FD1C5);    // Teal
}

class GroupMembersScreen extends StatefulWidget {
  final String groupId;
  final String groupName;

  const GroupMembersScreen({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  State<GroupMembersScreen> createState() => _GroupMembersScreenState();
}

class _GroupMembersScreenState extends State<GroupMembersScreen> {
  final FirebaseService _firebaseService = FirebaseService();

  List<Map<String, dynamic>> _members = [];
  bool _isLoading = true;
  String? _currentUserId;
  bool _isCurrentUserAdmin = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    setState(() => _isLoading = true);

    try {
      final authController = Provider.of<AuthController>(context, listen: false);
      _currentUserId = authController.currentUser?.id;

      final group = await _firebaseService.getGroupById(widget.groupId);
      if (group == null) return;

      _isCurrentUserAdmin = group.isAdmin(_currentUserId ?? '');

      final memberIds = group.memberIds;
      final List<Map<String, dynamic>> membersList = [];

      for (String userId in memberIds) {
        final userDoc = await _firebaseService.usersCollection.doc(userId).get();
        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;

          final lastActive = userData['lastActive'] != null
              ? (userData['lastActive'] as Timestamp).toDate()
              : null;

          final isOnline = lastActive != null &&
              DateTime.now().difference(lastActive).inMinutes < 5;

          final role = _getUserRole(group, userId);
          membersList.add({
            'id': userId,
            'name': userData['name'] ?? 'Unknown User',
            'photoUrl': userData['photoUrl'],
            'isVerified': userData['isVerifiedTraveler'] == true,
            'isOnline': isOnline,
            'role': role,
            'totalTrips': userData['totalTrips'] ?? 0,
            'rating': userData['rating'] ?? 5.0,
          });
        }
      }

      membersList.sort((a, b) {
        if (a['isOnline'] && !b['isOnline']) return -1;
        if (!a['isOnline'] && b['isOnline']) return 1;
        return (a['name'] as String).compareTo(b['name']);
      });

      setState(() {
        _members = membersList;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading members: $e');
      setState(() => _isLoading = false);
    }
  }

  String _getUserRole(GroupModel group, String userId) {
    if (group.isAdmin(userId)) return 'Admin';
    if (group.isModerator(userId)) return 'Moderator';
    return 'Member';
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'Admin':
        return MemberColors.adminColor;
      case 'Moderator':
        return MemberColors.moderatorColor;
      default:
        return MemberColors.memberColor;
    }
  }

  IconData _getRoleIcon(String role) {
    switch (role) {
      case 'Admin':
        return Icons.admin_panel_settings;
      case 'Moderator':
        return Icons.security;
      default:
        return Icons.person;
    }
  }

  List<Map<String, dynamic>> get _filteredMembers {
    if (_searchQuery.isEmpty) return _members;

    return _members.where((member) {
      final name = member['name'].toString().toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query);
    }).toList();
  }

  int get _onlineCount => _members.where((m) => m['isOnline']).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MemberColors.background,
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
                color: MemberColors.primary.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: MemberColors.primary),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.groupName,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: MemberColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [MemberColors.primary.withOpacity(0.1), MemberColors.primary.withOpacity(0.05)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: MemberColors.primary.withOpacity(0.2), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.people, size: 12, color: MemberColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        '${_members.length}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: MemberColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [MemberColors.success.withOpacity(0.1), MemberColors.success.withOpacity(0.05)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: MemberColors.success.withOpacity(0.2), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: MemberColors.success,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: MemberColors.success.withOpacity(0.5),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$_onlineCount online',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: MemberColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white, Colors.grey[50]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(23),
                boxShadow: [
                  BoxShadow(
                    color: MemberColors.primary.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                onChanged: (value) => setState(() => _searchQuery = value),
                style: GoogleFonts.poppins(fontSize: 14, color: MemberColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Search members...',
                  hintStyle: GoogleFonts.poppins(
                    color: MemberColors.textSecondary,
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: MemberColors.primary,
                    size: 20,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: MemberColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(Icons.close, color: MemberColors.primary, size: 16),
                      onPressed: () => setState(() => _searchQuery = ''),
                      padding: EdgeInsets.zero,
                    ),
                  )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [MemberColors.primary.withOpacity(0.1), MemberColors.secondary.withOpacity(0.1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(MemberColors.primary),
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Loading members...',
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: MemberColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      )
          : _filteredMembers.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [MemberColors.primary.withOpacity(0.1), MemberColors.secondary.withOpacity(0.1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.people_outline,
                size: 60,
                color: MemberColors.primary.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _searchQuery.isEmpty ? 'No members found' : 'No matching members',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: MemberColors.textPrimary,
              ),
            ),
            if (_searchQuery.isNotEmpty) ...[
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => setState(() => _searchQuery = ''),
                style: TextButton.styleFrom(
                  foregroundColor: MemberColors.primary,
                  backgroundColor: MemberColors.primary.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: Text(
                  'Clear Search',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredMembers.length,
        itemBuilder: (context, index) {
          final member = _filteredMembers[index];
          final isCurrentUser = member['id'] == _currentUserId;
          final role = member['role'];
          final roleColor = _getRoleColor(role);

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white,
                  member['isOnline']
                      ? MemberColors.success.withOpacity(0.02)
                      : Colors.white,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
                if (member['isOnline'])
                  BoxShadow(
                    color: MemberColors.success.withOpacity(0.1),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  if (!isCurrentUser) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserProfileViewScreen(userId: member['id']),
                      ),
                    );
                  }
                },
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Avatar with enhanced neon styling
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // Gradient border for online users
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              gradient: member['isOnline']
                                  ? const LinearGradient(
                                colors: [MemberColors.success, MemberColors.tertiary],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                                  : null,
                              shape: BoxShape.circle,
                            ),
                            child: CircleAvatar(
                              radius: 28,
                              backgroundColor: MemberColors.background,
                              backgroundImage: member['photoUrl'] != null
                                  ? CachedNetworkImageProvider(member['photoUrl'])
                                  : null,
                              child: member['photoUrl'] == null
                                  ? Text(
                                member['name'][0].toUpperCase(),
                                style: GoogleFonts.poppins(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: MemberColors.primary,
                                ),
                              )
                                  : null,
                            ),
                          ),
                          // Verified badge
                          if (member['isVerified'])
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: MemberColors.success.withOpacity(0.3),
                                      blurRadius: 4,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.verified,
                                  size: 14,
                                  color: MemberColors.success,
                                ),
                              ),
                            ),
                          // Online indicator with glow
                          if (member['isOnline'])
                            Positioned(
                              top: 2,
                              right: 2,
                              child: Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: MemberColors.success,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: MemberColors.success.withOpacity(0.5),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(width: 16),

                      // Member details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Name and role row
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    member['name'],
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: MemberColors.textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),

                                // Role badge with gradient
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        roleColor.withOpacity(0.1),
                                        roleColor.withOpacity(0.05),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(
                                      color: roleColor.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _getRoleIcon(role),
                                        size: 12,
                                        color: roleColor,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        role,
                                        style: GoogleFonts.poppins(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: roleColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // "You" badge for current user
                                if (isCurrentUser) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [Colors.grey[300]!, Colors.grey[200]!],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: Text(
                                      'You',
                                      style: GoogleFonts.poppins(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),

                            const SizedBox(height: 8),

                            // Stats row
                            Row(
                              children: [
                                // Trip count
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: MemberColors.primary.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.travel_explore,
                                        size: 12,
                                        color: MemberColors.primary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${member['totalTrips']} trips',
                                        style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          color: MemberColors.primary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(width: 8),

                                // Rating
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: MemberColors.accent.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.star,
                                        size: 12,
                                        color: MemberColors.accent,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${member['rating']}',
                                        style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          color: MemberColors.accent,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Action menu for non-current users
                      if (!isCurrentUser)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          decoration: BoxDecoration(
                            color: MemberColors.primary.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: PopupMenuButton<String>(
                            icon: Icon(
                              Icons.more_vert,
                              color: MemberColors.primary,
                              size: 20,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            color: Colors.white,
                            elevation: 8,
                            shadowColor: MemberColors.primary.withOpacity(0.2),
                            onSelected: (value) => _handleAction(value, member),
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'view_profile',
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: MemberColors.primary.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.person,
                                        size: 16,
                                        color: MemberColors.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'View Profile',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (_isCurrentUserAdmin && member['role'] != 'Admin') ...[
                                PopupMenuItem(
                                  value: 'make_admin',
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: MemberColors.accent.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          Icons.admin_panel_settings,
                                          size: 16,
                                          color: MemberColors.accent,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Make Admin',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'remove',
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: MemberColors.error.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          Icons.remove_circle,
                                          size: 16,
                                          color: MemberColors.error,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Remove from Group',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleAction(String value, Map<String, dynamic> member) {
    switch (value) {
      case 'view_profile':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserProfileViewScreen(userId: member['id']),
          ),
        );
        break;
      case 'make_admin':
        _showSnackbar('Making ${member['name']} admin...', isSuccess: true);
        break;
      case 'remove':
        _showSnackbar('Removing ${member['name']} from group...', isError: true);
        break;
    }
  }

  void _showSnackbar(String message, {bool isSuccess = false, bool isError = false}) {
    Color getColor() {
      if (isError) return MemberColors.error;
      if (isSuccess) return MemberColors.success;
      return MemberColors.primary;
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
}