import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'users_list_screen.dart';
import 'chat_screen.dart';
import 'tracker_screen.dart';
import 'chatbot_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _screens;
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();

    final user = supabase.auth.currentUser;

    _screens = [
      const TrackerScreen(),
      const ChatbotScreen(),
      const UsersListScreen(),
      ProfileScreen(currentUserId: user?.id ?? ''),
    ];

    _setUserStatus(true); // mark online
  }

  @override
  void dispose() {
    _setUserStatus(false); // mark offline
    super.dispose();
  }

  Future<void> _setUserStatus(bool isOnline) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      await supabase.from('profiles').update({
        'online': isOnline,
        'last_seen': DateTime.now().toIso8601String(),
      }).eq('id', user.id);
    } catch (e) {
      debugPrint('Error updating user status: $e');
    }
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SheWell'),
        backgroundColor: Colors.pinkAccent,
        centerTitle: true,
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.pinkAccent,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Tracker',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Chatbot',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
