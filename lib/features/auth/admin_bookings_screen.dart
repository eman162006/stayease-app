import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminBookingsScreen extends StatelessWidget {
  const AdminBookingsScreen({super.key});

  // Function to update booking status in Firestore
  Future<void> _updateStatus(BuildContext context, String id, String newStatus) async {
    try {
      await FirebaseFirestore.instance.collection('bookings').doc(id).update({
        'status': newStatus,
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Booking marked as $newStatus')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Confirmed':
        return Colors.green.shade100;
      case 'Cancelled':
        return Colors.red.shade100;
      default:
        return Colors.orange.shade100; // Pending
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status) {
      case 'Confirmed':
        return Colors.green.shade900;
      case 'Cancelled':
        return Colors.red.shade900;
      default:
        return Colors.orange.shade900;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("All Bookings")),
      backgroundColor: const Color(0xFFF8FAFC),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(child: Text("No bookings found"));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final id = docs[index].id;
              final status = data['status'] ?? 'Pending';

              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  title: Text(
                    data['hotelName'] ?? 'Unknown Property',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Guest: ${data['guestName'] ?? 'N/A'}"),
                      Text("Total: \$${data['price'] ?? 0}"),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(status),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(color: _getStatusTextColor(status), fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) => _updateStatus(context, id, value),
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'Confirmed', child: Text("Confirm")),
                      const PopupMenuItem(value: 'Cancelled', child: Text("Cancel")),
                      const PopupMenuItem(value: 'Pending', child: Text("Mark Pending")),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}