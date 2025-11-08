import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;

  void _toggleDarkMode(bool value) {
    setState(() => _isDarkMode = value);
  }

  void _toggleNotifications(bool value) {
    setState(() => _notificationsEnabled = value);
  }

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text('Logout', style: TextStyle(color: Colors.pinkAccent)),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Logged out successfully 🌸')),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SheWell',
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        primarySwatch: Colors.pink,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.pinkAccent,
          foregroundColor: Colors.white,
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: const ColorScheme.dark(primary: Colors.pinkAccent),
        appBarTheme: const AppBarTheme(backgroundColor: Colors.pinkAccent),
      ),
      home: HomeScreen(
        isDarkMode: _isDarkMode,
        notificationsEnabled: _notificationsEnabled,
        onToggleDarkMode: _toggleDarkMode,
        onToggleNotifications: _toggleNotifications,
        onLogout: _logout,
      ),
    );
  }
}

//
// 🏠 HOME SCREEN
//
class HomeScreen extends StatefulWidget {
  final bool isDarkMode;
  final bool notificationsEnabled;
  final void Function(bool) onToggleDarkMode;
  final void Function(bool) onToggleNotifications;
  final void Function(BuildContext) onLogout;

  const HomeScreen({
    super.key,
    required this.isDarkMode,
    required this.notificationsEnabled,
    required this.onToggleDarkMode,
    required this.onToggleNotifications,
    required this.onLogout,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const TrackerScreen(),
      const ChatbotScreen(),
      const ResourcesScreen(),
      ProfileScreen(
        isDarkMode: widget.isDarkMode,
        notificationsEnabled: widget.notificationsEnabled,
        onToggleDarkMode: widget.onToggleDarkMode,
        onToggleNotifications: widget.onToggleNotifications,
        onLogout: widget.onLogout,
      ),
    ];
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SheWell"),
        centerTitle: true,
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.pinkAccent,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Tracker"),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble), label: "Chatbot"),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: "Resources"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

//
// 🩷 1. WELLNESS TRACKER
//
class TrackerScreen extends StatefulWidget {
  const TrackerScreen({super.key});

  @override
  State<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends State<TrackerScreen> {
  String? _selectedMood;
  double _sleepHours = 7;
  String? _cycleInfo;

  final List<String> moods = ['Happy', 'Neutral', 'Sad', 'Stressed'];

  void _saveLog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Wellness log saved! 🌸')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Daily Wellness Tracker',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          const Text('How are you feeling today?'),
          Wrap(
            spacing: 10,
            children: moods.map((mood) {
              return ChoiceChip(
                label: Text(mood),
                selected: _selectedMood == mood,
                selectedColor: Colors.pinkAccent,
                onSelected: (_) => setState(() => _selectedMood = mood),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          const Text('How many hours did you sleep?'),
          Slider(
            value: _sleepHours,
            min: 0,
            max: 12,
            divisions: 12,
            label: _sleepHours.toStringAsFixed(1),
            activeColor: Colors.pinkAccent,
            onChanged: (val) => setState(() => _sleepHours = val),
          ),
          Text('${_sleepHours.toStringAsFixed(1)} hours', textAlign: TextAlign.center),
          const SizedBox(height: 24),
          const Text('Any cycle notes? (optional)'),
          TextField(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'e.g., light cramps, first day, etc.',
            ),
            onChanged: (val) => _cycleInfo = val,
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            icon: const Icon(Icons.save),
            label: const Text('Save Log'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pinkAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: _saveLog,
          ),
        ],
      ),
    );
  }
}

//
// 🤖 2. CHATBOT SCREEN
//
class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final List<Map<String, String>> _messages = [];
  final TextEditingController _controller = TextEditingController();

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;

    setState(() {
      _messages.add({'sender': 'You', 'text': _controller.text});
      _messages.add({
        'sender': 'SheWell AI',
        'text': 'That sounds important 🌸 Tell me more about how you feel.'
      });
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final msg = _messages[index];
              final isUser = msg['sender'] == 'You';
              return Align(
                alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isUser ? Colors.pinkAccent : Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    msg['text']!,
                    style: TextStyle(color: isUser ? Colors.white : Colors.black),
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: 'Type a message...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send, color: Colors.pinkAccent),
                onPressed: _sendMessage,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

//
// 📚 3. RESOURCES SCREEN
//
class ResourcesScreen extends StatelessWidget {
  const ResourcesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> resources = [
      {'title': 'Women’s Health Tips', 'link': 'https://www.who.int/health-topics/women-s-health'},
      {'title': 'Mental Wellness Resources', 'link': 'https://www.mentalhealth.gov/'},
      {'title': 'Support Groups Near You', 'link': 'https://findahelpline.com/'},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: resources.length,
      itemBuilder: (context, index) {
        final res = resources[index];
        return Card(
          child: ListTile(
            title: Text(res['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(res['link']!),
            trailing: const Icon(Icons.open_in_new, color: Colors.pinkAccent),
            onTap: () {}, // later integrate URL launcher
          ),
        );
      },
    );
  }
}

//
// ⚙️ 4. PROFILE SCREEN (Now Fully Functional)
//
class ProfileScreen extends StatelessWidget {
  final bool isDarkMode;
  final bool notificationsEnabled;
  final void Function(bool) onToggleDarkMode;
  final void Function(bool) onToggleNotifications;
  final void Function(BuildContext) onLogout;

  const ProfileScreen({
    super.key,
    required this.isDarkMode,
    required this.notificationsEnabled,
    required this.onToggleDarkMode,
    required this.onToggleNotifications,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const CircleAvatar(
          radius: 50,
          backgroundImage: AssetImage('assets/images/profile_placeholder.png'),
        ),
        const SizedBox(height: 10),
        const Text('Jane Doe', textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const Text('Wellness Enthusiast 🌸', textAlign: TextAlign.center),
        const SizedBox(height: 20),
        Card(
          child: SwitchListTile(
            title: const Text('Notifications'),
            value: notificationsEnabled,
            secondary: const Icon(Icons.notifications),
            onChanged: onToggleNotifications,
          ),
        ),
        Card(
          child: SwitchListTile(
            title: const Text('Dark Mode'),
            value: isDarkMode,
            secondary: const Icon(Icons.dark_mode),
            onChanged: onToggleDarkMode,
          ),
        ),
        const SizedBox(height: 40),
        ElevatedButton.icon(
          icon: const Icon(Icons.logout),
          label: const Text('Logout'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.pinkAccent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          onPressed: () => onLogout(context),
        ),
      ],
    );
  }
}
