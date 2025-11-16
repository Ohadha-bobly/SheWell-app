import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../secrets.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final List<Map<String, String>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;

  late GenerativeModel _model;

  @override
  void initState() {
    super.initState();

    _model = GenerativeModel(
      model: "gemini-1.5-flash",
      apiKey: Secrets.geminiApiKey,
    );
  }

  Future<void> _sendMessage() async {
    final userMessage = _controller.text.trim();
    if (userMessage.isEmpty) return;

    setState(() {
      _messages.add({'sender': 'You', 'text': userMessage});
      _isLoading = true;
    });
    _controller.clear();

    try {
      // Build conversation memory
      final history = _messages
          .map((msg) => Content.text(
              '${msg['sender'] == 'You' ? "User" : "AI"}: ${msg['text']}'))
          .toList();

      // Add the latest message as the user prompt
      final response = await _model.generateContent([
        ...history,
        Content.text(
            "Respond empathetically like a supportive mental wellness assistant. Avoid giving medical or legal advice. The user says: $userMessage")
      ]);

      final aiReply =
          response.text ?? "I'm here for you 🌸 Tell me more about how you feel.";

      setState(() {
        _messages.add({'sender': 'SheWell AI', 'text': aiReply});
      });
    } catch (e) {
      setState(() {
        _messages.add({
          'sender': 'SheWell AI',
          'text': 'I’m having trouble responding right now. Please try again. 💗'
        });
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.pink, Colors.pinkAccent],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                // Show loading bubble
                if (_isLoading && index == 0) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text("SheWell AI is typing..."),
                    ),
                  );
                }

                final msgIndex = _messages.length - 1 - (index - (_isLoading ? 1 : 0));
                final msg = _messages[msgIndex];
                final isUser = msg['sender'] == 'You';

                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.pinkAccent : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          offset: const Offset(1, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Text(
                      msg['text']!,
                      style: TextStyle(
                          color: isUser ? Colors.white : Colors.black),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
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
      ),
    );
  }
}
