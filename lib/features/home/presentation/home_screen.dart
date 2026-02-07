import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;
import '/../features/auth/presentation/auth_controller.dart';
import 'package:buddygoapp/features/discovery/presentation/discovery_screen.dart';
import 'package:buddygoapp/features/groups/presentation/create_group_screen.dart';
import 'package:buddygoapp/features/groups/presentation/chat_list_screen.dart';
import 'package:buddygoapp/features/user/presentation/profile_screen.dart';
import 'package:buddygoapp/features/user/presentation/my_trips_screen.dart';
import 'package:buddygoapp/features/safety/presentation/admin_dashboard.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DiscoveryScreen(),
    const ChatListScreen(),
    const MyTripsScreen(),
    const Scaffold(body: Center(child: Text('Notifications'))),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // REMOVED: appBar property completely
      body: _screens[_selectedIndex],
      floatingActionButton: _buildFloatingActionButton(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget? _buildFloatingActionButton() {
    switch (_selectedIndex) {
      case 0: // Discover - Create trip
        return FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CreateGroupScreen(),
              ),
            );
          },
          backgroundColor: const Color(0xFF7B61FF),
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            'Create Trip',
            style: TextStyle(color: Colors.white),
          ),
        );

      case 1: // Chats - Create new chat
        return FloatingActionButton(
          onPressed: () {
            // Create new chat/group
          },
          backgroundColor: const Color(0xFF7B61FF),
          child: const Icon(Icons.message, color: Colors.white),
        );

      default:
        return null;
    }
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF7B61FF),
        unselectedItemColor: Colors.grey[600],
        selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        items: [
          BottomNavigationBarItem(
            icon: Icon(_selectedIndex == 0 ? Icons.explore : Icons.explore_outlined),
            label: 'Discover',
          ),
          BottomNavigationBarItem(
            icon: Icon(_selectedIndex == 1 ? Icons.chat_bubble : Icons.chat_bubble_outlined),
            label: 'Chats',
          ),
          BottomNavigationBarItem(
            icon: Icon(_selectedIndex == 2 ? Icons.travel_explore : Icons.travel_explore_outlined),
            label: 'My Trips',
          ),
          BottomNavigationBarItem(
            icon: badges.Badge(
              showBadge: true,
              badgeContent: const Text(
                '3',
                style: TextStyle(fontSize: 10, color: Colors.white),
              ),
              child: Icon(_selectedIndex == 3 ? Icons.notifications : Icons.notifications_outlined),
            ),
            label: 'Alerts',
          ),
          BottomNavigationBarItem(
            icon: Icon(_selectedIndex == 4 ? Icons.person : Icons.person_outlined),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}