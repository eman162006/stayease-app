import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/booking_provider.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  final Set<String> _selectedIds = {};
  bool _isSelectionMode = false;

  String _fmt(DateTime d) => '${d.day}/${d.month}/${d.year}';

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bookings = context.watch<BookingsProvider>().bookings;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(_isSelectionMode
            ? '${_selectedIds.length} Selected'
            : 'My Bookings'),
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        leading: _isSelectionMode
            ? IconButton(
                icon: const Icon(Icons.close, color: Colors.black),
                onPressed: () => setState(() {
                  _isSelectionMode = false;
                  _selectedIds.clear();
                }),
              )
            : null,
        actions: [
          if (_isSelectionMode && _selectedIds.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                final provider = context.read<BookingsProvider>();
                for (final id in _selectedIds) {
                  // Ensure removeBooking(id) exists in your BookingsProvider!
                  provider.removeBooking(id);
                }
                setState(() {
                  _selectedIds.clear();
                  _isSelectionMode = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Selected bookings deleted')),
                );
              },
            )
          else if (!_isSelectionMode)
            TextButton(
              onPressed: () => setState(() => _isSelectionMode = true),
              child: const Text(
                'Select',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
            ),
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
                  final isSelected = _selectedIds.contains(b.id);

                  final isCancelled = b.status == 'Cancelled';
                  final isPending = b.status == 'Pending';

                  final pillBg = isCancelled
                      ? const Color(0xFFFEE2E2)
                      : const Color(0xFFDCFCE7);

                  final pillText = isCancelled
                      ? const Color(0xFFB91C1C)
                      : const Color(0xFF15803D);

                  return GestureDetector(
                    onLongPress: () {
                      setState(() => _isSelectionMode = true);
                      _toggleSelection(b.id);
                    },
                    onTap: () {
                      if (_isSelectionMode) {
                        _toggleSelection(b.id);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue.shade50 : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: isSelected
                            ? Border.all(color: Colors.blue, width: 2)
                            : null,
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                            color: Colors.black.withOpacity(0.06),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Column(
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
                                style:
                                    const TextStyle(color: Color(0xFF6B7280)),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                  'Dates: ${_fmt(b.checkIn)} - ${_fmt(b.checkOut)}'),
                              Text('Guests: ${b.guests}'),
                              Text('Total: \$${b.total.toStringAsFixed(0)}'),
                              const SizedBox(height: 10),
                              if (!isPending)
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
                              if (!_isSelectionMode) ...[
                                if (!isCancelled)
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () async {
                                        await context
                                            .read<BookingsProvider>()
                                            .cancelBooking(b.id);
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content:
                                                    Text('Booking cancelled ❌')),
                                          );
                                        }
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
                                        await context
                                            .read<BookingsProvider>()
                                            .confirmBooking(b.id);
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content:
                                                    Text('Booking confirmed ✅')),
                                          );
                                        }
                                      },
                                      child: const Text(
                                        'Confirm',
                                        style: TextStyle(
                                          color: Color(0xFF15803D),
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                              ]
                            ],
                          ),
                          if (isSelected)
                            const Positioned(
                              top: 0,
                              right: 0,
                              child:
                                  Icon(Icons.check_circle, color: Colors.blue),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}