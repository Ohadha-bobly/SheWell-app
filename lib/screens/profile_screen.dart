import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:mime/mime.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends StatefulWidget {
  final String currentUserId;
  const ProfileScreen({super.key, required this.currentUserId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  XFile? _image;
  bool _loading = false;
  Map<String, dynamic>? _userData;

  final supabase = Supabase.instance.client;
  final bucketName = "profile_pictures"; // <--_FINAL bucket name

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.currentUserId)
        .get();

    if (doc.exists) {
      _userData = doc.data();
      _nameController.text = _userData?['name'] ?? '';
      setState(() {});
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _image = picked);
  }

  Future<String?> _uploadToSupabase(File file) async {
    try {
      // Folder per user ✔
      final fileName =
          "${widget.currentUserId}/profile_${DateTime.now().millisecondsSinceEpoch}.jpg";

      final mimeType = lookupMimeType(file.path) ?? "image/jpeg";

      // Upload file ✔
      await supabase.storage.from(bucketName).upload(
            fileName,
            file,
            fileOptions: FileOptions(
              contentType: mimeType,
              metadata: {
                "owner": widget.currentUserId, // <-- required for RLS
              },
            ),
          );

      // Return public URL ✔
      return supabase.storage.from(bucketName).getPublicUrl(fileName);
    } catch (e) {
      print("Supabase upload error: $e");
      return null;
    }
  }

  Future<void> _updateProfile() async {
    setState(() => _loading = true);

    try {
      String? profileUrl = _userData?['profileUrl'];

      // Upload image if selected
      if (_image != null) {
        final file = File(_image!.path);
        final uploadedUrl = await _uploadToSupabase(file);
        if (uploadedUrl != null) profileUrl = uploadedUrl;
      }

      // Update Firestore ✔
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.currentUserId)
          .update({
        'name': _nameController.text.trim(),
        'profileUrl': profileUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_userData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final currentProfileUrl = _userData!['profileUrl'] ?? '';

    ImageProvider? avatarImage;

    if (_image != null) {
      avatarImage = FileImage(File(_image!.path));
    } else if (currentProfileUrl.isNotEmpty) {
      avatarImage = NetworkImage(currentProfileUrl);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: CircleAvatar(
              radius: 50,
              backgroundImage: avatarImage,
              child: avatarImage == null
                  ? const Icon(Icons.add_a_photo,
                      size: 40, color: Colors.white)
                  : null,
              backgroundColor: Colors.pinkAccent.withOpacity(0.3),
            ),
          ),

          const SizedBox(height: 16),

          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Name'),
          ),

          const SizedBox(height: 16),

          Text(
            _userData!['email'],
            style: const TextStyle(fontSize: 16),
          ),

          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: _loading ? null : _updateProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pinkAccent,
              padding:
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 40),
            ),
            child: _loading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text("Update Profile"),
          ),
        ],
      ),
    );
  }
}
