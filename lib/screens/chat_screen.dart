import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatScreen extends StatefulWidget {
  final String peerId;
  final String peerName;
  final String peerProfileUrl;

  const ChatScreen({
    super.key,
    required this.peerId,
    required this.peerName,
    required this.peerProfileUrl,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final supabase = Supabase.instance.client;
  late final String chatId;
  late final String currentUserId;

  @override
  void initState() {
    super.initState();

    final user = supabase.auth.currentUser;
    if (user == null) {
      // If no user, push to login or throw — keep simple fallback:
      currentUserId = '';
    } else {
      currentUserId = user.id;
    }

    // deterministic chat id (same ordering logic as before)
    chatId = (currentUserId.hashCode <= widget.peerId.hashCode)
        ? '$currentUserId-${widget.peerId}'
        : '${widget.peerId}-$currentUserId';
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    if (currentUserId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not authenticated')),
      );
      return;
    }

    try {
      await supabase.from('messages').insert({
        'chat_id': chatId,
        'sender_id': currentUserId,
        'receiver_id': widget.peerId,
        'text': text.trim(),
      });
      _controller.clear();
    } catch (e) {
      debugPrint('Send message error: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Send failed: $e')));
    }
  }

  // Stream of messages for this chat (newest first)
  Stream<List<Map<String, dynamic>>> _messagesStream() {
    return supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('chat_id', chatId)
        .order('created_at', ascending: false)
        .map((event) {
      // event is List<Map<String,dynamic>> of rows
      // ensure we return a copy sorted newest-first (already ordered but safe)
      final list = List<Map<String, dynamic>>.from(event);
      list.sort((a, b) {
        final aTs = a['created_at'] == null ? 0 : DateTime.parse(a['created_at']).millisecondsSinceEpoch;
        final bTs = b['created_at'] == null ? 0 : DateTime.parse(b['created_at']).millisecondsSinceEpoch;
        return bTs.compareTo(aTs);
      });
      return list;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.peerProfileUrl),
            ),
            const SizedBox(width: 8),
            Text(widget.peerName),
          ],
        ),
        backgroundColor: Colors.pinkAccent,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _messagesStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final docs = snapshot.data ?? [];

                if (docs.isEmpty) {
                  return const Center(child: Text('No messages yet'));
                }

                return ListView.builder(
                  reverse: true, // newest at bottom visually: list reversed
                  padding: const EdgeInsets.all(12),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index];
                    final senderId = data['sender_id']?.toString() ?? '';
                    final text = data['text']?.toString() ?? '';
                    final isMe = senderId == currentUserId;

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.pinkAccent : Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          text,
                          style: TextStyle(color: isMe ? Colors.white : Colors.black),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // composer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            color: Colors.grey[100],
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: InputBorder.none,
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (val) => _sendMessage(val),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.pinkAccent),
                  onPressed: () => _sendMessage(_controller.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
