import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:buddygoapp/core/widgets/custom_button.dart';
import 'package:buddygoapp/core/widgets/custom_textfield.dart';

import '../../home/presentation/home_screen.dart';

// ==================== CONSTANTS ====================
class PhoneColors {
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

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> with TickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  String _verificationId = '';
  bool _isOtpSent = false;
  bool _isLoading = false;
  bool _isResendLoading = false;
  int _resendTimer = 60;

  late AnimationController _pulseAnimationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = CurvedAnimation(
      parent: _pulseAnimationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pulseAnimationController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _startResendTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (_resendTimer > 0 && _isOtpSent && mounted) {
        setState(() => _resendTimer--);
        _startResendTimer();
      }
    });
  }

  Future<void> _verifyPhoneNumber() async {
    if (_phoneController.text.isEmpty || _phoneController.text.length < 10) {
      _showSnackbar('Please enter valid phone number', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    await _auth.verifyPhoneNumber(
      phoneNumber: '+91${_phoneController.text.trim()}',
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
        setState(() => _isLoading = false);
        _navigateToHome();
      },
      verificationFailed: (FirebaseAuthException e) {
        setState(() => _isLoading = false);
        _showSnackbar('Error: ${e.message}', isError: true);
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _verificationId = verificationId;
          _isOtpSent = true;
          _isLoading = false;
          _resendTimer = 60;
        });
        _startResendTimer();
        _showSnackbar('OTP sent successfully!', isSuccess: true);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        setState(() => _isLoading = false);
      },
      timeout: const Duration(seconds: 60),
    );
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.length != 6) {
      _showSnackbar('Please enter 6-digit OTP', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: _otpController.text.trim(),
      );

      await _auth.signInWithCredential(credential);
      setState(() => _isLoading = false);
      _navigateToHome();
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackbar('Invalid OTP: ${e.toString()}', isError: true);
    }
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(position: animation.drive(tween), child: child);
        },
      ),
    );
  }

  void _showSnackbar(String message, {bool isSuccess = false, bool isError = false}) {
    Color getColor() {
      if (isError) return PhoneColors.error;
      if (isSuccess) return PhoneColors.success;
      return PhoneColors.primary;
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
      backgroundColor: PhoneColors.background,
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
                color: PhoneColors.primary.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: PhoneColors.primary),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [PhoneColors.primary, PhoneColors.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: Text(
            'Phone Login',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // Animated Icon
            Center(
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const RadialGradient(
                        colors: [
                          PhoneColors.primary,
                          PhoneColors.secondary,
                          PhoneColors.tertiary,
                        ],
                        stops: [0.3, 0.6, 0.9],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: PhoneColors.primary.withOpacity(0.3 * _pulseAnimation.value),
                          blurRadius: 30,
                          spreadRadius: 5 * _pulseAnimation.value,
                        ),
                      ],
                    ),
                    child: Icon(
                      _isOtpSent ? Icons.smartphone : Icons.phone_android,
                      size: 40,
                      color: Colors.white,
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 30),

            // Title with Gradient
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [PhoneColors.primary, PhoneColors.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
              child: Text(
                _isOtpSent ? 'Verify OTP' : 'Enter your phone number',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              _isOtpSent
                  ? 'We sent a 6-digit code to your phone'
                  : 'We\'ll send you a verification code',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: PhoneColors.textSecondary,
              ),
            ),

            const SizedBox(height: 40),

            if (!_isOtpSent)
            // Phone Input Section
              Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: PhoneColors.primary.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: const BorderRadius.horizontal(
                              left: Radius.circular(16),
                            ),
                            border: Border.all(color: PhoneColors.border),
                          ),
                          child: Text(
                            '+91',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: PhoneColors.primary,
                            ),
                          ),
                        ),
                        Expanded(
                          child: CustomTextField(
                            controller: _phoneController,
                            label: 'Phone Number',
                            hintText: '9876543210',
                            prefixIcon: Icon(Icons.phone, color: PhoneColors.primary),
                            keyboardType: TextInputType.phone,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Send OTP Button with Gradient
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [PhoneColors.primary, PhoneColors.secondary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: PhoneColors.primary.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _verifyPhoneNumber,
                        borderRadius: BorderRadius.circular(20),
                        child: Center(
                          child: _isLoading
                              ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                              : Text(
                            'Send OTP',
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
                ],
              )
            else
            // OTP Input Section
              Column(
                children: [
                  // Phone Number Display
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [PhoneColors.primary.withOpacity(0.1), PhoneColors.secondary.withOpacity(0.05)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: PhoneColors.primary.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.phone, color: PhoneColors.primary, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '+91 ${_phoneController.text}',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: PhoneColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // OTP Input Field
                  PinCodeTextField(
                    appContext: context,
                    length: 6,
                    controller: _otpController,
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(16),
                      fieldHeight: 60,
                      fieldWidth: 50,
                      activeFillColor: Colors.white,
                      activeColor: PhoneColors.primary,
                      selectedColor: PhoneColors.secondary,
                      inactiveColor: PhoneColors.border,
                      disabledColor: Colors.grey[300],
                      activeBorderWidth: 2,
                      selectedBorderWidth: 2,
                      inactiveBorderWidth: 1,
                    ),
                    animationType: AnimationType.fade,
                    animationDuration: const Duration(milliseconds: 300),
                    keyboardType: TextInputType.number,
                    textStyle: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: PhoneColors.textPrimary,
                    ),
                    onChanged: (value) {},
                  ),

                  const SizedBox(height: 32),

                  // Verify OTP Button with Gradient
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [PhoneColors.primary, PhoneColors.secondary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: PhoneColors.primary.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _verifyOtp,
                        borderRadius: BorderRadius.circular(20),
                        child: Center(
                          child: _isLoading
                              ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                              : Text(
                            'Verify OTP',
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

                  const SizedBox(height: 24),

                  // Resend Timer Row
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: PhoneColors.primary.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Didn\'t receive code? ',
                          style: GoogleFonts.poppins(
                            color: PhoneColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        if (_resendTimer > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [PhoneColors.primary.withOpacity(0.1), PhoneColors.secondary.withOpacity(0.05)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: PhoneColors.primary.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              '$_resendTimer s',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: PhoneColors.primary,
                              ),
                            ),
                          )
                        else
                          TextButton(
                            onPressed: _isResendLoading
                                ? null
                                : () async {
                              setState(() {
                                _isResendLoading = true;
                                _resendTimer = 60;
                              });
                              await _verifyPhoneNumber();
                              setState(() => _isResendLoading = false);
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: PhoneColors.primary,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: _isResendLoading
                                ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(PhoneColors.primary),
                              ),
                            )
                                : Text(
                              'Resend OTP',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: PhoneColors.primary,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Change Phone Number Button
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isOtpSent = false;
                        _otpController.clear();
                      });
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: PhoneColors.secondary,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.edit, size: 16, color: PhoneColors.secondary),
                        const SizedBox(width: 8),
                        Text(
                          'Change phone number',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: PhoneColors.secondary,
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
    );
  }
}