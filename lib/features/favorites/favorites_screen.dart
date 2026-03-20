import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/favorities_provider.dart';
import '../../services/properties_service.dart';
import '../../models/property.dart';
import '../../widgets/property_card.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final fav = context.watch<FavoritesProvider>();
    final service = PropertiesService();

    return Scaffold(
      appBar: AppBar(title: const Text("Favorites")),
      body: StreamBuilder<List<Property>>(
        stream: service.watchProperties(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final all = snapshot.data ?? [];
          final favoriteList = all.where((p) => fav.isFavorite(p.id)).toList();

          if (favoriteList.isEmpty) {
            return const Center(child: Text("No favorites yet"));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: favoriteList.length,
            separatorBuilder: (_, __) => const SizedBox(height: 20),
            itemBuilder: (context, i) =>
                PropertyCard(property: favoriteList[i]),
          );
        },
      ),
    );
  }
}