import 'package:cloud_firestore/cloud_firestore.dart';

class Property {
  final String id;
  final String title;
  final String location;
  final String imageUrl;
  final double pricePerNight;

  Property({
    required this.id,
    required this.title,
    required this.location,
    required this.imageUrl,
    required this.pricePerNight,
  });

  // ✅ Firestore -> Property
  factory Property.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

    final rawPrice = data['pricePerNight'];
    final price = (rawPrice is num)
        ? rawPrice.toDouble()
        : double.tryParse(rawPrice?.toString() ?? '') ?? 0.0;

    return Property(
      id: doc.id,
      title: (data['title'] ?? '').toString(),
      location: (data['location'] ?? '').toString(),
      imageUrl: (data['imageUrl'] ?? '').toString(),
      pricePerNight: price,
    );
  }

  // ✅ Property -> Map (للتخزين على Firestore أو Local)
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'location': location,
      'imageUrl': imageUrl,
      'pricePerNight': pricePerNight,
    };
  }

  // ✅ Map -> Property (لو بدك Local/SharedPrefs أو غيره)
  factory Property.fromJson(Map<String, dynamic> json) {
    final rawPrice = json['pricePerNight'];
    final price = (rawPrice is num)
        ? rawPrice.toDouble()
        : double.tryParse(rawPrice?.toString() ?? '') ?? 0.0;

    return Property(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      location: (json['location'] ?? '').toString(),
      imageUrl: (json['imageUrl'] ?? '').toString(),
      pricePerNight: price,
    );
  }
}