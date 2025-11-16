import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CommunityDetailsScreen extends StatefulWidget {
  final String communityId;

  const CommunityDetailsScreen({super.key, required this.communityId});

  @override
  State<CommunityDetailsScreen> createState() => _CommunityDetailsScreenState();
}

class _CommunityDetailsScreenState extends State<CommunityDetailsScreen> {
  final supabase = Supabase.instance.client;
  final _controller = TextEditingController();
  bool _postAnonymously = false;

  Stream<List<Map<String, dynamic>>> _fetchPosts() {
    return supabase
        .from('community_posts')
        .stream(primaryKey: ['id'])
        .eq('community_id', widget.communityId)
        .order('created_at', ascending: false)
        .map((data) => data);
  }

  Future<bool> _hasLiked(String postId) async {
    final userId = supabase.auth.currentUser!.id;
    final likes = await supabase
        .from('community_likes')
        .select()
        .eq('post_id', postId)
        .eq('user_id', userId);

    return likes.isNotEmpty;
  }

  Future<void> _toggleLike(String postId) async {
    final userId = supabase.auth.currentUser!.id;

    if (await _hasLiked(postId)) {
      await supabase
          .from('community_likes')
          .delete()
          .eq('post_id', postId)
          .eq('user_id', userId);
    } else {
      await supabase.from('community_likes').insert({
        'post_id': postId,
        'user_id': userId,
      });
    }

    setState(() {}); // refresh UI
  }

  Future<List<Map<String, dynamic>>> _fetchComments(String postId) async {
    return await supabase
        .from('community_comments')
        .select()
        .eq('post_id', postId)
        .order('created_at', ascending: true);
  }

  Future<void> _addPost() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    await supabase.from('community_posts').insert({
      'community_id': widget.communityId,
      'user_id': supabase.auth.currentUser!.id,
      'text': text,
      'anonymous': _postAnonymously,
    });

    // Notify members of this community
    await supabase.rpc('notify_community', params: {
      'community_id_param': widget.communityId,
      'message_param': "New community post available 💬"
    });

    _controller.clear();
    _postAnonymously = false;
    setState(() {});
  }

  Future<void> _deletePost(String postId) async {
    await supabase.from('community_posts').delete().eq('id', postId);
    await supabase.from('community_comments').delete().eq('post_id', postId);
    await supabase.from('community_likes').delete().eq('post_id', postId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Community"),
        backgroundColor: Colors.pinkAccent,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: _fetchPosts(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final posts = snapshot.data!;

                if (posts.isEmpty) {
                  return const Center(
                    child: Text("No posts yet. Be the first 💗"),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: posts.length,
                  itemBuilder: (context, i) {
                    final post = posts[i];

                    return FutureBuilder(
                      future: _hasLiked(post['id']),
                      builder: (context, likeSnap) {
                        final liked = likeSnap.data ?? false;

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // ⭐ Anonymous or visible user
                                Text(
                                  post['anonymous'] == true
                                      ? "Anonymous"
                                      : post['user_id'],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 5),

                                Text(post['text']),
                                const SizedBox(height: 10),

                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        liked
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color: Colors.pinkAccent,
                                      ),
                                      onPressed: () =>
                                          _toggleLike(post['id']),
                                    ),
                                    const SizedBox(width: 8),

                                    // ⭐ Comment Button
                                    TextButton(
                                      child: const Text("Comments"),
                                      onPressed: () {
                                        _showCommentsModal(post['id']);
                                      },
                                    ),

                                    const Spacer(),

                                    // ⭐ Admin Tool — Delete
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.redAccent),
                                      onPressed: () => _deletePost(post['id']),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),

          // ⭐ Write Post Section
          Container(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: _postAnonymously,
                      onChanged: (v) =>
                          setState(() => _postAnonymously = v ?? false),
                    ),
                    const Text("Post anonymously"),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: "Write something...",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.send, color: Colors.pinkAccent),
                      onPressed: _addPost,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ⭐ Modal bottom sheet for comments
  void _showCommentsModal(String postId) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final commentController = TextEditingController();

        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.75,
          child: Column(
            children: [
              const SizedBox(height: 10),
              const Text("Comments",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              const Divider(),

              Expanded(
                child: FutureBuilder(
                  future: _fetchComments(postId),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                          child: CircularProgressIndicator());
                    }

                    final comments = snapshot.data!;

                    return ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: comments.length,
                      itemBuilder: (context, i) {
                        final c = comments[i];

                        return Card(
                          child: ListTile(
                            title: Text(c['text']),
                            subtitle: Text("by ${c['user_id']}"),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete,
                                  color: Colors.redAccent),
                              onPressed: () async {
                                await supabase
                                    .from('community_comments')
                                    .delete()
                                    .eq('id', c['id']);
                                setState(() {});
                              },
                            ),
                          ),
                        );
                      },
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
                        controller: commentController,
                        decoration: const InputDecoration(
                          hintText: "Add a comment...",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send, color: Colors.pinkAccent),
                      onPressed: () async {
                        final text = commentController.text.trim();
                        if (text.isEmpty) return;

                        await supabase.from('community_comments').insert({
                          'post_id': postId,
                          'user_id': supabase.auth.currentUser!.id,
                          'text': text,
                        });

                        commentController.clear();
                        setState(() {});
                      },
                    )
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
