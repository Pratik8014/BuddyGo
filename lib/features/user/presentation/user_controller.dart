import 'package:flutter/material.dart';

class UserController with ChangeNotifier {
  String? _selectedImageUrl;
  String? _name;
  String? _bio;
  String? _location;

  String? get selectedImageUrl => _selectedImageUrl;
  String? get name => _name;
  String? get bio => _bio;
  String? get location => _location;

  void updateProfile({
    String? name,
    String? bio,
    String? location,
    String? imageUrl,
  }) {
    if (name != null) _name = name;
    if (bio != null) _bio = bio;
    if (location != null) _location = location;
    if (imageUrl != null) _selectedImageUrl = imageUrl;

    notifyListeners();
  }

  void clearProfile() {
    _name = null;
    _bio = null;
    _location = null;
    _selectedImageUrl = null;
    notifyListeners();
  }
}