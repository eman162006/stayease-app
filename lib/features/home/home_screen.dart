import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stayease/providers/favorities_provider.dart';
import '../details/details_screen.dart';
import '../../models/property.dart';
import '../../data/sample_properties.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchCtrl = TextEditingController();
  String _query = "";
  double _minPrice = 0;
  double _maxPrice = 500;
  String _sort = 'recommended'; // 'low' | 'high' | 'recommended'
 static const String kAll = "__ALL__";
String _selectedLocation = kAll;

late final List<String> allLocations;

@override
void initState() {
  super.initState();
  allLocations = sampleProperties
      .map((p) => p.location.trim())
      .toSet()
      .toList()
    ..sort();
}

void _openFilters() {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) {

      // ✅ LOCAL VARIABLES (هوني محلهم)
      String loc = _selectedLocation;
      double min = _minPrice;
      double max = _maxPrice;
      String sort = _sort;

      return StatefulBuilder(
        builder: (context, setSheet) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const Text("Location",
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),

                DropdownButtonFormField<String>(
                  value: loc,
                  isExpanded: true,
                  items: [
                    const DropdownMenuItem(
                        value: kAll, child: Text("All")),
                    ...allLocations.map(
                      (l) => DropdownMenuItem(
                        value: l,
                        child: Text(l),
                      ),
                    ),
                  ],
                  onChanged: (v) =>
                      setSheet(() => loc = v ?? kAll),
                ),

                const SizedBox(height: 18),

                const Text("Price per night",
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),

                Text("\$${min.toInt()} - \$${max.toInt()}"),

                RangeSlider(
                  values: RangeValues(min, max),
                  min: 0,
                  max: 500,
                  divisions: 50,
                  onChanged: (v) => setSheet(() {
                    min = v.start;
                    max = v.end;
                  }),
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setSheet(() {
                            loc = kAll;
                            min = 0;
                            max = 500;
                            sort = 'recommended';
                          });
                        },
                        child: const Text("Reset"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedLocation = loc;
                            _minPrice = min;
                            _maxPrice = max;
                            _sort = sort;
                          });
                          Navigator.pop(context);
                        },
                        child: const Text("Apply"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final locations = <String>{
  for (final p in sampleProperties) p.location.trim(),
}.toList()
  ..sort();

final queryText = _query.trim().toLowerCase();

final filtered = sampleProperties.where((p) {
  // ✅ price filter
  final price = p.pricePerNight.toDouble();
  if (price < _minPrice) return false;
  if (price > _maxPrice) return false;

  // location
  if (_selectedLocation != kAll &&
      p.location.trim().toLowerCase() != _selectedLocation.toLowerCase()) {
    return false;
  }

  // search
  final q = _query.trim().toLowerCase();
  if (q.isNotEmpty) {
    final match = p.title.toLowerCase().contains(q) ||
        p.location.toLowerCase().contains(q);
    if (!match) return false;
  }

  return true;
}).toList();

// 4) sort
if (_sort == 'low') {
  filtered.sort((a, b) => a.pricePerNight.compareTo(b.pricePerNight));
} else if (_sort == 'high') {
  filtered.sort((a, b) => b.pricePerNight.compareTo(a.pricePerNight));
}

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 12),

              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'StayEase',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                          color: Colors.black.withOpacity(0.06),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.person, size: 20),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ✅ Search bar (واحد فقط)
             // ✅ Search + Filter Row
Row(
  children: [
    Expanded(
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              offset: const Offset(0, 4),
              color: Colors.black.withOpacity(0.06),
            ),
          ],
        ),
        child: TextField(
          controller: _searchCtrl,
          onChanged: (value) {
            setState(() {
              _query = value.toLowerCase().trim();
            });
          },
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search, color: Color(0xFF6B7280)),
            hintText: 'Search destinations',
            hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            suffixIcon: _query.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFF6B7280)),
                    onPressed: () {
                      _searchCtrl.clear();
                      setState(() => _query = "");
                    },
                  ),
          ),
        ),
      ),
    ),
    const SizedBox(width: 12),

    // ✅ Filter button
    SizedBox(
      height: 52,
      width: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF111827),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
        ),
        onPressed: _openFilters,
        child: const Icon(Icons.tune),
      ),
    ),
  ],
),

const SizedBox(height: 12),

// ✅ نتيجة البحث
if (_query.isNotEmpty)
  Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      "${filtered.length} result(s)",
      style: const TextStyle(color: Color(0xFF6B7280)),
    ),
  ),

const SizedBox(height: 8),

// ✅ List
Expanded(
  child: filtered.isEmpty
      ? const Center(
          child: Text(
            "No results found",
            style: TextStyle(color: Color(0xFF6B7280)),
          ),
        )
      : ListView.separated(
          itemCount: filtered.length,
          separatorBuilder: (_, __) => const SizedBox(height: 20),
          itemBuilder: (context, index) {
            final p = filtered[index];
            return _PropertyCard(property: p);
          },
        ),
      ),
    ],
  ),
),
),
);
  }
}

class _PropertyCard extends StatelessWidget {
  final Property property;
  const _PropertyCard({required this.property});

  @override
  Widget build(BuildContext context) {
    final fav = context.watch<FavoritesProvider>();
    final isFav = fav.isFavorite(property.id);

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailsScreen(property: property),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
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
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Stack(
                children: [
                  Image.network(
                    property.imageUrl,
                    height: 170,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 170,
                      color: const Color(0xFFE5E7EB),
                      alignment: Alignment.center,
                      child: const Icon(Icons.image_not_supported),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: InkWell(
                      onTap: () => fav.toggleFavorite(property.id),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                              color: Colors.black.withOpacity(0.10),
                            ),
                          ],
                        ),
                        child: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          color: isFav
                              ? const Color(0xFF0E7490)
                              : const Color(0xFF111827),
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Text
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.title,
                    style: const TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 6),

                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 16, color: Color(0xFF9CA3AF)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          property.location,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13.5,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Text(
                        '\$${property.pricePerNight.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        '/ night',
                        style: TextStyle(
                          fontSize: 13.5,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}