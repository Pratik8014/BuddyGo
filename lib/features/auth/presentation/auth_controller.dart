import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:buddygoapp/core/services/firebase_service.dart';
import 'package:buddygoapp/features/user/data/user_model.dart';

class AuthController with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseService _firebaseService = FirebaseService();
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  UserModel? _currentUser;
  bool _isLoading = false;
  bool _isLoggedIn = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;

  AuthController() {
    _initialize();
  }

  Future<void> _initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (_isLoggedIn) {
      await _loadCurrentUser();
    }
  }

  Future<void> _loadCurrentUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      final userData = await _firebaseService.getUserProfile(user.uid);
      if (userData != null) {
        _currentUser = userData;
      } else {
        // Create user profile if doesn't exist
        await _createUserProfile(user);
      }
    }
    notifyListeners();
  }

  Future<void> _createUserProfile(User firebaseUser) async {
    final userModel = UserModel(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      name: firebaseUser.displayName,
      photoUrl: firebaseUser.photoURL,
      isEmailVerified: firebaseUser.emailVerified,
    );

    await _firebaseService.createUserProfile(userModel);
    _currentUser = userModel;
  }

  Future<bool> signInWithEmail(String email, String password) async {
    try {
      _setLoading(true);
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _saveLoginStatus(true);
      await _loadCurrentUser();
      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signUpWithEmail(String email, String password, String name) async {
    try {
      _setLoading(true);
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await result.user?.updateDisplayName(name);
      await _createUserProfile(result.user!);
      await _saveLoginStatus(true);
      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      _setLoading(true);
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _setLoading(false);
        return false;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final result = await _auth.signInWithCredential(credential);

      // Check if user exists
      final existingUser = await _firebaseService.getUserProfile(result.user!.uid);
      if (existingUser == null) {
        await _createUserProfile(result.user!);
      } else {
        _currentUser = existingUser;
      }

      await _saveLoginStatus(true);
      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      return false;
    }
  }

  Future<void> updateProfile({
    String? name,
    String? bio,
    String? location,
    String? studentId,
    List<String>? interests,
  }) async {
    if (_currentUser == null) return;

    try {
      _setLoading(true);

      final updatedUser = _currentUser!.copyWith(
        name: name,
        bio: bio,
        location: location,
        studentId: studentId,
        interests: interests,
      );

      await _firebaseService.updateUserProfile(
        _currentUser!.id,
        updatedUser.toJson(),
      );

      _currentUser = updatedUser;
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setLoading(false);
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    await _saveLoginStatus(false);
    _currentUser = null;
    notifyListeners();
  }

  Future<void> _saveLoginStatus(bool status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', status);
    _isLoggedIn = status;
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}