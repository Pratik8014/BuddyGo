import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:buddygoapp/core/widgets/custom_button.dart';
import 'package:buddygoapp/core/widgets/custom_textfield.dart';

import '../../home/presentation/home_screen.dart';

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  String _verificationId = '';
  bool _isOtpSent = false;
  bool _isLoading = false;
  bool _isResendLoading = false;
  int _resendTimer = 60;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  void _startResendTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (_resendTimer > 0 && _isOtpSent) {
        setState(() => _resendTimer--);
        _startResendTimer();
      }
    });
  }

  Future<void> _verifyPhoneNumber() async {
    if (_phoneController.text.isEmpty || _phoneController.text.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid phone number')),
      );
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.message}')),
        );
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _verificationId = verificationId;
          _isOtpSent = true;
          _isLoading = false;
          _resendTimer = 60;
        });
        _startResendTimer();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP sent successfully!')),
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        setState(() => _isLoading = false);
      },
      timeout: const Duration(seconds: 60),
    );
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter 6-digit OTP')),
      );
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid OTP: $e')),
      );
    }
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phone Login'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            const Text(
              'Enter your phone number',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1D2B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _isOtpSent
                  ? 'We sent a 6-digit code to your phone'
                  : 'We\'ll send you a verification code',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 40),

            if (!_isOtpSent)
            // Phone Input
              Column(
                children: [
                  CustomTextField(
                    controller: _phoneController,
                    label: 'Phone Number',
                    hintText: '9876543210',
                    prefixIcon: const Icon(Icons.phone),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 32),
                  CustomButton(
                    text: 'Send OTP',
                    isLoading: _isLoading,
                    onPressed: _verifyPhoneNumber,
                  ),
                ],
              )
            else
            // OTP Input
              Column(
                children: [
                  Text(
                    '+91 ${_phoneController.text}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  PinCodeTextField(
                    appContext: context,
                    length: 6,
                    controller: _otpController,
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(12),
                      fieldHeight: 56,
                      fieldWidth: 45,
                      activeFillColor: Colors.white,
                      activeColor: const Color(0xFF7B61FF),
                      selectedColor: const Color(0xFF7B61FF),
                      inactiveColor: Colors.grey[300]!,
                    ),
                    animationType: AnimationType.fade,
                    keyboardType: TextInputType.number,
                    onChanged: (value) {},
                  ),
                  const SizedBox(height: 32),
                  CustomButton(
                    text: 'Verify OTP',
                    isLoading: _isLoading,
                    onPressed: _verifyOtp,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Didn\'t receive code? ',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      if (_resendTimer > 0)
                        Text(
                          'Resend in $_resendTimer s',
                          style: const TextStyle(
                            color: Color(0xFF7B61FF),
                            fontWeight: FontWeight.w600,
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
                          child: _isResendLoading
                              ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                              : const Text(
                            'Resend OTP',
                            style: TextStyle(
                              color: Color(0xFF7B61FF),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isOtpSent = false;
                        _otpController.clear();
                      });
                    },
                    child: const Text(
                      'Change phone number',
                      style: TextStyle(
                        color: Color(0xFF7B61FF),
                        fontWeight: FontWeight.w600,
                      ),
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