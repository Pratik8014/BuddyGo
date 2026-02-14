import 'package:flutter/material.dart';
import '../data/trip_model.dart';

class DiscoveryController with ChangeNotifier {
  List<Trip> _trips = [];
  bool _isLoading = false;
  String _selectedFilter = 'All';

  List<Trip> get trips => _trips;
  bool get isLoading => _isLoading;
  String get selectedFilter => _selectedFilter;

  void setFilter(String filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  Future<void> loadTrips() async {
    _isLoading = true;
    notifyListeners();

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    // Sample data
    _trips = [
      Trip(
        id: '1',
        title: 'Goa Beach Adventure',
        description: '7 days of sun, sand, and sea in beautiful Goa',
        destination: 'Goa, India',
        startDate: DateTime.now().add(const Duration(days: 5)),
        endDate: DateTime.now().add(const Duration(days: 12)),
        maxMembers: 6,
        currentMembers: 3,
        budget: 15000,
        hostId: 'host1',
        hostName: 'Sarah Wilson',
        hostImage: 'https://randomuser.me/api/portraits/women/65.jpg',
        images: [
          'https://images.unsplash.com/photo-1544551763-46a013bb70d5?auto=format&fit=crop&w=800',
        ],
        tags: ['Beach', 'Adventure', 'Party'],
        isPublic: true,
        createdAt: DateTime(2026),
      ),
    ];

    _isLoading = false;
    notifyListeners();
  }

  void addTrip(Trip trip) {
    _trips.insert(0, trip);
    notifyListeners();
  }
}