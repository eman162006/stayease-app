import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  bool _isLoading = false;
  Uint8List? _imageBytes;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Get current user data
    final user = FirebaseAuth.instance.currentUser;
    _nameCtrl = TextEditingController(text: user?.displayName ?? "");
    _emailCtrl = TextEditingController(text: user?.email ?? "");
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      // Optimize image: Resize to 512px and compress quality to 70%
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 300, // Smaller size for faster upload
        maxHeight: 300,
        imageQuality: 60, // Lower quality (still looks good for avatars)
      );

      if (picked != null) {
        final bytes = await picked.readAsBytes();
        setState(() => _imageBytes = bytes);
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to pick image: $e")),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final List<Future<void>> tasks = [];

        // 1. Add Image Upload Task (if image changed)
        if (_imageBytes != null) {
          tasks.add(() async {
            final ref = FirebaseStorage.instance
                .ref()
                .child('user_images')
                .child('${user.uid}.jpg');

            await ref.putData(_imageBytes!, SettableMetadata(contentType: 'image/jpeg'));
            final imageUrl = await ref.getDownloadURL();
            await user.updatePhotoURL(imageUrl);
          }());
        }

        // 2. Add Name Update Task
        tasks.add(user.updateDisplayName(_nameCtrl.text.trim()));

        // 3. Execute all tasks at the same time (Parallel)
        await Future.wait(tasks);

        // 4. Reload user to see changes
        await user.reload();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Profile updated successfully! ✅")),
          );
          Navigator.pop(context); // Go back
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(title: const Text("Edit Profile")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  // 1. Avatar Container
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.shade200,
                      image: _imageBytes != null
                          ? DecorationImage(image: MemoryImage(_imageBytes!), fit: BoxFit.cover)
                          : (FirebaseAuth.instance.currentUser?.photoURL != null
                              ? DecorationImage(
                                  image: NetworkImage(FirebaseAuth.instance.currentUser!.photoURL!),
                                  fit: BoxFit.cover)
                              : null),
                    ),
                    child: (_imageBytes == null && FirebaseAuth.instance.currentUser?.photoURL == null)
                        ? const Icon(Icons.person, size: 50, color: Colors.grey)
                        : null,
                  ),
                  
                  // 2. Loading Overlay (Shows when saving)
                  if (_isLoading)
                    Container(
                      width: 100,
                      height: 100,
                      decoration: const BoxDecoration(
                        color: Colors.black45,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(child: CircularProgressIndicator(color: Colors.white)),
                    ),

                  // 3. Camera Icon Badge
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Color(0xFF0E7490),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailCtrl,
              enabled: false, // Email cannot be changed easily without re-login
              decoration: const InputDecoration(labelText: "Email"),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                // Keep button enabled visually but do nothing on tap to maintain color
                onPressed: _isLoading ? () {} : _saveProfile,
                child: _isLoading
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          ),
                          SizedBox(width: 10),
                          Text("Saving..."),
                        ],
                      )
                    : const Text("Save"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}