import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  XFile? _image;
  Uint8List? _webImage;
  bool _loading = false;

  final supabase = Supabase.instance.client;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked == null) return;

    if (kIsWeb) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _webImage = bytes;
        _image = picked;
      });
    } else {
      setState(() => _image = picked);
    }
  }

  Future<void> _signup() async {
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields.')),
      );
      return;
    }

    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a profile picture.')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      // ---------------------------------------------------
      // 1️⃣ Create user in Supabase
      // ---------------------------------------------------
      final response = await supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (response.user == null) {
        throw Exception("Signup failed. Try again.");
      }

      final uid = response.user!.id;

      // ---------------------------------------------------
      // 2️⃣ Upload profile picture to Supabase Storage
      // ---------------------------------------------------
      final filePath = "$uid/profile.jpg";

      if (kIsWeb) {
        await supabase.storage
            .from('profile_pictures')
            .uploadBinary(filePath, _webImage!);
      } else {
        await supabase.storage
            .from('profile_pictures')
            .upload(filePath, File(_image!.path));
      }

      // ---------------------------------------------------
      // 3️⃣ Get URL to the uploaded image
      // ---------------------------------------------------
      final profileUrl = supabase.storage
          .from('profile_pictures')
          .getPublicUrl(filePath);

      // ---------------------------------------------------
      // 4️⃣ Save profile data into your database
      // ---------------------------------------------------
      await supabase.from('users').insert({
        'id': uid,
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'profile_url': profileUrl,
        'created_at': DateTime.now().toIso8601String(),
      });

      // ---------------------------------------------------
      // 5️⃣ Navigate to Home Screen
      // ---------------------------------------------------
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Signup error: $e")),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Colors.pink, Colors.pinkAccent]),
        ),
        padding: const EdgeInsets.all(24),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),

                // -----------------------
                //    Profile Picture
                // -----------------------
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    backgroundImage: kIsWeb && _webImage != null
                        ? MemoryImage(_webImage!)
                        : (_image != null
                            ? FileImage(File(_image!.path))
                            : null),
                    child: _image == null
                        ? const Icon(
                            Icons.add_a_photo,
                            size: 40,
                            color: Colors.white,
                          )
                        : null,
                  ),
                ),

                const SizedBox(height: 16),

                // -----------------------
                //   Input Fields
                // -----------------------
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: 'Full Name',
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    hintText: 'Email',
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: 'Password',
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),

                const SizedBox(height: 24),

                // -----------------------
                //   Sign Up Button
                // -----------------------
                ElevatedButton(
                  onPressed: _loading ? null : _signup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.pinkAccent,
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _loading
                      ? const CircularProgressIndicator(
                          color: Colors.pinkAccent)
                      : const Text('Sign Up'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
