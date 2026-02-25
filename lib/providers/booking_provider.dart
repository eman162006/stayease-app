import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/booking.dart';
import '../models/property.dart';

class BookingsProvider extends ChangeNotifier {
  static const _kBookingsKey = 'bookings_v1';

  final List<Booking> _bookings = [];
  List<Booking> get bookings => List.unmodifiable(_bookings);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kBookingsKey);
    if (raw == null || raw.isEmpty) return;

    final List decoded = jsonDecode(raw) as List;
    _bookings
      ..clear()
      ..addAll(decoded.map((e) => Booking.fromJson(e as Map<String, dynamic>)));

    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_bookings.map((b) => b.toJson()).toList());
    await prefs.setString(_kBookingsKey, encoded);
  }

  Future<void> addBooking({
    required Property property,
    required DateTime checkIn,
    required DateTime checkOut,
    required int guests,
    required double total,
  }) async {
    final booking = Booking(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      property: property,
      checkIn: checkIn,
      checkOut: checkOut,
      guests: guests,
      total: total,
      status: 'Pending',
    );

    _bookings.insert(0, booking);
    notifyListeners();
    await _save();
  }

  Future<void> confirmBooking(String bookingId) async {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index == -1) return;

    final old = _bookings[index];
    _bookings[index] = Booking(
      id: old.id,
      property: old.property,
      checkIn: old.checkIn,
      checkOut: old.checkOut,
      guests: old.guests,
      total: old.total,
      status: 'Confirmed',
    );

    notifyListeners();
    await _save();
  }

  Future<void> cancelBooking(String bookingId) async {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index == -1) return;

    final old = _bookings[index];
    _bookings[index] = Booking(
      id: old.id,
      property: old.property,
      checkIn: old.checkIn,
      checkOut: old.checkOut,
      guests: old.guests,
      total: old.total,
      status: 'Cancelled',
    );

    notifyListeners();
    await _save();
  }

  Future<void> clearAll() async {
    _bookings.clear();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kBookingsKey);
  }
}