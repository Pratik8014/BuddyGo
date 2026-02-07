import 'package:flutter/material.dart';

class GroupController with ChangeNotifier {
  List<Map<String, dynamic>> _groups = [];
  List<Map<String, dynamic>> _chats = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get groups => _groups;
  List<Map<String, dynamic>> get chats => _chats;
  bool get isLoading => _isLoading;

  Future<void> loadGroups() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    _groups = [
      {
        'id': '1',
        'name': 'Goa Trip 2024',
        'description': 'Beach adventure group',
        'members': 4,
        'image': 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?auto=format&fit=crop&w=800',
      },
    ];

    _isLoading = false;
    notifyListeners();
  }

  Future<void> createGroup(Map<String, dynamic> groupData) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));

    _groups.insert(0, {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      ...groupData,
    });

    _isLoading = false;
    notifyListeners();
  }
}