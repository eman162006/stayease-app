import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddDestinationScreen extends StatefulWidget {
  const AddDestinationScreen({super.key});

  @override
  State<AddDestinationScreen> createState() => _AddDestinationScreenState();
}

class _AddDestinationScreenState extends State<AddDestinationScreen> {
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  bool _isLoading = false;
  Uint8List? _imageBytes;

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        setState(() => _imageBytes = bytes);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  Future<void> _addDestination() async {
    if (_titleController.text.isEmpty ||
        _locationController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _imageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields and select an image')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      // 1. Upload Image to Firebase Storage
      final ref = FirebaseStorage.instance
          .ref()
          .child('destinations/${DateTime.now().millisecondsSinceEpoch}.jpg');

      await ref.putData(_imageBytes!, SettableMetadata(contentType: 'image/jpeg'));
      final imageUrl = await ref.getDownloadURL();

      // 2. Save Data to Firestore
      await FirebaseFirestore.instance.collection('destinations').add({
        'title': _titleController.text.trim(),
        'location': _locationController.text.trim(),
        'description': _descriptionController.text.trim(),
        'price': double.tryParse(_priceController.text.trim()) ?? 0.0,
        'imageUrl': imageUrl,
        'rating': 4.5, // Default start rating
        'reviews': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Destination added successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add destination: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Destination')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                  image: _imageBytes != null
                      ? DecorationImage(
                          image: MemoryImage(_imageBytes!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _imageBytes == null
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                          SizedBox(height: 8),
                          Text("Tap to add image", style: TextStyle(color: Colors.grey)),
                        ],
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(labelText: 'Location'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Price per night (\$)'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _addDestination,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Add Destination'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
