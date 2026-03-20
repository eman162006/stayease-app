import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/property.dart';

class PropertiesService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Property>> watchProperties() {
    return _db
        .collection('properties')
        .withConverter<Property>(
          fromFirestore: (snap, _) => Property.fromFirestore(snap),
          toFirestore: (p, _) => p.toJson(),
        )
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.data()).toList());
  }

  // (اختياري) تجيب مرة وحدة بدل Stream
  Future<List<Property>> getPropertiesOnce() async {
    final q = await _db
        .collection('properties')
        .withConverter<Property>(
          fromFirestore: (snap, _) => Property.fromFirestore(snap),
          toFirestore: (p, _) => p.toJson(),
        )
        .get();

    return q.docs.map((d) => d.data()).toList();
  }
}