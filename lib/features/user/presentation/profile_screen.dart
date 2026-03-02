import 'dart:io';

import 'package:buddygoapp/features/groups/presentation/chat_list_screen.dart';
import 'package:buddygoapp/features/groups/presentation/group_chat_screen.dart';
import 'package:buddygoapp/features/safety/presentation/help_support_screen.dart';
import 'package:buddygoapp/features/safety/presentation/privacy_safety_screen.dart';
import 'package:buddygoapp/features/safety/presentation/report_screen.dart';
import 'package:buddygoapp/features/user/presentation/edit_profile_screen.dart';
import 'package:buddygoapp/features/user/presentation/my_trips_screen.dart';
import 'package:buddygoapp/features/user/presentation/settings_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:buddygoapp/core/widgets/custom_button.dart';
import 'package:buddygoapp/features/auth/presentation/auth_controller.dart';
import 'package:buddygoapp/core/services/firebase_service.dart';

// ==================== CONSTANTS ====================
class ProfileColors {
  static const Color primary = Color(0xFF8B5CF6);     // Purple
  static const Color secondary = Color(0xFFFF6B6B);   // Coral
  static const Color tertiary = Color(0xFF4FD1C5);    // Teal
  static const Color accent = Color(0xFFFBBF24);      // Yellow
  static const Color lavender = Color(0xFF9F7AEA);    // Lavender
  static const Color success = Color(0xFF06D6A0);     // Mint Green
  static const Color error = Color(0xFFFF6B6B);       // Coral for errors
  static const Color background = Color(0xFFF0F2FE);  // Light purple tint
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF1A202C);
  static const Color textSecondary = Color(0xFF718096);
  static const Color border = Color(0xFFE2E8F0);
}

// ==================== LEVEL SYSTEM ====================
class LevelSystem {
  static const List<Map<String, dynamic>> levels = [
    {'name': 'Explorer', 'minTrips': 0, 'color': ProfileColors.tertiary},
    {'name': 'Adventurer', 'minTrips': 5, 'color': ProfileColors.primary},
    {'name': 'Globetrotter', 'minTrips': 15, 'color': ProfileColors.secondary},
    {'name': 'Voyager', 'minTrips': 30, 'color': ProfileColors.accent},
    {'name': 'Nomad', 'minTrips': 50, 'color': ProfileColors.lavender},
    {'name': 'Legend', 'minTrips': 100, 'color': ProfileColors.success},
  ];

  static Map<String, dynamic> getLevel(int tripCount) {
    for (int i = levels.length - 1; i >= 0; i--) {
      final int minTrips = levels[i]['minTrips'] as int;
      if (tripCount >= minTrips) {
        return levels[i];
      }
    }
    return levels.first;
  }

  static double getProgress(int tripCount) {
    final currentLevel = getLevel(tripCount);
    final nextLevel = getNextLevel(tripCount);

    if (nextLevel == null) return 1.0;

    final int currentMin = currentLevel['minTrips'] as int;
    final int nextMin = nextLevel['minTrips'] as int;

    return (tripCount - currentMin) / (nextMin - currentMin);
  }

  static Map<String, dynamic>? getNextLevel(int tripCount) {
    for (int i = 0; i < levels.length; i++) {
      final int minTrips = levels[i]['minTrips'] as int;
      if (tripCount < minTrips) {
        return levels[i];
      }
    }
    return null;
  }
}
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with TickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  final FirebaseService _firebaseService = FirebaseService();
  String? _selectedImageUrl;
  late AnimationController _pulseAnimationController;

  @override
  void initState() {
    super.initState();
    _pulseAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);
    final user = authController.currentUser;

    return Scaffold(
      backgroundColor: ProfileColors.background,
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
                color: ProfileColors.primary.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),

        ),
        title: Text(
          'Profile',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: ProfileColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: ProfileColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.edit_outlined, color: ProfileColors.primary),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditProfileScreen(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Header Card
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white, Colors.white.withOpacity(0.95)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: ProfileColors.primary.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Profile Image with Neon Glow
                    Stack(
                      children: [
                        // Pulsing glow for verified users
                        StreamBuilder<DocumentSnapshot>(
                          stream: _firebaseService.usersCollection
                              .doc(user?.id)
                              .snapshots(),
                          builder: (context, snapshot) {
                            bool isVerified = false;
                            if (snapshot.hasData && snapshot.data!.exists) {
                              final userData = snapshot.data!.data() as Map<String, dynamic>?;
                              isVerified = userData?['isVerifiedTraveler'] == true;
                            }

                            return AnimatedBuilder(
                              animation: _pulseAnimationController,
                              builder: (context, child) {
                                return Container(
                                  width: 130,
                                  height: 130,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: isVerified
                                        ? RadialGradient(
                                      colors: [
                                        ProfileColors.success.withOpacity(0.3),
                                        ProfileColors.success.withOpacity(0.1),
                                        Colors.transparent,
                                      ],
                                      stops: [0.4, 0.6, 0.8],
                                    )
                                        : null,
                                    boxShadow: isVerified
                                        ? [
                                      BoxShadow(
                                        color: ProfileColors.success.withOpacity(0.3 * _pulseAnimationController.value),
                                        blurRadius: 20,
                                        spreadRadius: 5,
                                      ),
                                    ]
                                        : [],
                                  ),
                                  child: child,
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      ProfileColors.primary,
                                      ProfileColors.secondary,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: CircleAvatar(
                                  radius: 60,
                                  backgroundColor: ProfileColors.background,
                                  backgroundImage: _selectedImageUrl != null
                                      ? FileImage(File(_selectedImageUrl!))
                                      : user?.photoUrl != null
                                      ? CachedNetworkImageProvider(user!.photoUrl!)
                                      : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
                                  child: _selectedImageUrl == null && user?.photoUrl == null
                                      ? Text(
                                    user?.name?[0].toUpperCase() ?? '?',
                                    style: GoogleFonts.poppins(
                                      fontSize: 40,
                                      fontWeight: FontWeight.w700,
                                      color: ProfileColors.primary,
                                    ),
                                  )
                                      : null,
                                ),
                              ),
                            );
                          },
                        ),

                        // Camera button
                        Positioned(
                          bottom: 5,
                          right: 5,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [ProfileColors.primary, ProfileColors.secondary],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: ProfileColors.primary.withOpacity(0.3),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: _pickImage,
                                customBorder: const CircleBorder(),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // User Info
                    Text(
                      user?.name ?? 'Travel Enthusiast',
                      style: GoogleFonts.poppins(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: ProfileColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      user?.email ?? 'No email provided',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: ProfileColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Verification Badge with StreamBuilder
                    StreamBuilder<DocumentSnapshot>(
                      stream: _firebaseService.usersCollection
                          .doc(user?.id)
                          .snapshots(),
                      builder: (context, snapshot) {
                        bool isVerified = false;

                        if (snapshot.hasData && snapshot.data!.exists) {
                          final userData = snapshot.data!.data() as Map<String, dynamic>?;
                          isVerified = userData?['isVerifiedTraveler'] == true;
                        }

                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isVerified
                                  ? [ProfileColors.success.withOpacity(0.1), ProfileColors.tertiary.withOpacity(0.05)]
                                  : [Colors.grey.withOpacity(0.1), Colors.grey.withOpacity(0.05)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: isVerified
                                  ? ProfileColors.success.withOpacity(0.3)
                                  : Colors.grey.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isVerified ? Icons.verified : Icons.verified_outlined,
                                size: 18,
                                color: isVerified ? ProfileColors.success : Colors.grey,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                isVerified ? 'Verified Traveler' : 'Not Verified',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isVerified ? ProfileColors.success : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Stats Card with Level
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: ProfileColors.primary.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Stats Row (Only Trips and Level)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Trips Stat
                        FutureBuilder<QuerySnapshot>(
                          future: FirebaseFirestore.instance
                              .collection('trips')
                              .where('hostId', isEqualTo: user?.id)
                              .get(),
                          builder: (context, snapshot) {
                            final tripCount = snapshot.data?.docs.length ?? 0;

                            return _buildStat(
                              label: 'Trips',
                              value: tripCount.toString(),
                              color: ProfileColors.primary,
                            );
                          },
                        ),

                        Container(
                          height: 40,
                          width: 1,
                          color: ProfileColors.border,
                        ),

                        // Level Stat with FutureBuilder
                        FutureBuilder<QuerySnapshot>(
                          future: FirebaseFirestore.instance
                              .collection('trips')
                              .where('hostId', isEqualTo: user?.id)
                              .get(),
                          builder: (context, snapshot) {
                            final tripCount = snapshot.data?.docs.length ?? 0;
                            final level = LevelSystem.getLevel(tripCount);

                            return _buildStat(
                              label: 'Level',
                              value: level['name'],
                              color: level['color'],
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Level Progress Bar
                    FutureBuilder<QuerySnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('trips')
                          .where('hostId', isEqualTo: user?.id)
                          .get(),
                      builder: (context, snapshot) {
                        final tripCount = snapshot.data?.docs.length ?? 0;
                        final progress = LevelSystem.getProgress(tripCount);
                        final currentLevel = LevelSystem.getLevel(tripCount);
                        final nextLevel = LevelSystem.getNextLevel(tripCount);

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  currentLevel['name'],
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: currentLevel['color'],
                                  ),
                                ),
                                if (nextLevel != null)
                                  Text(
                                    nextLevel['name'],
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: ProfileColors.textSecondary,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Stack(
                              children: [
                                Container(
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: ProfileColors.border,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                FractionallySizedBox(
                                  widthFactor: progress,
                                  child: Container(
                                    height: 8,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [currentLevel['color'], ProfileColors.secondary],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: currentLevel['color'].withOpacity(0.3),
                                          blurRadius: 8,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (nextLevel != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                '${tripCount}/${nextLevel['minTrips']} trips to reach ${nextLevel['name']}',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: ProfileColors.textSecondary,
                                ),
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Menu Items Card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: ProfileColors.primary.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildMenuItem(
                    icon: Icons.person_outline,
                    title: 'Edit Profile',
                    color: ProfileColors.primary,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditProfileScreen(),
                        ),
                      );
                    },
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    icon: Icons.travel_explore,
                    title: 'My Trips',
                    color: ProfileColors.tertiary,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MyTripsScreen(),
                        ),
                      );
                    },
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    icon: Icons.group_outlined,
                    title: 'My Groups',
                    color: ProfileColors.secondary,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ChatListScreen(),
                        ),
                      );
                    },
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    icon: Icons.security_outlined,
                    title: 'Privacy & Safety',
                    color: ProfileColors.lavender,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PrivacySafetyScreen(),
                        ),
                      );
                    },
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    color: ProfileColors.accent,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HelpSupportScreen(),
                        ),
                      );
                    },
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    icon: Icons.settings,
                    title: 'Settings',
                    color: ProfileColors.success,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingsScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Logout Button
            Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [ProfileColors.error, ProfileColors.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: ProfileColors.error.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () async {
                    await authController.signOut();
                    if (context.mounted) {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/login',
                            (route) => false,
                      );
                    }
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Center(
                    child: Text(
                      'Logout',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStat({required String label, required String value, required Color color}) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: ProfileColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: color.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: ProfileColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Divider(
        height: 1,
        color: ProfileColors.border,
      ),
    );
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImageUrl = image.path;
      });
      // TODO: Upload image to Firebase Storage
    }
  }
}