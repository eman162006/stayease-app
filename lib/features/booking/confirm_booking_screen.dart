import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stayease/providers/booking_provider.dart';
import '../../models/property.dart';
// ignore: unused_import
import 'my_bookings_screen.dart';
import '../main_navigation/main_navigation_screen.dart';
class ConfirmBookingScreen extends StatefulWidget {
  final Property property;
  const ConfirmBookingScreen({super.key, required this.property});

  @override
  State<ConfirmBookingScreen> createState() => _ConfirmBookingScreenState();
}

class _ConfirmBookingScreenState extends State<ConfirmBookingScreen> {
  int guests = 2;

DateTime? checkInDate;
DateTime? checkOutDate;

int get nights {
  if (checkInDate == null || checkOutDate == null) return 0;
  final diff = checkOutDate!.difference(checkInDate!).inDays;
  return diff > 0 ? diff : 0;
}

double get total => widget.property.pricePerNight * nights;

String _fmt(DateTime? d) {
  if (d == null) return 'Select';
  // format بسيط بدون package
  return '${d.day}/${d.month}/${d.year}';
}// مثال 3 ليالي
Future<void> _pickDate({required bool isCheckIn}) async {
  final now = DateTime.now();
  final initial = isCheckIn ? (checkInDate ?? now) : (checkOutDate ?? (checkInDate ?? now).add(const Duration(days: 1)));

  final picked = await showDatePicker(
    context: context,
    initialDate: initial,
    firstDate: now,
    lastDate: DateTime(now.year + 2),
  );

  if (picked == null) return;

  setState(() {
    if (isCheckIn) {
      checkInDate = picked;
      // إذا check-out قبل check-in، نزبطه تلقائي
      if (checkOutDate != null && !checkOutDate!.isAfter(checkInDate!)) {
        checkOutDate = checkInDate!.add(const Duration(days: 1));
      }
    } else {
      // لازم يكون بعد check-in
      if (checkInDate != null && !picked.isAfter(checkInDate!)) {
        // إذا اختار تاريخ غلط، نخليه يوم بعد check-in
        checkOutDate = checkInDate!.add(const Duration(days: 1));
      } else {
        checkOutDate = picked;
      }
    }
  });
}

String get checkIn => _fmt(checkInDate);
String get checkOut => _fmt(checkOutDate);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Confirm Booking',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Property summary card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                      color: Colors.black.withOpacity(0.06),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        widget.property.imageUrl,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.property.title,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.property.location,
                            style: const TextStyle(
                                fontSize: 13, color: Color(0xFF6B7280)),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '\$${widget.property.pricePerNight.toStringAsFixed(0)} / night',
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text('Select Dates',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827))),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _DateBox(
                        label: 'Check-in',
                        value: checkIn,
                        onTap: () => _pickDate(isCheckIn: true)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _DateBox(
                        label: 'Check-out',
                        value: checkOut,
                        onTap: () => _pickDate(isCheckIn: false)),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              const Text('Guests',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827))),
              const SizedBox(height: 12),

              Row(
                children: [
                  _CircleBtn(
                    icon: Icons.remove,
                    onTap: () {
                      if (guests > 1) setState(() => guests--);
                    },
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '$guests',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(width: 16),
                  _CircleBtn(
                    icon: Icons.add,
                    onTap: () => setState(() => guests++),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              const Divider(color: Color(0xFFE5E7EB), height: 32),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total',
                      style:
                          TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
                  Text(
                    '\$${total.toStringAsFixed(0)}',
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827)),
                  ),
                ],
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    if (checkInDate == null || checkOutDate == null || nights == 0) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please select valid dates')),
    );
    return;
  }
 context.read<BookingsProvider>().addBooking(
    property: widget.property,
    checkIn: checkInDate!,
    checkOut: checkOutDate!,
    guests: guests,
    total: total,
  );

 Navigator.pushAndRemoveUntil(
  context,
  MaterialPageRoute(builder: (_) => const MainNavigationScreen(initialIndex: 1)),
  (route) => false,
 );
},
                  child: const Text('Confirm',
                      style: TextStyle(fontSize: 16)),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateBox extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _DateBox({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: const Color(0xFFE5E7EB),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '$label: $value',
          style: const TextStyle(
            fontSize: 13.5,
            color: Color(0xFF374151),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFFE5E7EB),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: const Color(0xFF111827)),
      ),
    );
  }
}