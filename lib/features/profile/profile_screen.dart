import 'package:flutter/material.dart';
import '../auth/login_screen.dart';
import '../booking/my_bookings_screen.dart';
// ignore: unused_import
import 'package:provider/provider.dart';
// ignore: unused_import
import '../../providers/auth_provider.dart';
import '../profile/edit_profile.dart';
import '../favorites/favorites_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

   return Scaffold(
  backgroundColor: const Color(0xFFF8FAFC),
  appBar: AppBar(
    title: const Text("Profile"),
  ),
  body: SafeArea(
    child: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // Header
        Column(
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                    color: Colors.black.withOpacity(0.08),
                  ),
                ],
              ),
              child: const Icon(Icons.person, size: 38),
            ),
            const SizedBox(height: 16),
            Text(
              user?.name ?? "User Name",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              user?.email ?? "user@email.com",
              style: const TextStyle(color: Color(0xFF6B7280)),
            ),
          ],
        ),

        const SizedBox(height: 28),

        // Menu Card
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                blurRadius: 12,
                offset: const Offset(0, 4),
                color: Colors.black.withOpacity(0.06),
              ),
            ],
          ),
          child: Column(
            children: [
              _ProfileTile(
                icon: Icons.calendar_month,
                title: "My Bookings",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MyBookingsScreen()),
                  );
                },
              ),
              const Divider(height: 1),
              _ProfileTile(
                icon: Icons.edit,
                title: "Edit Profile",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                  );
                },
              ),
              const Divider(height: 1),
              _ProfileTile(
                icon: Icons.favorite,
                title: "Favorites",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FavoritesScreen()),
                  );
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // Logout
        SizedBox(
          height: 52,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.logout),
            label: const Text("Logout"),
            onPressed: () async {
              await context.read<AuthProvider>().logout();
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFB91C1C),
              side: const BorderSide(color: Color(0xFFFCA5A5)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    ),
  ),
);
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF0E7490)),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Color(0xFF111827),
        ),
      ),
      trailing: const Icon(Icons.chevron_right, size: 20, color: Color(0xFF9CA3AF)),
      onTap: onTap,
    );
  }
}