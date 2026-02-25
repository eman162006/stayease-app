import 'property.dart';

class Booking {
  final String id;
  final Property property;
  final DateTime checkIn;
  final DateTime checkOut;
  final int guests;
  final double total;
  final String status; // Confirmed / Pending ...

  const Booking({
    required this.id,
    required this.property,
    required this.checkIn,
    required this.checkOut,
    required this.guests,
    required this.total,
    required this.status,
  });
  Map<String, dynamic> toJson() => {
        'id': id,
        'property': property.toJson(),
        'checkIn': checkIn.toIso8601String(),
        'checkOut': checkOut.toIso8601String(),
        'guests': guests,
        'total': total,
        'status': status,
      };

  factory Booking.fromJson(Map<String, dynamic> json) => Booking(
        id: json['id'] as String,
        property: Property.fromJson(json['property'] as Map<String, dynamic>),
        checkIn: DateTime.parse(json['checkIn'] as String),
        checkOut: DateTime.parse(json['checkOut'] as String),
        guests: json['guests'] as int,
        total: (json['total'] as num).toDouble(),
        status: json['status'] as String,
      );
}