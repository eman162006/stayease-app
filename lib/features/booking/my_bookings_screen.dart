import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/booking_provider.dart';
// ignore: duplicate_import
import 'package:provider/provider.dart';
// ignore: duplicate_import
import '../../providers/booking_provider.dart';

class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});

  String _fmt(DateTime d) => '${d.day}/${d.month}/${d.year}';

  @override
  Widget build(BuildContext context) {
    final bookings = context.watch<BookingsProvider>().bookings;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('My Bookings'),
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => context.read<BookingsProvider>().clearAll(),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: bookings.isEmpty
           ? Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(
          Icons.event_busy,
          size: 72,
          color: Color(0xFF9CA3AF),
        ),
        SizedBox(height: 16),
        Text(
          'No bookings yet',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Book your first stay from Home.',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    ),
  )
            : ListView.separated(
                itemCount: bookings.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, i) {
                  final b = bookings[i];

  final isCancelled = b.status == 'Cancelled';
 final isPending = b.status == 'Pending';

final pillBg = isCancelled
    ? const Color(0xFFFEE2E2)
    : isPending
        ? const Color(0xFFFEF9C3)
        : const Color(0xFFDCFCE7);

final pillText = isCancelled
    ? const Color(0xFFB91C1C)
    : isPending
        ? const Color(0xFF92400E)
        : const Color(0xFF15803D);
                  return Container(
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          b.property.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          b.property.location,
                          style: const TextStyle(color: Color(0xFF6B7280)),
                        ),
                        const SizedBox(height: 10),
                        Text('Dates: ${_fmt(b.checkIn)} - ${_fmt(b.checkOut)}'),
                        Text('Guests: ${b.guests}'),
                        Text('Total: \$${b.total.toStringAsFixed(0)}'),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                             color: pillBg,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              b.status,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: pillText,
                              ),
                            ),
                          ),
                        ),
                        if (!isCancelled)
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () async {
  await context.read<BookingsProvider>().cancelBooking(b.id);
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Booking cancelled ❌')),
  );
                              },
                              child: const Text(
                                'Cancel',
                                style: TextStyle(
                                  color: Color(0xFFB91C1C),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        if (isPending)
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () async {
  await context.read<BookingsProvider>().confirmBooking(b.id);
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Booking approved ✅')),
  );
},
                              child: const Text(
                                'Approve',
                                style: TextStyle(
                                  color: Color(0xFF15803D),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}