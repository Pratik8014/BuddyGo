import 'package:buddygoapp/features/auth/presentation/change_password_screen.dart';
import 'package:buddygoapp/features/safety/presentation/privacy_policy_screen.dart';
import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:badges/badges.dart' as badges;
import 'package:buddygoapp/core/widgets/custom_button.dart';
import 'package:buddygoapp/features/auth/presentation/auth_controller.dart';

import '../../safety/presentation/terms_services_screen.dart';

// ==================== CONSTANTS ====================
class SettingsColors {
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
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with TickerProviderStateMixin {
  bool _notificationsEnabled = true;
  bool _locationEnabled = true;
  String _language = 'English';
  String _currency = 'INR (₹)';

  final List<String> _languages = ['English', 'Hindi', 'Spanish', 'French'];
  final List<String> _currencies = [
    'INR (₹)',
    'USD (\$)',
    'EUR (€)',
    'GBP (£)',
  ];

  late AnimationController _saveAnimationController;
  late Animation<double> _saveAnimation;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _saveAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _saveAnimation = CurvedAnimation(
      parent: _saveAnimationController,
      curve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    _saveAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications') ?? true;
      _locationEnabled = prefs.getBool('location') ?? true;
      _language = prefs.getString('language') ?? 'English';
      _currency = prefs.getString('currency') ?? 'INR (₹)';
    });
  }

  Future<void> _saveSettings() async {
    _saveAnimationController.reset();
    _saveAnimationController.forward();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications', _notificationsEnabled);
    await prefs.setBool('location', _locationEnabled);
    await prefs.setString('language', _language);
    await prefs.setString('currency', _currency);

    if (mounted) {
      _showSnackbar('Settings saved successfully!', isSuccess: true);
    }
  }

  final InAppReview _inAppReview = InAppReview.instance;

  Future<void> _rateApp() async {
    if (await _inAppReview.isAvailable()) {
      await _inAppReview.requestReview();
    } else {
      await _inAppReview.openStoreListing();
    }

    if (mounted) {
      _showSnackbar('Thanks for supporting BuddyGo ❤️', isSuccess: true);
    }
  }

  void _shareApp() {
    Share.share(
      'Hey! 👋 Check out BuddyGo – an awesome app to find travel buddies and plan trips together!\n\n'
          'Download now:\n'
          '👉 https://play.google.com/store/apps/details?id=com.yourcompany.buddygoapp',
    );
  }

  void _showSnackbar(String message, {bool isSuccess = false, bool isError = false,bool isInfo = false,}) {
    Color getColor() {
      if (isError) return SettingsColors.error;
      if (isSuccess) return SettingsColors.success;
      return SettingsColors.primary;
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
    final authController = Provider.of<AuthController>(context);

    return Scaffold(
      backgroundColor: SettingsColors.background,
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
                color: SettingsColors.primary.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: SettingsColors.primary),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Text(
          'Settings',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: SettingsColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Account Settings Card
            _buildSettingsCard(
              title: 'Account Settings',
              icon: Icons.account_circle,
              gradientColors: [SettingsColors.primary, SettingsColors.secondary],
              child: Column(
                children: [
                  _buildSettingsItem(
                    icon: Icons.notifications,
                    title: 'Push Notifications',
                    subtitle: 'Receive trip updates and messages',
                    value: _notificationsEnabled,
                    color: SettingsColors.primary,
                    onChanged: (value) {
                      setState(() => _notificationsEnabled = value);
                    },
                  ),
                  _buildDivider(),
                  _buildSettingsItem(
                    icon: Icons.location_on,
                    title: 'Location Services',
                    subtitle: 'Share location for trip matching',
                    value: _locationEnabled,
                    color: SettingsColors.secondary,
                    onChanged: (value) {
                      setState(() => _locationEnabled = value);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // App Preferences Card
            _buildSettingsCard(
              title: 'App Preferences',
              icon: Icons.tune,
              gradientColors: [SettingsColors.tertiary, SettingsColors.success],
              child: Column(
                children: [
                  _buildDropdownItem(
                    icon: Icons.language,
                    title: 'Language',
                    value: _language,
                    items: _languages,
                    color: SettingsColors.tertiary,
                    onChanged: (value) {
                      setState(() => _language = value!);
                    },
                  ),
                  _buildDivider(),
                  _buildDropdownItem(
                    icon: Icons.attach_money,
                    title: 'Currency',
                    value: _currency,
                    items: _currencies,
                    color: SettingsColors.success,
                    onChanged: (value) {
                      setState(() => _currency = value!);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Privacy & Security Card
            _buildSettingsCard(
              title: 'Privacy & Security',
              icon: Icons.security,
              gradientColors: [SettingsColors.lavender, SettingsColors.primary],
              child: Column(
                children: [
                  _buildMenuTile(
                    icon: Icons.lock,
                    title: 'Change Password',
                    color: SettingsColors.lavender,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ChangePasswordScreen(),
                        ),
                      );
                    },
                  ),
                  _buildDivider(),
                  _buildMenuTile(
                    icon: Icons.visibility_off,
                    title: 'Privacy Policy',
                    color: SettingsColors.primary,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PrivacyPolicyScreen(),
                        ),
                      );
                    },
                  ),
                  _buildDivider(),
                  _buildMenuTile(
                    icon: Icons.description,
                    title: 'Terms of Service',
                    color: SettingsColors.secondary,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TermsServicesScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // About Card
            _buildSettingsCard(
              title: 'About',
              icon: Icons.info_outline,
              gradientColors: [SettingsColors.accent, SettingsColors.warning],
              child: Column(
                children: [
                  _buildInfoTile(
                    icon: Icons.info,
                    title: 'App Version',
                    value: '1.0.0',
                    color: SettingsColors.accent,
                  ),
                  _buildDivider(),
                  _buildMenuTile(
                    icon: Icons.star,
                    title: 'Rate this App',
                    color: SettingsColors.warning,
                    onTap: _rateApp,
                  ),
                  _buildDivider(),
                  _buildMenuTile(
                    icon: Icons.share,
                    title: 'Share with Friends',
                    color: SettingsColors.success,
                    onTap: _shareApp,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Save Button with Animation
            ScaleTransition(
              scale: _saveAnimation,
              child: Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [SettingsColors.primary, SettingsColors.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: SettingsColors.primary.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _saveSettings,
                    borderRadius: BorderRadius.circular(20),
                    child: Center(
                      child: Text(
                        'Save Settings',
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
            ),

            const SizedBox(height: 12),

            // Logout Button
            Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [SettingsColors.error, SettingsColors.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: SettingsColors.error.withOpacity(0.3),
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
                    if (mounted) {
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

            const SizedBox(height: 12),

            // Delete Account (Danger Zone)
            Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: SettingsColors.error.withOpacity(0.5),
                  width: 2,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _showDeleteAccountDialog,
                  borderRadius: BorderRadius.circular(20),
                  child: Center(
                    child: Text(
                      'Delete Account',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: SettingsColors.error,
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

  Widget _buildSettingsCard({
    required String title,
    required IconData icon,
    required List<Color> gradientColors,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: gradientColors.first.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header with Gradient
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [gradientColors.first.withOpacity(0.1), gradientColors.last.withOpacity(0.05)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Row(
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
                  child: Icon(icon, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: SettingsColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          // Card Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Color color,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: SettingsColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: SettingsColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: color,
            activeTrackColor: color.withOpacity(0.3),
            inactiveThumbColor: Colors.grey,
            inactiveTrackColor: Colors.grey.withOpacity(0.2),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownItem({
    required IconData icon,
    required String title,
    required String value,
    required List<String> items,
    required Color color,
    required Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
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
                color: SettingsColors.textPrimary,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: color.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: DropdownButton<String>(
              value: value,
              underline: const SizedBox(),
              icon: Icon(Icons.arrow_drop_down, color: color),
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: color,
              ),
              dropdownColor: Colors.white,
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
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
                    color: SettingsColors.textPrimary,
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

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
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
                color: SettingsColors.textPrimary,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: SettingsColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Divider(
        height: 1,
        color: SettingsColors.border,
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(35),
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
                    color: SettingsColors.error.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: SettingsColors.error,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Delete Account',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: SettingsColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Are you sure you want to delete your account? This action cannot be undone. All your data will be permanently deleted.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: SettingsColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 28),
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
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: SettingsColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _showSnackbar('Account deletion requested', isInfo: true);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: SettingsColors.error,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Delete',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
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
}