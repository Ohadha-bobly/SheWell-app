import 'package:flutter/material.dart';

void main() {
  runApp(const SheWellApp());
}

class SheWellApp extends StatelessWidget {
  const SheWellApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SheWell',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pinkAccent),
        useMaterial3: true,
        fontFamily: 'Sans',
      ),
      home: const TrackerScreen(),
    );
  }
}

// 🌸 Tracker Screen (Main Feature)
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
    print('Mood: $_selectedMood');
    print('Sleep hours: $_sleepHours');
    print('Cycle info: $_cycleInfo');

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Wellness log saved! 🌸')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Wellness Tracker'),
        centerTitle: true,
        backgroundColor: Colors.pinkAccent,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            const Text(
              'How are you feeling today?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
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
            Text('$_sleepHours hours', textAlign: TextAlign.center),
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
      ),
    );
  }
}

// 🩷 Placeholder Screens
class ChatbotScreen extends StatelessWidget {
  const ChatbotScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'AI Chatbot Coming Soon 🤖',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class ResourcesScreen extends StatelessWidget {
  const ResourcesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Health Resources & NGOs 📚',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'User Profile & Settings ⚙️',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
